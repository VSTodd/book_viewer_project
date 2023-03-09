require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i

  redirect "/" unless (1..@contents.size).cover?(number)

  @title = "Chapter #{number}: #{@contents[number - 1]}"
  @chapter = File.read("data/chp#{params[:number]}.txt")

  erb :chapter
end

get "/search" do
  @results = searcher(params[:query])
  erb :search
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").each_with_index.map do |paragraph, index|
      "<p id=paragraph#{index}>#{paragraph}<p>"
    end.join
  end

  def searcher(query)
    return query if query == nil
    found = {}

    (1..@contents.size).each do |num|
      paragraphs = {}
      text = File.read("data/chp#{num}.txt")
      if text.downcase.include?(query.downcase)
        text.split("\n\n").each_with_index do |par, index|
          paragraphs[index]= par if par.downcase.include?(query.downcase)
        end
        found[num] = paragraphs
      end
    end
    found
  end

  def bolder(text, query)
    text.gsub(query, "<strong>#{query}</strong>")
  end
end

not_found do
  redirect "/"
end