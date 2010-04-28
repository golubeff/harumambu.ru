require 'hpricot'
require 'open-uri'
require 'iconv'
require File.dirname(__FILE__) + '/../lib/sequel_adapter.rb'

class FreeLanceRu

  def self.desc
    'free-lance.ru'
  end

  CURRENCIES = { 'Р.' => "руб.", "$" => '$', '&euro;' => '€', "FM" => 'FM' }

  def self.latest
    doc = Hpricot(open('http://free-lance.ru/'))

    #doc = Hpricot(open('http://free-lance.ru/'))
    args = {}
    resultset = []
    threads = []
    (doc/".project-preview").each do |project_div|
      args = {}
      args[:title] = convert(project_div.at("h3").children.last.innerHTML)
      args[:remote_id] = convert((project_div/"h3").at("a").attributes['name']).gsub(/prj/, '')

      #puts "select count(*) from projects where klass = 'FreeLanceRu' and remote_id like E'#{args[:remote_id]}'"
      counter = DB["select count(*) from projects where klass = 'FreeLanceRu' and remote_id like E'#{args[:remote_id]}'"].first[:count].to_i
      #puts "counter: #{counter.inspect}"
      next if counter > 0

      puts "#{args[:title]} #{args[:remote_id]}"
      args[:url] = "http://free-lance.ru/projects/?pid=#{args[:remote_id]}"

      inner_doc = convert(open(args[:url]).read)
      category = inner_doc.scan(/Раздел: *(.+?) *<\/div/m)[0]
      category = category[0].gsub(/&nbsp;/, ' ').gsub(/ \/.+$/, '') unless category.nil?
      begin
        if category
          args[:category_id] = DB["select id from categories where title ilike E'%#{category}%'"].first[:id]
        end
      rescue
      end

      args[:desc] = convert((project_div/".project-preview-desc"/"p").to_s)
      stats = project_div.at(".project-stats")
      args[:created_at] = Time.now
      budjet = project_div.at('.project-budjet')
      if budjet
        budjet_string = convert(budjet.at("nobr").children.last.content)
        args[:budjet] = budjet_string.gsub(/[^\d]+/, '').to_f
        re = budjet_string.match(/\$/) ? Regexp.new('&nbsp;.*$') : Regexp.new('^.+&nbsp;')
        currency = budjet_string.gsub(re, '')
        args[:currency] = CURRENCIES[currency]
      end

      #args[:created_at] = convert(stats.children.last.content.gsub(/^(&nbsp;)+/, ''))
      args[:attachments] = []
      (project_div/".flw_offer_attach").each do |attachment|
        args[:attachments] << {
          :url => attachment.at("a")['href'],
          :title => convert(attachment.children[2].to_s)
        }
      end

      resultset << args
    end
    resultset.reverse
  end

  def self.convert(s)
    Iconv.conv('utf-8', 'windows-1251', s.to_s).to_s
  end
end
