class RenameNameToKeyOnSettings < ActiveRecord::Migration
  def change
    rename_column :settings, :name, :key
  end
end
