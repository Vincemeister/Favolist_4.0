# this is only for background jobs. I use a seperate redis instance (using the heroku data for redis add-on) for session storage
# this initializer is only for the background jobs using the rediscloud add on

def redis_config(url)
  if Rails.env.production?
    {
      url: url,
      ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
    }
  else
    { url: url }
  end
end

# Configure Redis for caching
$redis_cache = Redis.new(redis_config(ENV["REDIS_CACHE_URL"] || ENV["REDIS_URL"]))

# Configure Sidekiq
sidekiq_url = ENV["REDIS_SIDEKIQ_URL"] || ENV["REDIS_URL"]
Sidekiq.configure_server { |config| config.redis = redis_config(sidekiq_url) }
Sidekiq.configure_client { |config| config.redis = redis_config(sidekiq_url) }

