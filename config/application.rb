require_relative "boot"

require "rails"
# Pick the frameworks you want:
# require "active_model/railtie"
# require "active_job/railtie"
# require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie" # Needed for cucumber-rails 2.1.0
# require "action_mailbox/engine"
# require "action_text/engine"
# require "action_view/railtie"
# require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

if !Rails.env.production? || ENV["HEROKU_APP_NAME"].present?
  require "govuk_publishing_components"
end

module Collections
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "London"

    config.i18n.default_locale = :en
    config.i18n.load_path += Dir[Rails.root.join("config/locales/**/*.yml")]
    config.i18n.fallbacks = true
    config.i18n.available_locales = %i[
      ar
      az
      be
      bg
      bn
      cs
      cy
      da
      de
      dr
      el
      en
      es
      es-419
      et
      fa
      fi
      fr
      gd
      gu
      he
      hi
      hr
      hu
      hy
      id
      is
      it
      ja
      ka
      kk
      ko
      lt
      lv
      ms
      mt
      ne
      nl
      no
      pa
      pa-pk
      pl
      ps
      pt
      ro
      ru
      si
      sk
      sl
      so
      sq
      sr
      sv
      sw
      ta
      th
      tk
      tr
      uk
      ur
      uz
      vi
      yi
      zh
      zh-hk
      zh-tw
    ]

    config.assets.prefix = "/assets/collections/"

    # allow overriding the asset host with an enironment variable, useful for
    # when router is proxying to this app but asset proxying isn't set up.
    config.asset_host = ENV["ASSET_HOST"]

    # Override Rails 6 default which restricts framing to SAMEORIGIN.
    config.action_dispatch.default_headers = {
      "X-Frame-Options" => "ALLOWALL",
    }

    # Using a sass css compressor causes a scss file to be processed twice
    # (once to build, once to compress) which breaks the usage of "unquote"
    # to use CSS that has same function names as SCSS such as max.
    # https://github.com/alphagov/govuk-frontend/issues/1350
    config.assets.css_compressor = nil

    # Rotate SHA1 cookies to SHA256 (the new Rails 7 default)
    # TODO: Remove this after existing user sessions have been rotated
    # https://guides.rubyonrails.org/v7.0/upgrading_ruby_on_rails.html#key-generator-digest-class-changing-to-use-sha256
    Rails.application.config.action_dispatch.cookies_rotations.tap do |cookies|
      salt = Rails.application.config.action_dispatch.authenticated_encrypted_cookie_salt
      secret_key_base = Rails.application.secrets.secret_key_base
      next if secret_key_base.blank?

      key_generator = ActiveSupport::KeyGenerator.new(
        secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA1
      )
      key_len = ActiveSupport::MessageEncryptor.key_len
      secret = key_generator.generate_key(salt, key_len)

      cookies.rotate :encrypted, secret
    end
  end
end
