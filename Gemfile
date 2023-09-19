source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.4", ">= 7.0.4.2"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Sass to process CSS
gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem "devise"
gem "autoprefixer-rails"
gem "simple_form", github: "heartcombo/simple_form"
group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "dotenv-rails"

end

# ADDED AFTER TEMPLATE
gem "faker"
gem "cloudinary"
source "https://token:7F03DB71-762E-485E-B73A-A3C88B457C05@dl.fontawesome.com/basic/fontawesome-pro/ruby/" do
  gem "font-awesome-pro-sass", "6.4.0"
end
gem 'pg_search'
gem "httparty"
gem 'nokogiri'
# change from cookie storage to redis to allow for product creation from shopify and generic stores. Also created file config/initializers/session_store.rb
=begin
Devise works with Rails' session management mechanism, and switching the session store doesn't specifically interfere with Devise's operation. However, there are a few considerations to be aware of when integrating Devise with a Redis-backed session store:
1. **Session Serialization**: If you've customized the serialization method of your session data, ensure that it remains compatible when switching stores.
2. **Session Timeout**: If you're relying on Devise's `timeoutable` module to automatically sign out users after a period of inactivity, this behavior should remain the same. Just ensure that the `expire_after` option in your session store configuration is not shorter than Devise's `timeout_in` configuration to prevent unexpected session expirations.
3. **Migration**: If you're migrating from a cookie store to Redis while your app is in production, be aware that user sessions will be reset during the migration, as the session data in cookies won't be automatically transferred to Redis. Users will need to sign in again.
4. **Secure Your Redis**: Ensure your Redis instance is secure, especially if it's exposed to the internet. Consider using a password and binding it to localhost if it's only accessed locally. If using Redis in production, consider using a solution that supports encryption in transit, like Redis over SSL/TLS.
5. **Session Cleanup**: Redis doesn't automatically remove expired sessions. You may want to configure Redis to use an eviction policy like `allkeys-lru` to evict least recently used keys when it reaches its maximum memory threshold. Alternatively, you can periodically run a task to clean up old sessions.
6. **Backup and Monitoring**: Since Redis is an in-memory datastore, make sure you're regularly backing up its data if you're storing anything important in sessions. Also, monitor its usage to ensure it doesn't run out of memory, especially if you have a lot of active sessions.
All that said, switching the session store to Redis while using Devise should be relatively straightforward, and Devise itself shouldn't be affected. But, as always, it's important to test thoroughly in a development or staging environment before making any changes in production.

how I set up redis after really finding difficulties with it
https://medium.com/@mohammedalaa/how-to-configure-redis-as-a-session-store-in-rails-7-8627c28fb4db

=end
gem "redis", "~> 5.0" # Redis client for Ruby
gem "redis-actionpack", "~> 5.3" # Redis session store for ActionPack
gem 'bullet', group: 'development'
gem 'rack-mini-profiler'
gem 'rmagick' # to generate tiled backgrounds
gem 'kaminari' # pagination





group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end
