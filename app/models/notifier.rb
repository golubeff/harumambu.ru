class Notifier < ActionMailer::Base
  def feedback(message)
    @message = message
    mail(:to => 'pavel@golubeff.ru', :subject => "haramambu.ru")
  end
end
