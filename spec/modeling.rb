require File.expand_path '../spec_helper.rb', __FILE__

#User TESTS//////////////////////////////////////////////////////////////
describe User do
  it { should have_property           :id }
  it { should have_property           :email }
  it { should have_property           :password }
  it { should have_property           :fname }
  it { should have_property           :lname }
  it { should have_property           :phone_number }
end

def has_status_200
	expect(last_response.status).to eq(200)
end

def has_status_404
	expect(last_response.status).to eq(404)
end

def has_status_unauthorized
	expect(last_response.status).to eq(401)
end

def has_status_unprocessable
	expect(last_response.status).to eq(422)
end

def has_status_bad_request
	expect(last_response.status).to eq(400)
end

def has_status_created
	expect(last_response.status).to eq(201)
end

def is_valid_token?(encoded_token)
	begin
	JWT.decode encoded_token, "lasjdflajsdlfkjasldkfjalksdjflk", true, { algorithm: 'HS256' }
	return true
  rescue
    print("invalid")
	return false
	end
end

def get_user_id_from_token(encoded_token)
	begin
	decoded = JWT.decode encoded_token, "lasjdflajsdlfkjasldkfjalksdjflk", true, { algorithm: 'HS256' }
	return decoded[0]["user_id"]
	rescue
	return nil
	end
end

describe "When not signed in, API" do
  before(:all) do 
  	@u = User.new
  	@u.email = "p1@p1.com"
  	@u.password = "p1"
  	@u.fname = "f1"
  	@u.lname = "l1"
  	@u.phone_number = "123"
  	@u.save

  	@u2 = User.new
  	@u2.email = "p2@p2.com"
  	@u2.password = "p2"
  	@u2.fname = "f2"
  	@u2.lname = "l2"
  	@u2.phone_number = "321"
  	@u2.save
  end

  it "should have two users in test database" do 
  	expect(User.all.count).to eq(2)
  end
#ASK why this is not working with null user
 it "should get back valid token with valid sign-in" do
  	get "/api/login?username=p1@p1.com&password=p1"
    has_status_200	
  	token = JSON.parse(last_response.body)["token"]
  	expect(is_valid_token?(token)).to eq(true)
  	token_user_id = get_user_id_from_token(token)
  	token_user = User.get(token_user_id) 
  	expect(token_user.id).to eq(@u.id)
  end

  it "should give error with no token" do
    get "/api/login?username=p1@p1.com&password=p1"
    has_status_200	
    @token = JSON.parse(last_response.body)["token"]
    header "AUTHORIZATION", "Bearer #{@token}"
  end

  it "should have status 401 with invalid token on /api/token_check" do
    header "AUTHORIZATION", "bearer NOTVALIDTOKEN"
    get "/api/token_check"
    has_status_unauthorized
  end

  it "should allow registering a new user" do
    post "/api/register?username=billy&password=bob"
    has_status_created
    u = User.last
    expect(u.email).to eq("billy")
    expect(u.password).to eq("bob")
  end

  it "should not allow registering a user when username is already in use" do
    post "/api/register?username=p1@p1.com&password=bob"
    has_status_unprocessable
  end

  it "should not allow registering a user when username is missing" do
    post "/api/register?password=bob"
    has_status_bad_request
  end

  it "should not allow registering a user when password is missing" do
    post "/api/register?username=billy"
    has_status_bad_request
  end
#Orlando Tests Start

  it "should allow updates to all fields of the user" do
    patch "/users/1?password=bob3&role_id=1&fname=changed&lname=lily&phone_number=0192"
    u = User.get("1")
    expect(u.password).to eq("bob3")
    expect(u.role_id).to eq(1)
    expect(u.fname).to eq("changed")
    expect(u.lname).to eq("lily")
    expect(u.phone_number).to eq("0192")
    has_status_200	
  end

  it "should allow updates to one field of the user, and leave other fields as is" do
    patch "/users/1?fname=billy"
    u = User.get("1")
    expect(u.fname).to eq("billy")
    expect(u.lname).to eq("lily")
    has_status_200	
  end

  it "should allow deleting a user" do
    delete "/users/1"
    has_status_200	
  end

  it "should not allow duplicate deletions" do
    delete "/users/1"
    has_status_404	
  end

end
#Book TESTS//////////////////////////////////////////////////////////////
describe Book do
  it { should have_property           :id }
  it { should have_property           :title }
  it { should have_property           :edition }
  it { should have_property           :author }
  it { should have_property           :isbn }
  it { should have_property           :description }
  it { should have_property           :checked_out }
end

