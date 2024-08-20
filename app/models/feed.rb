class Feed < ApplicationRecord
  belongs_to :user

  def icon
    feed_url = self.source
    parser = RssFeedParser.new(self)
    parser.extract_icon
  end
end
