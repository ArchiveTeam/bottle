require 'eventmachine'
require 'logger'

require File.expand_path('../couchdb_connection_factory', __FILE__)
require File.expand_path('../data_access', __FILE__)

CouchDB = CouchDbConnectionFactory.make_couchdb_connection

include DataAccess

def refresh_views
  DataAccess::Views.values.each { |view| couchdb.view(view) }
end

log = Logger.new($stderr)

EM.run do
  EM.add_periodic_timer(5) do
    log.info('Refreshing views.')
    refresh_views
  end
end
