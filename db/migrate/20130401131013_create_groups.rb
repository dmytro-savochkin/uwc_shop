class CreateGroups < ActiveRecord::Migration
  def up
    create_table :groups, {:id => false} do |t|
      t.text :link
      t.text :name
      t.text :category_link
    end

    execute "CREATE TYPE group_type AS ENUM ('unique', 'non-unique', 'specific');"
    execute "ALTER TABLE groups ADD COLUMN type group_type;"

    add_index :groups, :category_link
  end

  def down
    drop_table :groups
  end
end
