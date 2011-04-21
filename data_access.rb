module DataAccess
  Views = {
    :downloaded_by_user => 'aggregates/downloaded_by_user',
    :by_insert_time => 'filters/by_insert_time'
  }

  def couchdb
    CouchDB
  end

  ##
  # Return value:
  #
  #   [ { "user": "a user", "count": 100, "size": 123456789 },
  #     ...
  #   ]
  def users_and_download_count
    [].tap do |rows|
      couchdb.view(Views[:downloaded_by_user], :group => true, :stale => :ok) do |row|
        rows << row['value'].tap do |v|
          user = row.delete('key')
          v['user'] = user
        end
      end
    end
  end
  
  def recently_downloaded(limit)
    [].tap do |rows|
      by_insert_time(:limit => limit, :descending => true) do |row|
        rows << row['value']
      end
    end
  end

  def latest_timestamp
    ts = 0

    by_insert_time(:limit => 1, :descending => true) do |row|
      ts = row['value']['inserted_at']
    end

    Time.at(ts)
  end

  private

  def by_insert_time(options, &block)
    couchdb.view(Views[:by_insert_time], options.merge(:stale => :ok), &block)
  end
end
