class SetDefaultProjectCategory < ActiveRecord::Migration
  def self.up
    Project.update_all "category_id = #{Category.others.id}", "category_id is null"
    execute "alter table projects alter column category_id set not null"
  end

  def self.down
  end
end
