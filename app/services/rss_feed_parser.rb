class RssFeedParser
  require 'nokogiri'
  require 'open-uri'

  def initialize(feed)
    @feed = feed
    begin
      @doc = Nokogiri::XML(URI.open(feed.source))
    rescue => e
      @feed.errors.add(:source, "is invalid or unreachable: #{e.message}")
    end
  end

  def extract_icon
    return if @feed.errors.any?

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
    return if @feed.errors.any?
  
    articles = []
  
    # Define namespaces
    namespaces = {
      'atom' => 'http://www.w3.org/2005/Atom',
      'media' => 'http://search.yahoo.com/mrss/',
      'dc' => 'http://purl.org/dc/elements/1.1/'
    }

    # Check if the document is an RSS feed
    if @doc.at_xpath('//rss/channel/item')
      # RSS Feed Parsing
      @doc.xpath('//rss/channel/item').each do |item|
        article = {
          title: item.at_xpath('title')&.text,
          link: item.at_xpath('link')&.text,
          description: item.at_xpath('description')&.text,
          pub_date: item.at_xpath('pubDate')&.text,
          image: item.at_xpath('media:thumbnail/@url', namespaces)&.text || item.at_xpath('image')&.text,
          audio_link: item.at_xpath('enclosure[@type="audio/mpeg"]/@url')&.text # Extract audio link if present
        }
  
      # If description is not found, attempt to retrieve it from 'media:description'
      article[:description] ||= item.at_xpath('media:description', namespaces)&.text

      # If pubDate is not found, attempt to retrieve it from 'dc:date'
      article[:pub_date] ||= item.at_xpath('dc:date', namespaces)&.text
      
      next if article[:pub_date].nil? or article[:description].nil?
      articles << article
    end
  
    # Check if it's an Atom feed
    elsif @doc.at_xpath('//atom:feed/atom:entry', namespaces)
      # Atom Feed Parsing
      @doc.xpath('//atom:feed/atom:entry', namespaces).each do |entry|
        article = {
          title: entry.at_xpath('atom:title', namespaces)&.text,
          link: entry.at_xpath('atom:link[@rel="alternate"]', namespaces)&.[]('href'),
          description: entry.at_xpath('atom:content', namespaces)&.text || entry.at_xpath('atom:summary', namespaces)&.text,
          pub_date: entry.at_xpath('atom:published', namespaces)&.text || entry.at_xpath('atom:updated', namespaces)&.text,
          image: entry.at_xpath('atom:content//img/@src', namespaces)&.text # Extract the first image src if present
        }
  
        articles << article
      end
    end
  
    articles
  end
end
