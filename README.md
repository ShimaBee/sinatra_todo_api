# sinatra_todo_api
sinatraでtodolistのAPIを作る

## 新規登録
```
$ curl --request POST \
--url http://localhost:4567/api/users \
--header 'Content-Type: application/json' \
--data '{ "name": "shimabee","email": "mrs1122ani@gmail.com","password": "password"}'
```
<br>

## ログイン
```
$ curl --request POST \
--url http://localhost:4567/api/users/login \
--header 'Content-Type: application/json' \
--data '{ "email": "mrs1122ani@gmail.com","password": "password"}'
```
<br>

## User一覧
```
$ curl --request GET \
--url http://localhost:4567/api/users \
--header 'Content-Type: application/json'
```
<br>

## User詳細
```
$ curl --request GET \
--url http://localhost:4567/api/users/1 \
--header 'Content-Type: application/json'
```

## 自分のtask一覧
```
$ curl --request GET \
--url http://localhost:4567/api/todos \
--header 'Authorization: tokenxxxxxxxxxxxxxxxx' --header 'Content-Type: application/json'
```
