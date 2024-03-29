require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Zite
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.page_caching = false
    mail_config = (YAML::load( File.open(config.root + 'config/auth_mail.yml') ))
    config.action_mailer.smtp_settings = 
      mail_config["server"].merge(mail_config["credentials"]).symbolize_keys
    config.action_mailer.raise_delivery_errors = true
    captcha_config = (YAML::load( File.open(config.root + 'config/captcha_config.yml') ))
    config.captcha_secret = captcha_config["secret"]	
    config.captcha_good_test_token = captcha_config["good-test-token"]
    config.captcha_bad_test_token = captcha_config["bad-test-token"]

    config.active_storage.service = :local
	
  end
end
