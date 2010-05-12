require 'open-uri'
require 'rubygems'
require 'net/http'
require 'iconv'
require File.dirname(__FILE__) + "/../lib/free_lance_ru.rb"
require File.dirname(__FILE__) + "/../lib/weblancer_ru.rb"
require File.dirname(__FILE__) + "/../lib/freelance_ru.rb"
require File.dirname(__FILE__) + "/../lib/free_lancers_net.rb"
require File.dirname(__FILE__) + "/../lib/freelancejob_ru.rb"
require File.dirname(__FILE__) + "/../lib/dalance_ru.rb"
require File.dirname(__FILE__) + "/../lib/netlancer_ru.rb"
require File.dirname(__FILE__) + "/../lib/best_lance_ru.rb"
require File.dirname(__FILE__) + "/../lib/vingrad_ru.rb"
require File.dirname(__FILE__) + "/../lib/free_lancing_ru.rb"
require File.dirname(__FILE__) + "/../lib/acula_org.rb"


require File.dirname(__FILE__) + '/../lib/sequel_adapter.rb'
require File.dirname(__FILE__) + '/../lib/sources.rb'

ROOT = '/tmp/travel_grab'

$projects_db = DB[:projects]
$attachments_db = DB[:project_attachments]

$others_category = DB["select id from categories where title like 'Прочее'"].first[:id]

def process(klass)
  project_datas = klass.latest

  existing_project_ids = $projects_db.where(:klass => klass.name, :remote_id => project_datas.map{|it| it[:remote_id] }).map(:remote_id)

  project_datas.select{|it| !existing_project_ids.include?(it[:remote_id]) }.each do |project_data|
    attachments = project_data[:attachments]
    project_data[:klass] = klass.name
    project_data.delete(:attachments)
    project_data[:category_id] ||= $others_category
    project_id = $projects_db.insert(project_data)

    if attachments.is_a?(Array)
      attachments.each do |attachment|
        id = $attachments_db.insert(attachment.update(:project_id => project_id))
      end
    end
  end

end

loop do
  SOURCES.each do |klass|
    begin
      timeout(30) do
        process(klass)
      end
    rescue Exception => e
      puts "#{e} #{e.backtrace}"
    rescue Timeout::Error => e
    end
  end
  sleep 5
end

#loop do
  #rows = DB['select id, url from grabber_queue where state in (0,4) order by id'].all
  #unless rows.empty?
    #DB["update grabber_queue set state = 1 where id in (#{rows.map { |row| row[:id] }.join(',')})"].all
    #rows.each do |row| 
      #Thread.new { grab_url(row) }
    #end
  #end
  #sleep 0.5
#end
