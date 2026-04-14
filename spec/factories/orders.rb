FactoryBot.define do
  factory :order do
    association :listing
    buyer { create(:user) }
    amount_cents { (listing.price * 100).round }
    currency { "hkd" }
    status { "pending" }

    trait :paid do
      status { "paid" }
      stripe_payment_intent_id { "pi_test_#{SecureRandom.hex(8)}" }
      stripe_checkout_session_id { "cs_test_#{SecureRandom.hex(8)}" }
    end

    trait :completed do
      status { "completed" }
      buyer_confirmed_at { Time.current }
      seller_confirmed_at { Time.current }
    end

    trait :cancelled do
      status { "cancelled" }
    end

    trait :refunded do
      status { "refunded" }
    end

    trait :seller_confirmed do
      seller_confirmed_at { Time.current }
    end

    trait :buyer_confirmed do
      buyer_confirmed_at { Time.current }
    end
  end
end
