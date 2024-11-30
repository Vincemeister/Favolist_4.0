require 'openssl'

# Common SSL settings
ssl_params = {
  verify_mode: OpenSSL::SSL::VERIFY_NONE,
  ssl_version: :TLSv1_2
}

# Session store Redis config (using main Redis instance)
session_redis_config = {
  url: ENV.fetch('REDIS_TLS_URL'),
  ssl: true,
  ssl_params: ssl_params,
  timeout: 60,  # Matching your Sidekiq timeout
  reconnect_attempts: 2
}

# Configure session store
Rails.application.config.session_store(
  :redis_store,
  servers: [session_redis_config],
  expire_after: 5.days,
  key: '_app_session',
  secure: Rails.env.production?,
  same_site: :lax,
  httponly: true
)

# Sidekiq Redis config (using dedicated Redis instance)
sidekiq_redis_config = {
  url: ENV.fetch('HEROKU_REDIS_CYAN_URL'),
  ssl: true,
  ssl_params: ssl_params,
  network_timeout: 60  # Matching your Sidekiq timeout
}

# Configure Sidekiq
Sidekiq.configure_server do |config|
  config.redis = sidekiq_redis_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_redis_config
end
