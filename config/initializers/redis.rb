require 'openssl'

# Session store configuration
Rails.application.config.session_store :redis_store, {
  url: ENV.fetch('REDIS_TLS_URL', ENV['REDIS_URL']),
  ssl: true,
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
  expire_after: 5.days,
  key: '_favolist_session',
  domain: '.favolist.xyz',
  secure: Rails.env.production?,
  same_site: :lax
}

# Cache store configuration
Rails.application.config.cache_store = :redis_cache_store, {
  url: ENV.fetch('REDIS_CACHE_URL', ENV['REDIS_URL']),
  ssl: false  # Since REDIS_CACHE_URL is non-SSL
}

# Sidekiq configuration
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
