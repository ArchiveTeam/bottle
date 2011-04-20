require File.expand_path('../../couchdb_connection_factory', __FILE__)
require File.expand_path('../../redis_import', __FILE__)

require 'redis'

include RedisImport

DB = CouchDbConnectionFactory.make_couchdb_connection

r = Redis.new

to_save = []

r.smembers('gv_downloaded').each do |vidid|
  begin
    next if DB.get(dl['id'])

    doc = redis_to_couchdb(r, vidid)

    to_save << doc

    if to_save.length > 1000
      DB.bulk_save(to_save)

      to_save = []
    end
  rescue RuntimeError => e
    puts "Error when retrieving data for #{vidid}: #{e.inspect}"
  end
end
