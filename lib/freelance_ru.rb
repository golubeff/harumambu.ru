require 'rubygems'
require 'hpricot'
require 'open-uri'

class FreelanceRu

  def self.desc; 'freelance.ru'; end

  CATEGORIES = {
    'Дизайн и графика' => 'Дизайн',
    "Дизайн и графика для WEB" => "Дизайн",
    "Фирменный стиль (айдентика)" => "Дизайн",
    "Интернет-маркетинг" => "Реклама/Маркетинг",
    "Администрирование" => "Программирование",
    "Аутсорсинг/Консалтинг" => "Консалтинг",
    "Программирование" => "Программирование",
    "Фото/Видео" => "Фотография",
	  "Переводы" => "Переводы",
    "Реклама/Маркетинг" => "Реклама/Маркетинг",
    "Тексты" => "Тексты",
    "Музыка/звук" => "Аудио/Видео"
  }

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
      category = convert((project_div/'li.spec_name').inner_html.to_s)
      begin
        if category && CATEGORIES[category]
          args[:category_id] = DB["select id from categories where title ilike E'%#{CATEGORIES[category]}%'"].first[:id]
        end
      rescue
      end
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
