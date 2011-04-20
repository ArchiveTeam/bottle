require File.expand_path('../../couchdb_connection_factory', __FILE__)

require 'redis'

DB = CouchDbConnectionFactory.make_couchdb_connection

def each_download
  r = Redis.new

  r.smembers('gv_downloaded').each do |vidid|
    begin
      hash = r.hgetall(vidid)

      yield hash.merge('id' => vidid)
    rescue RuntimeError => e
      puts "Error when retrieving data for #{vidid}: #{e.inspect}"
    end
  end
end

to_save = []

each_download do |dl|
  doc = {
    '_id' => dl['id'],
    'hash' => dl['hash'],
    'user' => dl['user'],
    'inserted_at' => Time.now.to_f,
    'size' => dl['size'].to_i
  }

  to_save << doc

  if to_save.length > 1000
    DB.bulk_save(to_save)

    to_save = []
  end
end
