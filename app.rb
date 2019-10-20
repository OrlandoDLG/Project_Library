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

#USER STUFF////////////////////////////
get "/users" do
	#halt 200, Book.all.to_json
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
	 		us.role_id = temp_role_id if !temp_role_id.nil?
	 		us.fname = temp_fname if !temp_fname.nil?
	 		us.lname = temp_lname if !temp_lname.nil?
	 		us.phone_number = temp_phone_number if !temp_phone_number.nil?
	 		us.save
	 		halt 200, {message: "User Update"}.to_json
		else
			halt 404, {message: "You did not select any field"}.to_json
			redirect "/users/:id"
	 	end
	else
		message = "Invalid User ID"
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

#BOOKS STUFF////////////////////////////////////////
post "/books" do



	session[:user_id] = u.id

	erb :"authentication/successful_signup"
	halt 200, {message: "Not implemented"}.to_json
end

get "/books" do
	#halt 200, Book.all.to_json
	halt 200, {message: "Not implemented"}.to_json
end

get "/books/check_out" do
	#get all books checked out that have not been returned
	#make an empty array of books
	#loop through checkouts and add each book to the array
	#return the array as json
	books = []
	checkouts = Check_Out.all(returned: false)
	checkouts.each do |c|
		books << c.book
	end
	halt 200, books.to_json
end

get "/books/check_in" do
	#halt 200, Book.all.to_json
	halt 200, {message: "Not implemented"}.to_json
end

get "/books/:id" do
	# id = params["id"]
	# b = Book.get(id)
	# if b != nil
	# 	halt 200, b.to_json
	# else
	# 	halt 404, {message: "Book not found"}.to_json
	# end
end

patch "/books/:id" do
	#halt 200, Book.all.to_json
	halt 200, {message: "Not implemented"}.to_json
end

delete "/books/:id" do
	#halt 200, Book.all.to_json
	halt 200, {message: "Not implemented"}.to_json

end

#CUSTOMERS STUFF////////////////////////////
post "/customers" do
	#halt 200, Book.all.to_json
	halt 200, {message: "Not implemented"}.to_json
end

get "/customers" do
	#halt 200, Book.all.to_json
	halt 200, {message: "Not implemented"}.to_json
end

get "/customers/:id" do
	# id = params["id"]
	# b = Book.get(id)
	# if b != nil
	# 	halt 200, b.to_json
	# else
	# 	halt 404, {message: "Book not found"}.to_json
	# end
end

patch "/customers/:id" do
	#halt 200, Book.all.to_json
	halt 200, {message: "Not implemented"}.to_json
end

delete "/customers/:id" do
	#halt 200, Book.all.to_json
	halt 200, {message: "Not implemented"}.to_json
end

#CHECK_OUT STUFF////////////////////////////
post "/check_outs" do
	#halt 200, Book.all.to_json
	halt 200, {message: "Not implemented"}.to_json
end

get "/check_outs" do
	#halt 200, Book.all.to_json
	halt 200, {message: "Not implemented"}.to_json
end

get "/check_outs/not_returned" do
	#halt 200, Book.all.to_json
	halt 200, {message: "Not implemented"}.to_json
end

get "/check_outs/:id_c/:id_b"  do#       :id" do #ASK??
	# id = params["id"]
	# b = Book.get(id)
	# if b != nil
	# 	halt 200, b.to_json
	# else
	# 	halt 404, {message: "Book not found"}.to_json
	# end
end

patch "/check_outs/:id" do
	#halt 200, Book.all.to_json
	halt 200, {message: "Not implemented"}.to_json
end

delete "/check_outs/:id" do
	#halt 200, Book.all.to_json
	halt 200, {message: "Not implemented"}.to_json
end
