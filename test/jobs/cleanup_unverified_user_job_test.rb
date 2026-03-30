require "test_helper"

class CleanupUnverifiedUserJobTest < ActiveJob::TestCase
  def valid_attributes
    {
      name: "Mike",
      email: "jobtest@link.cuhk.edu.hk",
      college: "C. W. Chu College",
      faculty: [ "Faculty of Engineering" ],
      department: [ "Department of Computer Science and Engineering" ],
      password: "securepassword123",
      password_confirmation: "securepassword123"
    }
  end

  test "destroys unverified user" do
    user = User.create!(valid_attributes)
    assert_difference "User.count", -1 do
      CleanupUnverifiedUserJob.perform_now(user.id)
    end
  end

  test "does not destroy verified user" do
    user = User.create!(valid_attributes.merge(verified_at: Time.current))
    assert_no_difference "User.count" do
      CleanupUnverifiedUserJob.perform_now(user.id)
    end
  end

  test "does nothing when user does not exist" do
    assert_no_difference "User.count" do
      CleanupUnverifiedUserJob.perform_now(-1)
    end
  end
end
