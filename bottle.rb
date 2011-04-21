require 'facets/multipliers'
require 'haml'
require 'json'
require 'sass'
require 'sinatra'
require 'yaml'

require File.expand_path('../couchdb_connection_factory', __FILE__)
require File.expand_path('../data_access', __FILE__)

include DataAccess

configure(:development) do |c|
  require 'sinatra/reloader'

  c.also_reload '*.rb'
end

CouchDB = CouchDbConnectionFactory.make_couchdb_connection

set :haml, :format => :html5

get '/' do
  @averaging_period = 300
  @recent = recently_downloaded(50)
  @users = users_and_download_count
  @latest = latest_timestamp

  @users.reject! { |u| !u['user'] }

  sort = params[:sort]

  if sort
    @users.sort! { |x, y| x[sort] <=> y[sort] }
    @users.reverse! unless sort == 'user'
  end

  haml :index
end

get '/screen.css' do
  scss :screen
end
