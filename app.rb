require 'sinatra'
require 'sinatra/reloader'
require 'mysql2'
require 'mysql2-cs-bind'
# gem 'rack-contrib'

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

end
