json.extract! feed, :id, :name, :source, :favorite, :created_at, :updated_at
json.url feed_url(feed, format: :json)
