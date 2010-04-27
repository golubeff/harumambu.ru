#написан andreyd22  dmitrichev@gmail.com при пинках Паши Голубева golubev.pavel@gmail.com
require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'iconv'

class DalanceRu
  
  CURRENCIES = { 'руб' => "руб.", "$" => '$', '&euro;' => '€', "FM" => 'FM' }

  def self.desc
    'dalance.ru'
  end

  def self.latest
    doc = Hpricot(open('http://dalance.ru/'))
    args = {}
    resultset = []
    #puts convert(doc.to_s)
    (doc/"div.main_job_block").each do |project_div|
#      puts convert(project_div.inner_html)
      args = {}
      args[:title] = convert((project_div/"a.job_title").first.inner_html)
      link = (project_div/"a.job_title").first
      id = link.attributes['id'].to_i
      url = link.attributes['href']

      args[:remote_id] = id
      #args[:remote_id] = url.match(/\/[\d]+\/$/)[0].gsub(/[^\d]+/,"")
      args[:url] = "http://dalance.ru/#{url}"
      args[:desc] = convert((project_div/"div.job_content").inner_html).gsub(/<a href.+?$/,"")
      args[:created_at] = Time.now
      budjet = convert((project_div/"span.job_money").inner_html.to_s).gsub(/[^\d\.]+/,"").to_f
      currency = convert((project_div/"span.job_money").inner_html.to_s).gsub(/[\d\.\s]+/,"")
      if budjet
        args[:budjet] = budjet
    	args[:currency] = CURRENCIES[currency]
      end

      #args[:created_at] = convert(stats.children.last.content.gsub(/^(&nbsp;)+/, ''))
      args[:attachments] = []

      resultset << args
    end
    resultset.reverse
  end

  # А вдруг понадобится XML - не думаю, что он раз в 5 минут обновляется. Мне кажется что rss связан с основным выводом
  def self.rss
    doc = Hpricot.XML(open('http://dalance.ru/projects.xml'))
    args = {}
    resultset = []
    #puts convert(doc.to_s)
    (doc/:item).each do |project_div|
#      puts project_div
      args = {}
      args[:title] = convert((project_div/:title).inner_html)
      args[:url] = convert((project_div/:link).inner_html)
      #budjet = convert((project_div/:description).inner_html).to_s.match(/\d+/)[0]
      #currency = convert((project_div/:description).inner_html).to_s.match(/(РУБ|\$)/i)[0]

      args[:desc] = convert((project_div/:description).inner_html)
    
      args[:created_at] = Time.now
    args[:budjet] = 0
    args[:currency] = ""

      #args[:created_at] = convert(stats.children.last.content.gsub(/^(&nbsp;)+/, ''))
      args[:attachments] = []

      resultset << args
    end
    resultset.reverse
  end

  def self.convert(s)
    Iconv.conv('utf-8', 'windows-1251', s).to_s
  end
end
