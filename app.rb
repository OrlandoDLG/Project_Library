require "sinatra"
require 'sinatra/flash'
require_relative "authentication.rb"
require_relative "api_authentication.rb"
#the following urls are included in authentication.rb
# GET /login
# GET /logout
# GET /sign_up

# authenticate! will make sure that the user is signed in, if they are not they will be redirected to the login page
# if the user is signed in, current_user will refer to the signed in user object.
# if they are not signed in, current_user will be nil

get "/" do
	erb :index
end

get "/dashboard" do
	authenticate!
	erb :dashboard
end

#USER STUFF////////////////////////////////////////////////////////////
get "/users" do
	halt 200, User.all.to_json(except: [:password])
end

get "/users/:id" do
	id = params["id"]
	u = User.get(id)
	if u != nil
		halt 200, u.to_json(except: [:password])
	else
		halt 404, {message: "User not found"}.to_json
	end
end

patch "/users/:id" do
	if params["id"]
		us = User.get(params["id"])
	    temp_email = params["email"]
	    temp_password = params["password"]
	    temp_role_id = params["role_id"]
	    temp_fname = params["fname"]
	    temp_lname = params["lname"]
	    temp_phone_number = params["phone_number"]

	 	if !us.nil?
	 		us.email = temp_email if !temp_email.nil?
	 		us.password = temp_password if !temp_password.nil?
	 		#Only change to integer here to avoid changing null 
	 		#to 0 integer
	 		us.role_id = temp_role_id.to_i if !temp_role_id.nil?
	 		us.fname = temp_fname if !temp_fname.nil?
	 		us.lname = temp_lname if !temp_lname.nil?
	 		us.phone_number = temp_phone_number if !temp_phone_number.nil?
	 		us.save
	 		halt 200, {message: "User Updated"}.to_json
		else
			halt 404, {message: "You did not select any field"}.to_json
			redirect "/users/:id"
	 	end
	else
		message = "Invalid User Input"
	    halt 401, {"message": message}.to_json
	end 
end

delete "/users/:id" do
	id = params["id"]
	u = User.get(id)
	if u != nil
		u.destroy
		halt 200, {message: "User deleted"}.to_json
	else
		halt 404, {message: "User not found"}.to_json
	end
end

#BOOKS STUFF//////////////////////////////////////////////////////
post "/books" do
	# create a new book entry
	title = params[:title]
	edition = params[:edition]
	author = params[:author]
	isbn = params[:isbn]
	description = params[:description]

	b = Book.new
	b.title = title
	b.edition = edition
	b.author = author
	b.isbn = isbn
	b.description = description
	b.checked_out = false
	b.save

	halt 201, {message: "Book Created"}.to_json
end

get "/books" do
	halt 200, Book.all.to_json
end

get "/books/check_out" do
	#get all books checked out that have been checked out
	#make an empty array of books
	#loop through checkouts and add each book to the array
	#return the array as json
	books = []
	checkouts = Book.all(checked_out: true)
	checkouts.each do |c|
		books << c
	end
	halt 200, books.to_json
end

get "/books/check_in" do
	#get all books checked in (available) 
	#make an empty array of books
	#loop through books, add each book to the array
	#return the array as json
	books = []
	#checked_out is part of the book class
	checkouts = Book.all(checked_out: false)
	checkouts.each do |c|
		books << c
	end
	halt 200, books.to_json
end

get "/books/:id" do
	id = params["id"]
	b = Book.get(id)
	if b != nil
		halt 200, b.to_json
	else
		halt 404, {message: "Book not found"}.to_json
	end
end

patch "/books/:id" do
	if params["id"]
		bo = Book.get(params["id"])
	    temp_title = params["title"]
	    temp_edition = params["edition"]
	    temp_author = params["author"]
	    temp_isbn = params["isbn"]
	    temp_description = params["description"]
	    temp_checked_out = params["checked_out"]
	   # if temp_checked_out if !checked_out.nil? || temp_description.to_i==1

	    #end

	 	if !bo.nil?
	 		bo.title = temp_title if !temp_title.nil?
	 		bo.edition = temp_edition if !temp_edition.nil?
	 		bo.author = temp_author if !temp_author.nil?
	 		bo.isbn = temp_isbn if !temp_isbn.nil?
	 		bo.description = temp_description if !temp_description.nil? 
			bo.checked_out = temp_checked_out if !temp_checked_out.nil?
	 		bo.save
	 		halt 200, {message: "Book Updated"}.to_json
		else
			halt 404, {message: "You did not select any field"}.to_json
	 	end
	else
		message = "Invalid Book Input"
	    halt 401, {"message": message}.to_json
	end 
end

delete "/books/:id" do
	id = params["id"]
	b = Book.get(id)
	if b != nil
		b.destroy
		halt 200, {message: "Book deleted"}.to_json
	else
		halt 404, {message: "Book not found"}.to_json
	end
