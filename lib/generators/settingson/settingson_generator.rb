require 'rails/generators/active_record'
class SettingsonGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration

  source_root File.expand_path('../templates', __FILE__)

  desc "This generator creates a model and its migration"
  def settingson_migration
    klass = name.camelize
    say "Searching for #{klass} class"
    if Object.const_defined?(klass)

      settingson_inject_lines(name)

      if klass.constantize.column_names.include?('name')
        migration_template 'migrations/rename_name_to_key_on_settings.rb', 'db/migrate/rename_name_to_key_on_settings.rb'
      end

    else
      generate(:model, "#{klass} key:string:uniq value:text --force-plural")
      settingson_inject_lines(name)
    end
  end

  def self.next_migration_number dirname
    ActiveRecord::Generators::Base.next_migration_number dirname
  end

  private
  def settingson_inject_lines(name)
    file = Rails.root.join("app/models/#{name.downcase}.rb")
    if File.readlines(file).grep(/\A\s*include Settingson::Base\z/).blank?
      inject_into_class file, name.camelize, "\tinclude Settingson::Base\n"
    end
  end
end
