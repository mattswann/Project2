class Book < ActiveRecord::Base
belongs_to :categories
has_many :reviews
has_many :favourites
end
