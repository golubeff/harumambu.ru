require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'iconv'
require File.dirname(__FILE__) + '/../lib/sequel_adapter.rb'

class NetlancerRu
  
  CATEGORIES = {
    'C/C++' => "Программирование",
    'Delphi' => "Программирование",
    "Java" => "Программирование",
    "JSP" => "Программирование",
    '.NET' => "Программирование",
    'PHP/Perl/CGI' => "Программирование",
    "ASP" => "Программирование",
    "Python" => "Программирование",
    "Visual Basic" => "Программирование",
    "Javascript" => "Программирование",
    "Windows-проекты" => "Программирование",
    "Linux-проекты" => "Программирование",
    "Разработка ПО" => "Программирование",
    "Разработка БД" => "Программирование",
    "HTML" => "Создание сайтов",
    "XML" => "Программирование",
    "Web" => "Создание сайтов",
    "Мобильные устройства" => "Программирование",
    "Мультимедиа проекты" => "Программирование",
    "Графика" => "Арт",
    "Фотография" => "Фотография",
    "Дизайн" => "Дизайн",
    "Логотипы" => "Дизайн",
    "Flash" => "Флеш",
    "Photoshop" => "Дизайн",
    "Web-дизайн" => "Дизайн",
    "Баннеры" => "Дизайн",
    "Создание сайтов" => "Создание сайтов",
    "Продвижение сайтов" => 'Оптимизация (SEO)',
    'SEO' => "Оптимизация (SEO)",
    'Перевод текста' => "Переводы",
    "Написание статей" => "Тексты",
    "Набор текста" => "Тексты",
    "Копирайтинг" => "Тексты"
  }

  def self.desc
    'netlancer.ru'
  end

  def self.latest
    doc = Hpricot(open('http://netlancer.ru/'))
    resultset = []

    projects_table = doc/"/html/body/table[4]/tr/td[2]/table[3]/tr[2]/td/table"

    #puts convert(doc.to_s)
    (projects_table/"tr").each do |project_row|
      args = {}
      next if project_row.at("td").attributes['class'] == 'td_LightHeader'

      args[:title] = convert((project_row/'td')[0].inner_text).chomp.strip
      #puts args[:title]
      args[:url] = "http://netlancer.ru#{((project_row/'td')[0]/"a").first.attributes['href']}"
      #puts args[:url]
      proj_doc = convert(open(args[:url]).read)
      begin
        args[:desc] = proj_doc.scan(/Описание:.+?<TD>(.+?)<\/TD>/m)[0][0].gsub(/\r/, '')
      rescue Exception => e
        #puts "#{e} #{args[:url]} #{e.backtrace}"
      end
      args[:remote_id] = args[:url].gsub(/[^\d]/, '')
      #puts args[:remote_id]
      args[:created_at] = Time.now
      args[:budjet] = convert((project_row/"td")[1].inner_text).gsub(/[^\d]/, '')
      args[:currency] = "руб."
      begin
        categories = convert((project_row/'td')[3].inner_text).split(', ').map{|it| it.chomp.strip}
        categories.each do |category|
          if CATEGORIES[category]
            args[:category_id] = DB["select id from categories where title ilike E'%#{CATEGORIES[category]}%'"].first[:id]
            break
          end
        end
      rescue
      end

      resultset << args
    end
    resultset.reverse
  end

  def self.convert(s)
    Iconv.conv('utf-8', 'windows-1251', s).to_s
  end
end
