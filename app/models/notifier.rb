class Notifier < ActionMailer::Base
  default :from => "harumambu@harumambu.ru"

  def feedback(message)
    @message = message
    mail(:to => 'pavel@golubeff.ru', :subject => "harumambu.ru")
  end
end
