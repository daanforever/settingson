class SettingsonGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration

  source_root File.expand_path('../templates', __FILE__)

  desc "This generator creates a model and its migration"
  def settingson_migration
    if defined?(Settings)

      settingson_inject_lines(name)

      if Settings.column_names.include?('name')
        migration_template 'migrations/rename_name_to_key_on_settings.rb', 'db/migrate/rename_name_to_key_on_settings.rb'
      end

    else
      generate(:model, "#{name.camelize} key:string value:text")
      settingson_inject_lines(name)
    end
  end

  def self.next_migration_number dirname
    ActiveRecord::Generators::Base.next_migration_number dirname
  end

  private
  def settingson_inject_lines(name)
    if File.readlines("app/models/#{name.downcase}.rb").grep(/\A\s*include Settingson::Base\z/).blank?
      inject_into_class "app/models/#{name.downcase}.rb", name.camelize, "\tinclude Settingson::Base\n"
    end
  end
end