When("I visit the profile page") do
  visit profile_path
end

Then("I should be on the profile page") do
  expect(current_path).to eq(profile_path)
end
