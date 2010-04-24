require 'rubygems'
require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'
require 'iconv'

class FreeLancersNet

  def self.desc; 'free-lancers.net'; end

  def self.latest
    source = "http://free-lancers.net/rss/projects/"
    content = ""
    open(source) do |s| content = s.read end
    rss = RSS::Parser.parse(content, false)
    resultset = []
    rss.items.each do |item|
      resultset << {
        :title => item.title,
        :remote_id => item.link.gsub(/[^\d]/, ''),
        :url => item.link,
        :desc => item.description,
        :created_at => Time.now
      }
    end

    resultset.reverse
  end
end
