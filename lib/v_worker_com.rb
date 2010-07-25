#написан andreyd22  dmitrichev@gmail.com при пинках Паши Голубева golubev.pavel@gmail.com
require 'rubygems'
require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'
require 'hpricot'
require 'iconv'
require 'uri'
require File.dirname(__FILE__) + '/../lib/sequel_adapter.rb'

class VWorkerCom
  
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
    'vworker.com'
  end

  def self.latest
    self.rss
  end

  #По идее обновляется почти одновременно с основным выводом (я разницы во времени не заметил)
  def self.rss
    source = "http://www.vworker.com/RentACoder/misc/LinkToUs/RssFeed_newBidRequests.asp" # url or local file
    content = "" # raw content of rss feed will be loaded here
    open(source) do |s| content = s.read end
    #open(source, :proxy=>'http://192.168.0.250:3128') do |s| content = s.read end
    rss = RSS::Parser.parse(content, false)
    
    args = {}
    resultset = []
    #puts convert(doc.to_s)
    rss.items.each do |project_div|
      args = {}
      
      args[:title] = project_div.title.split("--")[0]
      #puts args[:title]
      link = project_div.link
      id = link.match(/lngBidRequestId=(\d+)/)[1].to_i
      last_id = nil
      last_id = DB["select id from projects where remote_id = '#{id}' and klass = 'VWorkerCom'"].first
     
      break if last_id != nil
      
      args[:remote_id] = id
      args[:url] = "#{link}"
      args[:desc] = project_div.description
      args[:created_at] = Time.now
      budjet = nil
      currency = '$'

      if project_div.title.split("--")[2].match(/Max Bid: \$(\d+)/)
        budjet = project_div.title.split("--")[2].match(/Max Bid: \$(\d+)/)[1]   
      end

      if budjet
        args[:budjet] = budjet
        args[:currency] = CURRENCIES[currency]
      end
      begin
    	    category = CATEGORIES['Miscellaneous']
    	    #args[:category_name]=category
    	    args[:category_id] = DB["select id from categories where title ilike E'%#{category}%'"].first[:id]
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
