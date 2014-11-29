#!/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'instagram'
require 'date'
require 'socket'
require_relative 'functions'

	#setting
	CLIENT_ID = ""
	CLIENT_SECRET = ""
	ACCESS_TOKEN = ""
	LOGIN = ""
	IP = ""
	MAX_FOLLOWS_PER_HOUR = 50 #max 60
	MAX_SLEEP_TIME = 3600 
	FILE_PATH = "usernames.txt" 
  
	puts "Массфолловер инстаграм. Версия 0.2"
	sleep 3

	#get list of username
	usernames = File.readlines(FILE_PATH)
	puts "Ники загружены"
	sleep 1

	#create client for instagram api
	client = Instagram.client(:client_id => CLIENT_ID, :client_secret => CLIENT_SECRET, :client_ips => IP, :access_token => ACCESS_TOKEN)
	puts "Авторизация инстаграм успешна"
	sleep 1
	
	puts "Получаем список подписок текущего пользователя(может занять продолжительное время)"
	old_follows_username = user_follows(LOGIN)
	sleep 1
	
	puts "Сохраняем в файл"
	f = File.new('old_follows_username.txt', 'w')
  f.puts(old_follows_username)  
  f.close
  sleep 1
  
  old_follows_username = File.readlines("old_follows_username.txt") #исправление непонятного бага
	puts "Обрабатываем результат"
	sleep 1
	
	#сделать уникальный массив для будущих подписок
	usernames_uniq = usernames - old_follows_username
	
	puts "Приступаем к работе"

	i = 0
	current_follows_count = 0
	global_error_count = 0
	temp = [] #список username, которых уже зафоловили в ходе выполнения программы

	while i < usernames_uniq.size
		error_count = 0
		
		begin
		  users = client.user_search(usernames_uniq[i])
		  current_user = users[0]
		  uid = current_user[:id]
		  
			response = client.follow_user(uid)
			
			if response.outgoing_status == "follows"
				puts "[#{Time.now}]: Успешно подписались на #{usernames[i]}"
			end
			if response.outgoing_status == "requested"
				puts "[#{Time.now}]: Отправили запрос на подписку #{usernames[i]}"
			end
			temp.push(usernames_uniq[i])
			i+= 1
		rescue
			puts "[#{Time.now}]: Что-то пошло не так..."
			puts "[#{Time.now}]: Пробуем еще раз..."
			error_count += 1
		  if global_error_count < 3
		    if error_count < 3
		      retry
		    else
			    i+= 1
			    global_error_count += 1
			    retry
			  end
			else
			  puts "Превышено количество критических ошибок. Завершаем работу"
			  break
			end
		end
		timer = rand(15) + 15
		sleep timer
		
		current_follows_count += 1
		if  current_follows_count == MAX_FOLLOWS_PER_HOUR
			current_follows_count = 0
			
			#удаляем из иходного массива тех, на кого уже подписались
			result_array = usernames_uniq - temp
			
			puts "Перезаписываем файл с никами(удаляем тех, на кого уже подписались)"
			#rewrite usernames
      f = File.new(FILE_PATH, 'w')
      f.puts(result_array)  
      f.close
      puts "Готово"
      
			puts "[#{Time.now}]: Достигнут лимит на подписки в час. Приостанавливаем работу на #{MAX_SLEEP_TIME} секунд"
			sleep MAX_SLEEP_TIME
		end
	end
	puts "Работа завершена"
