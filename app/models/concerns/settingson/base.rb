module Settingson::Base

  extend ActiveSupport::Concern

  included do
    attr_accessor :settingson
  end

  def to_s
    self.new_record? ? '' : super
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

    else # getter

      @settingson += ".#{symbol.to_s}"
      if record = self.class.find_by(key: @settingson)
        YAML.load(record.value)
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

        if record = find_by(key: @settingson)
          record.update(value: args.first.to_yaml)
        else
          create(key: @settingson, value: args.first.to_yaml, settingson: @settingson)
        end

      else # getter

        if record = find_by(key: symbol.to_s)
          YAML.load record.value
        else
          new(settingson: symbol.to_s)
        end

      end
    end


  end

end