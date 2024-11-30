require 'sidekiq'
require 'sidekiq/web'

redis_config = {
  url: ENV.fetch('HEROKU_REDIS_CYAN_URL'),
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
  network_timeout: 60
}

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end

# Protect the Sidekiq web interface in production
Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  # Secure comparison of credentials
  ActiveSupport::SecurityUtils.secure_compare(user, ENV.fetch('SIDEKIQ_USER', 'admin')) &
  ActiveSupport::SecurityUtils.secure_compare(password, ENV.fetch('SIDEKIQ_PASSWORD', 'favolist2024secure'))
end

# Only allow access to Sidekiq web interface in production if credentials are present
if Rails.env.production? && !ENV['SIDEKIQ_USER'].present?
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    warn "SIDEKIQ_USER and SIDEKIQ_PASSWORD not configured in production!"
    false # Always deny access if credentials aren't configured
  end
end 
