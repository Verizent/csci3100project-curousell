require "rails_helper"

RSpec.describe "Listings", type: :request do
  let!(:owner) { create(:user, college: "Shaw College") }
  let!(:public_listing) { create(:listing, user: owner, title: "Public MacBook") }

  # ---------------------------------------------------------------------------
  # Home / index
  # ---------------------------------------------------------------------------

  describe "GET /home" do
    it "returns 200" do
      get home_path
      expect(response).to have_http_status(:ok)
    end

    it "shows public listings to a guest" do
      get home_path
      expect(response.body).to include(public_listing.title)
    end

    it "does not show restricted listings to a guest" do
      restricted = create(:listing, user: owner, title: "Shaw Members Only")
      create(:listing_access_rule, listing: restricted,
        colleges: [ "Shaw College" ], faculties: [], departments: [])

      get home_path
      expect(response.body).not_to include("Shaw Members Only")
    end

    context "when a logged-in user is from Shaw College" do
      let!(:shaw_user) do
        create(:user, college: "Shaw College",
          faculty: [ "Faculty of Engineering" ],
          department: [ "Department of Computer Science and Engineering" ])
      end
      let!(:shaw_only) do
        listing = create(:listing, user: owner, title: "Shaw Exclusive Item")
        create(:listing_access_rule, listing: listing,
          colleges: [ "Shaw College" ], faculties: [], departments: [])
        listing
      end

      before { sign_in_as(shaw_user) }

      it "shows listings restricted to their own college" do
        get home_path
        expect(response.body).to include("Shaw Exclusive Item")
      end
    end
  end

  describe "GET /listings" do
    it "returns 200" do
      get listings_path
      expect(response).to have_http_status(:ok)
    end
  end

  # ---------------------------------------------------------------------------
  # Category filter
  # ---------------------------------------------------------------------------

  describe "GET /home with category filter" do
    let!(:book) { create(:listing, :books, user: owner, title: "Used Textbook") }
    let!(:tech) { create(:listing, category: "tech", user: owner, title: "Old Laptop") }

    it "shows only tech listings when filtered by tech" do
      get home_path, params: { categories: [ "tech" ] }
      expect(response.body).to include("Old Laptop")
      expect(response.body).not_to include("Used Textbook")
    end

    it "shows only book listings when filtered by books" do
      get home_path, params: { categories: [ "books" ] }
      expect(response.body).to include("Used Textbook")
      expect(response.body).not_to include("Old Laptop")
    end
  end

  # ---------------------------------------------------------------------------
  # Free filter
  # ---------------------------------------------------------------------------

  describe "GET /home with free filter" do
    let!(:free_listing) { create(:listing, :free, user: owner, title: "Free Chair") }
    let!(:paid_listing) { create(:listing, price: 200, user: owner, title: "Paid Sofa") }

    it "shows only free listings" do
      get home_path, params: { free: "1" }
      expect(response.body).to include("Free Chair")
      expect(response.body).not_to include("Paid Sofa")
    end
  end

  # ---------------------------------------------------------------------------
  # Max price filter
  # ---------------------------------------------------------------------------

  describe "GET /home with max_price filter" do
    let!(:cheap)     { create(:listing, price: 30, user: owner, title: "Cheap Book") }
    let!(:expensive) { create(:listing, price: 500, user: owner, title: "Pricey Desk") }

    it "shows only listings at or below the max price" do
      get home_path, params: { max_price: "50" }
      expect(response.body).to include("Cheap Book")
      expect(response.body).not_to include("Pricey Desk")
    end
  end

  # ---------------------------------------------------------------------------
  # Show
  # ---------------------------------------------------------------------------

  describe "GET /listings/:id" do
    it "returns 200 for a public listing" do
      get listing_path(public_listing)
      expect(response).to have_http_status(:ok)
    end

    context "with a restricted listing that the guest cannot see" do
      let!(:restricted) do
        listing = create(:listing, user: owner, title: "Staff Only Widget")
        create(:listing_access_rule, listing: listing,
          colleges: [ "United College" ], faculties: [], departments: [])
        listing
      end

      it "redirects a guest to the home page with an alert" do
        get listing_path(restricted)
        expect(response).to redirect_to(home_path)
        follow_redirect!
        expect(response.body).to include("not available")
      end

      it "redirects a user from a different college" do
        other = create(:user, college: "Shaw College",
          faculty: [ "Faculty of Arts" ], department: [ "Department of English" ])
        sign_in_as(other)
        get listing_path(restricted)
        expect(response).to redirect_to(home_path)
      end
    end

    context "with a restricted listing that the user can access" do
      let!(:shaw_user) do
        create(:user, college: "Shaw College",
          faculty: [ "Faculty of Engineering" ],
          department: [ "Department of Computer Science and Engineering" ])
      end
      let!(:shaw_listing) do
        listing = create(:listing, user: owner, title: "Shaw Members Book")
        create(:listing_access_rule, listing: listing,
          colleges: [ "Shaw College" ], faculties: [], departments: [])
        listing
      end

      before { sign_in_as(shaw_user) }

      it "returns 200" do
        get listing_path(shaw_listing)
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