describe "Book Testing" do
  before(:all) do 
  	@b = Book.new
  	@b.title = "b1"
  	@b.edition = "first"
  	@b.author = "au1"
  	@b.isbn = "asd123"
  	@b.description = "des1"
  	@b.save

  	@b2 = Book.new
  	@b2.title = "b2"
  	@b2.edition = "first"
  	@b2.author = "au2"
  	@b2.isbn = "qwe123"
  	@b2.description = "des2"
  	@b2.save
  end

  it "should have two books in test database" do 
  	expect(Book.all.count).to eq(2)
  end

  it "should allow creating a new book" do
    post "/books?title=b3&edition=first&author=au3&isbn=asdkhj&description=trythree"
    has_status_created
    b = Book.last
    expect(b.title).to eq("b3")
    expect(b.edition).to eq("first")
    expect(b.author).to eq("au3")
    expect(b.isbn).to eq("asdkhj")
    expect(b.description).to eq("trythree")
  end

  it "should access all the books" do
    get "/books"
    has_status_200	
  end

  it "should access all checked in book books" do
    get "/books/check_in"
    has_status_200
    b = Book.get("3")
    expect(b.checked_out).to eq(false)	
  end

  it "should access a specific book the books" do
    get "/books/3"
    has_status_200
    b = Book.get("3")
    expect(b.title).to eq("b3")
    expect(b.edition).to eq("first")
    expect(b.author).to eq("au3")
    expect(b.isbn).to eq("asdkhj")
    expect(b.description).to eq("trythree")	
  end

  it "should not access a book that doesn't exist" do
    get "/books/10"
    has_status_404	
  end

  it "should allow updates to all fields of the book" do
    patch "/books/3?title=b4&edition=first&author=au4&isbn=changed&description=changed&checked_out=1"
    b = Book.get("3")
    expect(b.title).to eq("b4")
    expect(b.edition).to eq("first")
    expect(b.author).to eq("au4")
    expect(b.isbn).to eq("changed")
    expect(b.description).to eq("changed")
    expect(b.checked_out).to eq(true)		
    has_status_200	
  end

  it "should access all checked out book books" do
    get "/books/check_out"
    has_status_200
    b = Book.get("3")
    expect(b.checked_out).to eq(true)	
  end

  it "should allow updates to one field of the book, and leave other fields as is" do
    patch "/books/3?title=newtitle"
    b = Book.get("3")
    expect(b.title).to eq("newtitle")
    expect(b.edition).to eq("first")
    has_status_200	
  end

  it "should allow deleting a user" do
    delete "/books/3"
    has_status_200	
  end

  it "should not allow duplicate deletions" do
    delete "/books/3"
    has_status_404	
  end
end

#Customer TESTS//////////////////////////////////////////////////////////////
describe Customer do
  it { should have_property           :id }
  it { should have_property           :fname }
  it { should have_property           :lname }
  it { should have_property           :phone_number }
end

describe "Customer Testing" do
  before(:all) do 
  	@c = Customer.new
  	@c.fname = "cf1"
  	@c.lname = "cl1"
  	@c.phone_number = "1234"
  	@c.save

  	@c2 = Customer.new
  	@c2.fname = "cf2"
  	@c2.lname = "cl2"
  	@c2.phone_number = "5678"
  	@c2.save
  end

  it "should have two Customers in test database" do 
  	expect(Customer.all.count).to eq(2)
  end

  it "should allow creating a new Customer" do
    post "/customers?fname=cf3&lname=cl3&phone_number=0987"
    has_status_created
    c = Customer.last
    expect(c.fname).to eq("cf3")
    expect(c.lname).to eq("cl3")
    expect(c.phone_number).to eq("0987")
  end

  it "should access all the Customers" do
    get "/customers"
    has_status_200	
  end

  it "should access a specific customer" do
    get "/customers/3"
    has_status_200
    c = Customer.get("3")
    expect(c.fname).to eq("cf3")
    expect(c.lname).to eq("cl3")
    expect(c.phone_number).to eq("0987")
  end

  it "should not access a book that doesn't exist" do
    get "/customers/10"
    has_status_404	
  end

  it "should allow updates to all fields of the book" do
    patch "/customers/3?fname=fff&lname=lll&phone_number=0000"
    c = Customer.get("3")
    expect(c.fname).to eq("fff")
    expect(c.lname).to eq("lll")
    expect(c.phone_number).to eq("0000")	
    has_status_200	
  end

  it "should allow updates to one field of the book, and leave other fields as is" do
    patch "/customers/3?fname=newname"
    c = Customer.get("3")
    expect(c.fname).to eq("newname")
    expect(c.lname).to eq("lll")
    expect(c.phone_number).to eq("0000")	
    has_status_200	
  end

  it "should allow deleting a user" do
    delete "/customers/3"
    has_status_200	
  end

  it "should not allow duplicate deletions" do
    delete "/customers/3"
    has_status_404	
  end

end

#Check_Out TESTS//////////////////////////////////////////////////////////////
describe Check_Out do
  it { should have_property           :id }
  it { should have_property           :customer_id }
  it { should have_property           :book_id }
  it { should have_property           :due_date }
  it { should have_property           :returned }
  it { should have_property           :checked_out_date }
end

