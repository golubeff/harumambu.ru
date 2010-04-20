module WillPaginate
  module ViewHelpers
    self.pagination_options[:previous_label] = '&#8592; Назад'
    self.pagination_options[:next_label] = 'Вперед &#8594;'
  end
end

class ActiveRecord::Base
  cattr_accessor :per_page
  @@per_page = 5
end
