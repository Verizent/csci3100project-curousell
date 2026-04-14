Rails.application.config.session_store :cookie_store,
  key: "_curousell_session",
  expire_after: 8.hours,
  same_site: :lax,
  secure: false # secure: Rails.env.production?
