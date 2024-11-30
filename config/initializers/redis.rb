require 'openssl'

# Common Redis SSL configuration
redis_ssl_params = {
  ssl: true,
  ssl_params: {
    verify_mode: OpenSSL::SSL::VERIFY_NONE  # Required for Heroku Redis
  }
}

# Session store Redis config
session_config = {
  url: ENV.fetch('REDIS_TLS_URL', ENV['REDIS_URL']),
  ssl: true,
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
  timeout: 60,
  reconnect_attempts: 2,
  namespace: "session"
}

# Configure session store
Rails.application.config.session_store :redis_store, {
  servers: [session_config],
  expire_after: 5.days,
  key: '_favolist_session',
  secure: Rails.env.production?,
  same_site: :lax
}

# Sidekiq Redis config
Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV.fetch('HEROKU_REDIS_CYAN_URL', ENV['REDIS_URL']),
    ssl: true,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    network_timeout: 60
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV.fetch('HEROKU_REDIS_CYAN_URL', ENV['REDIS_URL']),
    ssl: true,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    network_timeout: 60
  }
end
