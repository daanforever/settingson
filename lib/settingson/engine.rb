class Settingson::Engine < ::Rails::Engine
  config.autoload_paths += Dir["#{config.root}/app/models/concerns"]
end
