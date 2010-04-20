class Notifier < ActionMailer::Base
  default :from => "haramambu@haramambu.ru"

  def feedback(message)
    @message = message
    mail(:to => 'pavel@golubeff.ru', :subject => "haramambu.ru")
  end
end
