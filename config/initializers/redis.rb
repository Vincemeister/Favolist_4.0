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


redis_url = ENV["REDIS_TLS_URL"] || ENV["REDIS_URL"]

if redis_url
  Sidekiq.configure_server do |config|
    config.redis = { url: redis_url, ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: redis_url, ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
  end
end
