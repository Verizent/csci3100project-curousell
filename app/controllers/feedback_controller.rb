class FeedbackController < ApplicationController
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
