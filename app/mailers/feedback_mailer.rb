class FeedbackMailer < ApplicationMailer
  TEAM_INBOX = "curousell.team@gmail.com"

  def feedback_email(sender_email, message)
    @sender_email = sender_email
    @message      = message

    mail(
      to:       TEAM_INBOX,
      reply_to: sender_email,
      subject:  "[CUrousell Feedback] from #{sender_email}"
    )
  end
end
