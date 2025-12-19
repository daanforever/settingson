require 'ostruct'
require "settingson/version"
require 'settingson/config'

module Settingson
  if defined?(Rails)
    require 'settingson/engine'
    require 'settingson/store'
  end
end
