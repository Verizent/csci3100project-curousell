FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@link.cuhk.edu.hk" }
    name                  { "Test User" }
    password              { "SecurePassword123!" }
    password_confirmation { "SecurePassword123!" }
    college               { "Shaw College" }
    faculty               { [ "Faculty of Engineering" ] }
    department            { [ "Department of Computer Science and Engineering" ] }
    verified_at           { Time.current }

    trait :unverified do
      verified_at { nil }
    end

    trait :with_otp do
      otp_code     { "123456" }
      otp_sent_at  { Time.current }
      otp_attempts { 0 }
    end

    trait :max_otp_attempts do
      otp_code     { "123456" }
      otp_sent_at  { Time.current }
      otp_attempts { User::MAX_OTP_ATTEMPTS }
    end
  end
end
