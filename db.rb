require 'couchrest'
require 'yaml'

module Db
  def config
    YAML.load(File.read(config_file))
  end

  def config_file
    File.expand_path('../database.yml', __FILE__)
  end

  def make_connection
    c = config
    uri = URI.parse(c['base_url']).tap do |u|
      u.userinfo = "#{c['username']}:#{c['password']}"
    end.to_s

    CouchRest.new(uri).database(c['database'])
  end
end
