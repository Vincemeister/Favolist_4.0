require 'sidekiq'
require 'sidekiq/web'

redis_url = ENV["REDIS_TLS_URL"] || ENV["REDIS_URL"]

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url, ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url, ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
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
