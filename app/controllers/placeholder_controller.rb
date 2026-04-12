class PlaceholderController < ApplicationController
  def chats
    render plain: "Chats — coming soon", status: :ok
  end

  def orders
    render plain: "Orders — coming soon", status: :ok
  end

end
