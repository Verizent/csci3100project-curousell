FactoryBot.define do
  factory :listing_access_rule do
    association :listing
    colleges    { [ "Shaw College" ] }
    faculties   { [ "Faculty of Engineering" ] }
    departments { [ "Department of Computer Science and Engineering" ] }

    trait :college_only do
      faculties   { [] }
      departments { [] }
    end

    trait :open_within_college do
      # Matches any faculty/department within the specified college
      faculties   { [] }
      departments { [] }
    end
  end
end
