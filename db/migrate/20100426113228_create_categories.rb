class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :title
      t.integer :category_id, :on_delete => :cascade, :on_update => :cascade
    end
    add_column :projects, :category_id, :integer, :null => true, :on_delete => :cascade, :on_update => :cascade
  end

  def self.down
    remove_column :projects, :category_id
    drop_table :categories
  end
end
