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


require 'redis'

redis_config = {
  url: ENV.fetch('REDIS_TLS_URL', 'redis://localhost:6379/0/session'),
  ssl: true,
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
}

# Create a Redis instance
$redis = Redis.new(redis_config)

# Configure session store
Rails.application.config.session_store :redis_store,
  servers: [redis_config],
  expire_after: 5.days,
  key: "_app_session",
  domain: "www.favolist.xyz",
  threadsafe: true,
  secure: true,
  same_site: :lax,
  httponly: true

