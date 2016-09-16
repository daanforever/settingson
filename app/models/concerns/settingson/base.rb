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

    # Settings.delete_all
    # Delete cached items before super
    def delete_all
      Rails.cache.delete_matched(/#{self.configure.cache.namespace}/)
      super
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
        Rails.cache.clear
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
    attr_accessor  :settingson
    serialize      :value
    before_destroy :delete_cached
  end

  def delete_cached
    cache_key = "#{self.class.configure.cache.namespace}/#{self.key}"
    Rails.cache.delete(cache_key)
    Rails.logger.debug("#{self.class.name}: delete '#{self.key}' '#{cache_key}'")
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

  def cached_key
    [ self.class.configure.cache.namespace, @settingson ].join('/')
  end

  def rescue_action(key, value)
    case key
    when /(.+)=/  # setter
      @settingson = [@settingson, $1].compact.join('.')
      record = self.class.find_or_create_by!(key: @settingson)
      record.update!(value: value)
      Rails.cache.write(cached_key, value)
      Rails.logger.debug("#{self.class.name}##{__method__} setter '#{cached_key}'")
      record.value
    else # returns values or self
      @settingson = [@settingson, key].compact.join('.')
      Rails.logger.debug("#{self.class.name}##{__method__} getter '#{@settingson}'")
      cached_value_or_self
    end
  end

  def cached_value_or_self
    result = cached_value
    result.is_a?(ActiveRecord::RecordNotFound) ? self : result
  end

  def cached_value
    Rails.logger.debug("#{self.class.name}##{__method__} '#{@settingson}'")
    Rails.cache.fetch(
      cached_key,
      expires_in:         self.class.configure.cache.expires,
      race_condition_ttl: self.class.configure.cache.race_condition_ttl
    ) do
      Rails.logger.debug("#{self.class.name}: fresh '#{@settingson}'")
      fresh_value
    end
  end

  def fresh_value
    self.class.find_by!(key: @settingson).value
  rescue ActiveRecord::RecordNotFound
    ActiveRecord::RecordNotFound.new
  end

end # Settingson::Base
