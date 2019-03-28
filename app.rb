require 'sinatra'
require 'sinatra/reloader'
require 'mysql2'
require 'mysql2-cs-bind'
require 'rack/contrib'
require 'json'
require 'pry'
require 'jwt'

enable :sessions

use Rack::PostBodyContentTypeParser

$rsa_private = OpenSSL::PKey::RSA.generate(500)

def db
  @db ||= Mysql2::Client.new(
      host: 'localhost',
      username: 'root',
      password: '',
      database: 'todo_db'
  )
end

post "/api/v1/users" do
  # paramsで受け取ったら、ハッシュ化する。
  register_data = params

  if register_data['name'] == ""
    response = {"status": 400, message: "nameを入れてください"}
    status 400

  elsif register_data['email'] == ''
    response = {"status": 400, message: "emailを入れてください"}
    status 400

  elsif register_data['password'] == ''
    response = {"status": 400, message: "passwordを入れてください"}
    status 400

  else
    name = register_data['name']
    email = register_data['email']
    user = db.xquery("select * from User where name = ? and email = ?", name, email).to_a.first

    if user
      response = {"status": 400, message: "すでに存在しているユーザーです"}
      status 400
    else
      name = register_data['name']
      email = register_data['email']
      password = register_data['password']
      db.xquery('insert into User values( null, ?, null , ?, ?)', name, email, password)
      response = {"status": 200, message: "ユーザー登録が完了しました"}

    end

  end
  response.to_json

end


post '/api/v1/users/login' do

  login_data = params

  if login_data['email'] == ""
    response = {"status": 400, message: "emailを入れてください"}
    status 400

  elsif login_data['password'] == ''
    response = {"status": 400, message: "passwordを入れてください"}
    status 400

  else
    email = login_data['email']
    password = login_data['password']
    user = db.xquery("select * from User where email = ? and password = ?", email, password).to_a.first

    unless user
      response = {"status": 400, message: "存在しないユーザーです"}
      status 400

    else
      # hashをjsonに戻す
      login_data_json = login_data.to_json
      # login_dataを暗号化して、tokenにいれる。
      token = JWT.encode(login_data_json, $rsa_private, 'RS256')
      p token

      p '----------------------------------'
      devode_token = JWT.decode(token, $rsa_private, true, { algorithm: 'RS256' })

      p devode_token
      response = {"status": 200, message: "ログインしました" ,"token": token}

    end

  end
  response.to_json

end

get '/api/v1/users' do
  users_show = db.xquery("select * from User")
  users_show_array =  users_show.to_a
  users_show_array.to_json

end

get '/api/v1/users/:id' do
  user_ditale = db.xquery("select * from User where id = ?", params[:id]).to_a.first
  user_ditale_array =  user_ditale
  user_ditale_array.to_json

end

get '/api/v1/todos' do
 
  token = @env['HTTP_AUTHORIZATION']
  devode_token = JWT.decode(token, $rsa_private, true, { algorithm: 'RS256' })
  hash = JSON.parse(devode_token[0])
  email = hash['email']
  password = hash['password']
  user = db.xquery("select * from User where email = ? and password = ?", email, password).to_a.first
  show_user_todos = db.xquery("select * from Todo where user_id = ?", user['id']).to_a
  show_user_todos.to_json

end

get '/api/v1/todos/:id' do
  token = @env['HTTP_AUTHORIZATION']
  devode_token = JWT.decode(token, $rsa_private, true, { algorithm: 'RS256' })
  hash = JSON.parse(devode_token[0])
  email = hash['email']
  password = hash['password']
  access_user = db.xquery("select * from User where email = ? and password = ?", email, password).to_a.first
  show_user = db.xquery("select * from User where id = ?", params[:id]).to_a.first
  if access_user == show_user
    response = {"status": 200, message: "見れた"}
  elsif
    response = {"status": 400, message: "存在しないユーザーです"}
      status 400 
  end
  response.to_json
end
