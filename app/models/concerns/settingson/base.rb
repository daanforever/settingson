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

    # Settings.defaults do |default|
    #   default.server.host = 'host'
    #   default.server.port = 80
    # end
    def defaults
      @__defaults = Settingson::Store::Default.new( klass: self )

      if block_given?
        Rails.application.config.after_initialize do
          yield @__defaults
        end
      end

      @__defaults
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
      Rails.cache.delete_matched(/#{self.configure.cache.namespace}/)
    end

    def method_missing(symbol, *args)
      super
    rescue NameError, NoMethodError
      Settingson::Store::General.new(klass: self).send(symbol, *args)
    end

  end # module ClassMethods

  included do
    serialize      :value, coder: JSON
    before_destroy :__delete_cached
  end

  def __delete_cached
    cache_key = "#{self.class.configure.cache.namespace}/#{self.key}"
    Rails.cache.delete(cache_key)
  end

end # Settingson::Base
