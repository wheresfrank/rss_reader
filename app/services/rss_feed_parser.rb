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

  def extract_articles
  articles = []
  atom_ns = { 'atom' => 'http://www.w3.org/2005/Atom' }

  # Check if the document is an RSS feed
  if @doc.at_xpath('//rss/channel/item')
    # RSS Feed Parsing
    @doc.xpath('//rss/channel/item').each do |item|
      article = {
        title: item.at_xpath('title')&.text,
        link: item.at_xpath('link')&.text,
        description: item.at_xpath('description')&.text,
        pub_date: item.at_xpath('pubDate')&.text,
        image: item.at_xpath('image')&.text, # If there's an <image> tag within <item>
        audio_link: item.at_xpath('enclosure[@type="audio/mpeg"]')&.[]('url') # Extract audio link if present
      }

      articles << article
    end
  
  # Check if it's an Atom feed
  elsif @doc.at_xpath('//atom:feed/atom:entry', atom_ns)
    # Atom Feed Parsing
    @doc.xpath('//atom:feed/atom:entry', atom_ns).each do |entry|
      article = {
        title: entry.at_xpath('atom:title', atom_ns)&.text,
        link: entry.at_xpath('atom:link[@rel="alternate"]', atom_ns)&.[]('href'),
        description: entry.at_xpath('atom:content', atom_ns)&.text || entry.at_xpath('atom:summary', atom_ns)&.text,
        pub_date: entry.at_xpath('atom:published', atom_ns)&.text || entry.at_xpath('atom:updated', atom_ns)&.text,
        image: entry.at_xpath('atom:content//img/@src', atom_ns)&.text # Extract the first image src if present
      }

      articles << article
    end
  end

  articles
end
end