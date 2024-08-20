module FeedsHelper
  def parse_description(description)
    parsed_description = description.gsub(/\[&#8230;\].*\z/m, '[...]')
    parsed_description.html_safe
  end
end
