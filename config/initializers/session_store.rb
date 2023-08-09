# Configurations
# Added for redis storage to work over cookie storage, see gem file redis comments and https://medium.com/@mohammedalaa/how-to-configure-redis-as-a-session-store-in-rails-7-8627c28fb4db

session_url = "#{ENV.fetch('REDIS_CACHE_URL', 'redis://127.0.0.1:6379')}/0/session"
secure = Rails.env.production?
key = Rails.env.production? ? "_app_session" : "_app_session_#{Rails.env}"
domain = ENV.fetch("DOMAIN_NAME", "localhost")

Rails.application.config.session_store :redis_store,
                                       url: session_url,
                                       expire_after: 180.days,
                                       key: key,
                                       domain: domain,
                                       threadsafe: true,
                                       secure: secure,
                                       same_site: :lax,
                                       httponly: true
