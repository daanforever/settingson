require "settingson/version"
require 'settingson/config'

module Settingson
  if defined?(Rails)
    require 'settingson/engine'
    require 'settingson/store'
    require 'settingson/defaults'
  end
end
