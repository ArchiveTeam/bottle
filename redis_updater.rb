require 'logger'
require 'redis'

require File.expand_path('../couchdb_connection_factory', __FILE__)

DB = CouchDbConnectionFactory.make_couchdb_connection
R = Redis.new

to_save = []

R.monitor do |line|
  if line =~ /([0-9\.]+)\s"HMSET"\s"([0-9\-]+)"\s"hash"\s"([0-9a-f]+)"\s"user"\s"([^"]+)"\s"size"\s"([0-9]+)"/
    time = $1
    docid = $2
    hash = $3
    user = $4
    size = $5

    doc = {
      '_id' => docid,
      'hash' => hash,
      'size' => size.to_i,
      'user' => user,
      'inserted_at' => time.to_f
    }

    begin
      DB.save_doc(doc)
    rescue RestClient::Conflict
      puts "#{docid} already saved"
    end
  end
end
