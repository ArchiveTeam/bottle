require 'logger'
require 'redis'
require 'json'

LOGGER = Logger.new($stderr)

pid = fork

def process_docid(docid, source, stats, time = nil)
  data = source.hgetall(docid)

  loop do
    user = data['user']

    unless stats.hexists(user, docid)
      stats.watch(user)

      ok = stats.multi do |m|
        m.hset(user, docid, true)
        m.hincrby('by_user', user, data['size'])
      end

      stats.unwatch

      if ok
        stats.lpush 'downloaded', { :user => user, :docid => docid, :time => time }.to_json
        stats.ltrim 'downloaded', 0, stats.hlen('by_user') - 1
        stats.set 'last_update', Time.now.to_f

        break
      else
        LOGGER.info("Conflict on #{user}, retrying.")
      end
    else
      break
    end
  end
end

if pid
  source = Redis.new
  stats = Redis.new
  mon = Redis.new
  
  source.select 0
  stats.select 1

  LOGGER.info('Started monitor.')

  # Watch for changes to the "downloaded" queue.
  mon.monitor do |line|
    mset = line.match(/^([0-9\.]+)\s"HMSET"\s"([0-9\-]+)"/i)
 
    if mset
      time = mset[1]
      docid = mset[2]

      LOGGER.debug("Processing #{docid}.")

      process_docid(docid, source, stats, time)
    end
  end
else
  LOGGER.info('Bootstrapping.')

  source = Redis.new
  stats = Redis.new

  source.select 0
  stats.select 1

  # Bring ourselves up to date.
  source.smembers('gv_downloaded').each do |docid|
    begin
      process_docid(docid, source, stats)
    rescue RuntimeError
    end
  end

  LOGGER.info('Bootstrap complete.')
end
