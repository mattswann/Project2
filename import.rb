require 'httparty'
require './db_config'
require './models/author'
require './models/book'
require './models/category'
require './models/user'
require 'pry'

categories = Category.pluck(:name)

isbns = ['0439286115', '0582331536']

isbns.each do |num|
  result = HTTParty.get("http://openlibrary.org/api/books?bibkeys=ISBN:#{num}&jscmd=data&format=json")

  data = result["ISBN:#{num}"]

  book = Book.new
  book.title = data['title']
    if data['authors']
      book.author = data['authors'][0]['name']
    else
      book.author = "No one wrote this"
    end

  if data['subjects']
    arr = data['subjects'].map {|s| s['name'].downcase } & categories
    book.category = arr.first
  else
    book.category = "Category not available"
  end

  book.year = data['publish_date']
  # book.cover = data['cover']['large']
  if data['number_of_pages']
  book.page_count = data['number_of_pages']
  end

  book.save

  end
 
