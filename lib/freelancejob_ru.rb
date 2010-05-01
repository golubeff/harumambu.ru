#написан andreyd22  dmitrichev@gmail.com при пинках Паши Голубева golubev.pavel@gmail.com
require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'iconv'
require File.dirname(__FILE__) + '/../lib/sequel_adapter.rb'

class FreelancejobRu

  def self.desc; 'freelancejob.ru'; end
  
  CATEGORIES = {
     "3D Графика/Анимация" => "3D Графика",
     "Архитектура/Инжиниринг" => 'Архитектура/Инжиниринг',
     "Аудио/Видео" => 'Аудио/Видео',
     "Верстка полиграфии" => 'Полиграфия',
     "Верстка сайтов" => 'Разработка сайтов',
     "Дизайн полиграфии" => 'Полиграфия',
     "Дизайн сайтов" => "Дизайн",
     "Иллюстрации" => "Арт",
     "Консалтинг" => "Консалтинг",
     "Креатив/Арт" => "Арт",
     "Менеджмент" => "Менеджмент",
     "Моделирование экстерьера" => "3D Графика",
     "Написание текстов" => "Тексты",
     "Оптимизация (SEO)" => "Оптимизация (SEO)",
     "Переводы" => "Переводы",
     "Полиграфия" => "Полиграфия",
     "Программирование" => "Программирование",
     "Разработка игр" => "Разработка игр",
     "Разработка логотипа" => "Дизайн",
     "Разработка сайтов" => "Разработка сайтов",
     "Разработка фирменного стиля" => "Дизайн",
     "Реклама/Маркетинг" => "Реклама/Маркетинг",
     "Тексты" => "Тексты",
     "Флеш" => "Флеш",
     "Фотография" => "Фотография"
  }

  CURRENCIES = { 'РУБ' => "руб.", "$" => '$', '&euro;' => '€', "FM" => 'FM' }

  def self.latest
    doc = Hpricot(open('http://freelancejob.ru/'))
    args = {}
    resultset = []
    #puts convert(doc.to_s)
    (doc/"div.act2").each do |project_div|
#      puts project_div
      args = {}
      args[:title] = convert((project_div/"a").first.inner_html)
      args[:remote_id] = (project_div/"a").first.attributes['href']
      args[:url] = "http://freelancejob.ru#{args[:remote_id]}"
      args[:desc] = convert((project_div/"p").first.inner_html.to_s).gsub(/^(<br *\/?>)+/m, '').gsub(/(<br *\/?>)+$/m, '')
      begin
        matched = convert((project_div/"p")[1].inner_text).scan(/Категория: ([^|]+) |/)[0][0]
        category = CATEGORIES[matched]
        args[:category_id] = DB["select id from categories where title ilike E'%#{category}%'"].first[:id]
      rescue
      end
      args[:created_at] = Time.now
      budjet = convert((project_div/"i").inner_html.to_s)
      currency = convert((project_div/"u").inner_html.to_s)
      if budjet
        value = budjet.gsub(/[^\d]+/, '').to_f
        if value > 0
          args[:budjet] = budjet.gsub(/[^\d]+/, '').to_f
          args[:currency] = currency
        end
      end

      #args[:created_at] = convert(stats.children.last.content.gsub(/^(&nbsp;)+/, ''))
      args[:attachments] = []

      resultset << args
    end
    resultset.reverse
  end

  # А вдруг понадобится XML - не думаю, что он раз в 5 минут обновляется. Мне кажется что rss связан с основным выводом
  #def self.latest
    #doc = Hpricot.XML(open('http://freelancejob.ru/rss.php'))
    #args = {}
    #resultset = []
    ##puts convert(doc.to_s)
    #(doc/:item).each do |project_div|
##      puts project_div
      #args = {}
      #args[:title] = convert((project_div/:title).inner_html)
      #args[:url] = convert((project_div/:link).inner_html)
      #budjet = convert((project_div/:description).inner_html).to_s.match(/\d+/)[0]
      #currency = convert((project_div/:description).inner_html).to_s.match(/(РУБ|\$)/i)[0]

      #args[:desc] = convert((project_div/:description).inner_html).to_s.gsub(/\<\!\[CDATA\[Бюджет: (\d+)(РУБ|\$)\s+Предоплата имеется\s+<br\/>/i,"").gsub(/\]\]\>/,"")

      #args[:created_at] = Time.now
      #if budjet
        #args[:budjet] = budjet.to_f
    	#args[:currency] = CURRENCIES["#{currency}"]
      #end

      ##args[:created_at] = convert(stats.children.last.content.gsub(/^(&nbsp;)+/, ''))
      #args[:attachments] = []

      #resultset << args
    #end
    #resultset.reverse
  #end

  def self.convert(s)
    Iconv.conv('utf-8', 'windows-1251', s).to_s
  end
end
