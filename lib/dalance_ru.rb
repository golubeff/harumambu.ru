#написан andreyd22  dmitrichev@gmail.com при пинках Паши Голубева golubev.pavel@gmail.com
require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'iconv'
require File.dirname(__FILE__) + '/../lib/sequel_adapter.rb'

class DalanceRu
  
  CURRENCIES = { 'руб' => "руб.", "$" => '$', '&euro;' => '€', "FM" => 'FM' }

  CATEGORIES = {
    "2D анимация" => "Анимация/Мультипликация",
    "3D графика/Анимация" => "3D Графика",
    "Баннеры" => "Дизайн",
    "Архитектурный дизайн" => "Дизайн",
    "Видео-дизайн" => "Дизайн",
    "Векторная графика" => "Арт",
    "Разработка шрифтов" => "Арт",
    "Рисунки и иллюстрации" => "Арт",
    "Иконки" => "Арт",
    "Логотипы" => "Дизайн",
    "Логотипы для сотовых телефонов" => "Дизайн",
    "Наружная реклама" => "Дизайн",
    "Промышленный дизайн" => "Дизайн",
    "Пиксельная графика" => "Арт",
    "Полиграфия" => "Полиграфия",
    "Мультимедиа презентации" => "Дизайн",
    "Фирменный стиль" => "Дизайн",
    "Дизайн интерфейсов" => "Дизайн",
    "Дизайн интерьера" => "Дизайн",
    "Дизайн упаковки" => "Дизайн",
    "Разработка сайтов" => "Разработка сайтов",
    "Веб-программирование" => "Программирование",
    "Верстка" => "Разработка сайтов",
    "Flash" => "Флеш",
    "Оптимизация/SEO" => "Оптимизация (SEO)",
    "Сайт «под ключ»" => "Разработка сайтов",
    "WAP сайты" => "Разработка сайтов",
    "Дизайн сайтов" => "Дизайн",
    "Программирование" => "Программирование",
    "Базы данных" => "Программирование",
    "Веб-программирование" => "Программирование",
    "Прикладное программирование" => "Программирование",
    "Программирование игр" => "Разработка игр",
    "Программирование для сотовых телефонов и КПК" => "Программирование",
    "Прочее программирование" => "Программирование",
    "Системное программирование" => "Программирование",
    "Тексты/Статьи/Переводы" => "Тексты",
    "Веб-контент" => "Тексты",
    "Рефераты/Дипломы/Курсовые" => "Тексты",
    "Креатив/Копирайтинг/Редактирование" => "Тексты",
    "Новости/Статьи/Пресс-релизы" => "Тексты",
    "Слоганы/Рекламные объявления" => "Тексты",
    "Художественный перевод" => "Переводы",
    "Техническая документация" => "Тексты",
    "Технический перевод" => "Переводы",
    "Экономический перевод" => "Переводы",
    "Управление персоналом" => "Менеджмент",
    "HR менеджер" => "Менеджмент",
    "Менеджмент проектов" => "Менеджмент",
    "Реклама/Маркетинг" => "Реклама/Маркетинг",
    "Брендинг" => "Реклама/Маркетинг",
    "Рекламные кампании" => "Реклама/Маркетинг",
    "Исследование рынка" => "Реклама/Маркетинг",
    "Маркетинговые и консалтинговые исследования" => "Реклама/Маркетинг",
    "Медиапланирование" => "Реклама/Маркетинг",
    "Сбор и обработка информации" => "Реклама/Маркетинг",
    "PR менеджер" => "Реклама/Маркетинг",
    "Модерирование" => "3D Графика",
    "Фото" => "Фотография",
    "Ретуширование фотографий" => "Фотография",
    "Фотосъемка" => "Фотография",
    "Архитектурное и строительное проектирование" => "Архитектура/Инжиниринг",
    "Аудио/Видео" => "Аудио/Видео",
    "Музыка и звуковое сопровождение" => "Аудио/Видео"
  }

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
      id = link.attributes['id'].gsub(/[^\d]+/, '').to_i.to_s
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
      begin
        matched = convert(project_div.at('div.job_info').inner_html).scan(/Категория:\s*<a.+?>(.+?)<\/a>/)[0][0].chomp.strip
        category = CATEGORIES[matched]
        args[:category_id] = DB["select id from categories where title ilike E'%#{category}%'"].first[:id]
      rescue Exception => e
        puts e
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
