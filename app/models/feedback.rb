class Feedback
  attr_accessor :message
  def initialize(options={})
    #options[:message] ||= "Предложения и комментарии пишите сюда!"
    options.each do |k, v|
      self.send("#{k}=", v)
    end
  end
end
