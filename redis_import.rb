module RedisImport
  def redis_to_couchdb(r, vidid)
    dl = r.hgetall(vidid)

    {
      '_id' => vidid,
      'hash' => dl['hash'],
      'user' => dl['user'],
      'inserted_at' => Time.now.to_f,
      'size' => dl['size'].to_i
    }
  end
end
