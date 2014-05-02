require "settingson/version"

module Settingson
  if defined?(Rails)
    require 'settingson/engine'
  end
end
