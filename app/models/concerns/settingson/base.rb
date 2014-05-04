module Settingson::Base

  extend ActiveSupport::Concern

  included do
    attr_accessor :settingson, :name, :value
  end

  def method_missing(symbol, *args)
    Rails.logger.debug("Instance method_missing: #{symbol} #{args.inspect} s:#{@settingson}")
    case symbol.to_s
    when /(.+)=/  # setter

      Rails.logger.debug("\tsetter")
      @settingson = "#{@settingson}.#{$1}"

      if record = self.class.find_by(name: @settingson)
        Rails.logger.debug("\tfound record for #{@settingson}")
        record.update(value: args.first.to_yaml)
      else
        Rails.logger.debug("\trecord not found for #{@settingson}")
        self.class.create(name: @settingson, value: args.first.to_yaml)
      end

    else # getter

      Rails.logger.debug("\tgetter")
      @settingson += ".#{symbol.to_s}"
      if record = self.class.find_by(name: @settingson)
        Rails.logger.debug("\tfound record for #{@settingson}")
        YAML.load(record.value)
      else
        Rails.logger.debug("\trecord not found for #{@settingson}")
        self
      end

    end
  end

  module ClassMethods

    def method_missing(symbol, *args)
      Rails.logger.debug("Class method_missing: #{symbol} #{args.inspect} #{@settingson}")
      case symbol.to_s
      when /(.+)=/  # setter

        Rails.logger.debug("\tsetter")
        @settingson = $1

        if record = find_by(name: @settingson)
          Rails.logger.debug("\tfound record for #{@settingson}")
          record.update(value: args.first.to_yaml)
        else
          Rails.logger.debug("\trecord not found for #{@settingson}")
          create(name: @settingson, value: args.first.to_yaml, settingson: @settingson)
        end

      else # getter

        Rails.logger.debug("\tgetter")
        if record = find_by(name: symbol.to_s)
          Rails.logger.debug("\tfound record for #{@settingson}")
          YAML.load record.value
        else
          Rails.logger.debug("\trecord not found for #{@settingson}")
          new(settingson: symbol.to_s)
        end

      end
    end


  end

end