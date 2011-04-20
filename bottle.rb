require 'facets/multipliers'
require 'haml'
require 'json'
require 'sass'
require 'sinatra'
require 'yaml'

require File.expand_path('../db', __FILE__)
require File.expand_path('../data_access', __FILE__)

include Db
include DataAccess

configure(:development) do |c|
  require 'sinatra/reloader'

  c.also_reload '*.rb'
end

DB = make_connection

set :haml, :format => :html5

get '/' do
  @users = users_and_download_count
  @recent = recently_downloaded(50)

  haml :index
end

get '/screen.css' do
  scss :screen
end
