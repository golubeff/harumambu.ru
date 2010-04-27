class Category < ActiveRecord::Base
  scope :top, :conditions => 'category_id is null', :include => [ :categories ]
  has_many :categories
  belongs_to :category
end
