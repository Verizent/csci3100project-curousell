class FeedbackController < ApplicationController
  def create
    name    = params[:name].to_s.strip
    email   = params[:email].to_s.strip
    message = params[:message].to_s.strip

    if name.present? && email.present? && message.present?
      FeedbackMailer.contact(name: name, email: email, message: message).deliver_later
      redirect_to root_path, notice: "Thank you for your feedback!"
    else
      redirect_to root_path, alert: "Please fill in all feedback fields."
    end
  end
end
