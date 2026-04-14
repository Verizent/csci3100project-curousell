require 'rails_helper'

RSpec.describe ListingsController, type: :controller do
  let(:user) do
    User.create!(
      name: "Shaw Student",
      email: "shaw@cuhk.edu.hk",
      college: "Shaw College",
      faculty: [ "Faculty of Engineering" ],
      department: [ "Department of Computer Science and Engineering" ],
      password: "securepassword123",
      password_confirmation: "securepassword123",
      verified_at: Time.current
    )
  end

  def log_in(u)
    allow(controller).to receive(:current_user).and_return(u)
  end

  # GET /listings/new
  describe "GET #new" do
    context "when not logged in" do
      it "redirects to the sign in page" do
        get :new
        expect(response).to redirect_to(account_signin_path)
        expect(flash[:alert]).to match(/log in/i)
      end
    end

    context "when logged in" do
      before { log_in(user) }

      it "returns http success" do
        get :new
        expect(response).to have_http_status(:success)
      end

      it "assigns a new listing" do
        get :new
        expect(assigns(:listing)).to be_a_new(Listing)
      end

      it "builds an access rule on the new listing" do
        get :new
        expect(assigns(:listing).access_rules.length).to eq(1)
      end
    end
  end

  # POST /listings/
  describe "POST #create" do
    let(:valid_params) do
      { listing: { title: "New Item", description: "A nice item", price: 100, category: "tech" } }
    end

    let(:invalid_params) do
      { listing: { title: "", price: -1, category: "invalid" } }
    end

    context "when not logged in" do
      it "redirects to the sign in page" do
        post :create, params: valid_params
        expect(response).to redirect_to(account_signin_path)
      end

      it "does not create a listing" do
        expect {
          post :create, params: valid_params
        }.not_to change(Listing, :count)
      end
    end

    context "when logged in" do
      before { log_in(user) }

      it "creates a listing with valid params" do
        expect {
          post :create, params: valid_params
        }.to change(Listing, :count).by(1)
      end

      it "assigns the listing to the current user" do
        post :create, params: valid_params
        expect(Listing.last.user).to eq(user)
      end

      it "redirects to the new listing with a notice" do
        post :create, params: valid_params
        expect(response).to redirect_to(listing_path(Listing.last))
        expect(flash[:notice]).to match(/live/i)
      end

      it "re-renders the form with invalid params" do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "creates a listing with a college access rule" do
        params = valid_params.deep_merge(
          listing: {
            access_rules_attributes: {
              "0" => { colleges: [ "Shaw College" ], departments: [], faculties: [] }
            }
          }
        )
        expect {
          post :create, params: params
        }.to change(ListingAccessRule, :count).by(1)
        expect(Listing.last.access_rules.first.colleges).to include("Shaw College")
      end

      it "creates a listing with a faculty access rule" do
        params = valid_params.deep_merge(
          listing: {
            access_rules_attributes: {
              "0" => { colleges: [], departments: [], faculties: [ "Faculty of Engineering" ] }
            }
          }
        )
        post :create, params: params
        expect(Listing.last.access_rules.first.faculties).to include("Faculty of Engineering")
      end
    end
  end
end
