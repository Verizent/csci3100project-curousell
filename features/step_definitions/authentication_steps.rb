Given("a verified user exists with email {string} and password {string}") do |email, password|
  @user = User.create!(
    name: "Test Student",
    email: email,
    college: "Shaw College",
    faculty: [ "Faculty of Engineering" ],
    department: [ "Department of Computer Science and Engineering" ],
    password: password,
    password_confirmation: password,
    verified_at: Time.current
  )
end

Given("an unverified user exists with email {string} and password {string}") do |email, password|
  User.create!(
    name: "Unverified Student",
    email: email,
    college: "Shaw College",
    faculty: [ "Faculty of Engineering" ],
    department: [ "Department of Computer Science and Engineering" ],
    password: password,
    password_confirmation: password
  )
end

Given("I am on the sign in page") do
  visit account_signin_path
end

Given("I am on the sign up page") do
  visit account_signup_path
end

When("I fill in the signup form with valid details") do
  fill_in "Full Name", with: "Test Student"
  fill_in "Email Address", with: "newstudent@cuhk.edu.hk"
  select "Shaw College", from: "College"
  select "Faculty of Engineering", from: "user[faculty][]"
  select "Department of Computer Science and Engineering", from: "user[department][]"
  fill_in "Password", with: "securepassword123"
  fill_in "Confirm Password", with: "securepassword123"
end

When("I fill in the signup form with email {string}") do |email|
  fill_in "Full Name", with: "Test Student"
  fill_in "Email Address", with: email
  select "Shaw College", from: "College"
  select "Faculty of Engineering", from: "user[faculty][]"
  select "Department of Computer Science and Engineering", from: "user[department][]"
  fill_in "Password", with: "securepassword123"
  fill_in "Confirm Password", with: "securepassword123"
end

When("I accept the Terms & Conditions") do
  check "terms_accepted"
end

Then("I should be on the verify page") do
  expect(current_path).to eq(signup_verify_path)
end

Then("I should be on the sign up page") do
  expect(current_path).to eq(account_signup_path)
end

When("I submit the signup OTP") do
  user = User.find_by(email: "newstudent@cuhk.edu.hk")
  fill_in "otp_code", with: user.otp_code
  click_button "Verify Email"
end

When("I submit an incorrect OTP {string}") do |code|
  user = User.find_by(email: "newstudent@cuhk.edu.hk")
  user.update!(otp_code: code != "111111" ? "111111" : "010101")                      # ensure that otp_code is wrong
  fill_in "otp_code", with: code
  click_button "Verify Email"
end

When("I submit an incorrect OTP {string} {int} times") do |code, times|
  user = User.find_by(email: "newstudent@cuhk.edu.hk")
  user.update!(otp_code: code != "111111" ? "111111" : "010101")
  times.times do
    fill_in "otp_code", with: code
    click_button "Verify Email"
  end
end

When("I fill in {string} with {string}") do |field, value|
  fill_in field, with: value
end

When("I click {string}") do |button|
  find_button(button, disabled: :all).click                                           # allow pressing disabled button (because capybara's rack_test driver doesn't run JavaScript)
end

Then("I should be on the 2FA page") do
  expect(current_path).to eq(signin_2fa_path)
end

Then("I should be on the sign in page") do
  expect(current_path).to eq(account_signin_path)
end

Then("I should be redirected to the home page") do
  expect(current_path).to eq(home_path)
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

When("I submit the correct OTP") do
  @user.reload
  fill_in "otp_code", with: @user.otp_code
  click_button "Verify Email"
end

When("the OTP has expired") do
  @user.update!(otp_sent_at: (User::OTP_EXPIRY_MINUTES + 1).minutes.ago)
end
