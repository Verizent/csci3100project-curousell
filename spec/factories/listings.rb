FactoryBot.define do
  factory :listing do
    sequence(:title) { |n| "Test Listing #{n}" }
    description      { "A test item available for sale." }
    price            { 50.00 }
    category         { "tech" }
    status           { "unsold" }
    association      :user

    trait :free do
      price { 0 }
    end

    trait :sold do
      status { "sold" }
    end

    trait :books do
      category { "books" }
    end

    trait :furniture do
      category { "furniture" }
    end
  end
end
