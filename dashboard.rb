require 'haml'
require 'redis'
require 'sinatra'
require 'json'
require 'time'

class Dashboard
  def initialize
    @r = Redis.new
    @r.select(1)
  end

  def sizes_and_counts_by_user
    @r.hgetall('by_user').map do |k, v|
      { 'user' => k,
        'size' => v.to_i / 1_000_000_000,
        'count' => @r.hlen(k)
      }
    end
  end

  def most_recently_downloaded
    @r.lrange('downloaded', 0, @r.llen('downloaded')).map { |d| JSON.parse(d) }
  end

  def last_update
    Time.at(@r.get('last_update').to_f)
  end
end

D = Dashboard.new

get '/' do
  @data = D.sizes_and_counts_by_user
  @recent = D.most_recently_downloaded
  @last_update = D.last_update

  field = params[:sort] || 'user'
  @data.sort! { |h1, h2| h1[field] <=> h2[field] }
  @data.reverse! unless field == 'user'

  haml :index
end

get '/reset.css' do
  File.read('views/reset.css')
end

get '/screen.css' do
  scss :screen
end
