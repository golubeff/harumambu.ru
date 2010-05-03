#написан andreyd22  dmitrichev@gmail.com при пинках Паши Голубева golubev.pavel@gmail.com
require 'rubygems'
require 'hpricot'
require 'open-uri'
require File.dirname(__FILE__) + '/../lib/sequel_adapter.rb'


class BestLanceRu
  
  CATEGORIES = {
    "Разработка сайтов" => 'Разработка сайтов',
    "Менеджмент" => 'Менеджмент',
    "Дизайн/Арт" => 'Дизайн',
    "Флеш" => "Флеш",
    "Программирование" => "Программирование",
    "Оптимизация/SEO/Раскрутка" => 'Оптимизация (SEO)',
    "Переводы" => "Переводы",
    "Тексты" => "Тексты",
    "3D Графика/Анимация" => '3D Графика',
    "Фотография" => "Фотография",
    "Аудио/Видео" => "Аудио/Видео",
    "Реклама/Маркетинг" => "Реклама/Маркетинг",
    "Консалтинг" => "Консалтинг",
    "Архитектура" => 'Архитектура/Инжиниринг',
    "Инженерия" => 'Архитектура/Инжиниринг',
    "Мультипликация/Анимация" => "Анимация/Мультипликация",
    "Разработка игр" => "Разработка игр"
  }

  CURRENCIES = { 'Руб.' => "руб.", "&#x0024;" => '$', '&euro;' => '€', "FM" => 'FM' }

  def self.desc
    'best-lance.ru'
  end

  def self.latest
    self.rss
  end

  def self.rss
    doc = Hpricot.XML(open('http://best-lance.ru/rss/all.xml'))
    args = {}
    resultset = []
    (doc/:item).each do |project_div|
      args = {}
      args[:title] = convert((project_div/:title).inner_html)
      args[:url] = convert((project_div/:link).inner_html)
      args[:remote_id] = args[:url].gsub(/[^\d]/, '')
      desc = convert((project_div/:description).inner_html)
      args[:desc] =  desc.gsub(/^(.+?)Описание:/i,"").gsub(/\]\]\>/,"")
      budjet = desc.gsub(/^(.+?)Бюджет:/i,"").gsub(/\&\#x0024\;|Руб\.(.+?)$/,"").gsub(/\s+/,"").to_f
      currency = desc.match(/(\&\#x0024\;|Руб\.)/)[0]
      begin
        category = desc.scan(/Категория: *(.+?)<br/)[0][0]
        if CATEGORIES[category]
          args[:category_id] = DB["select id from categories where title ilike E'%#{CATEGORIES[category]}%'"].first[:id]
        end
      rescue Exception => e
        puts e

      end


      args[:created_at] = Time.now
      args[:budjet] = budjet
      args[:currency] = CURRENCIES[currency]
      if args[:budjet].to_f == 0.0
        args[:budjet] = nil
        args[:currency] = nil
      end

      resultset << args
    end
    resultset.reverse
  end

  def self.convert(s)
    s.force_encoding('UTF-8').to_s
  end
end
