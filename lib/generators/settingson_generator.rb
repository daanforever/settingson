require 'rails/generators/active_record'
class SettingsonGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration

  source_root File.expand_path('../templates', __FILE__)

  desc "This generator creates a model and its migration"
  def settingson_migration
    klass = name.camelize
    say "Searching for #{klass} class"

    unless Object.const_defined?(klass)
      generate(:model, "#{klass} key:string:uniq value:text --force-plural")
    end

    settingson_inject_lines(name)
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
