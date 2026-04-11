class FeedbackController < ApplicationController
  rate_limit to: 5, within: 1.hour, by: -> { request.remote_ip },
             with: -> { redirect_back fallback_location: root_path, alert: "Too many feedback submissions. Please try again later." }

  def create
    name    = params[:name].to_s.strip
    email   = params[:email].to_s.strip
    message = params[:message].to_s.strip

    if email.blank? || message.blank?
      redirect_back fallback_location: root_path, alert: "Please fill in all fields."
      return
    end

    FeedbackMailer.feedback_email(name, email, message).deliver_later
    redirect_back fallback_location: root_path, notice: "Thanks for your feedback!"
  end
end
