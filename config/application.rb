require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module RemoteWind
  class Application < Rails::Application

    # By default, Rails expects app/services/users/delete.rb to define Users::Delete,
    # but we want it to expect Services::Users::Delete.
    # To make this work, we add the app folder to the autoload path
    # @see https://github.com/krautcomputing/services
    config.autoload_paths += [config.root.join('app')]

    # Default in the next version of rails
    config.active_record.raise_in_transactional_callbacks = true

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'UTC'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.generators do |g|
      g.test_framework :rspec
      g.integration_tool :rspec
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
    end

  end
end
