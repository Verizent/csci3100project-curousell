require "factory_bot_rails"

# ── FactoryBot ────────────────────────────────────────────────────────────────
World(FactoryBot::Syntax::Methods)

# ── Route helpers ─────────────────────────────────────────────────────────────
World(Rails.application.routes.url_helpers)

# ── ActionMailer ──────────────────────────────────────────────────────────────
ActionMailer::Base.delivery_method = :test

Before do
  ActionMailer::Base.deliveries.clear
end

# ── Capybara: headless Chrome for @javascript scenarios ───────────────────────
Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless=new")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--disable-gpu")
  options.add_argument("--window-size=1280,800")
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :headless_chrome
