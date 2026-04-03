class PlaceholderController < ApplicationController
  def chats
    render inline: coming_soon_html("Chats"), layout: "application"
  end

  def orders
    render inline: coming_soon_html("Orders"), layout: "application"
  end

  def profile
    render inline: coming_soon_html("Profile"), layout: "application"
  end

  private

  def coming_soon_html(page)
    <<~HTML
      <% content_for :title, "CUrousell \u2014 #{page}" %>
      <div class="flex flex-col items-center justify-center min-h-[60vh] text-center px-4">
        <div class="text-6xl mb-6">🚧</div>
        <h1 class="text-3xl font-bold text-cuhk-purple mb-3">#{page} — Coming Soon</h1>
        <p class="text-gray-500 mb-8">This page is under construction. Check back later!</p>
        <%= link_to "Back to Listings", root_path,
              class: "bg-cuhk-purple text-white px-6 py-3 rounded-lg font-semibold
                      hover:bg-cuhk-purple-dark transition-colors" %>
      </div>
    HTML
  end
end
