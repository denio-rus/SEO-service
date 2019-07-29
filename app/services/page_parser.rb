require 'open-uri'

class Services::PageParser
  def initialize(page)
    @page = page
  end

  def call
    @content = Nokogiri::HTML(open(@page.url))
    @parsed_page = {}
    parse_meta_info
    parse_html_tags

    @parsed_page
  end
  
  private

  def parse_meta_info
    @parsed_page[:title] = @content.title
    @parsed_page[:charset] = @content.meta_encoding
    @parsed_page[:meta_tags] = @content.css('meta').map(&:values)
  end

  def parse_html_tags
    @parsed_page[:headers] = %w[h1 h2 h3 h4 h5 h6].each.with_object({}) do |header, hash| 
                                hash[header] = @content.css(header).map(&:content)
                              end
    @parsed_page[:links] = parse_a_tag
  end

  def parse_a_tag
    @content.css('a').each.with_object([]) do |link, arr|
      arr << { text: link.text, href: link.attributes['href'].try(:value) } if link.name = 'a'
    end
  end
end