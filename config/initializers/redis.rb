# this is only for background jobs. I use a seperate redis instance (using the heroku data for redis add-on) for session storage
# this initializer is only for the background jobs using the rediscloud add on

url = ENV["REDISCLOUD_URL"]

if url
  Sidekiq.configure_server do |config|
    config.redis = { url: url }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: url }
  end
end