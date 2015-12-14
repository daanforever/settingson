module Settingson::Base

  extend ActiveSupport::Concern

  module ClassMethods

    # Settings.defaults do
    #   Settings.server.host? || Settings.server.host = 'host'
    #   Settings.server.port? || Settings.server.port = 80
    # end

    def defaults
      Rails.application.config.after_initialize do
        begin
          yield
        rescue
          Rails.logger.warn('Settingson::defaults failed')
        end
      end
    end

    def from_hash(attributes)
      case attributes
      when Hash
        attributes.map{|k,v| find_or_create_by(key: k).update!(value: v)}
      else
        false
      end
    end

    def cached(expires_in = 10.seconds)
      new._settingson_cached(expires_in)
    end

    def method_missing(symbol, *args)
      super
    rescue NoMethodError
      case symbol.to_s
      when /(.+)=/  # setter
        self.find_or_create_by(
          key: $1
        ).update(
          value: args.first
        )
      when /(.+)\?$/  # returns boolean
        find_by(key: $1).present?
      when /(.+)\!$/  # returns self or nil
        find_by(key: $1)
      else # getter
        record = find_by(key: symbol.to_s)
        record ? record.value : new(settingson: symbol.to_s)
      end
    end

  end # module ClassMethods

  included do
    attr_accessor :settingson
    serialize     :value
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

  def _settingson_cached(expires_in)
    @_settingson_cached = expires_in
    self
  end

  def method_missing(symbol, *args)
    super
  rescue NoMethodError
    case symbol.to_s
    when /(.+)=/  # setter
      _settingson_variable_update($1)
      self.class.find_or_create_by(key: @settingson).update(value: args.first)
      Rails.cache.delete("settingson_cache/#{@settingson}")
    when /(.+)\?$/  # returns boolean
      _settingson_variable_update($1)
      _settingson_value.present?
    when /(.+)\!$/  # returns self or nil
      _settingson_variable_update($1)
      _settingson_value
    else # returns values or self
      _settingson_variable_update(symbol.to_s)
      record = _settingson_value
      record ? record.value : self
    end
  end # method_missing

  protected
  def _settingson_fresh_value
    self.class.find_by(key: @settingson)
  end

  def _settingson_cached_value
    Rails.cache.fetch("settingson_cache/#{@settingson}", expires_in: @_settingson_cached) do
      _settingson_fresh_value
    end
  end

  def _settingson_value
    if @_settingson_cached
      _settingson_cached_value
    else
      _settingson_fresh_value
    end
  end

  def _settingson_variable_update(key)
    if @settingson.blank?
      @settingson = key
    else
      @settingson += ".#{key}"
    end
  end

end # Settingson::Base