describe "Check Out Testing" do
  before(:all) do 
  	@ch = Check_Out.new
  	@ch.customer_id = 1
  	@ch.book_id = 1
  	@ch.due_date = "later1"
  	@ch.checked_out_date = "now1"
  	@ch.save

  	@ch2 = Check_Out.new
  	@ch2.customer_id = 3
  	@ch2.book_id = 3
  	@ch2.due_date = "later2"
  	@ch2.checked_out_date = "now2"
  	@ch2.save

  end

  it "should have two Check Out Entries in test database" do 
  	expect(Check_Out.all.count).to eq(2)
  end

  it "should allow creating a Check Out Entry of a Customer with a Book" do
    post "/check_outs?customer_id=2&book_id=1&due_date=later3&checked_out_date=now3"
    has_status_created

    ch = Check_Out.last
    expect(ch.customer_id).to eq(2)
    expect(ch.book_id).to eq(1)
    expect(ch.due_date).to eq("later3")
    expect(ch.checked_out_date).to eq("now3")
    expect(ch.returned).to eq(false)

    c = Customer.get(ch.customer_id)
    expect(c.fname).to eq("cf2")
    expect(c.lname).to eq("cl2")
    expect(c.phone_number).to eq("5678")

    b = Book.get(ch.book_id)
    expect(b.title).to eq("b1")
    expect(b.edition).to eq("first")
    expect(b.author).to eq("au1")
    expect(b.isbn).to eq("asd123")
    expect(b.description).to eq("des1")
    expect(b.checked_out).to eq(true)
  end

  it "should access all the Check Out Entries" do
    get "/check_outs"
    has_status_200	
  end

  it "should access all checked out books that are not returned" do
    get "/check_outs/not_returned"
    has_status_200
    ch = Check_Out.get("3")
    expect(ch.returned).to eq(false)
  end

  it "should access a specific Check Out" do
    get "/check_outs/3"
    has_status_200
    ch = Check_Out.get("3")
    expect(ch.customer_id).to eq(2)
    expect(ch.book_id).to eq(1)
    expect(ch.due_date).to eq("later3")
    expect(ch.checked_out_date).to eq("now3")
    expect(ch.returned).to eq(false)	
  end

  it "should not access a Check Out that doesn't exist" do
    get "/check_outs/10"
    has_status_404	
  end

#ASK for help here, is this the correct logic to manage 
#customers with check outs?
  it "should access a specific Customer with specific Book" do
    get "/check_outs/2/1"
    has_status_200

    c = Customer.get(2)
    expect(c.fname).to eq("cf2")
    expect(c.lname).to eq("cl2")
    expect(c.phone_number).to eq("5678")

    b = Book.get(1)
    expect(b.title).to eq("b1")
    expect(b.edition).to eq("first")
    expect(b.author).to eq("au1")
    expect(b.isbn).to eq("asd123")
    expect(b.description).to eq("des1")
    expect(b.checked_out).to eq(true)	

 #ASK if I need a way to access the Check Out ID, 
 #May not be needed since customers are already 
 #checked if they have the book ID
    ch = Check_Out.get("3")
    expect(ch.customer_id).to eq(2)
    expect(ch.book_id).to eq(1)
    expect(ch.due_date).to eq("later3")
    expect(ch.checked_out_date).to eq("now3")
    expect(ch.returned).to eq(false)		
  end

  it "should not access a Check Out that doesn't exist" do
    get "/check_outs/10"
    has_status_404	
  end

  it "should allow updates to all fields of the Check Out Entry" do
    patch "/check_outs/3?customer_id=2&book_id=1&due_date=laterch&checked_out_date=nowch&returned=1"
    ch = Check_Out.get("3")
    expect(ch.customer_id).to eq(2)
    expect(ch.book_id).to eq(1)
    expect(ch.due_date).to eq("laterch")
    expect(ch.checked_out_date).to eq("nowch")
    expect(ch.returned).to eq(true)
  end

  it "should allow updates to one field of the Check Out, and leave other fields as is" do
    patch "/check_outs/3?returned=0"
    ch = Check_Out.get("3")
    expect(ch.customer_id).to eq(2)
    expect(ch.book_id).to eq(1)
    expect(ch.due_date).to eq("laterch")
    expect(ch.checked_out_date).to eq("nowch")
    expect(ch.returned).to eq(false)	
    has_status_200	
  end

  it "should allow deleting a Check Out Entry" do
    delete "/check_outs/3"
    has_status_200	
  end

  it "should not allow duplicate deletions" do
    delete "/check_outs/3"
    has_status_404	
  end

end

# Here are the high level commands that should be considered in order
# to be onsidered functioning:

# -As an Admin, I should be able to look up a book is checked in/out and if
# checked out, see when it is expected to be returned

# -As an Admin, I should be able to  checked in/out books for customers

# -As an Admin, I should be able to view books a customer has checked out
# and if they have been returned, if not when they are supposed to return it

# -As an Admin, I should be able to view which books have not been turned in
# and past due date

# -As an Admin, I should be able to view the percentage of book checked out

# -As an Admin, I should be able to add books to the inventory

# -As an Admin, I should be able to view books checked out for a certain period

# -As an Admin, I should be able to add customers to the system