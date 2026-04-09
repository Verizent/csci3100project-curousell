# This file is to generate the listings for testing. For whomever is going to create user profiles or listing pages, you may delete this file in your versions.

# Seeds are idempotent — safe to re-run.
puts "Seeding..."

# Clear existing data so re-runs start clean
Listing.delete_all
User.delete_all

COLLEGES = Listing::COLLEGES.freeze

# Real CUHK faculties and their departments
CUHK_FACULTY_DEPARTMENTS = {
  "Faculty of Arts" => [
    "Department of Chinese Language and Literature",
    "Department of Cultural and Religious Studies",
    "Department of English",
    "Department of Fine Arts",
    "Department of History",
    "Department of Japanese Studies",
    "Department of Music",
    "Department of Philosophy"
  ],
  "Faculty of Business Administration" => [
    "Department of Accountancy",
    "Department of Decision Sciences and Managerial Economics",
    "Department of Finance",
    "Department of Hotel and Tourism Management",
    "Department of Management",
    "Department of Marketing"
  ],
  "Faculty of Education" => [
    "Department of Curriculum and Instruction",
    "Department of Educational Administration and Policy",
    "Department of Educational Psychology"
  ],
  "Faculty of Engineering" => [
    "Department of Computer Science and Engineering",
    "Department of Electronic Engineering",
    "Department of Information Engineering",
    "Department of Mechanical and Automation Engineering",
    "Department of Systems Engineering and Engineering Management"
  ],
  "Faculty of Law" => [
    "Faculty of Law"
  ],
  "Faculty of Medicine" => [
    "School of Biomedical Sciences",
    "Department of Medicine and Therapeutics",
    "Department of Obstetrics and Gynaecology",
    "Department of Pharmacology",
    "Department of Surgery"
  ],
  "Faculty of Science" => [
    "Department of Biology",
    "Department of Chemistry",
    "Department of Earth and Environmental Sciences",
    "Department of Mathematics",
    "Department of Physics",
    "Department of Statistics"
  ],
  "Faculty of Social Science" => [
    "Department of Economics",
    "Department of Government and Public Administration",
    "Department of Psychology",
    "Department of Social Work",
    "Department of Sociology"
  ]
}.freeze

SEED_NAMES = [
  "Chan Siu Ming", "Wong Wai Kin", "Lee Ka Yan", "Ng Ho Fung",
  "Lau Mei Ling", "Cheung Chi Wai", "Tsang Yuen Yee", "Kwok Tsz Hin",
  "Ho Pak Hei", "Lam Hoi Ting", "Yip Ka Wai", "Fung Wai Ho", "Mok Ching Yu",
  "Wang Meihua", "Zhang Wei", "Liu Yangguang",
  "James Wijaya", "David Lee"
].freeze

# ── Seed users ───────────────────────────────────────────────────────────────
name_pool = SEED_NAMES.dup
users = COLLEGES.flat_map do |college|
  2.times.map do |i|
    slug  = college.downcase.gsub(/[^a-z0-9]/, "")
    email = "#{slug}#{i + 1}@link.cuhk.edu.hk"
    name  = name_pool.shift
    user  = User.find_or_initialize_by(email: email)
    faculty    = CUHK_FACULTY_DEPARTMENTS.keys.sample
    department = CUHK_FACULTY_DEPARTMENTS[faculty].sample
    user.assign_attributes(
      name:        name,
      college:     college,
      faculty:     faculty,
      department:  department,
      verified_at: Time.current
    )
    user.password = "password123456" if user.new_record?
    user.save!
    user
  end
end
puts "  #{users.size} users ready"

