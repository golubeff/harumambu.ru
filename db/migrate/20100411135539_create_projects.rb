class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :currencies do |t|
      t.string :title, :null => false
      t.float :rur_exchange, :null => false
    end
    
    create_table :projects do |t|
      t.string :klass, :null => false
      t.string :title, :null => false
      t.text :desc, :null => true
      t.timestamps
      t.float :budjet
      t.string :currency
      t.string :url
      t.string :remote_id, :references => nil
    end

    add_index :projects, [ :klass, :remote_id ], :unique => true

    create_table :project_attachments do |t|
      t.integer :project_id, :on_delete => :cascade, :on_update => :cascade, :null => false
      t.string :title, :null => false
      t.string :url, :null => false
    end
  end

  def self.down
    drop_table :project_attachments
    drop_table :projects
    drop_table :currencies
  end
end
