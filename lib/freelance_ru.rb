require 'rubygems'
require 'hpricot'
require 'open-uri'

class FreelanceRu

  def self.desc; 'freelance.ru'; end

  def self.latest
    doc = Hpricot(open('http://freelance.ru/'))
    args = {}
    resultset = []
    (doc/"div.proj").each do |project_div|
      args = {}
      args[:title] = convert(project_div.at("h4").inner_html)
      args[:remote_id] = convert(project_div.at("a").attributes['href']).gsub(/projects/,"").gsub(/\//,"")
      args[:url] = "http://freelance.ru/projects/#{args[:remote_id]}/"
      args[:desc] = convert((project_div/".descr").inner_html.to_s)
      stats = project_div.at(".project-stats")
      args[:created_at] = Time.now
      budjet = convert((project_div/'li.cost').inner_html.to_s)
      if budjet
        val = budjet.gsub(/[^\d]+/, '').to_f 
        if val > 0
          args[:budjet] = val
          args[:currency] = "руб."
        end
      end

      args[:attachments] = []

      resultset << args
    end
    resultset.reverse
  end

  def self.convert(s)
    Iconv.conv('utf-8', 'windows-1251', s).to_s
  end
end
