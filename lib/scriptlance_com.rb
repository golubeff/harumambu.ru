require 'hpricot'
require 'open-uri'
require File.dirname(__FILE__) + '/../lib/sequel_adapter.rb'

class ScriptlanceCom
  def self.desc
    'scriptlance.com'
  end

  def self.latest
    doc = Hpricot.XML(open('http://www.scriptlance.com/rss/rss_projects_d.xml'))
    resultset = []
    (doc/:item).each do |project|
      args = {}
      args[:title] = (project/:title).inner_html
      args[:url] = (project/:link).inner_html
      args[:remote_id] = (project/:link).inner_html.gsub(/[^\d]/, '')
      args[:desc] = (project/:description).inner_html
      args[:created_at] = Time.now
      counter = DB["select count(*) from projects where klass = 'ScriptlanceCom' and remote_id like E'#{args[:remote_id]}'"].first[:count].to_i
      next if counter > 0

      puts "#{args[:url]} ..."
      inner_doc = open(args[:url]).read
      puts "done"
      #categories = inner_doc.scan(/<td.+?>.*?Tags:.*?<\/td>.+?<td.+?><td.+?>(.+?)<\/td>.+?<\/td>/m)[0][0]
      #puts "scanned categories"
      #categories = categories.gsub(/<a.+?>(.+?)<\/a>/, '\1')
      #puts "gsubbed categories"
      #p categories.split(/, */)
      #puts "splitted"

      b = Time.now.to_f
      budjet = inner_doc.scan(/<td.+?>.*?Budget:.*?<\/td>.*?<td.+?>(.+?)<\/td>/m)[0][0]
      #puts 
      #p budjet
      resultset << args
    end

    resultset
  end
end
