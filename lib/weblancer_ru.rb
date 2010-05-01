require 'rubygems'
require 'open-uri'
require 'iconv'
require 'hpricot'
require File.dirname(__FILE__) + '/../lib/sequel_adapter.rb'

class WeblancerRu
  CURRENCIES = { 'USD' => "$" }

  def self.desc
    'weblancer.net'
  end

  CATEGORIES = {
    'Веб-программирование' => "Программирование",
    'Создание сайтов "под ключ"' => "Разработка сайтов",
    'HTML-верстка' => "Разработка сайтов",
    'Продвижение сайтов/SEO' => "Оптимизация (SEO)",
    'Системы управления контентом' => "Разработка сайтов",
    'Flash' => "Флеш",
    'Интернет-магазины' => "Разработка сайтов",
    'Тестирование сайтов' => "Разработка сайтов",

    "Скрипты/Веб-приложения" => "Программирование",
    "Разработка прикладного ПО" => "Программирование",
    "Разработка баз данных" => "Архитектура/Инжиниринг",
    "Разработка игр" => "Разработка игр",
    "Приложения для телефонов" => "Программирование",
    "Системное программирование" => "Программирование",
    "Приложения для PDA/PocketPC" => "Программирование",
    "Тестирование ПО" => "Программирование",
    "Управление проектами" => "Менеджмент",
    
    "Дипломы/Курсовые/Рефераты" => "Тексты",
    "Копирайтинг/Рерайтинг" => "Тексты",
    "Контент-менеджмент" => "Тексты",
    "Новости/Статьи/Обзоры" => "Тексты",
    "Технические статьи" => "Тексты",
    "Технические переводы" => "Переводы",
    "Художественные переводы" => "Переводы",
    "Редактирование/Корректировка" => "Тексты",
    "Резюме/Речи/Письма" => "Тексты",

    "Дизайн сайтов" => "Дизайн",
    "Баннеры" => "Дизайн",
    "Рисунки/Иллюстрации" => "Арт",
    "Логотипы" => "Дизайн",
    "Анимация" => "Анимация/Мультипликация",
    "Полиграфия" => "Полиграфия",
    "3D-графика" => "3D Графика",
    "Фирменный стиль" => "Дизайн",
    "Дизайн продукции" => "Дизайн",
    "Программные интерфейсы" => "Дизайн",
    "Дизайн интерьера" => "Дизайн",
    "Обработка фотографий" => "Фотография",
    "Фотографии" => "Фотография",
    "Мультимедиа презентации" => "Дизайн",
    "Наружная реклама" => "Дизайн",
    "Пиксель-арт/Иконки" => "Арт",
    "Промышленный дизайн" => "Дизайн",

    "Настройка сервера/ПО" => "Программирование",
    "Системное администрирование" => "Программирование",
    "Хостинг" => "Программирование",

    "Аудио/Видео-ролики" => "Аудио/Видео",
    "Озвучивание" => "Аудио/Видео"

  }

  def self.latest
    doc = Hpricot(open('http://weblancer.net'))
    args = {}
    resultset = []
    rows = ((doc/'.items_list')/'tr')
    rows.shift
    rows.each do |project_tr|
      args = {}
      cols = project_tr/"td"
      args[:title] = convert(cols.first.at('a').innerText)
      #puts args[:title]

      link = cols.first.at('a')
      link = link['href']
      link.gsub!(/[^\d+]/, '')
      args[:remote_id] = link

      counter = DB["select count(*) from projects where klass = 'WeblancerRu' and remote_id like E'#{args[:remote_id]}'"].first[:count].to_i
      next if counter > 0

      args[:url] = "http://weblancer.net/projects/#{link}.html"

      proj_doc = Hpricot(open(args[:url]))
      args[:desc] = convert(proj_doc.at('div.id_description').inner_html)
      #puts args[:desc]

      category = convert(project_tr.at('.il_item_descr').innerText).gsub(/\|\s*сегодня.*$/, '').gsub(/,.+$/, '').gsub(/ +$/, '')
      if category
        begin
          category = CATEGORIES[category]
          args[:category_id] = DB["select id from categories where title ilike E'%#{category}%'"].first[:id]
        rescue Exception => e
          puts e
        end
      end
      args[:created_at] = Time.now
      budjet = convert(project_tr.at('.il_medium').innerText)
      if budjet != '?'
        args[:budjet] = budjet.gsub(/[^\d]+/, '').to_f
        args[:currency] = CURRENCIES[budjet.gsub(/^.*\d+\s*/, '')]
      end
      resultset << args
    end
    resultset.reverse
  end

  def self.convert(s)
    Iconv.conv('utf-8', 'windows-1251', s).to_s
  end

end
