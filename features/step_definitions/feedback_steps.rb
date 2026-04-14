When("I submit feedback with name {string}, email {string}, and message {string}") do |name, email, message|
  fill_in "Your Name", with: name
  fill_in "Your Email", with: email
  fill_in "Message", with: message
  click_button "Send Feedback"
end
