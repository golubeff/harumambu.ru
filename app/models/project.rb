class Project < ActiveRecord::Base
  default_scope :order => "id desc"

  has_many :attachments, :class_name => "ProjectAttachment"
  belongs_to :category
  validates :klass, :presence => true
  validates :title, :presence => true
  validates :desc, :presence => true

  def budjet_with_currency
    retval = ""
    retval = self.currency == '$' ? "#{self.currency}#{self.budjet}" : "#{self.budjet} #{self.currency}"
    if self.currency == 'руб.' 
      retval = "#{retval} ≈ $#{(self.budjet / 30.0).round}"
    end
    retval
  end

  def budjet
    self.attributes['budjet'].to_i.to_f == self.attributes['budjet'] ? self.attributes['budjet'].to_i : self.attributes['budjet']
  end

  def desc
    self.attributes['desc'].gsub(/[\n\r]/m, '').gsub(/(<br *\/?>)+/m, '<br/>')
  end
end
