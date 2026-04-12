# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Seeding database..."

User.find_or_create_by!(email: "hiadmin@link.cuhk.edu.hk") do |u|
  u.name = "Admin"
  u.email = "hiadmin@link.cuhk.edu.hk"
  u.password = "adminpassword123"
  u.college = "United College"
  u.faculty = [ "Engineering" ]
  u.department = [ "Computer Science and Engineering" ]
  u.verified_at = Time.current
end

puts "Seeding done. Users: #{User.count}"
