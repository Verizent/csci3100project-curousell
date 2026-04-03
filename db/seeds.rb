# Seed data for CUrousell — 50 sample listings across all categories
# Run with: bin/rails db:seed

puts "Seeding users..."

COLLEGES = [
  "Shaw College", "United College", "New Asia College", "Chung Chi College",
  "Morningside College", "CW Chu College", "S.H. Ho College",
  "Yat-sen College", "Wu Yee Sun College"
].freeze

seed_users = [
  { name: "Chan Tai Man",    email: "taiman.chan@cuhk.edu.hk",  college: "Shaw College" },
  { name: "Wong Siu Ling",   email: "siuling.wong@cuhk.edu.hk", college: "New Asia College" },
  { name: "Lee Ka Wai",      email: "kawai.lee@cuhk.edu.hk",    college: "Chung Chi College" },
  { name: "Lam Ho Yin",      email: "hoyin.lam@cuhk.edu.hk",    college: "United College" },
  { name: "Ng Mei Yee",      email: "meiyee.ng@cuhk.edu.hk",    college: "Morningside College" },
].freeze

users = seed_users.map do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |u|
    u.name             = attrs[:name]
    u.college          = attrs[:college]
    u.faculty          = [ "Engineering" ]
    u.department       = [ "Computer Science" ]
    u.password         = "SeedPassword123!"
    u.verified_at      = Time.current
  end
end

puts "Created #{users.size} seed users."

puts "Seeding listings..."

