module Settingson::Base

  extend ActiveSupport::Concern

  included do
    attr_accessor :settingson

    after_find do |setting|
      setting.value = YAML.load(setting.value)
    end
  end

  def to_s
    self.new_record? ? '' : self.value.to_s
  end

  def to_i
    self.new_record? ? 0 : self.value.to_i
  end

  def method_missing(symbol, *args)
    super
  rescue NoMethodError

    case symbol.to_s
    when /(.+)=/  # setter

      @settingson = "#{@settingson}.#{$1}"

      if record = self.class.find_by(key: @settingson) and args.first.nil?
        record.destroy
      elsif record
        record.update(value: args.first.to_yaml)
      else
        self.class.create(key: @settingson, value: args.first.to_yaml)
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

    def method_missing(symbol, *args)
      super
    rescue NoMethodError

      case symbol.to_s
      when /(.+)=/  # setter

        @settingson = $1

        if record = find_by(key: @settingson) and args.first.nil?
          record.destroy
        elsif record
          record.update(value: args.first.to_yaml)
        else
          create(key: @settingson, value: args.first.to_yaml, settingson: @settingson)
        end
  
      when /(.+)\?$/  # 

        find_by(key: $1).present?

      else # getter

        if record = find_by(key: symbol.to_s)
          # YAML.load record.value
          record.value
        else
          new(settingson: symbol.to_s)
        end

      end
    end


  end

end