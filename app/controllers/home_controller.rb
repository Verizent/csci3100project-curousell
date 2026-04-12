class HomeController < ApplicationController
  before_action :require_login

  # GET /home
  def index
  end
end
