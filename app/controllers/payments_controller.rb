class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :webhook
  before_action :require_login, only: [ :checkout, :success, :cancel ]

  def checkout
    @product = Product.available.find(params[:product_id])

    order = Order.create!(
      buyer: current_user,
      product: @product,
      amount_cents: @product.price_cents,
      currency: @product.currency,
      status: "pending"
    )

    session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      line_items: [ {
        price_data: {
          currency: @product.currency,
          product_data: {
            name: @product.title,
            description: @product.description.presence || "Item from CurouSell"
          },
          unit_amount: @product.price_cents
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
  end

  def success
    @order = current_user.buyer_orders.find(params[:order_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to home_path, alert: "Order not found." and return
  end

  def cancel
    @order = current_user.buyer_orders.find(params[:order_id])
    @order.update!(status: "cancelled") if @order.status == "pending"
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
