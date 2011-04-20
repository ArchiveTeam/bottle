require 'json'
require 'sinatra'
require 'yaml'

require File.expand_path('../db', __FILE__)

include Db

DB = make_connection

RestClient.log = $stderr

get '/users' do
  content_type :json

  DB.view('aggregates/downloaded_by_user', :group => true) do |rows|
    rows.map do |row|
      row['value'].tap { |v| v['user'] = row.delete('key') }
    end.to_json
  end
end
