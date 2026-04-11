class FeedbackMailer < ApplicationMailer
  TEAM_INBOX = "curousell.team@gmail.com"

  def feedback_email(name, sender_email, message)
    @name         = name
    @sender_email = sender_email
    @message      = message

    safe_name = name.to_s.gsub(/[\r\n]+/, " ").strip
    mail(
      to:       TEAM_INBOX,
      reply_to: sender_email,
      subject:  "[CUrousell Feedback] from #{safe_name.presence || sender_email}"
    )
  end
end
