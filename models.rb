require 'data_mapper' # metagem, requires common plugins too.

# need install dm-sqlite-adapter
# if on heroku, use Postgres database
# if not use sqlite3 database I gave you
if ENV['DATABASE_URL']
  DataMapper::setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
else
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/app.db")
end

class User
    include DataMapper::Resource
    property :id, Serial
    property :email, Text
    property :password, Text
    property :role_id, Integer
    property :fname, Text
    property :lname, Text
    property :phone_number, Text
    property :created_at, DateTime

    def login(password)
        return self.password == password
    end
end

class Book
    include DataMapper::Resource
    property :id, Serial
    property :title, Text
    property :edition, Text
    property :author, Text
    property :isbn, Text
    property :description, Text
    property :checked_out, Boolean
    property :created_at, DateTime

    def current_check_out
        return Check_Out.first(book_id: id, returned: false)
    end

    def current_check_in
        return Check_Out.first(book_id: id, returned: true)
    end

    def currently_checked_out?
        co = Check_Out.first(book_id: id, returned: false)
        return !co.nil?
    end
end

class Customer
    include DataMapper::Resource
    property :id, Serial
    property :fname, Text
    property :lname, Text
    property :phone_number, Text
    property :created_at, DateTime

    def check_outs
        return Check_Out.all(customer_id: id)
    end

    def unreturned_check_outs
        return Check_Out.all(customer_id: id, returned: false)
    end
end

class Check_Out
    include DataMapper::Resource
    property :id, Serial
    property :customer_id, Integer
    property :book_id, Integer
    property :due_date, Text
    property :returned, Boolean
    property :checked_out_date, Text
    property :created_at, DateTime

    def customer
        return Customer.get(customer_id)
    end

    def book
        return Book.get(book_id)
    end
end

# Perform basic sanity checks and initialize all relationships
# Call this when you've defined all your models
DataMapper.finalize

# automatically create the post table
User.auto_upgrade!
Book.auto_upgrade!
Customer.auto_upgrade!
Check_Out.auto_upgrade!
