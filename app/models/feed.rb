class Feed < ApplicationRecord
  belongs_to :user

  def icon
    feed_url = self.source
    parser = RssFeedParser.new(feed_url)
    parser.extract_icon
  end
end
