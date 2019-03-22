require 'sinatra'
require 'sinatra/reloader'
require 'mysql2'
require 'mysql2-cs-bind'
require 'rack/contrib'
require 'json'
require 'pry'


use Rack::PostBodyContentTypeParser

get '/' do
  erb :index
end

def db
  @db ||= Mysql2::Client.new(
      host: 'localhost',
      username: 'root',
      password: '',
      database: 'todo_db'
  )
end


post "/api/v1/users" do

  register_data = params.to_json
  hash = JSON.parse(register_data)

  p hash

  if hash['name'] == ""
    response = {"status": 400, message: "nameを入れてください"}

  elsif hash['email'] == ''
    response = {"status": 400, message: "emailを入れてください"}

  elsif hash['password'] == ''
    response = {"status": 400, message: "passwordを入れてください"}

  else

    name = hash['name']
    email = hash['email']
    password = hash['password']
    db.xquery('insert into User values( null, ?, null , ?, ?)', name, email, password)
    response = {"status": 200, message: "ユーザー登録が完了しました"}
  end

  response.to_json

end


post '/api/v1/users/login' do

  register_data = params.to_json
  hash = JSON.parse(register_data)


  # email = hash['email']
  # password = hash['password']

  if hash['email'] == ""
    response = {"status": 400, message: "emailを入れてください"}

  elsif hash['password'] == ''
    response = {"status": 400, message: "passwordを入れてください"}

  else

  end

  response.to_json
end