end

#CUSTOMERS STUFF//////////////////////////////////////////////////////////////
post "/customers" do
	# create a new customer entry
	fname = params[:fname]
	lname = params[:lname]
	phone_number = params[:phone_number]

	c = Customer.new
	c.fname = fname
	c.lname = lname
	c.phone_number = phone_number
	c.save

	halt 201, {message: "Customer Created"}.to_json
end

get "/customers" do
	halt 200, Customer.all.to_json
end

get "/customers/:id" do
	id = params["id"]
	c = Customer.get(id)
	if c != nil
		halt 200, c.to_json
	else
		halt 404, {message: "Book not found"}.to_json
	end
end

patch "/customers/:id" do
	if params["id"]
		cu = Customer.get(params["id"])
	    temp_fname = params["fname"]
	    temp_lname = params["lname"]
	    temp_phone_number = params["phone_number"]

	 	if !cu.nil?
	 		cu.fname = temp_fname if !temp_fname.nil?
	 		cu.lname = temp_lname if !temp_lname.nil?
	 		cu.phone_number = temp_phone_number if !temp_phone_number.nil?
	 		cu.save

	 		halt 200, {message: "Customer Updated"}.to_json
		else
			halt 404, {message: "You did not select any field"}.to_json
	 	end
	else
		message = "Invalid Customer Input"
	    halt 401, {"message": message}.to_json
	end 
end

delete "/customers/:id" do
	id = params["id"]
	c = Customer.get(id)
	if c != nil
		c.destroy
		halt 200, {message: "Customer deleted"}.to_json
	else
		halt 404, {message: "Customer not found"}.to_json
	end
end

#CHECK_OUT STUFF//////////////////////////////////////////////////
post "/check_outs" do
	# create a new customer entry
	customer_id = params[:customer_id].to_i
	book_id = params[:book_id].to_i
	due_date = params[:due_date]
	checked_out_date = params[:checked_out_date]

	ch = Check_Out.new
	ch.customer_id = customer_id
	ch.book_id = book_id
	ch.due_date = due_date
	ch.checked_out_date = checked_out_date
	ch.returned = false
	ch.save

	id_of_book = book_id
	id_b = Book.get(id_of_book)
	id_b.checked_out = true
	id_b.save

	halt 201, {message: "Check Out Entry Created"}.to_json
end

get "/check_outs" do
	halt 200, Check_Out.all.to_json
end

#after any get request with same intro sample /check_outs/:id
#Order of the functions matter
get "/check_outs/not_returned" do
	#get all books checked out that have not been returned
	#make an empty array of books
	#loop through checkouts and add each book to the array
	#return the array as json
	books = []
	#unreturned_check_out returns the id 
	checkouts = Check_Out.all(returned: false)
	checkouts.each do |c|
		books << c.book
	end

	halt 200, books.to_json
end

get "/check_outs/:id"  do
	id = params["id"]
	ch = Check_Out.get(id)
	if ch != nil
		halt 200, ch.to_json
	else
		halt 404, {message: "Check Out Entry not found"}.to_json
	end
end

#Gets specific customer and specific book
get "/check_outs/:id_c/:id_b"  do
	id_c = params["id_c"]
	id_c = Customer.get(id_c)

	id_b = params["id_b"]
	id_b = Book.get(id_b)

	if id_c && id_b != nil
		halt 200, id_c.to_json + id_b.to_json
	else
		halt 404, {message: "User with book not found"}.to_json
	end
end

#Updates the check out entry
patch "/check_outs/:id" do
	if params["id"]
		ch = Check_Out.get(params["id"])
	    temp_customer_id = params["customer_id"]
	    temp_book_id = params["book_id"]
	    temp_due_date = params["due_date"]
	    temp_checked_out_date = params["checked_out_date"]
	    temp_returned = params["returned"]

	 	if !ch.nil?
	 		ch.customer_id = temp_customer_id.to_i if !temp_customer_id.nil?
	 		ch.book_id = temp_book_id.to_i if !temp_book_id.nil?
	 		ch.due_date = temp_due_date if !temp_due_date.nil?
	 		ch.checked_out_date = temp_checked_out_date if !temp_checked_out_date.nil?
	 		ch.returned = temp_returned if !temp_returned.nil?
	 		ch.save

	 		halt 200, {message: "Check Out Entry Updated"}.to_json
		else
			halt 404, {message: "You did not select any field"}.to_json
	 	end
	else
		message = "Invalid Customer Input"
	    halt 401, {"message": message}.to_json
	end 
end

delete "/check_outs/:id" do
	id = params["id"]
	ch = Check_Out.get(id)
	if ch != nil
		ch.destroy
		halt 200, {message: "Check Out Entry deleted"}.to_json
	else
		halt 404, {message: "Check Out Entry not found"}.to_json
	end
end
