FactoryBot.define do
  factory :order do
    association :listing
    buyer { create(:user) }
    seller { listing.user }
    status { "pending" }
    price_at_purchase { listing.price }
    purchased_at { Time.current }

    trait :completed do
      status { "completed" }
      buyer_confirmed_at { Time.current }
      seller_confirmed_at { Time.current }
      completed_at { Time.current }
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

    trait :old_pending do
      status { "pending" }
      purchased_at { 15.days.ago }
      created_at { 15.days.ago }
      updated_at { 15.days.ago }
    end

    trait :free_item do
      price_at_purchase { 0 }
    end
  end
end
