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
  @recent = recently_downloaded(25)
  @throughput = estimated_throughput(5)
  @users = users_and_download_count
  @latest = latest_timestamp

  haml :index
end

get '/screen.css' do
  scss :screen
end
