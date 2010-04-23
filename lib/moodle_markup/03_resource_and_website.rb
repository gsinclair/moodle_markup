
module ResourceWebsiteHelper
  def levels_array
    @_levels ||= @level.sub('5.','').split(//)   # [2, 3]
  end

  def level_html
    alt_text = levels_array().map { |x| "5.#{x}" }.join(', ')
    image_path = File.join( Dirs.level_images, "#{levels_array().join}.png" )
    %[<img width="60" vspace="0" hspace="0" height="10" border="0"] +
    %[ title="#{alt_text}" alt="#{alt_text}" src="#{image_path}" />]
  end

  def category_html
    colour = Options::CATEGORY_COLOUR
    %[<span style="color: #{colour}"><b>(#{@category})</b></span>]
  end

  def description_html
    TextParser.parse(@description).untag('p')
  end

  def validate(level, category)
    unless level =~ /^5.(1|2|3|12|23|123)$/
      raise "Invalid value for 'level': #{level}"
    end
    unless category.split(',').all? { |x| x.in? %w[PS U F R] }
      raise "Invalid value for 'category': #{category}"
    end
  end
end

class Resource
  def initialize(paragraph, topic_number)
    # Process the paragraph into bits, taking account of the structure:
    #   <Coordinate geometry skills worksheet> 5.23 F (pdf) file:^A030.+worksheet.pdf
    #     A summary of (nearly?) all the skills taught in this topic.
    #     {-file:Solutions|PDF|A030*SOLUTIONS.pdf}
    lines = paragraph.split(NL)
    @topic_number = topic_number
    @title, @level, @category, @file_re = extract_details(lines)
    @description  = extract_description(lines)
  end

  attr_reader :topic_number, :title, :level, :category, :file_re
  attr_reader :description

  include ResourceWebsiteHelper
  
  def html
    out = String.new
    out << [file_html, level_html, category_html].join(" ") << NL
    out << description_html
    out.tag('p')
  end

  private
  DETAILS_RE = %r{< ([^>]+) > \s+     # title
                  (5.\d+) \s+         # level
                  ([A-Z,]+) \s+       # category
                  file:(.+) \s* $     # file_re
                 }x
  def extract_details(lines)
    line = lines.first
    unless line =~ DETAILS_RE
      raise "Invalid format for resource details:\n  #{line}"
    end
    title, level, category, file_re = $1, $2, $3, $4
    validate(level, category)
    file_re = Regexp.new(file_re)
    [title, level, category, file_re]
  end

  def extract_description(lines)
    lines[1..-1].join(NL).tabto(0) rescue ""
  end

  def file_html
    text = @title.tag(:b)
    Filters.file(text, @topic_number, @file_re)
  end

end

class Website
  def initialize(paragraph)
    # Process the paragraph into bits, taking account of the structure:
    #   <Linear graph animation> 5.23 F
    #     Take the challenge to determine an equation from its graph, and vice versa.
    lines = paragraph.split(NL)
    @title, @level, @category = extract_details(lines)
    @url                      = extract_url(lines)
    @description              = extract_description(lines)
  end

  attr_reader :title, :level, :category, :url, :description

  include ResourceWebsiteHelper

  def html
    out = String.new
    out << [url_html, level_html, category_html].join(" ") << NL
    out << description_html
    out.tag('p')
  end

  private
  DETAILS_RE = %r{< ([^>]+) > \s+     # title
                  (5.\d+) \s+         # level
                  ([A-Z,]+) \s* $     # category
                 }x
  def extract_details(lines)
    line = lines.first
    unless line =~ DETAILS_RE
      raise "Invalid format for website details:\n  #{line}"
    end
    title, level, category = $1, $2, $3
    validate(level, category)
    [title, level, category]
  end

  def extract_url(lines)
    unless lines[1].chomp =~ /^ *url: *(.+)$/
      error "Invalid URL spec: #{lines[1].strip}"
    end
    $1.strip
  end

  def extract_description(lines)
    lines[2..-1].join(NL).tabto(0) rescue ""
  end

  def url_html
    %[<a href="#@url" target="_blank" style="color: #0000FF"><b>#@title</b></a>]
  end
end  # class Website

