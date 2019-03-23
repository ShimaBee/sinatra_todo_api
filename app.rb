require 'sinatra'
require 'sinatra/reloader'
require 'mysql2'
require 'mysql2-cs-bind'
require 'rack/contrib'
require 'json'
require 'pry'
require 'jwt'
# require 'sinatra/json'

use Rack::PostBodyContentTypeParser

def db
  @db ||= Mysql2::Client.new(
      host: 'localhost',
      username: 'root',
      password: '',
      database: 'todo_db'
  )
end

post "/api/v1/users" do
  # paramsで受け取ったら、なぜかハッシュ化してる。
  register_data = params

  if register_data['name'] == ""
    response = {"status": 400, message: "nameを入れてください"}

  elsif register_data['email'] == ''
    response = {"status": 400, message: "emailを入れてください"}

  elsif register_data['password'] == ''
    response = {"status": 400, message: "passwordを入れてください"}

  else
    name = register_data['name']
    email = register_data['email']
    user = db.xquery("select * from User where name = ? and email = ?", name, email).to_a.first

    if user
      response = {"status": 400, message: "すでに存在しているユーザーです"}
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

  elsif login_data['password'] == ''
    response = {"status": 400, message: "passwordを入れてください"}

  else
    email = login_data['email']
    password = login_data['password']
    user = db.xquery("select * from User where email = ? and password = ?", email, password).to_a.first

    unless user
      response = {"status": 400, message: "存在しないユーザーです"}

    else
      # privatekey生成
      rsa_private = OpenSSL::PKey::RSA.generate(2048)
      login_data_json = login_data.to_json
      p login_data_json
      # login_dataを暗号化して、tokenにいれる。
      token = JWT.encode(login_data_json, rsa_private, 'RS256')
      response = {"status": 200, message: "ログインしました" ,"token": token}
    end

  end
  response.to_json

end

# tokenをlogin_dataに戻す
# devode_token = JWT.decode(token, rsa_private, true, { algorithm: 'RS256' })
#
# p devode_token
