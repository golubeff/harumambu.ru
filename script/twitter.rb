require 'rubygems'
require 'sinatra'
require 'twitter_oauth'

client = TwitterOAuth::Client.new(:consumer_key => 'bDbB4QgQtwFKxETUfqg8LQ', :consumer_secret => 'd4l4cBj5yzfuACQVLo0KsPoaU1PHlAAcyyHoUWEM')
request_token = client.request_token(:oauth_callback => 'http://harumambu.ru/connected_twitter')

get '/twitter' do
  redirect request_token.authorize_url
end

get '/connected_twitter' do
  client.authorize(
    request_token.token,
    request_token.secret,
    :oauth_verifier => params[:oauth_verifier]
  )
  client.update('Нашелся прикольный сервис для фрилансеров — http://harumambu.ru/')
  redirect '/'
end

