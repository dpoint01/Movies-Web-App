require 'sinatra'
require 'csv'
require 'pry'
require 'redis'

#-----------------------REDISSSSSSS!!!!---------------------#
def get_connection
  if ENV.has_key?("REDISCLOUD_URL")
    Redis.new(url: ENV["REDISCLOUD_URL"])
  else
    Redis.new
  end
end


#-----------------------METHODS--------------------#

def read_csv(csv)

  all_movies = []
  count_movies = 0

  CSV.foreach(csv, headers: true, header_converters: :symbol) do |row|
    all_movies  << row
    count_movies += 1
  end

  return all_movies, count_movies

end

def pagination(model, page, offset)
  if page == 1
    model = model[offset..offset+30]
  else
    model = model[offset + 1..offset+31]
  end
end

#---------------------------------------------------#


all_movies, count_movies = read_csv("movies.csv")
all_movies = all_movies.sort_by{|row| row[:title]}

per_page = 30


get '/' do
  erb :home
end

get '/movies' do

  @total_movies = count_movies
  @page  = params[:page] || 1
  @search = params[:query]
  @all_movies = all_movies

  if @search
    @all_movies = all_movies.find_all do |movie|
      movie[:title].downcase.include?(@search.downcase) ||
      if movie[:synopsis]
        movie[:synopsis].downcase.include?(@search.downcase)
      end

    end
  end

    @page = @page.to_i
    offset = ((@page - 1) * per_page)

  if !@search
    @all_movies = pagination(@all_movies, @page, offset)
  end

    erb :movies
end

get '/movies/:movie_id' do

  @movie_id = params[:movie_id]

  @movie = all_movies.select{|movie| movie[:id] == @movie_id}

  erb :movie

end
