class SettingsonGenerator < Rails::Generators::NamedBase
  desc "This generator creates a model and his migration"
  def create_migration
    generate(:model, "#{name.camelize} name:string value:text")
    inject_into_class "app/models/#{name.downcase}.rb", name.camelize, "\tinclude Settingson::Base\n"
  end
end