require "factory_bot_rails"

# ── Shared helpers ────────────────────────────────────────────────────────────

# Fill in the standard signup form fields (college, faculty, department are
# set to safe defaults so callers only need to override what they care about).
def fill_signup_form(name: "Test User",
                     email: "testuser@link.cuhk.edu.hk",
                     password: "SecurePassword123!",
                     password_confirmation: nil)
  password_confirmation ||= password

  fill_in "Full Name",        with: name
  fill_in "Email Address",    with: email
  select  "Shaw College",     from: "user_college"
  select  "Faculty of Engineering",
          from: "user_faculty"
  select  "Department of Computer Science and Engineering",
          from: "user_department"
  fill_in "Password",         with: password
  fill_in "Confirm Password", with: password_confirmation
end

# Sign in through the UI and complete 2FA using the OTP stored on the user.
# Returns after being redirected to root.
def ui_sign_in(email, password)
  visit account_signin_path
  fill_in "Email Address", with: email
  fill_in "Password",      with: password
  click_button "Sign In"

  # Complete 2FA
  user = User.find_by!(email: email)
  otp  = user.reload.otp_code
  fill_in "Verification Code", with: otp
  click_button "Verify Email"
end

# ── Given ─────────────────────────────────────────────────────────────────────

Given "I visit the signup page" do
  visit account_signup_path
end

Given "I visit the signin page" do
  visit account_signin_path
end

Given "a verified user exists with email {string} and password {string}" do |email, password|
  @registered_user = create(:user, email: email, password: password,
                                   password_confirmation: password)
end

Given "a verified user exists with email {string} and password {string} and college {string}" do |email, password, college|
  @registered_user = create(:user, email: email, password: password,
                                   password_confirmation: password,
                                   college: college)
end

Given "an unverified user exists with email {string} and password {string}" do |email, password|
  create(:user, :unverified, email: email, password: password,
                             password_confirmation: password)
end

Given "I have completed the signup form successfully" do
  # Prevent actual email delivery and background jobs
  allow(OtpMailer).to receive(:send_code).and_return(double(deliver_later: true))
  allow(CleanupUnverifiedUserJob).to receive_message_chain(:set, :perform_later)

  visit account_signup_path
  fill_signup_form
  check "terms_accepted"
  click_button "Create Account"
  # We should now be on the verify page
  expect(page).to have_content("Verify Your Email")
end

Given "I am signed in as {string} with password {string}" do |email, password|
  # Stub OTP mailer so we don't need real SMTP
  allow(OtpMailer).to receive(:send_2fa).and_return(double(deliver_later: true))
  ui_sign_in(email, password)
end

Given "I am signed in as a Shaw College user" do
  allow(OtpMailer).to receive(:send_2fa).and_return(double(deliver_later: true))
  shaw_user = create(:user,
    college: "Shaw College",
    faculty: [ "Faculty of Engineering" ],
    department: [ "Department of Computer Science and Engineering" ])
  ui_sign_in(shaw_user.email, "SecurePassword123!")
end

# ── When ──────────────────────────────────────────────────────────────────────

When "I fill in the signup form with valid CUHK credentials" do
  fill_signup_form
end

When "I fill in the signup form with email {string}" do |email|
  fill_signup_form(email: email)
end

When "I fill in the signup form with password {string}" do |password|
  fill_signup_form(password: password, password_confirmation: password)
end

When "I check the terms and conditions checkbox" do
  check "terms_accepted"
end

When "I do not check the terms and conditions checkbox" do
  # Intentionally do not check the box
end

When "I submit the signup form" do
  click_button "Create Account"
end

When "I sign in with email {string} and password {string}" do |email, password|
  fill_in "Email Address", with: email
  fill_in "Password",      with: password
  click_button "Sign In"
end

When "I enter the OTP code sent to my email" do
  # The OTP was stored on the most-recently-created unverified user
  user = User.order(:created_at).last
  fill_in "Verification Code", with: user.otp_code
end

When "I enter the 2FA OTP code" do
  user = User.order(:created_at).last
  fill_in "Verification Code", with: user.reload.otp_code
end

When "I enter an incorrect OTP code {string}" do |code|
  fill_in "Verification Code", with: code
end

When "I enter an incorrect OTP code {string} {int} times" do |code, times|
  times.times do
    fill_in "Verification Code", with: code
    click_button "Verify Email"
  end
end

When "I submit the 2FA form with code {string}" do |code|
  fill_in "Verification Code", with: code
  click_button "Verify Email"
end

When "I sign out" do
  # The signout link/button uses DELETE method (Rails UJS / Turbo)
  # rack_test can simulate this via a direct delete request helper
  page.driver.submit :delete, account_signout_path, {}
end

When "I click {string}" do |label|
  click_button label
end

# ── Then ──────────────────────────────────────────────────────────────────────

Then "I should be on the verify email page" do
  expect(page).to have_content("Verify Your Email")
end

Then "I should still be on the verify email page" do
  expect(page).to have_content("Verify Your Email")
end

Then "I should be on the signin page" do
  expect(page).to have_content("Sign In")
end

Then "I should be on the 2FA verification page" do
  expect(page).to have_content("Verify Your Email")
  expect(current_path).to eq(signin_2fa_path)
end

Then "I should still be on the 2FA verification page" do
  expect(page).to have_content("Verify Your Email")
  expect(current_path).to eq(signin_2fa_path)
end

Then "I should be on the signup page" do
  expect(page).to have_content("Register")
end

Then "I should be redirected to the home page" do
  expect(current_path).to eq(home_path)
end

Then "the {string} button should be disabled" do |label|
  btn = find_button(label, disabled: :all)
  expect(btn[:disabled]).to be_truthy
end

Then "I should see {string}" do |text|
  expect(page).to have_content(text)
end

Then "I should not see {string}" do |text|
  expect(page).not_to have_content(text)
end
