require 'sinatra'
require 'slim'
require 'sqlite3'
require 'byebug'
require 'bcrypt'

enable :sessions

get('/') do
    if session[:username] != nil
        redirect('/logged_in')
    end 
    slim(:home)
end

get('/logged_in') do
    db = SQLite3::Database.new("db/db_login.db")
    session[:inlägg] = db.execute("SELECT * FROM blogg")
    if session[:username] == nil
        redirect('/')
    else
        slim(:logged_in)
    end
end

get('/profil') do
    if session[:username] == nil
        redirect('/')
    else
        slim(:profil)
    end
end

post('/makepost') do
    db = SQLite3::Database.new("db/db_login.db")
    db.execute("INSERT INTO blogg (Username, Rubrik, Text, Time) VALUES (?, ?, ?, ?)", session[:username], params["Rubrik"], params["Text"], Time.now.to_s[0..9])

    redirect('/profil')
end

get('/login') do
    if session[:user_id] != nil
        redirect('/logged_in')
    end
    slim(:login)
end

post('/login') do
    db = SQLite3::Database.new("db/db_login.db")
    db.results_as_hash = true

    result = db.execute("SELECT Password, Id FROM users WHERE Username = '#{params["Username"]}'")
    
    if BCrypt::Password.new(result[0]["Password"]) == params["Password"]
        session[:username] = params["Username"]
        session[:user_id] = result[0]["Id"]
        redirect('/profil')
    else
        redirect('/failed')
    end

end

get('/register') do
    if session[:user_id] != nil
        redirect('/logged_in')
    end
    slim(:register)
end

post('/register') do
    db = SQLite3::Database.new("db/db_login.db")   
    new_password = params["Password"] 
    hashed_password = BCrypt::Password.create(new_password)

    db.execute("INSERT INTO users (Username, Password) VALUES (?, ?)", params["Username"], hashed_password)
    redirect('/login')
end

get('/failed') do
    slim(:failed)
end

get('/edit_profile/:id') do
    slim(:edit_profile)
end

post('/edit_profile') do
    if session[:username] == nil
        redirect('/')
    else
        slim(:edit_profile)
    end

    db = SQLite3::Database.new("db/db_login.db")
    db.execute(%Q(UPDATE users SET Username = '#{params['Rubrik']}' WHERE Id = #{session[:user_id]}))

    session.destroy
    redirect back 
end

get('/edit_post/:id') do
    if session[:username] == nil
        redirect('/')
    else
        slim(:edit_post)
    end
end

post('/edit_post') do
    db = SQLite3::Database.new("db/db_login.db")
    db.execute(%Q(UPDATE blogg SET Rubrik = '#{params['Header']}' WHERE Id = #{session[:user_id]}))

    redirect back
end

post('/edit_post/:id') do
    db = SQLite3::Database.new("db/db_login.db")
    db.execute("DELETE FROM blogg WHERE Id = #{session[:user_id]}")

    redirect back
end