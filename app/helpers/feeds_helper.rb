module FeedsHelper
  def parse_description(description)
    return if description.nil?
    
    parsed_description = description.gsub(/\[&#8230;\].*\z/m, '[...]')
    parsed_description.html_safe
  end

  def article_title(article)
    if @feed
      article[:title]
    else
      "#{article[:title]} - [#{article[:feed_name]}]"
    end
  end
end
