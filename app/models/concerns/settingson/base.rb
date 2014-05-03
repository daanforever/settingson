module Settingson::Base

  extend ActiveSupport::Concern

  module ClassMethods

    def method_missing(string, *args)
      if result = find_by(name: string)
        YAML.load result.value
      else
        ::Settingson::Store.new(self, string, *args)
      end
    end

  end

end