class RssFeedParser
  require 'nokogiri'
  require 'open-uri'

  def initialize(feed_url)
    @doc = Nokogiri::XML(URI.open(feed_url))
  end

  def extract_icon
    # Look for an Atom icon first
    icon_element = @doc.at_xpath('//atom:feed/atom:icon', 'atom' => 'http://www.w3.org/2005/Atom')

    # If Atom icon isn't found, look for RSS image in <channel><image><url>
    unless icon_element
      icon_element = @doc.at_xpath('//rss/channel/image/url') ||
                     @doc.at_xpath('//channel/image/url') # For RSS 2.0 and other variants
    end
  
    # Return the icon URL if found
    icon_element.text if icon_element
  end
end