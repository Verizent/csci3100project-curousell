require "test_helper"

class UserTest < ActiveSupport::TestCase
  def valid_attributes
    {
      name: "Mike",
      email: "migel@cuhk.edu.hk",
      college: "C. W. Chu College",
      faculty: [ "Faculty of Engineering" ],
      department: [ "Department of Computer Science and Engineering" ],
      password: "securepassword123",
      password_confirmation: "securepassword123"
    }
  end

  # Validations
  test "valid with all required attributes" do
    assert User.new(valid_attributes).valid?
  end

  test "invalid without name" do
    user = User.new(valid_attributes.merge(name: nil))
    assert user.invalid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "invalid without email" do
    user = User.new(valid_attributes.merge(email: nil))
    assert user.invalid?
  end

  test "invalid with non-CUHK email" do
    user = User.new(valid_attributes.merge(email: "user@gmail.com"))
    assert user.invalid?
    assert_includes user.errors[:email], "must be a CUHK email address"
  end

  test "valid with link.cuhk.edu.hk subdomain email" do
    assert User.new(valid_attributes.merge(email: "user@link.cuhk.edu.hk")).valid?
  end

  test "invalid with duplicate email" do
    User.create!(valid_attributes)
    user2 = User.new(valid_attributes)
    assert user2.invalid?
    assert_includes user2.errors[:email], "has already been taken"
  end

  test "invalid without college" do
    user = User.new(valid_attributes.merge(college: nil))
    assert user.invalid?
  end

  test "invalid without faculty" do
    user = User.new(valid_attributes.merge(faculty: nil))
    assert user.invalid?
  end

  test "invalid without department" do
    user = User.new(valid_attributes.merge(department: nil))
    assert user.invalid?
  end

  test "invalid with difference between password and password confirmation" do
    user = User.new(valid_attributes.merge(password: "securepassword135"))
    assert user.invalid?
    assert_includes user.errors[:password_confirmation], "doesn't match Password"
  end

  test "invalid with password shorter than 12 characters" do
    user = User.new(valid_attributes.merge(password: "short", password_confirmation: "short"))
    assert user.invalid?
    assert_includes user.errors[:password], "is too short (minimum is 12 characters)"
  end

  test "valid without password when updating other fields" do
    user = User.create!(valid_attributes)
    user.name = "New Name"
    assert user.valid?
  end

  # generate_otp!
  test "generate_otp! returns a 6-digit string" do
    user = User.create!(valid_attributes)
    code = user.generate_otp!
    assert_match(/\A\d{6}\z/, code)
  end

  test "generate_otp! updates otp fields on user" do
    user = User.create!(valid_attributes)
    user.generate_otp!
    user.reload
    assert_not_nil user.otp_code
    assert_not_nil user.otp_sent_at
    assert_equal 0, user.otp_attempts
  end

  # otp_valid?
  test "otp_valid? returns true for correct code within expiry" do
    user = User.create!(valid_attributes)
    code = user.generate_otp!
    assert user.otp_valid?(code)
  end

  test "otp_valid? returns false for wrong code" do
    user = User.create!(valid_attributes)
    code = user.generate_otp!
    wrong_code = code == "000000" ? "000001" : "000000"
    assert_not user.otp_valid?(wrong_code)
  end

  test "otp_valid? returns false for expired code" do
    user = User.create!(valid_attributes)
    code = user.generate_otp!
    user.update!(otp_sent_at: 11.minutes.ago)
    assert_not user.otp_valid?(code)
  end

  test "otp_valid? returns false when otp_code is blank" do
    user = User.new(valid_attributes)
    assert_not user.otp_valid?("123456")
  end

  # verified?
  test "verified? returns true when verified_at is present" do
    assert User.new(valid_attributes.merge(verified_at: Time.current)).verified?
  end

  test "verified? returns false when verified_at is nil" do
    assert_not User.new(valid_attributes).verified?
  end
end
