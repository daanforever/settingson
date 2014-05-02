module Settingson::Base
  extend ActiveSupport::Concern

  module ClassMethods
    def hello
      'hello'
    end
  end
end