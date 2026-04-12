require "rails_helper"

RSpec.describe CleanupUnverifiedUserJob, type: :job do
  describe "#perform" do
    context "when the user does not exist" do
      it "does nothing" do
        expect { described_class.new.perform(-1) }.not_to raise_error
      end
    end

    context "when the user is verified" do
      let!(:user) { create(:user) }

      it "does not destroy the user" do
        expect { described_class.new.perform(user.id) }
          .not_to change(User, :count)
      end
    end

    context "when the user is unverified" do
      let!(:user) { create(:user, :unverified) }

      it "destroys the user" do
        described_class.new.perform(user.id)
        expect(User.find_by(id: user.id)).to be_nil
      end

      it "decrements the user count by 1" do
        expect { described_class.new.perform(user.id) }
          .to change(User, :count).by(-1)
      end
    end
  end
end
