require 'hpricot'

class FreeLanceRu
  
  CURRENCIES = { 'Р.' => "руб.", "$" => '$', '&euro;' => '&euro;', "FM" => 'FM' }

  def self.latest
    doc = Hpricot(open('http://free-lance.ru/'))
    args = {}
    resultset = []
    (doc/".project-preview").each do |project_div|
      args = {}
      args[:title] = convert(project_div.at("h3").children.last.innerHTML)
      args[:remote_id] = convert((project_div/"h3").at("a").attributes['name']).gsub(/prj/, '')
      args[:url] = "http://free-lance.ru/projects/?pid=#{args[:remote_id]}"
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
    Iconv.conv('utf-8', 'windows-1251', s).to_s
  end
end
