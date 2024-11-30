# this is only for background jobs. I use a seperate redis instance (using the heroku data for redis add-on) for session storage
# this initializer is only for the background jobs using the rediscloud add on

# url = ENV["REDISCLOUD_URL"]

# if url
#   Sidekiq.configure_server do |config|
#     config.redis = { url: url }
#   end

#   Sidekiq.configure_client do |config|
#     config.redis = { url: url }
#   end
# end

require 'connection_pool'

redis_config = {
  url: ENV.fetch('REDIS_TLS_URL'),
  ssl: true,
  ssl_params: {
    verify_mode: OpenSSL::SSL::VERIFY_NONE,
    ssl_version: :TLSv1_2
  },
  timeout: 1,
  reconnect_attempts: 2
}

REDIS_POOL = ConnectionPool.new(size: 5, timeout: 5) do
  Redis.new(redis_config)
end

Rails.application.config.session_store(
  :redis_store,
  redis_server: redis_config,
  pool_size: 5,
  pool_timeout: 5,
  expire_after: 5.days,
  key: '_app_session',
  secure: true,
  same_site: :lax,
  httponly: true
)
