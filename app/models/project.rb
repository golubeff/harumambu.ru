class Project < ActiveRecord::Base
  default_scope :order => "id desc"

  has_many :attachments, :class_name => "ProjectAttachment"
  validates :klass, :presence => true
  validates :title, :presence => true
  validates :desc, :presence => true

  def budjet_with_currency
    self.currency == '$' ? "#{self.currency}#{self.budjet}" : "#{self.budjet} #{self.currency}"
  end

  def budjet
    self.attributes['budjet'].to_i.to_f == self.attributes['budjet'] ? self.attributes['budjet'].to_i : self.attributes['budjet']
  end
end
