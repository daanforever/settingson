module Settingson::Base

  extend ActiveSupport::Concern

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

  def _settingson_fresh_value
    self.class.find_by(key: @settingson)
  end

  def _settingson_cached(expires_in)
    @_settingson_cached = expires_in
    self
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

  def _settingson_find_or_create(key)
    if @settingson.blank?
      @settingson = key
    else
      @settingson += ".#{key}"
    end
  end

  def method_missing(symbol, *args)
    super
  rescue NoMethodError

    case symbol.to_s
    when /(.+)=/  # setter

      _settingson_find_or_create($1)

      if args.first.nil? and record = _settingson_fresh_value
        record.destroy
      elsif record = _settingson_fresh_value
        record.update!(value: args.first)
      else
        self.class.create(key: @settingson, value: args.first)
      end

      Rails.cache.delete("settingson_cache/#{@settingson}")

    when /(.+)\?$/  # returns boolean

      _settingson_find_or_create($1)
      _settingson_value.present?

    when /(.+)\!$/  # returns self or nil

      _settingson_find_or_create($1)
      _settingson_value

    else # returns values or self

      _settingson_find_or_create(symbol.to_s)

      if record = _settingson_value
        record.value
      else
        self
      end

    end
  end

  module ClassMethods

    # Settings.defaults do
    #   Settings.server.host? || Settings.server.host = 'host'
    #   Settings.server.port? || Settings.server.port = 80
    # end

    def defaults(&block)
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

    def method_missing(symbol, *args)
      super
    rescue NoMethodError

      case symbol.to_s
      when /(.+)=/  # setter

        @settingson = $1

        if record = find_by(key: @settingson) and args.first.nil?
          record.destroy
        elsif record
          record.update(value: args.first)
        else
          self.create(key: @settingson,
                      value: args.first,
                      settingson: @settingson)
        end
      when /(.+)\?$/  # returns boolean
        find_by(key: $1).present?
      when /(.+)\!$/  # returns self or nil
        find_by(key: $1)
      else # getter

        if record = find_by(key: symbol.to_s)
          record.value
        else
          new(settingson: symbol.to_s)
        end

      end
    end

    def cached(expires_in = 10.seconds)
      new._settingson_cached(expires_in)
    end

  end # module ClassMethods

end
