require 'redis'

redis_config = {
  url: ENV.fetch('REDIS_TLS_URL', 'redis://localhost:6379/0/session'),
  ssl: true,
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
}

Redis.current = Redis.new(redis_config)

# Configure session store with the same Redis connection
Rails.application.config.session_store :redis_store,
  redis_server: Redis.current,
  expire_after: 5.days,
  key: "_app_session",
  domain: "www.favolist.xyz",
  threadsafe: true,
  secure: true,
  same_site: :lax,
  httponly: true

