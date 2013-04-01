class CreateProducts < ActiveRecord::Migration
  def up
    create_table :products do |t|
      #t.references :category
      t.text :name
      t.decimal :price, :precision => 10, :scale => 2
      t.boolean :availability
      t.text :link
      t.text :photo
      t.text :photos
      t.text :short_description
      t.text :description
      t.text :category_link
    end

    add_index :products, :price
    add_index :products, :availability
    add_index :products, [:price, :availability]
    add_index :products, :category_link

    # TODO: create fulltext index on name and description if sphinx won't work
  end

  def down
    drop_table :products
  end
end
