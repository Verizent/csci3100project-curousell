secret_key      = Rails.application.credentials.dig(:stripe, :secret_key)      || ENV["STRIPE_SECRET_KEY"]
publishable_key = Rails.application.credentials.dig(:stripe, :publishable_key) || ENV["STRIPE_PUBLISHABLE_KEY"]
webhook_secret  = Rails.application.credentials.dig(:stripe, :webhook_secret)  || ENV["STRIPE_WEBHOOK_SECRET"]

if secret_key.blank?
  Rails.logger.warn "[Stripe] STRIPE_SECRET_KEY is not set — payments will not work."
end

Stripe.api_key = secret_key

Rails.application.config.stripe = ActiveSupport::OrderedOptions.new
Rails.application.config.stripe.publishable_key = publishable_key
Rails.application.config.stripe.webhook_secret  = webhook_secret
