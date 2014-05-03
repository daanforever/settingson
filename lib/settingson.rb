require "settingson/version"

module Settingson
  if defined?(Rails)
    require 'settingson/engine'
    require 'settingson/store'
  end
end
