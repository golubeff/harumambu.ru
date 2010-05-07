require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'iconv'
require File.dirname(__FILE__) + '/../lib/sequel_adapter.rb'

class FreeLancingRu
  
  CURRENCIES = { 'руб' => "руб.", "$" => '$', '&euro;' => '€', "FM" => 'FM' }

  def self.desc
    'free-lancing.ru'
  end

  def self.latest
    doc = open('http://free-lancing.ru/').read
    
    resultset = []

    doc.scan(/(<div style="width:96%.+?gorpolbg.gif.+?<\/div>)/m).each do |project|
      args = {}
      project_title = project[0].scan(/class="subject" *>(.+?)<\/td/m)[0][0]
      args[:title] = convert(project_title.scan(/>(.+?)</m)[0][0])
      args[:url] = "http://free-lancing.ru#{project_title.scan(/href="(.+?)"/)[0][0]}"
      args[:remote_id] = args[:url].gsub(/[^\d]/, '')
      args[:desc] = project[0].scan(/class="subject1".+?<\/div>.*?<div.+?>(.+?)<\/div>/m)[0][0]
      args[:created_at] = Time.now
      begin
        budjet = project[0].scan(/pricepan.+?>(.+?)</m)[0][0].gsub(/&#036;/, '$')
        args[:budjet] = budjet.gsub(/[^\d]/, '')
        args[:currency] = budjet.gsub(/[\d ]/, '')
      rescue Exception => e
      end

      category = project[0].scan(/class="subject1".+?<div.+?>(.+?)<\/div>/m)[0][0]
      category = category.scan(/<b>(.+?)<\/b>/)[0][0]

      begin
        args[:category_id] = DB["select id from categories where title ilike E'%#{category}%'"].first[:id]
      rescue Exception => e
        puts e
      end

      resultset << args
    end
    resultset.reverse
  end

  def self.convert(s)
    Iconv.conv('UTF-8//IGNORE', 'UTF-8', s.to_s.force_encoding('UTF-8'))
  end
end
