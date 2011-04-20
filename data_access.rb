module DataAccess
  def db
    DB
  end

  ##
  # Return value:
  #
  #   [ { "user": "a user", "count": 100, "size": 123456789 },
  #     ...
  #   ]
  def users_and_download_count
    [].tap do |rows|
      db.view('aggregates/downloaded_by_user', :group => true) do |row|
        rows << row['value'].tap do |v|
          user = row.delete('key')
          v['user'] = user
        end
      end
    end
  end
  
  def recently_downloaded(limit)
    [].tap do |rows|
      db.view('filters/by_insert_time', :limit => limit, :descending => true) do |row|
        rows << row['value']
      end
    end
  end
end
