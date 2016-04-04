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

    def method_missing(symbol, *args)
      super
    rescue NameError
      self.new.send(symbol, *args)
    rescue NoMethodError
      self.new.send(symbol, *args)
    end


  end # module ClassMethods

  included do
    attr_accessor :settingson
    serialize     :value
    before_destroy :delete_cached
  end

  def delete_cached
    Rails.cache.delete("#{self.class.configure.cache.namespace}/#{self.key}")
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
  rescue NameError
    rescue_action(symbol.to_s, args.first)
  rescue NoMethodError
    rescue_action(symbol.to_s, args.first)
  end # method_missing

  protected
  def rescue_action(key, value)
    case key
    when /(.+)=/  # setter
      @settingson = [@settingson, $1].compact.join('.')
      record = self.class.find_or_create_by(key: @settingson)
      record.update(value: value)
      Rails.cache.write("#{self.class.configure.cache.namespace}/#{@settingson}", record)
    else # returns values or self
      @settingson = [@settingson, key].compact.join('.')
      cached = cached_value
      cached ? cached.value : self
    end
  end

  def cached_value
    Rails.cache.fetch(
      "#{self.class.configure.cache.namespace}/#{@settingson}",
      expires_in:         self.class.configure.cache.expires,
      race_condition_ttl: self.class.configure.cache.race_condition_ttl
    ) do
      Rails.logger.debug("#{self.class.name}: fresh '#{@settingson}'")
      self.class.find_by(key: @settingson)
    end
  end
end # Settingson::Base
