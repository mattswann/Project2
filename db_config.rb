require 'active_record'

options = {
  adapter: 'postgresql',
  database: 'bookshelf'
}

ActiveRecord::Base.establish_connection(options)
