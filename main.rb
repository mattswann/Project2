require 'pry'
require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'httparty'
# require 'google_books'

require './db_config'
require './models/book'
require './models/category'
require './models/user'
require './models/review'
require './models/favourite'

after do
  ActiveRecord::Base.connection.close
end

enable :sessions

helpers do

  def current_user
    User.find_by(id: session[:user_id])
  end

  def logged_in?
    !!current_user
        # if current_user
        #   return true
        # else
        #   return false
        # end
  end

end

get '/' do
  erb :index
end
get '/user/signup' do
  erb :signup
end

post '/user/signup' do
  #saving my user on db
  user = User.new
  user.email = params[:email]
  user.first_name = params[:first_name]
  user.last_name = params[:last_name]
  user.password = params[:password]
  user.save

  if user.save
    redirect to '/account'
  else
    "Sorry"
  end

  erb :signUp
end

get '/session/login' do
  erb :login
end

post '/session' do

  user = User.find_by(email: params[:email])
  if user && user.authenticate(params[:password])
    session[:user_id] = user.id
    redirect to '/search'
  else
    "Sorry, try again"
    erb :login
  end
end

delete '/session' do
   session[:user_id] = nil
   redirect to '/'
  end

delete '/user/:id' do
  user = User.find(params[:id])
  user.destroy
  redirect to '/'
end

get '/search' do
  @categories = Category.all
  erb :search
end


get '/by_category/:id' do
 category = Category.find(params[:id])
 @my_books = Book.where(category: category['name'])
  erb :by_category
end


get '/list' do
  @more = HTTParty.get("http://isbndb.com/api/v2/xml/POV7SEJN/books?q=#{params[:book]}")

  books = @more["isbndb"]["data"]
  @filtered_books = Array.new

  books.each do |book|
    found = false
  @filtered_books.each do |filtered|
    if book["title"] == filtered["title"]
      found = true
    end
  end

  if !found
    @filtered_books.push(book)
  end

 end
   erb :list
 end


get '/info/:isbn' do

  if book = Book.find_by(isbn: params[:isbn])

    @book_title = book.title
    @book_author = book.author
    @book_year = book.year
    @book_page_count = book.page_count
    @book_category = book.category
    @book_id = book.id
    @book_isbn = book.isbn

  else

  @infos = HTTParty.get("http://openlibrary.org/api/books?bibkeys=ISBN:#{params[:isbn]}&jscmd=data&format=json")
  @data = @infos["ISBN:#{params[:isbn]}"]

  categories = Category.pluck(:name)
    if @infos.empty?
      redirect to '/sorry'
    else
  @infos.each do |isbn|

  @book_title = @data["title"]

      if @data['authors']
       @book_author = @data['authors'][0]['name']
      else
       @book_author = "No one wrote this"
      end

    @book_year = @data['publish_date']

      if @data['number_of_pages']
        @book_page_count = @data['number_of_pages']
      else
        @book_page_count = "Numb pages not available"
      end

      if @data['cover']["large"]
        @book_cover = @data['cover']["large"]
        @book_cover = "Cover not available"
      end
      if @data['subjects']
        @arr = @data['subjects'].map {|s| s['name'].downcase } & categories
        @book_category = @arr.first
      else
        @book_category = "Category not available"
      end
        if @data['cover']
        @book_cover = @data['cover']
        else
         @book_cover = "No image provided"
        end

    #
    book = Book.new
    book.title = @book_title
    book.author = @book_author
    book.year = @book_year
    book.page_count = @book_page_count
    book.category = @book_category
    book.cover = @book_cover
    book.isbn = params[:isbn]
    book.save

    @book_id = book.id
  #
  end

 end
end
  @reviews = book.reviews
  @favourites = book.favourites
  erb :info
end

post '/info' do
  review = Review.new
  review.body = params[:body]
  review.book_id = params[:book_id]
  review.save
  redirect to "/info/#{ review.book.isbn }"
end

delete '/info/:isbn' do
  review = Review.find_by(params[:book_id])
  review.delete
  redirect to "/info/#{ review.book.isbn }"
end

post '/info/:isbn' do
  favourite = Favourite.new
  favourite.book_id = params[:book_id]
  favourite.user_id = current_user.id
  favourite.save
  redirect to "/info/#{ params[:book_isbn] }"

end

get '/sorry' do
  erb :not_available
end

get '/account' do
 @user = current_user
  erb :user_profile
end
