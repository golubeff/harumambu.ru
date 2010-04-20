module Hpricot
  module Traverse
    def inner_text
      if respond_to?(:children) and children
        children.map { |x| x.inner_text.force_encoding('UTF-8') }.join.force_encoding('UTF-8')
      else
        ""
      end
    end
  end
end
