class CreateGroupValues < ActiveRecord::Migration
  def up
    create_table :group_values do |t|
      t.text :name
      t.text :products
      t.text :category_link
      t.text :group_link
    end
    add_index :group_values, :category_link
    add_index :group_values, [:category_link, :group_id]
    add_index :group_values, [:category_link, :group_id, :id]

    # TODO: work it out
    # execute "ALTER TABLE group_values ADD PRIMARY KEY (category_id, group_id, id);"
  end

  def down
    drop_table :group_values
  end
end
