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

  describe "GET /listings/:id/edit" do
    let!(:seller) { create(:user) }
    let!(:listing) { create(:listing, user: seller, status: "unsold") }

    it "shows only the price field — no title, description, location, category or access rules" do
      sign_in_as(seller)

      get edit_listing_path(listing)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("HK$")                      # price input present
      expect(response.body).not_to include("Add Photos")
      expect(response.body).not_to include("listing_form_target=\"fileInput\"")
      expect(response.body).not_to include("Meeting Place")
      expect(response.body).not_to include("Restrict Audience")
      expect(response.body).not_to include("negotiable")
      expect(response.body).not_to include("Category")
      expect(response.body).not_to match(/label[^>]*>Title/)
      expect(response.body).not_to match(/label[^>]*>Description/)
    end

    it "shows delete button for the seller" do
      sign_in_as(seller)

      get edit_listing_path(listing)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Delete Listing")
    end

    it "shows delete-disabled message when delivery has been confirmed" do
      create(:order, :paid, :seller_confirmed, listing: listing)
      sign_in_as(seller)

      get edit_listing_path(listing)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Delete is disabled after delivery has been confirmed")
      expect(response.body).not_to include("Delete Listing")
    end
  end

  # ---------------------------------------------------------------------------
  # Update (price only)
  # ---------------------------------------------------------------------------

  describe "PATCH /listings/:id" do
    let!(:seller) { create(:user) }
    let!(:listing) { create(:listing, user: seller, status: "unsold", title: "Original Title", price: 100) }

    it "updates only the price" do
      sign_in_as(seller)

      patch listing_path(listing), params: { listing: { price: 75 } }

      expect(response).to redirect_to(listing_path(listing))
      expect(listing.reload.price).to eq(75)
    end

    it "ignores other fields even if submitted" do
      sign_in_as(seller)

      patch listing_path(listing), params: { listing: { price: 60, title: "Hacked Title" } }

      listing.reload
      expect(listing.price).to eq(60)
      expect(listing.title).to eq("Original Title")
    end
  end

  # ---------------------------------------------------------------------------
  # Destroy
  # ---------------------------------------------------------------------------

  describe "DELETE /listings/:id" do
    let!(:seller) { create(:user) }
    let!(:other_user) { create(:user) }
    let!(:listing) { create(:listing, user: seller, status: "unsold") }

    it "allows the seller to delete when no delivery confirmation exists" do
      sign_in_as(seller)

      expect {
        delete listing_path(listing)
      }.to change(Listing, :count).by(-1)

      expect(response).to redirect_to(home_path)
    end

    it "rejects non-sellers from deleting" do
      sign_in_as(other_user)

      expect {
        delete listing_path(listing)
      }.not_to change(Listing, :count)

      expect(response).to redirect_to(home_path)
      follow_redirect!
      expect(response.body).to include("only delete your own listings")
    end

    it "rejects deletion after seller confirmed delivery" do
      create(:order, :paid, :seller_confirmed, listing: listing)
      sign_in_as(seller)

      expect {
        delete listing_path(listing)
      }.not_to change(Listing, :count)

      expect(response).to redirect_to(listing_path(listing))
      follow_redirect!
      expect(response.body).to include("cannot be deleted after delivery has been confirmed")
    end

    it "rejects deletion after buyer confirmed receipt" do
      create(:order, :paid, :buyer_confirmed, listing: listing)
      sign_in_as(seller)

      expect {
        delete listing_path(listing)
      }.not_to change(Listing, :count)

      expect(response).to redirect_to(listing_path(listing))
      follow_redirect!
      expect(response.body).to include("cannot be deleted after delivery has been confirmed")
    end
  end
end
