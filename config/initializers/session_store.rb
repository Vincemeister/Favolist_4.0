session_url = ENV["REDIS_SESSION_URL"] || ENV["REDIS_URL"]
session_config = if Rails.env.production?
  {
    url: session_url,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }
else
  { url: session_url }
end

Rails.application.config.session_store :redis_store,
  servers: [session_config],
  expire_after: 90.minutes,
  key: '_favolist_session'
