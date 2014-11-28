#!/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'instagram'
require 'date'
require 'socket'

	#setting
	CLIENT_ID = "9e691ed2cd784497aabd000b0982e6c9"
	CLIENT_SECRET = "6a882a90f17c434d80f85871f7f563b8"
	ACCESS_TOKEN = "506686147.9e691ed.1b8842e973bd4bd595fd33a781ca667b"
	IP = "92.124.119.9"
	MAX_FOLLOWS_PER_HOUR = 50 #max 60
	MAX_SLEEP_TIME = 3600 
	FILE_PATH = "usernames.txt" 

	Instagram.configure do |config|
    config.client_id = CLIENT_ID
    config.client_secret = CLIENT_SECRET
  end
	#end settings
  
	puts "Массфоловер инстаграм. Версия 0.1"
	sleep 3

	#get list of username
	usernames = File.readlines(FILE_PATH)
	puts "Ники загружены"
	sleep 3

	#create client for instagram api
	client = Instagram.client(:client_id => CLIENT_ID, :client_secret => CLIENT_SECRET, :client_ips => IP, :access_token => ACCESS_TOKEN)
	puts "Авторизация инстаграм успешна"
	sleep 3
	

	i = 0
	current_follows_count = 0

	while i < usernames.size
		
		users = client.user_search(usernames[i])
		current_user = users[0]
		uid = current_user[:id]
		
		begin
			response = client.follow_user(uid)
			i+= 1
			if response.outgoing_status == "follows"
				puts "[#{Time.now}]: Успешно подписались на #{usernames[i]}"
			end
			if response.outgoing_status == "requested"
				puts "[#{Time.now}]: Отправили запрос на подписку #{usernames[i]}"
			end
		rescue
			puts "[#{Time.now}]: Что-то пошло не так..."
			i+= 1
		end
		timer = rand(15) + 15
		sleep timer
		
		current_follows_count += 1
		if  current_follows_count == MAX_FOLLOWS_PER_HOUR
			puts "[#{Time.now}]: Достигнут лимит на подписки в час. Приостанавливаем работу на #{MAX_SLEEP_TIME} секунд"
			sleep MAX_SLEEP_TIME
			current_follows_count = 0
		end
	end
	puts "Работа завершена"
