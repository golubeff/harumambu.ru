require 'rubygems'
require 'sinatra'
require 'twitter_oauth'

configure do
  enable :sessions
end

client = TwitterOAuth::Client.new(:consumer_key => 'bDbB4QgQtwFKxETUfqg8LQ', :consumer_secret => 'd4l4cBj5yzfuACQVLo0KsPoaU1PHlAAcyyHoUWEM')

get '/twitter' do
  session[:request_token] = client.request_token(:oauth_callback => 'http://qwe.qwe:4567/twitter/connected')
  redirect session[:request_token].authorize_url
end

get '/twitter/connected' do
  client.authorize(
    session[:request_token].token,
    session[:request_token].secret,
    :oauth_verifier => params[:oauth_verifier]
  )
  puts client.authorized?
  client.update('Нашелся прикольный сервис для фрилансеров — http://harumambu.ru/')
  client.friend('harumambu')

  redirect '/'
end