listings_data = [
  # Furniture
  { title: "IKEA KALLAX Shelf Unit (White, 4x2)",  category: "furniture",   price: 350,  location: "Shaw College",       status: "unsold",     college: nil,                  description: "Good condition IKEA KALLAX 4x2 shelf. Some minor scratches on the top. Dimensions: 147x147 cm. Self-pickup only." },
  { title: "Study Desk with Drawer",               category: "furniture",   price: 280,  location: "New Asia College",   status: "unsold",     college: "New Asia College",   description: "Solid wood study desk, 120x60 cm, one drawer. Very sturdy and clean. Perfect for a dorm room." },
  { title: "Office Chair (Ergonomic)",             category: "furniture",   price: 450,  location: "United College",     status: "in_process", college: nil,                  description: "Ergonomic office chair with lumbar support and adjustable armrests. 3 years old but still in great shape." },
  { title: "Foldable Single Bed Frame",            category: "furniture",   price: 200,  location: "Chung Chi College",  status: "unsold",     college: "Chung Chi College",  description: "Metal foldable bed frame, fits standard single mattress. Easy to disassemble." },
  { title: "Bedside Table with Lamp",              category: "furniture",   price: 120,  location: "CW Chu College",     status: "unsold",     college: nil,                  description: "White bedside table with one drawer and a desk lamp (bulb included). Both items sold together." },
  { title: "Bookshelf (5 tiers)",                  category: "furniture",   price: 180,  location: "Morningside College", status: "sold",      college: nil,                  description: "Five-tier bookshelf, approx. 180cm tall. Some paint chips on the edges. Great for organising textbooks." },
  { title: "Bean Bag Chair (Dark Blue)",           category: "furniture",   price: 90,   location: "S.H. Ho College",    status: "unsold",     college: nil,                  description: "Large bean bag, dark blue cover. Still comfortable and clean. Buyer picks up." },
  { title: "Wooden Coffee Table",                  category: "furniture",   price: 250,  location: "Yat-sen College",    status: "unsold",     college: nil,                  description: "Low wooden coffee table, 100x50 cm. Light walnut finish. One small scratch on the surface." },
  { title: "Clothes Rack (Metal, Adjustable)",     category: "furniture",   price: 65,   location: "Wu Yee Sun College", status: "unsold",     college: nil,                  description: "Adjustable metal clothes rack, height up to 170 cm. Holds up to 30 kg." },
  { title: "Mini Fridge (20L, White)",             category: "furniture",   price: 320,  location: "Shaw College",       status: "in_process", college: "Shaw College",       description: "20-litre compact fridge, perfect for dorm rooms. Works perfectly. Barely used." },

  # Tech
  { title: "MacBook Air M1 (8GB/256GB, Space Grey)", category: "tech",      price: 4800, location: "Science Building",   status: "unsold",     college: nil,                  description: "MacBook Air M1, purchased 2021. Battery cycle count: 210. Comes with original charger and box. Minor cosmetic scratches." },
  { title: "iPad (9th Gen, 64GB, Wi-Fi)",           category: "tech",       price: 1500, location: "United College",     status: "unsold",     college: nil,                  description: "iPad 9th generation with Apple Pencil 1st gen. Used for one year. Includes Smart Cover." },
  { title: "Mechanical Keyboard (TKL, Blue Switches)", category: "tech",    price: 380,  location: "Library",            status: "unsold",     college: nil,                  description: "Tenkeyless mechanical keyboard, Cherry MX Blue switches. Clicky and tactile. Used 1.5 years." },
  { title: "Sony WH-1000XM4 Headphones",           category: "tech",        price: 1200, location: "New Asia College",   status: "sold",       college: nil,                  description: "Sony noise-cancelling headphones. Excellent condition, all accessories included." },
  { title: "Dell 24 inch Monitor (1080p, 60Hz)",   category: "tech",        price: 700,  location: "Chung Chi College",  status: "unsold",     college: "Chung Chi College",  description: "Dell S2421H 24-inch IPS monitor. HDMI and audio out. Great for studying or gaming." },
  { title: "Logitech MX Master 3 Mouse",           category: "tech",        price: 350,  location: "Shaw College",       status: "unsold",     college: nil,                  description: "MX Master 3 wireless mouse with USB-C charging. Barely used. All packaging included." },
  { title: "External Hard Drive 1TB (USB 3.0)",    category: "tech",        price: 220,  location: "Engineering Building", status: "unsold",   college: nil,                  description: "Seagate 1TB portable hard drive. Works fine. Great for storing photos and documents." },
  { title: "Nintendo Switch Lite (Yellow)",        category: "tech",        price: 900,  location: "Morningside College", status: "in_process", college: nil,                 description: "Switch Lite in yellow. Comes with Animal Crossing and Pokémon Sword. Charger included." },
  { title: "HP LaserJet Printer (Black & White)",  category: "tech",        price: 480,  location: "United College",     status: "unsold",     college: "United College",     description: "HP LaserJet Pro M15w wireless laser printer. Rarely used. Works perfectly." },
  { title: "Ring Light (10 inch) with Tripod",     category: "tech",        price: 150,  location: "CW Chu College",     status: "unsold",     college: nil,                  description: "10-inch ring light with adjustable colour temperature, comes with phone holder and tripod stand." },

  # Books
  { title: "COMP2711 Discrete Math Textbook",      category: "books",       price: 80,   location: "Science Library",    status: "unsold",     college: nil,                  description: "Discrete Mathematics and Its Applications, 8th Ed. by Rosen. Some highlighting in chapters 1-3." },
  { title: "Organic Chemistry (Clayden, 2nd Ed)",  category: "books",       price: 120,  location: "Science Building",   status: "unsold",     college: nil,                  description: "Clayden Organic Chemistry 2nd edition. Very clean copy, no markings. Highly recommended." },
  { title: "FINA1310 Corporate Finance Notes",     category: "books",       price: 45,   location: "Business School",    status: "sold",       college: nil,                  description: "Complete set of handwritten FINA1310 notes + past papers 2020-2023. Very helpful." },
  { title: "Linear Algebra Done Right (Axler)",    category: "books",       price: 60,   location: "Mathematics Building", status: "unsold",   college: nil,                  description: "Axler's Linear Algebra Done Right, 3rd edition. Some notes in the margin, generally clean." },
  { title: "HSS bundle: UGFH, UGFN, UGEA",         category: "books",       price: 100,  location: "Lee Woo Sing College", status: "unsold",   college: nil,                  description: "Bundle of 3 CUHK GE textbooks. UGFH1000, UGFN1000, UGEA2160. Selling together only." },
  { title: "Introduction to Algorithms (CLRS)",    category: "books",       price: 150,  location: "Engineering Building", status: "unsold",   college: nil,                  description: "Cormen et al, Introduction to Algorithms 3rd edition. Good condition, no markings." },
  { title: "ECON1010 & ECON1020 Textbooks",        category: "books",       price: 90,   location: "Social Science Building", status: "unsold", college: nil,                 description: "Principles of Micro and Macroeconomics (Mankiw). Selling as a pair. Some highlights." },
  { title: "CHEM1070 Lab Manual",                  category: "books",       price: 30,   location: "Chemistry Building",  status: "unsold",    college: nil,                  description: "General Chemistry Lab manual for CHEM1070. Completed, so some sections are filled in." },
  { title: "Harry Potter Complete Box Set",        category: "books",       price: 180,  location: "Shaw College",        status: "unsold",    college: nil,                  description: "All 7 Harry Potter books in paperback. Great condition, minimal wear." },
  { title: "The Pragmatic Programmer (20th Ann.)", category: "books",       price: 85,   location: "Engineering Building", status: "unsold",   college: nil,                  description: "The Pragmatic Programmer anniversary edition. Barely read. Great for CS students." },

  # Accessories
  { title: "Fjällräven Kånken Backpack (Navy)",    category: "accessories", price: 380,  location: "New Asia College",   status: "unsold",     college: nil,                  description: "Fjällräven Kånken classic backpack in navy. Used for one semester. No damage." },
  { title: "AirPods Pro (1st Gen) with Case",      category: "accessories", price: 650,  location: "Shaw College",       status: "in_process", college: nil,                  description: "AirPods Pro 1st gen. Active Noise Cancellation works great. Battery health ~88%." },
  { title: "Casio G-Shock Watch (GA-2100)",        category: "accessories", price: 430,  location: "United College",     status: "unsold",     college: nil,                  description: "Casio G-Shock GA-2100 in black. One year old, excellent condition. Original box included." },
  { title: "MUJI A5 Notebook Bundle (6 pcs)",      category: "accessories", price: 40,   location: "Y.C. Liang Hall",    status: "unsold",     college: nil,                  description: "Six brand new MUJI dotted notebooks. Never opened. Selling because I bought too many." },
  { title: "Reusable Water Bottle (1L, Stainless)", category: "accessories", price: 55,  location: "Sports Complex",     status: "unsold",     college: nil,                  description: "1-litre double-walled stainless steel water bottle. Keeps drinks cold for 24h. Minor dents." },
  { title: "Laptop Sleeve 13 inch (Dark Green)",   category: "accessories", price: 45,   location: "Library",            status: "unsold",     college: nil,                  description: "Neoprene laptop sleeve for 13-inch laptops. Fits MacBook Air/Pro 13. Good condition." },
  { title: "Umbrella (Windproof, Auto-Open)",      category: "accessories", price: 35,   location: "Wu Yee Sun College", status: "unsold",     college: nil,                  description: "Windproof auto-open umbrella. Bought last year, rarely used. Still works perfectly." },
  { title: "Phone Stand (Adjustable, Aluminium)",  category: "accessories", price: 50,   location: "Science Building",   status: "unsold",     college: nil,                  description: "Adjustable aluminium phone/tablet stand. Good for video calls and watching content." },
  { title: "IKEA RÅSKOG Trolley Cart",             category: "accessories", price: 120,  location: "Chung Chi College",  status: "sold",       college: nil,                  description: "White RÅSKOG utility cart with 3 tiers. Great for carrying items around dorm. Some scratches." },
  { title: "Korean Air Fryer (3.5L)",              category: "accessories", price: 260,  location: "S.H. Ho College",    status: "unsold",     college: "S.H. Ho College",    description: "3.5-litre air fryer. Only used a handful of times. Comes with manual and recipes booklet." },

  # Miscellaneous
  { title: "Yoga Mat (6mm, Non-slip)",             category: "miscellaneous", price: 80,  location: "Sports Complex",    status: "unsold",     college: nil,                  description: "Non-slip yoga mat, 6mm thick. Cleaned and in good condition. Purple colour." },
  { title: "Bicycle (Trek FX2, Size M)",           category: "miscellaneous", price: 1800, location: "Shaw College",     status: "unsold",     college: nil,                  description: "Trek FX2 hybrid bike, size M. 3 years old, well maintained. New tyres fitted last year. Lock included." },
  { title: "CUHK Graduation Gown Rental",          category: "miscellaneous", price: 0,   location: "University Hall",   status: "sold",       college: nil,                  description: "Graduation gown rental for upcoming ceremony. Already arranged, price negotiable." },
  { title: "Rice Cooker (Panasonic, 1L)",          category: "miscellaneous", price: 140,  location: "New Asia College",  status: "unsold",    college: "New Asia College",   description: "1-litre Panasonic rice cooker. Perfect for single person. Works perfectly. Slightly yellowed." },
  { title: "Dumbbell Set (5kg x2)",               category: "miscellaneous", price: 95,   location: "United College",    status: "unsold",     college: nil,                  description: "Pair of 5kg hexagonal rubber dumbbells. Good for home workouts." },
  { title: "Electric Kettle (1.2L, Stainless)",   category: "miscellaneous", price: 75,   location: "Morningside College", status: "unsold",   college: nil,                  description: "1.2-litre stainless steel electric kettle. 1500W, boils fast. Very clean." },
  { title: "Foam Roller (60cm)",                  category: "miscellaneous", price: 45,   location: "Sports Complex",    status: "unsold",     college: nil,                  description: "High-density foam roller, 60cm. Great for post-workout recovery. Hardly used." },
  { title: "Playing Cards Bundle (3 decks)",      category: "miscellaneous", price: 25,   location: "Lee Woo Sing College", status: "unsold",  college: nil,                  description: "Three standard decks of playing cards. All complete. Good for card nights." },
  { title: "Portable Bluetooth Speaker (JBL Clip 4)", category: "miscellaneous", price: 280, location: "Shaw College",  status: "unsold",     college: nil,                  description: "JBL Clip 4 waterproof portable speaker. Red colour. Great sound, long battery life." },
  { title: "Indoor Plant (Pothos, with pot)",     category: "miscellaneous", price: 40,   location: "Chung Chi College", status: "unsold",     college: nil,                  description: "Easy-care pothos plant in a white ceramic pot. About 30cm tall. Self-watering not included." },
].freeze

created = 0
listings_data.each_with_index do |attrs, i|
  seller = users[i % users.size]
  Listing.find_or_create_by!(title: attrs[:title], user: seller) do |l|
    l.description = attrs[:description]
    l.price       = attrs[:price]
    l.category    = attrs[:category]
    l.location    = attrs[:location]
    l.status      = attrs[:status]
    l.college     = attrs[:college]
    l.created_at  = rand(60).days.ago
  end
  created += 1
end

puts "Created #{created} seed listings."
puts "Done! Visit http://localhost:3000 to see the listings."
