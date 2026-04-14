require "rails_helper"

RSpec.describe "Feedback", type: :request do
  describe "POST /feedback" do
    it "queues feedback email and redirects back with notice" do
      mail_delivery = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      expect(FeedbackMailer).to receive(:feedback_email)
        .with("Alice", "alice@example.com", "Great app")
        .and_return(mail_delivery)

      post feedback_index_path,
           params: { name: "Alice", email: "alice@example.com", message: "Great app" },
           headers: { "HTTP_REFERER" => home_path }

      expect(response).to redirect_to(home_path)
      follow_redirect!
      expect(response.body).to include("Thanks for your feedback!")
    end

    it "rejects blank required fields" do
      expect(FeedbackMailer).not_to receive(:feedback_email)

      post feedback_index_path,
           params: { name: "Alice", email: "", message: "" },
           headers: { "HTTP_REFERER" => home_path }

      expect(response).to redirect_to(home_path)
      follow_redirect!
      expect(response.body).to include("Please fill in all fields.")
    end
  end
end
