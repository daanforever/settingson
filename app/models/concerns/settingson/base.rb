module Settingson::Base

  extend ActiveSupport::Concern

  included do
    attr_accessor :settingson
  end

  def method_missing(symbol, *args)
    super
  rescue NoMethodError

    case symbol.to_s
    when /(.+)=/  # setter

      @settingson = "#{@settingson}.#{$1}"

      if record = self.class.find_by(name: @settingson)
        record.update(value: args.first.to_yaml)
      else
        self.class.create(name: @settingson, value: args.first.to_yaml)
      end

    else # getter

      @settingson += ".#{symbol.to_s}"
      if record = self.class.find_by(name: @settingson)
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

        if record = find_by(name: @settingson)
          record.update(value: args.first.to_yaml)
        else
          create(name: @settingson, value: args.first.to_yaml, settingson: @settingson)
        end

      else # getter

        if record = find_by(name: symbol.to_s)
          YAML.load record.value
        else
          new(settingson: symbol.to_s)
        end

      end
    end


  end

end