module Settingson::Base

  extend ActiveSupport::Concern

  module ClassMethods

    # Settings.configure do |config|
    #   config.cache.expires = 600   # default: 600
    #   config.cache.enabled = true  # default: true
    # end
    #
    # # or
    #
    # Settings.configure.cache.expires = 600
    # Settings.configure.cache.enabled = true
    def configure
      @_settings ||= ::Settingson::Config.new
      yield @_settings if block_given?
      @_settings
    end

    # Settings.defaults do |settings|
    #   settings.server.host = 'host'
    #   settings.server.port = 80
    # end
    def defaults
      Rails.application.config.after_initialize do
        begin
          yield new(search_path: '__defaults') if block_given?
        # rescue
        #   Rails.logger.warn('Settingson::defaults failed')
        end
      end
      true
    end

    # Settings.delete_all
    # Delete cached items before super
    def delete_all
      Rails.cache.delete_matched(/#{self.configure.cache.namespace}/)
      super
    end

    # Settings.from_hash('smtp.host' => 'host')
    # Settings.smtp.host
    def from_hash(attributes)
      case attributes
      when Hash
        attributes.map{|k,v| find_or_create_by(key: k).update!(value: v)}
        Rails.cache.clear
        true
      else
        raise ArgumentError, 'Hash required', caller
      end
    end

    # Custom hook for clear cache before delete_all
    #
    def delete_all
      super
      cache_key = "#{self.class.configure.cache.namespace}/#{self.key}"
      Rails.cache.delete(cache_key)
      __debug("#{self.class.name}: delete '#{self.key}' '#{cache_key}'")
    end

    def method_missing(symbol, *args)
      super
    rescue NameError, NoMethodError
      Settingson::Store.new.send(symbol, *args)
    end

  end # module ClassMethods

  included do
    serialize      :value
  end

end # Settingson::Base
