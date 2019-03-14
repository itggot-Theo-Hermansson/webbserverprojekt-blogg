require 'SQLite3'
require 'bcrypt'

def database()
    return SQLite3::Database.New("db/db_login.db")
end
