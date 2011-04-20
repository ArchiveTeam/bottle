require 'eventmachine'
require 'logger'
require 'redis'

require File.expand_path('../couchdb_connection_factory', __FILE__)
require File.expand_path('../data_access', __FILE__)
require File.expand_path('../redis_import', __FILE__)

CouchDB = CouchDbConnectionFactory.make_couchdb_connection
R = Redis.new

include DataAccess
include RedisImport

def refresh_views
  DataAccess::Views.values.each do |view|
    begin
      couchdb.view(view)
    rescue RestClient::RequestTimeout
      # this is ok; we'll just let the view server keep going
    end
  end
end

def update_download_stats
  to_update = R.sdiff 'gv_downloaded', 'lstats_already_seen'

  $log.info("Updating #{to_update.length} docids.")

  to_save = []

  to_update.each do |key|
    to_save << redis_to_couchdb(R, key)

    if to_save.length > 1000
      CouchDB.bulk_save(to_save)

      to_save = []
    end
  end

  CouchDB.bulk_save(to_save)

  to_update.each { |vidid| R.sadd 'lstats_already_seen', vidid }
end

$log = Logger.new($stderr)

EM.run do
  EM.add_periodic_timer(5) do
    $log.info('Updating download stats from Redis.')
    update_download_stats
  end

  EM.add_periodic_timer(10) do
    $log.info('Refreshing views.')
    refresh_views
  end
end
