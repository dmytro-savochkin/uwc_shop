class CreateCategories < ActiveRecord::Migration
  def up
    create_table :categories, {:id => false} do |t|
      t.text :name
      t.text :link
      t.references :faction
    end
    add_index :categories, :link
  end

  def down
    drop_table :categories
  end
end