# ── Listing data ─────────────────────────────────────────────────────────────
LISTING_DATA = [
  # Tech
  { title: "MacBook Air M1 (2021)",               description: "Barely used, 8GB RAM, 256GB SSD. Selling because I upgraded.",           category: "tech",          price: 3800, location: "Chung Chi College" },
  { title: "iPad Pro 11\" with Apple Pencil",     description: "2022 model, Wi-Fi only, includes pencil and folio case.",               category: "tech",          price: 4200, location: "New Asia College" },
  { title: "Sony WH-1000XM4 Headphones",          description: "Noise-cancelling, great condition, minimal use.",                      category: "tech",          price: 900,  location: "United College" },
  { title: "Mechanical Keyboard (Keychron K2)",   description: "Brown switches, TKL layout. Comes with USB-C cable.",                  category: "tech",          price: 350,  location: "Shaw College" },
  { title: "Nintendo Switch OLED",                description: "With dock, 2 joy-cons, and 3 games. No scratches.",                    category: "tech",          price: 2200, location: "Morningside College" },
  { title: "Logitech MX Master 3 Mouse",          description: "Wireless, works on any surface. Lightly used.",                        category: "tech",          price: 280,  location: "S.H. Ho College" },
  { title: "Samsung 27\" 4K Monitor",             description: "IPS panel, 60Hz, USB-C. Perfect for studying.",                       category: "tech",          price: 1500, location: "Wu Yee Sun College" },
  { title: "GoPro Hero 11 Black",                 description: "Water-resistant, includes 2 batteries and carrying case.",             category: "tech",          price: 1800, location: "CW Chu College" },
  { title: "Portable SSD 1TB (Samsung T7)",       description: "USB 3.2, extremely fast read/write speeds.",                          category: "tech",          price: 380,  location: "Lee Woo Sing College" },
  { title: "Raspberry Pi 4 (4GB)",                description: "With case, SD card, and power supply. Great for projects.",            category: "tech",          price: 420,  location: "New Asia College" },
  { title: "USB-C Hub 7-in-1",                    description: "HDMI, USB 3.0 x3, SD card, PD charging. Compact.",                   category: "tech",          price: 95,   location: "United College" },
  { title: "Xiaomi Smart Band 7",                 description: "Heart rate, sleep tracking, 14-day battery. Like new.",               category: "tech",          price: 120,  location: "Shaw College" },
  { title: "Kindle Paperwhite (11th Gen)",         description: "6.8\", waterproof, 32GB. Comes with leather cover.",                  category: "tech",          price: 680,  location: "Chung Chi College" },
  { title: "Canon EF 50mm f/1.8 Lens",            description: "Sharp prime lens, great for portraits. Minimal use.",                 category: "tech",          price: 580,  location: "Morningside College" },
  { title: "Mini Bluetooth Speaker (JBL Clip 4)", description: "Waterproof, carabiner clip. Loud for its size.",                     category: "tech",          price: 240,  location: "S.H. Ho College" },
  { title: "Monitor Light Bar (BenQ ScreenBar)",  description: "With remote. Zero glare reading light for desk.",                     category: "tech",          price: 420,  location: "CW Chu College" },
  { title: "USB Microphone (Blue Snowball)",       description: "Cardioid mode, plug-and-play. Good for online classes.",              category: "tech",          price: 290,  location: "New Asia College" },
  { title: "Sony ZV-E10 Mirrorless Camera",        description: "Vlogging camera with kit lens. Used for one semester project.",       category: "tech",          price: 2800, location: "CW Chu College" },
  { title: "Portable Projector (Anker Nebula)",   description: "720p, built-in Android TV, battery. Perfect for movie nights.",       category: "tech",          price: 1400, location: "Wu Yee Sun College" },
  { title: "Fujifilm Instax Mini 12",             description: "Pastel blue, includes one film pack. Perfect gift.",                  category: "tech",          price: 350,  location: "New Asia College" },
  # Furniture
  { title: "IKEA ALEX Drawer Unit",               description: "White, 5 drawers. Perfect for dorm room desk storage.",               category: "furniture",     price: 250,  location: "Chung Chi College" },
  { title: "Foldable Study Chair",                description: "Ergonomic back support, adjustable height. Easy to store.",           category: "furniture",     price: 180,  location: "New Asia College" },
  { title: "Standing Desk Converter",             description: "Lifts your laptop/monitor to standing height. Used 6 months.",        category: "furniture",     price: 320,  location: "United College" },
  { title: "IKEA KALLAX Shelf (2×2)",             description: "White, good condition. Pick up from hostel.",                         category: "furniture",     price: 150,  location: "Shaw College" },
  { title: "Bean Bag Chair (Large)",              description: "Dark grey. Super comfy for gaming or reading.",                       category: "furniture",     price: 200,  location: "Morningside College" },
  { title: "Whiteboard with Stand (90×60cm)",     description: "Magnetic whiteboard. Markers and eraser included.",                   category: "furniture",     price: 160,  location: "S.H. Ho College" },
  { title: "LED Desk Lamp",                       description: "Adjustable arm, USB charging port, 3 brightness levels.",            category: "furniture",     price: 85,   location: "Wu Yee Sun College" },
  { title: "Mini Fridge (45L)",                   description: "Single door, very quiet motor. Perfect for hostel room.",             category: "furniture",     price: 450,  location: "CW Chu College" },
  { title: "Floor Lamp (Arc Style)",              description: "Modern design, 3 light settings. Great for study corner.",            category: "furniture",     price: 230,  location: "Lee Woo Sing College" },
  { title: "Cork Bulletin Board (90×60cm)",       description: "With push pins included. Great for schedules and notes.",             category: "furniture",     price: 95,   location: "Lee Woo Sing College" },
  { title: "Folding Laptop Tray Table",           description: "For bed or sofa. Adjustable angle, cup holder.",                     category: "furniture",     price: 120,  location: "Shaw College" },
  { title: "IKEA Poäng Armchair",                 description: "Birch veneer frame + cushion. Very comfortable reading chair.",       category: "furniture",     price: 380,  location: "CW Chu College" },
  # Books
  { title: "COMP3230 Operating Systems Textbook", description: "Silberschatz 10th ed. Highlighted but complete.",                    category: "books",         price: 80,   location: "Chung Chi College" },
  { title: "Calculus: Early Transcendentals",     description: "Stewart 8th edition. Minor wear, all pages intact.",                 category: "books",         price: 60,   location: "New Asia College" },
  { title: "Introduction to Algorithms (CLRS)",   description: "3rd edition hardcover. Essential for CS students.",                  category: "books",         price: 120,  location: "United College" },
  { title: "Financial Accounting Bundle",         description: "Weygandt + Kieso, 3 books. ACCT1010 compatible.",                    category: "books",         price: 90,   location: "Shaw College" },
  { title: "The Pragmatic Programmer",            description: "20th Anniversary edition. Great for any developer.",                 category: "books",         price: 55,   location: "Morningside College" },
  { title: "BIOL1010 + BIOL1020 Notes Pack",      description: "Handwritten summary notes, A4 spiral bound.",                       category: "books",         price: 40,   location: "S.H. Ho College" },
  { title: "CFA Level 1 Study Pack (2024)",       description: "Schweser Notes + Practice Exams. Unused.",                          category: "books",         price: 350,  location: "Wu Yee Sun College" },
  { title: "Organic Chemistry (McMurry, 9th ed)", description: "A few highlights, otherwise clean.",                                category: "books",         price: 75,   location: "CW Chu College" },
  { title: "Design Patterns: GoF",                description: "Classic software engineering book. Good condition.",                 category: "books",         price: 95,   location: "Lee Woo Sing College" },
  { title: "STAT2001 Statistics Textbook",         description: "DeVeaux et al. Minor highlights. Selling after finals.",            category: "books",         price: 65,   location: "Shaw College" },
  { title: "PHYS1110 General Physics Notes",      description: "Full semester, handwritten and typed mix.",                          category: "books",         price: 30,   location: "Shaw College" },
  { title: "MAFS2050 Past Papers Bundle",         description: "2019–2024 past exams with solutions. Printed and bound.",            category: "books",         price: 45,   location: "S.H. Ho College" },
  { title: "Graphic Novel Collection (10 books)", description: "Mix of Marvel and DC. All in good condition.",                      category: "books",         price: 160,  location: "Lee Woo Sing College" },
  { title: "CHEM1010 Lab Manual + Notes",         description: "Full lab reports and lecture notes. Printed and bound.",             category: "books",         price: 35,   location: "Chung Chi College" },
  # Accessories
  { title: "Leather Laptop Sleeve 13\"",          description: "Handmade look, water-resistant. Fits MacBook Air/Pro.",              category: "accessories",   price: 120,  location: "Chung Chi College" },
  { title: "AirPods Pro (2nd Gen)",               description: "Used 4 months. All tips included, original box.",                   category: "accessories",   price: 900,  location: "New Asia College" },
  { title: "Phone Stand + Wireless Charger",      description: "15W MagSafe-compatible for iPhone. Desk-friendly design.",          category: "accessories",   price: 145,  location: "United College" },
  { title: "Vintage Canvas Backpack (35L)",       description: "Lots of pockets. Good for day trips or campus use.",                category: "accessories",   price: 180,  location: "Shaw College" },
  { title: "Seiko 5 Automatic Watch",             description: "Classic navy dial, automatic movement. Gift condition.",             category: "accessories",   price: 580,  location: "Morningside College" },
  { title: "Anker Power Bank 20000mAh",           description: "Dual USB-A + USB-C PD. Used twice.",                                category: "accessories",   price: 210,  location: "Wu Yee Sun College" },
  { title: "Hydro Flask Style Bottle (1L)",       description: "Keeps cold 24h. Matte black. Reusable.",                            category: "accessories",   price: 65,   location: "CW Chu College" },
  { title: "Lowepro DSLR Camera Bag",             description: "Fits body + 3 lenses. Rain cover included.",                        category: "accessories",   price: 290,  location: "Lee Woo Sing College" },
  { title: "Ergonomic Mouse Pad with Wrist Rest", description: "Memory foam, non-slip base. 40×90cm extended size.",               category: "accessories",   price: 90,   location: "United College" },
  { title: "Foldable Aluminium Laptop Stand",     description: "Adjustable 6 angles. Works with any laptop.",                       category: "accessories",   price: 115,  location: "Wu Yee Sun College" },
  { title: "Garmin Forerunner 245 Watch",         description: "GPS running watch, heart rate, sleep tracking.",                    category: "accessories",   price: 720,  location: "United College" },
  { title: "Closca Foldable Bike Helmet (M)",     description: "MIPS protection, urban style.",                                     category: "accessories",   price: 320,  location: "S.H. Ho College" },
  { title: "Pilot G2 Gel Pen Set (20 pens)",      description: "Mix of colours and sizes. Half still unused.",                      category: "accessories",   price: 25,   location: "Morningside College" },
  { title: "Foldable Umbrella (Windproof)",       description: "Double-layer canopy, auto open/close. Fits any bag.",               category: "accessories",   price: 55,   location: "Shaw College" },
  # Misc
  { title: "PS5 DualSense Controller",            description: "White, works perfectly. Selling because I have two.",               category: "miscellaneous", price: 380,  location: "Chung Chi College" },
  { title: "Yoga Mat + Cork Blocks Set",          description: "Purple 6mm mat + 2 cork blocks. Used for one semester.",            category: "miscellaneous", price: 95,   location: "New Asia College" },
  { title: "Bodum French Press (1L)",             description: "Makes great coffee for your study sessions.",                       category: "miscellaneous", price: 80,   location: "United College" },
  { title: "LEGO Architecture Set (Unopened)",    description: "Empire State Building #21046. Sealed in box.",                      category: "miscellaneous", price: 320,  location: "Shaw College" },
  { title: "Polaroid Now+ Camera + Film",         description: "Includes 2 film packs. Great for events.",                          category: "miscellaneous", price: 480,  location: "Morningside College" },
  { title: "Weighted Blanket (6kg)",              description: "Dark blue, 150×200cm. Helps with sleep. Good condition.",           category: "miscellaneous", price: 280,  location: "CW Chu College" },
  { title: "Bamboo Cutting Board Set (3 sizes)",  description: "Used for one year, still in great shape.",                          category: "miscellaneous", price: 55,   location: "S.H. Ho College" },
  { title: "Compact Electric Kettle (0.8L)",      description: "Fast boil, auto shut-off. Ideal for dorm.",                        category: "miscellaneous", price: 75,   location: "Wu Yee Sun College" },
  { title: "Stainless Steel 3-Tier Lunch Box",    description: "With bag and cutlery. Barely used.",                                category: "miscellaneous", price: 60,   location: "Chung Chi College" },
  { title: "Cable Knit Throw Blanket",            description: "Chunky knit, cream colour. Super cosy for winter study.",          category: "miscellaneous", price: 85,   location: "New Asia College" },
  { title: "Collapsible 2-Tier Dish Rack",        description: "Stainless steel, with utensil holder.",                             category: "miscellaneous", price: 45,   location: "Chung Chi College" },
  { title: "Memory Foam Chair Cushion",           description: "Fits any standard chair. Reduces fatigue during long sessions.",    category: "miscellaneous", price: 70,   location: "United College" },
  { title: "Dyson V8 Cordless Vacuum",            description: "20-min runtime, wall mount included. Perfect for hostel.",           category: "miscellaneous", price: 1200, location: "Lee Woo Sing College" },
  # Free items
  { title: "ECON1010 Lecture Notes (Full Sem)",   description: "Free to a good home. Typed notes, well-organised.",                 category: "books",         price: 0,    location: "New Asia College" },
  { title: "IKEA Desk Mat (slightly worn)",       description: "47×23cm, edges worn but functional. Free.",                         category: "miscellaneous", price: 0,    location: "United College" },
  { title: "Large Cardboard Boxes (5 pcs)",       description: "Moving out — take as many as you need. Free.",                      category: "miscellaneous", price: 0,    location: "Shaw College" },
  { title: "Old Phone Cables Bundle",             description: "Mix of Lightning and USB-C. Some may work. Free.",                  category: "tech",          price: 0,    location: "Morningside College" },
  { title: "Noise-Cancelling Earplugs (10 pairs)", description: "SNR 35dB, ideal for library or exam season. Sealed. Free.",       category: "accessories",   price: 0,    location: "Morningside College" },
  { title: "Instant Noodle Stockpile (50 packs)", description: "Various flavours. Moving out sale. Free.",                         category: "miscellaneous", price: 0,    location: "Wu Yee Sun College" },
  { title: "Cable Management Kit",               description: "Velcro ties, clips, and sleeves. Clean up your desk setup.",        category: "accessories",   price: 35,   location: "S.H. Ho College" }
].freeze

# ── Create listings ───────────────────────────────────────────────────────────
created = 0
LISTING_DATA.each_with_index do |attrs, i|
  seller = users[i % users.size]
  Listing.find_or_create_by!(title: attrs[:title], user: seller) do |l|
    l.description = attrs[:description]
    l.price       = attrs[:price]
    l.category    = attrs[:category]
    l.location    = attrs[:location]
    l.status      = "unsold"
    l.created_at  = rand(30).days.ago
  end
  created += 1
end

puts "  #{created} listings seeded"
puts "Done."
