module Settingson::Base

  extend ActiveSupport::Concern

  module ClassMethods

    def method_missing(string, *args)
      ::Settingson::Store.new(self, string, *args)
    end

  end

end