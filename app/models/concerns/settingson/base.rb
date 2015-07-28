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

  def method_missing(symbol, *args)
    super
  rescue NoMethodError

    case symbol.to_s
    when /(.+)=/  # setter

      if not defined?(@settingson) or @settingson.blank?
        @settingson = $1
      else
        @settingson += ".#{$1}"
      end

      if record = self.class.find_by(key: @settingson) and args.first.nil?
        record.destroy
      elsif record
        record.update(value: args.first)
      else
        self.class.create(key: @settingson, value: args.first)
      end

    when /(.+)\?$/  # returns boolean
      @settingson = "#{@settingson}.#{$1}"
      self.class.find_by(key: @settingson).present?
    when /(.+)\!$/  # returns self or nil
      @settingson = "#{@settingson}.#{$1}"
      self.class.find_by(key: @settingson)
    else # returns values or self

      if not defined?(@settingson) or @settingson.blank?
          @settingson = "#{symbol.to_s}"
      else
          @settingson += ".#{symbol.to_s}"
      end

      if record = self.class.find_by(key: @settingson)
        record.value
      else
        self
      end

    end
  end

  module ClassMethods

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
          create(key: @settingson, value: args.first, settingson: @settingson)
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


  end

end
