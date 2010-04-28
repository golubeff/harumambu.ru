require 'sequel'
require 'yaml'

config = YAML::load_file( File.join( File.dirname(__FILE__), '../config/database.yml' ) )[ENV['RAILS_ENV'] || 'development']
DB = Sequel.connect("postgres://#{config['username']}:#{config['password']}@#{config['host'] || 'localhost'}/#{config['database']}")

