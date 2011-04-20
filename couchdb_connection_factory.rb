require 'couchrest'
require 'yaml'

module CouchDbConnectionFactory
  def self.config
    YAML.load(File.read(config_file))
  end

  def self.config_file
    File.expand_path('../database.yml', __FILE__)
  end

  def self.make_couchdb_connection
    c = config
    uri = URI.parse(c['base_url']).tap do |u|
      u.userinfo = "#{c['username']}:#{c['password']}"
    end.to_s

    CouchRest.new(uri).database(c['database'])
  end
end
