require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CurrencyTracker
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    config.eager_load_paths << Rails.root.join('lib')
    config.eager_load_paths << Rails.root.join('lib/rest_connectors')

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set up logging to be the same in all environments but control the level
    # through an environment variable.
    config.log_level = ENV['LOG_LEVEL']

    # Log to STDOUT because Docker expects all processes to log here. You could
    # then redirect logs to a third party service on your own such as systemd,
    # or a third party host such as Loggly, etc..
    if !Rails.env.development?
      logger           = ActiveSupport::Logger.new(STDOUT)
      logger.formatter = config.log_formatter
      config.log_tags  = %i[subdomain uuid]
      config.logger    = ActiveSupport::TaggedLogging.new(logger)
    end

    # Action mailer settings.
    # config.action_mailer.delivery_method = :smtp
    # config.action_mailer.smtp_settings = {
    #   address:              ENV['SMTP_ADDRESS'],
    #   port:                 ENV['SMTP_PORT'].to_i,
    #   domain:               ENV['SMTP_DOMAIN'],
    #   user_name:            ENV['SMTP_USERNAME'],
    #   password:             ENV['SMTP_PASSWORD'],
    #   authentication:       ENV['SMTP_AUTH'],
    #   enable_starttls_auto: ENV['SMTP_ENABLE_STARTTLS_AUTO'] == 'true'
    # }

    # config.action_mailer.default_url_options = {
    #   host: ENV['ACTION_MAILER_HOST']
    # }
    # config.action_mailer.default_options = {
    #   from: ENV['ACTION_MAILER_DEFAULT_FROM']
    # }

    # Set Redis as the back-end for the cache.
    config.cache_store = :redis_store, ENV['REDIS_CACHE_URL']

    # Set Sidekiq as the back-end for Active Job.
    config.active_job.queue_adapter = :sidekiq
    config.active_job.queue_name_prefix =
      "#{ENV['ACTIVE_JOB_QUEUE_PREFIX']}_#{Rails.env}"
      
    config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

    config.time_zone = 'America/Sao_Paulo'
    config.active_record.default_timezone = :local

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.middleware.use Rack::Attack
  end
end
