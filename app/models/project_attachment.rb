class ProjectAttachment < ActiveRecord::Base
  belongs_to :project
  validates :project, :presence => true, :associated => true
  validates :title, :presence => true
  validates :url, :presence => true
end
