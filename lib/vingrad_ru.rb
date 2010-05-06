require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'iconv'
require File.dirname(__FILE__) + '/../lib/sequel_adapter.rb'

class VingradRu
  
  CURRENCIES = { 'руб' => "руб.", "$" => '$', '&euro;' => '€', "FM" => 'FM' }

  def self.desc
    'vingrad.ru'
  end

  def self.latest
    doc = open('http://vingrad.ru/').read
    
    resultset = []
    doc.scan(/(<div *>[^<>]+?<table *width="99%".+?<\/div>[\r\n\s]+<\/div>)/m).each do |project|
      args = {}
      project_title = project[0].scan(/class="project_title" *>(.+?)<\/td/m)[0][0]
      args[:title] = convert(project_title.scan(/>(.+?)</m)[0][0])
      args[:url] = "http://vingrad.ru#{project_title.scan(/href="(.+?)"/)[0][0]}"
      args[:remote_id] = args[:url].gsub(/[^\d]/, '')
      args[:desc] = convert(project[0].scan(/class="project_descr" *>(.+?)</m)[0][0])
      args[:created_at] = Time.now
      category = convert(project[0].scan(/(<td width="250".+?<\/td>)/m)[0][0]).scan(/Категория: (.+?)\n/)[0][0]
      begin
        args[:category_id] = DB["select id from categories where title ilike E'%#{category}%'"].first[:id]
      rescue Exception => e
        puts e
      end
      begin
        budjet = convert(project[0].scan(/class="project_budjet">(.+?)</m)[0][0]).scan(/Бюджет: (.+)/)[0][0]
        args[:budjet] = budjet.gsub(/[^\d]/, '')
        args[:currency] = budjet.gsub(/[\d ]/, '')
      rescue Exception => e
      end

      resultset << args
    end
    resultset.reverse
  end

  def self.convert(s)
    #Iconv.conv('utf-8', 'windows-1251', s).to_s
    Iconv.conv('UTF-8//IGNORE', 'UTF-8', s.to_s.force_encoding('UTF-8'))
  end
end
