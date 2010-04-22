require 'open-uri'
require 'rubygems'
require 'net/http'
require 'sequel'
require 'iconv'
require 'yaml'
require File.dirname(__FILE__) + '/../lib/free_lance_ru.rb'
require File.dirname(__FILE__) + '/../lib/weblancer_ru.rb'

config = YAML::load_file( File.join( File.dirname(__FILE__), '../config/database.yml' ) )[ENV['RAILS_ENV'] || 'development']

DB = Sequel.connect("postgres://#{config['username']}:#{config['password']}@#{config['host'] || 'localhost'}/#{config['database']}")
ROOT = '/tmp/travel_grab'

$projects_db = DB[:projects]
$attachments_db = DB[:project_attachments]

def process(klass)
  project_datas = klass.latest

  existing_project_ids = $projects_db.where(:remote_id => project_datas.map{|it| it[:remote_id] }).map(:remote_id)

  project_datas.select{|it| !existing_project_ids.include?(it[:remote_id]) }.each do |project_data|
    attachments = project_data[:attachments]
    project_data[:klass] = klass.name
    project_data.delete(:attachments)
    project_id = $projects_db.insert(project_data)

    if attachments.is_a?(Array)
      attachments.each do |attachment|
        id = $attachments_db.insert(attachment.update(:project_id => project_id))
      end
    end
  end

end

loop do
  [ 
    FreeLanceRu,
    WeblancerRu
  ].each do |klass|
    begin
      process(klass)
    rescue Exception => e
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
