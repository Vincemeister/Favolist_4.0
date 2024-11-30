# Configurations
# Added for redis storage to work over cookie storage, see gem file redis comments and https://medium.com/@mohammedalaa/how-to-configure-redis-as-a-session-store-in-rails-7-8627c28fb4db

# session_url = "#{ENV.fetch('REDIS_TLS_URL', 'redis://127.0.0.1:6379')}/0/session"
# secure = Rails.env.production?
# key = Rails.env.production? ? "_app_session" : "_app_session_#{Rails.env}"
# domain = Rails.env.production? ? "www.favolist.xyz" : "localhost"
# # domain = ENV.fetch("DOMAIN_NAME", "localhost")

# Rails.application.config.session_store :redis_store,
#                                        url: session_url,
#                                        expire_after: 5.days,
#                                        key: key,
#                                        domain: domain,
#                                        threadsafe: true,
#                                        secure: secure,
#                                        same_site: :lax,
#                                        httponly: true


session_url = ENV.fetch('REDIS_TLS_URL', 'redis://localhost:6379/0/session')
secure = Rails.env.production?
key = Rails.env.production? ? "_app_session" : "_app_session_#{Rails.env}"
domain = Rails.env.production? ? "www.favolist.xyz" : "localhost"
# domain = ENV.fetch("DOMAIN_NAME", "localhost")

session_url = "#{ENV.fetch('REDIS_TLS_URL', 'redis://127.0.0.1:6379')}/0/session"

Rails.application.config.session_store :redis_store,
                                       url: session_url,
                                       ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }, # Add this line
                                       expire_after: 5.days,
                                       key: "_app_session",
                                       domain: "www.favolist.xyz",
                                       threadsafe: true,
                                       secure: true,
                                       same_site: :lax,
                                       httponly: true

