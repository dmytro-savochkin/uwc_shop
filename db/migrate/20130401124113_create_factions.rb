class CreateFactions < ActiveRecord::Migration
  def up
    create_table :factions do |t|
      t.text :name
      t.text :link
    end
  end

  def down
    drop_table :factions
  end
end
