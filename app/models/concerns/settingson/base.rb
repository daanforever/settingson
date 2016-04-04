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
    # Settings.configure.expires = 600
    # Settings.configure.enabled = true

    def configure
      @_settings ||= ::Settingson::Config.new
      yield @_settings if block_given?
      @_settings
    end

    # Settings.defaults do |settings|
    #   settings.server.host = 'host'
    #   settings.server.port = 80
    # end
    # FIXME: not ready yet
    def defaults
      Rails.application.config.after_initialize do
        begin
          yield new(settingson: 'defaults') if block_given?
        rescue
          Rails.logger.warn('Settingson::defaults failed')
        end
      end
      true
    end

    # Settings.from_hash('smtp.host' => 'host')

    def cached(*args)
      ActiveSupport::Deprecation.warn('Now caching is enabled by default')
      self.new
    end

    def from_hash(attributes)
      case attributes
      when Hash
        attributes.map{|k,v| find_or_create_by(key: k).update!(value: v)}
        true
      else
        raise ArgumentError, 'Hash required', caller
      end
    end

    def cached_value(key)
      Rails.cache.fetch(
        "#{configure.cache.namespace}/#{key}",
        expires_in:         configure.cache.expires,
        race_condition_ttl: configure.cache.race_condition_ttl
      ) do
        Rails.logger.debug("#{name}: cached_value query '#{key}'")
        find_by(key: key)
      end
    end

    def method_missing(symbol, *args)
      super
    rescue NoMethodError
      case symbol.to_s
      when /(.+)=/  # setter
        Rails.logger.debug("#{name}: class method_missing setter '#{$1}'")
        record = find_or_create_by(key: $1)
        record.update(value: args.first)
        Rails.cache.write("#{configure.cache.namespace}/#{$1}", record)
      else # getter
        Rails.logger.debug("#{name}: class method_missing getter '#{symbol.to_s}'")
        record = cached_value(symbol.to_s)
        record ? record.value : new(settingson: symbol.to_s)
      end
    end

  end # module ClassMethods

  included do
    attr_accessor :settingson
    serialize     :value
    before_destroy :delete_from_cache
  end

  def delete_from_cache
    Rails.cache.delete("#{configure.cache.namespace}/#{self.key}")
    Rails.logger.debug("#{self.class.name}: instance delete_from_cache '#{self.key}'")
  end

  def to_s
    self.new_record? ? '' : super
  end

  def inspect
    self.new_record? ? '""' : super
  end

  def to_i
    self.new_record? ? 0 : super
  end

  def nil?
    self.new_record? ? true : super
  end

  alias empty? nil?

  def method_missing(symbol, *args)
    super
  rescue NoMethodError
    case symbol.to_s
    when /(.+)=/  # setter
      Rails.logger.debug("#{self.class.name}: instance method_missing setter '#{$1}'")
      @settingson = [@settingson, $1.to_s].join('.')
      record = self.class.find_or_create_by(key: @settingson)
      record.update(value: args.first)
      Rails.cache.write("#{configure.cache.namespace}/#{@settingson}", record)
    else # returns values or self
      Rails.logger.debug("#{self.class.name}: instance method_missing getter '#{symbol.to_s}'")
      @settingson = [@settingson, symbol.to_s].join('.')
      record = self.class.cached_value(@settingson)
      record ? record.value : self
    end
  end # method_missing

end # Settingson::Base
