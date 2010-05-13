#написан andreyd22  dmitrichev@gmail.com при пинках Паши Голубева golubev.pavel@gmail.com
require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'iconv'
require File.dirname(__FILE__) + '/../lib/sequel_adapter.rb'

class FreelanceTomskRu
  
  CURRENCIES = { 'руб' => "руб.", "$" => '$', '&euro;' => '€', "FM" => 'FM' }

  CATEGORIES = {
    "Разработка сайтов" => "Разработка сайтов",
    "Программирование" => "Программирование",
    "Переводы/Тексты" => "Тексты",
    "Дизайн/Арт" => "Дизайн",
    "Реклама/Маркетинг" => "Реклама/Маркетинг",
    "Прочее" => "Прочее",
    "Нет раздела" => "Прочее"
 
  }

  def self.desc
    'freelance.tomsk.ru'
  end

  def self.latest
    doc = Hpricot(open('http://freelance.tomsk.ru/'))
    args = {}
    resultset = []
    #puts convert(doc.to_s)
    (doc/"li.comment").each do |project_div|
      args = {}
      args[:title] = convert((project_div/"a")[1].inner_html)
      link = (project_div/"a").first
      id = link.attributes['href'].match("\/vacancy\/([^\d]+)\/")[1].to_i.to_s
      url = link.attributes['href']

      args[:remote_id] = id
      args[:url] = "#{url}"
      args[:desc] = convert((project_div/"div.message").inner_html)
      args[:created_at] = Time.now
      budjet = nil
      currency = nil
      if budjet
        args[:budjet] = budjet
        args[:currency] = CURRENCIES[currency]
      end
      begin
        matched = convert(project_div.at("div.l").inner_html).match("Раздел:\s{0,1}(.+?)$")[1].chomp.strip
        category = CATEGORIES[matched]
        #args[:category_name]=category
        args[:category_id] = DB["select id from categories where title ilike E'%#{category}%'"].first[:id]
      rescue Exception => e
        puts e
      end

      args[:attachments] = []
        (project_div/"div.attach").each do |attachment|
          args[:attachments] << {
            :url => attachment.at("a")['href'],
            :title => convert((attachment/"span.bg_r").inner_html.to_s)
          }
      end

      resultset << args
    end
    resultset.reverse
  end

  # А вдруг понадобится XML - не думаю, что он раз в 5 минут обновляется. Мне кажется что rss связан с основным выводом
  def self.rss
    self.latest
  end

  def self.convert(s)
    Iconv.conv('utf-8', 'windows-1251', s.to_s).to_s
  end
  
end
