require 'sinatra'
require 'slim'
require 'sqlite3'
require 'byebug'
require 'bcrypt'

enable :sessions

get('/') do 
    db = SQLite3::Database.new("db/db_login.db")      
    session[:inlägg] = db.execute("SELECT * FROM blogg")
    slim(:home)  
end

get('/profil') do
    if session[:user_id] == nil
        redirect('/')
    else
        slim(:profil)
    end
end

post('/makepost') do
    db = SQLite3::Database.new("db/db_login.db")
    db.execute("INSERT INTO blogg (Username, Text, Rubrik, Time) VALUES (?, ?, ?, ?)", session[:username], params["Text"], params["Rubrik"], Time.now.to_s[0..9])

    redirect('/profil')
end

get('/login') do
    if session[:user_id] != nil
        redirect('/')
    end
    slim(:login)
end

post('/login') do
    db = SQLite3::Database.new("db/db_login.db")

    password = params["Password"]
    hashed_password = BCrypt::Password.create("#{params["Password"]}")
    
    list = db.execute("SELECT Password FROM users WHERE Username = '#{params["Username"]}'")

    if BCrypt::Password.new(hashed_password) == params["Password"]
        session[:user_id] = params["Username"]
        redirect('/profil')
    else
        redirect('/failed')
    end

end

get('/register') do
    if session[:user_id] != nil
        redirect('/')
    end
    slim(:register)
end

post('/register') do
    db = SQLite3::Database.new("db/db_login.db")    
    hashed_password = BCrypt::Password.create("#{params["Password"]}")

    db.execute("INSERT INTO users (Username, Password) VALUES (?, ?)", params["Username"], hashed_password)
    redirect('/login')
end

get('/failed') do
    slim(:failed)
end

