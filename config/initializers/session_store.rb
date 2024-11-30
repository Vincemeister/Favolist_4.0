Rails.application.config.session_store :redis_store,
  key: '_favolist_session',
  domain: '.favolist.xyz',
  secure: Rails.env.production?,
  same_site: :lax,
  expire_after: 5.days,
  servers: [{
    url: ENV.fetch('REDIS_TLS_URL', ENV['REDIS_URL']),
    ssl: true,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }]
