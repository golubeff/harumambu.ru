#написан andreyd22  dmitrichev@gmail.com при пинках Паши Голубева golubev.pavel@gmail.com
require 'rubygems'
require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'
require 'hpricot'
require 'iconv'
require 'uri'
require File.dirname(__FILE__) + '/../lib/sequel_adapter.rb'

class GetacoderCom
  
  CURRENCIES = { 'руб' => "руб.", "$" => '$', '&euro;' => '€', "FM" => 'FM' }

  CATEGORIES = {
    "Web Design / Development" => 'Разработка сайтов',
    "Database Development" => 'Архитектура/Инжиниринг',
    "Writing" => 'Тексты',
    "Computer Platforms" => 'Архитектура/Инжиниринг',
    "Engineering" => 'Архитектура/Инжиниринг',
    "Testing / Quality Assurance" => 'Прочее',
    "Project Management" => 'Менеджмент',
    "Enterprise Resource Planning" => 'Консалтинг',
    "Training" => 'Прочее',
    "Programming" => 'Программирование',
    "Graphics / Multimedia" => '3D Графика',
    "Marketing / Promotion" => 'Реклама/Маркетинг',
    "Gaming" => 'Разработка игр',
    "Security" => 'Архитектура/Инжиниринг',
    "Administrative Support" => 'Архитектура/Инжиниринг',
    "Requirements" => 'Прочее',
    "Legal" => 'Прочее',
    "Miscellaneous" => 'Прочее'
  }

  def self.desc
    'getacoder.com'
  end

  def self.latest
    self.rss
  end

  #По идее обновляется почти одновременно с основным выводом (я разницы во времени не заметил)
  def self.rss
    source = "http://getacoder.com/rss.xml" # url or local file
    content = "" # raw content of rss feed will be loaded here
    open(source) do |s| content = s.read end
    #open(source, :proxy=>'http://192.168.0.250:3128') do |s| content = s.read end
    rss = RSS::Parser.parse(content, false)
    
    args = {}
    resultset = []
    #puts convert(doc.to_s)
    rss.items.each do |project_div|
      args = {}
      args[:title] = project_div.title
      link = project_div.link
      id = link.match(/\_(\d+)\.html/)[1].to_i
      last_id = nil
      last_id = DB["select id from projects where remote_id = '#{id}' and klass = 'VWorkerCom'"].first
     
      break if last_id != nil
      
      args[:remote_id] = id
      args[:url] = "#{link}"
      args[:desc] = project_div.description
      args[:created_at] = Time.now
      budjet = nil
      currency = '$'

      doc  = Hpricot(open(URI.escape("#{link}")))
      #doc  = Hpricot(open(URI.escape("#{link}"),:proxy=>'http://192.168.0.250:3128'))
      doc3 = doc.inner_html
      if doc3.match(/<td><small>.+?(\d+)-(\d+)<\/small><\/td>/)
	budjet = doc3.match(/<td><small>.+?(\d+)-(\d+)<\/small><\/td>/)[2]   
      end

      if budjet
        args[:budjet] = budjet
        args[:currency] = CURRENCIES[currency]
      end
      begin
        arr_cat=project_div.description.gsub(/^(.+?)Required Skills: /,"").split(",")
        arr_cat.each do |matched|
    	    category = nil
    	    category = CATEGORIES[matched]
    	    if category
    		#args[:category_name]=category
    		args[:category_id] = DB["select id from categories where title ilike E'%#{category}%'"].first[:id]
    		break
    	    end
        end
      rescue Exception => e
        puts e
      end

      args[:attachments] = []

      resultset << args
    end
    resultset.reverse
  end

  def self.convert(s)
    Iconv.conv('utf-8', 'windows-1251', s.to_s).to_s
  end
  
end
