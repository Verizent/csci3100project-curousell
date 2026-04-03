class FeedbackMailer < ApplicationMailer
  def contact(name:, email:, message:)
    @name    = name
    @email   = email
    @message = message
    mail(
      to:       "curousell@gmail.com",
      reply_to: email,
      subject:  "CUrousell Feedback from #{name}"
    )
  end
end
