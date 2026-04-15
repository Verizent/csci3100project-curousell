class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :webhook
  before_action :require_login, only: [ :checkout, :claim, :resume, :success, :cancel ]

  def checkout
    @listing = Listing.available.find(params[:listing_id])

    if @listing.user == current_user
      redirect_to listing_path(@listing), alert: "You cannot buy your own listing." and return
    end

    order = Order.create!(
      buyer: current_user,
      listing: @listing,
      amount_cents: @listing.price_cents,
      currency: @listing.currency,
      status: "pending"
    )

    @listing.update!(status: "in_process")

    session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      line_items: [ {
        price_data: {
          currency: @listing.currency,
          product_data: {
            name: @listing.title,
            description: @listing.description.presence || "Item from CUrousell"
          },
          unit_amount: @listing.price_cents
        },
        quantity: 1
      } ],
      mode: "payment",
      success_url: payment_success_url(order_id: order.id),
      cancel_url: payment_cancel_url(order_id: order.id),
      metadata: { order_id: order.id }
    )

    order.update!(stripe_checkout_session_id: session.id)
    redirect_to session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    order&.update!(status: "failed")
    @listing.update!(status: "unsold")
    redirect_to listing_path(@listing), alert: "Payment could not be initiated: #{e.message}"
  end

  def claim
    @listing = Listing.available.find(params[:listing_id])

    if @listing.user == current_user
      redirect_to listing_path(@listing), alert: "You cannot claim your own listing." and return
    end

    unless @listing.price_cents == 0
      redirect_to listing_path(@listing), alert: "This listing is not free." and return
    end

    order = Order.create!(
      buyer: current_user,
      listing: @listing,
      amount_cents: 0,
      currency: @listing.currency,
      status: "paid"
    )

    @listing.update!(status: "in_process")
    AutoCancelOrderJob.set(wait: 2.weeks).perform_later(order.id)

    redirect_to order_path(order), notice: "You claimed this item! Arrange with the seller to complete handover."
  rescue ActiveRecord::RecordNotFound
    redirect_to home_path, alert: "Listing not found."
  end

  def resume
    @order = current_user.buyer_orders.find(params[:order_id])

    unless @order.status == "pending"
      redirect_to order_path(@order), alert: "This order is no longer awaiting payment." and return
    end

    # Try to reuse existing Stripe session if still open
    if @order.stripe_checkout_session_id.present?
      stripe_session = Stripe::Checkout::Session.retrieve(@order.stripe_checkout_session_id)
      if stripe_session.status == "open"
        redirect_to stripe_session.url, allow_other_host: true and return
      end
    end

    # Create a fresh Stripe session for the same order
    listing = @order.listing
    session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      line_items: [ {
        price_data: {
          currency: @order.currency,
          product_data: {
            name: listing.title,
            description: listing.description.presence || "Item from CUrousell"
          },
          unit_amount: @order.amount_cents
        },
        quantity: 1
      } ],
      mode: "payment",
      success_url: payment_success_url(order_id: @order.id),
      cancel_url: payment_cancel_url(order_id: @order.id),
      metadata: { order_id: @order.id }
    )

    @order.update!(stripe_checkout_session_id: session.id)
    redirect_to session.url, allow_other_host: true
  rescue ActiveRecord::RecordNotFound
    redirect_to orders_path, alert: "Order not found."
  rescue Stripe::StripeError => e
    redirect_to order_path(@order), alert: "Could not resume payment: #{e.message}"
  end

  def success
    @order = current_user.buyer_orders.find(params[:order_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to home_path, alert: "Order not found." and return
  end

  def cancel
    @order = current_user.buyer_orders.find(params[:order_id])
    if @order.status == "pending"
      @order.update!(status: "cancelled")
      @order.listing.update!(status: "unsold")
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to home_path, alert: "Order not found." and return
  end

  def webhook
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, Rails.application.config.stripe.webhook_secret
      )
    rescue JSON::ParserError
      head :bad_request and return
    rescue Stripe::SignatureVerificationError
      head :bad_request and return
    end

    case event.type
    when "checkout.session.completed"
      handle_checkout_completed(event.data.object)
    when "payment_intent.payment_failed"
      handle_payment_failed(event.data.object)
    end

    head :ok
  end

  private

  def handle_checkout_completed(checkout_session)
    order = Order.find_by(stripe_checkout_session_id: checkout_session.id)
    return unless order

    order.mark_paid!(payment_intent_id: checkout_session.payment_intent)
  end

  def handle_payment_failed(payment_intent)
    order = Order.find_by(stripe_payment_intent_id: payment_intent.id)
    return unless order

    order.mark_failed!
  end
end
