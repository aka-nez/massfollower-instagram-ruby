#function
	
	def user_follows(login)
    #создаем клиента
    client = Instagram.client(:access_token => ACCESS_TOKEN)
    
    users = client.user_search(login)
    user = users[0]
    uid  = user[:id]
    
    #опции
    options = {
           :count => 100,
    }
    
    response = client.user_follows(uid, options)
      
    follows_username = [] #список тех, кого уже зафоловили до запуска программы
    response.each do |i|
      follows_username.push(i.username)
    end
   
    
    if pagination = response.pagination
      #если обьект pagination есть, дозаписываем username в ранее открытый файл
      cursor = pagination.next_cursor
      begin
        opt = {
           :cursor => cursor,
           :count => 100,
        }
      
        temp = client.user_follows(uid, opt)
      
        temp.each do |i|
          follows_username.push(i.username)
        end
      
        cursor = temp.pagination.next_cursor
      end while temp.pagination.any?  #до тех пор, пока в response есть pagination. Реализация через костыль, лучше пока не придумал   
    end
    
      return follows_username
    end
