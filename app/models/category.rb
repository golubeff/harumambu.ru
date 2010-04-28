class Category < ActiveRecord::Base
  scope :top, :conditions => 'category_id is null', :include => [ :categories ]
  has_many :categories
  belongs_to :category

  def self.others
    @others ||= self.find_by_title('Прочее')
  end
end
