require 'yaml'

require File.expand_path('../../couchdb_connection_factory', __FILE__)

views = YAML.load(File.read(File.expand_path('../views.yaml', __FILE__)))

DB = CouchDbConnectionFactory.make_couchdb_connection

def real_doc_name(n)
  "_design/#{n}"
end

views.each do |doc_name, doc_contents|
  DB.delete DB.get(real_doc_name(doc_name)) rescue nil

  DB.save_doc({ "_id" => real_doc_name(doc_name) }.merge('views' => doc_contents))
end
