#
# This file is scratchy but good.  It will probably need to be separated into
# smaller files, and it will certainly need to have unit tests written for most
# of the classes.
#

require 'rubygems'
require 'extensions/all'
require 'dev-utils/debug'
require 'ruby-debug'
require 'redcloth'

NL = "\n"

class Options
  COURSE_ID = 153
  RESOURCE_TITLE_COLOUR = "#0000FF"
  CATEGORY_COLOUR       = "#FF0000"
  MAIN_HEADING_TAG      = :h2
  SUB_HEADING_TAG       = :h4
end

def error(msg=nil)
  if msg
    raise StandardError, msg
  else
    raise StandardError
  end
end

def returning(obj)
  yield obj
end

class Object
  def not_empty?
    not empty?
  end
end

class String
  def tag(t)
    open, close = "<#{t}>", "</#{t}>"
    open + self + close
  end
  def untag(t)
    if self =~ %r{ \A <#{t}> (.*) </#{t}> \Z }mx
      $1
    else
      self
    end
  end
end

class Dirs
  def Dirs.local() File.expand_path("~/My Documents/16. Enable/Web content") end
  def Dirs.server() "../file.php/#{Options::COURSE_ID}" end

  def Dirs.level_images() File.join( server, "images" ) end

  # Returns local and server directory for the given topic number.  E.g.
  #   Dirs.resource_directory(16)
  #     # -> [ "~/My Documents/16. Enable/Web content/11-20/16",
  #     #      "../file.php/153/11-20/16" ]
  def Dirs.resource_directory(n)
    group =
      case n
      when  1..10 then "1-10"
      when 11..20 then "11-20"
      when 21..30 then "21-30"
      else
        error "Invalid argument: #{n}"
      end
    _local  = File.join( local,  group, n.to_s )
    _server = File.join( server, group, n.to_s )
    [_local, _server]
  end

  # Returns a pathname for the file on the server in topic _n_ matching the
  # _regex_.
  def Dirs.server_file(n, regex)
    _local, _server = resource_directory(n)
    filenames = Dir.entries(_local).grep(regex)
    filename =
      case filenames.size
      when 0
        debug ( Dir.entries(_local) ).join(NL).indent(4)
        error "No files match #{regex.inspect} in topic ##{n}"
      when 1
        filenames.first.gsub(' ', '_')
      else
        error "Too many files match #{regex.inspect} in topic ##{n}:\n" +
          filenames.join("\n").indent(4)
      end
    File.join(_server, filename)
  end
end  # class Dirs

# A collection of strings, with methods to support the extraction of
# sections (headings and the paragraphs that follow).
#
#   lines.paragraphs
#     # -> [ String, String, String, ... ]
#     # (no care for section headers; they're just another paragraph)
#
#   lines.sections
#     # -> [ Section, Section, ... ]
#     # (each section has a heading and some paragraphs)
#
# Note there's an internal position marker, so you can't extract paragraphs
# _then_ extract sections, because after the first operation it will be at EOF.
#                              
class Lines
  def initialize(string)
    @lines = string.gsub("\r", "").split(NL)
    @index = 0  # We're pointing at the first line
  end

    # Return an array of paragraphs (each one an array of strings).
  def paragraphs
    result = []
    paragraph = []
    loop do
      if eof?
        result << paragraph.join(NL)
        return result
      elsif current_line.empty?
        if paragraph.empty?
          # No action
        else
          result << paragraph.join(NL)
          paragraph = []
        end
      else
        paragraph << current_line
      end
      move_on
    end
  end

  def sections
    paragraphs = paragraphs()
      # [ "[Topic 16]", "...", "...", "[Resources]", "...", "...", ... ]
    unless section_title?( paragraphs.first )
      raise "Document must start with section heading"
    end
    result = []
    until paragraphs.empty?
      name = section_title( paragraphs.shift )
      raise "Coding error" if name.nil?
      idx = paragraphs.index { |p| section_title?(p) }
        # ^^^ We want the index of the _next_ section so we can strip out the
        #     intervening paragraphs.
      paras_belonging_to_this_section =
        case idx
        when nil  # No other section was found; consume the rest of the array.
          paragraphs.slice!(0..-1)
        when 0    # The very next paragraph is a new section; we consume nothing.
          []
        else      # There's a new section in some future paragraph.
          paragraphs.slice!(0...idx)
        end
      result << Section.new(name, paras_belonging_to_this_section)
    end
    result
  end

  SECTION_TITLE = /\A \[ (.+) \] \s* \Z/x
  def section_title?(str)
    str =~ SECTION_TITLE
  end
  def section_title(str)
    if str =~ SECTION_TITLE
      $1
    end
  end

  def current_line; @lines[@index]; end
  def move_on; @index += 1; end
  def eof?; current_line.nil?; end
end  # class Lines

# Contains a Heading and various Section objects.
class TopicDocument
  def initialize(string)
    @lines = Lines.new(string)
    process
  end
  def process
    sections = @lines.sections
    @heading = Heading.from_section(sections.shift)
    @sections = sections.map { |s|
      case s.name
      when "Resources"
        Resources.new(s.paragraphs, @heading.topic_number)
      when "Websites"
        Websites.new(s.paragraphs)
      when "Description"
        Description.new(s.paragraphs)
      when "Note"
        Note.new(s.paragraphs)
      when"Notes"
        Notes.new(s.paragraphs)
      else
        error "Invalid section heading: #{s.name}"
      end
    }
  end
  attr_reader :heading, :sections
  def html
    returning(StringIO.new) do |out|
      out << @heading.html << NL
      @sections.each do |s|
        out << NL << s.html << NL
      end
    end
  end
end  # class TopicDocument

class Heading
  def initialize(name)
    raise ArgumentError unless name =~ /Topic (\w+)/
    n = $1.to_i
    error "Invalid topic number #{n}" if n > 30
    @topic_number = n
    @topic_name   = _topic_name(n)
  end
  def Heading.from_section(section)
    raise ArgumentError unless section.paragraphs.empty?
    Heading.new(section.name)
  end
  attr_reader :topic_number, :topic_name
  def html
    "Topic #{@topic_number}: #{@topic_name}".tag(:h2)
  end
  private
  def _topic_name(n)
    @@topic_names ||=
      File.readlines("topic-names.txt").
      build_hash { |line| m = line.match(/^(\d+)\. (.+)$/); [ m[1].to_i, m[2].strip ] }
    @@topic_names[n]
  end
end  # class Heading

class Section
  def initialize(name, paragraphs)
    @name, @paragraphs = name, paragraphs
  end
  attr_reader :name, :paragraphs
  def html
    out = String.new
    _html_heading(out)
    _html_paragraphs(out)
    out
  end
  protected
  def _html_heading(out)
    out << NL << @name.tag(Options::SUB_HEADING_TAG) << NL
  end
  def _html_paragraphs(out)
    @paragraphs.each do |p|
      out << NL << TextParser.parse(p) << NL
    end
  end
end

class SelfNamingSection < Section
  def initialize(paragraphs)
    super(self.class.name, paragraphs)
  end
end

class Description < SelfNamingSection
    # Description doesn't print the heading "Description"; just the contents of
    # the section.
  def html
    out = String.new
    _html_paragraphs(out)
    out
  end
end

class Resources
  def initialize(paragraphs, n)
    @resources = paragraphs.map { |p| Resource.new(p, n) }
  end
  attr_reader :resources
  def html
    out = String.new
    out << "Resources".tag(Options::SUB_HEADING_TAG) << NL
    @resources.each do |r|
      out << NL << r.html << NL
    end
    out
  end
end

class Websites
  def initialize(paragraphs)
    @websites = paragraphs.map { |p| Website.new(p) }
  end
  attr_reader :websites
end

class Note  < SelfNamingSection; end
class Notes < SelfNamingSection; end

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
    @levels = @level.sub('5.','').split(//)   # [2, 3]
  end

  attr_reader :topic_number, :title, :level, :category, :file_re
  attr_reader :description

  def html
    out = String.new
    out << [file_html, level_html, category_html].join(" ") << NL
    out << description_html
    out.tag('p')
  end

  private
  DETAILS_RE = %r{< ([^>]+) > \s+ (5.\d+) \s+ ([A-Z,]+) \s+   # title, level, category
                  file:(.+) \s* $                             # file_re
                 }x
  def extract_details(lines)
    line = lines.first
    unless line =~ DETAILS_RE
      raise "Invalid format for resource details:\n  #{line}"
    end
    title, level, category, file_re = $1, $2, $3, $4
    Resource.validate(level, category)
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

  def level_html
    alt_text = @levels.map { |x| "5.#{x}" }.join(', ')
    image_path = File.join( Dirs.level_images, "#{@levels.join}.png" )
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

  def Resource.validate(level, category)
    unless level =~ /^5.(1|2|3|12|23|123)$/
      raise "Invalid value for 'level': #{level}"
    end
    unless category.split(',').all? { |x| x.in? %w[PS U F R] }
      raise "Invalid value for 'category': #{category}"
    end
  end
end

class Website
  def initialize(paragraph)
    # Process the paragraph into bits, taking account of the structure:
    #   <Linear graph animation> 5.23 F
    #     Take the challenge to determine an equation from its graph, and vice versa.
    lines = paragraph.split(NL)
    @title, @level, @category = extract_details(lines)
    @description  = extract_description(lines)
  end
  attr_reader :title, :level, :category, :description
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
    Resource.validate(level, category)
    [title, level, category]
  end

  def extract_description(lines)
    lines[1..-1].join(NL).tabto(0) rescue ""
  end
end  # class Website



# = TextParser
#
# Takes paragraph text, looks for things like {red:...} or {-file:...}, or
# bullet points, or...; splits it up, processes stuff, runs it through textile,
# and produces HTML.
#
# Example input:
#   *Latin* is a {red:live} language, with a weekly news radio program
#   even being broadcast from {wp:Switzerland}.  See more in
#   {file:this file:A025.*.pdf}.  *Some occupations* using Latin include:
#   * vetinarian
#   * botanist
#   * Latin teacher
#
# Step 1 of processing would produce:
#   ["*Latin* is a ",
#    [:red, "live"],
#    "languate, with a weekly news radio program\neven being broadcase from ",
#    [:wp, "Switzerland"],
#    ".  See more in\n",
#    [:file, "this file", "A025*.pdf"],
#    ".  *Some occupations* using Latin include:\n* vetinarian\n*botanist\n*Latin teacher"
#   ]
#
# From there:
#  * each array like <tt>[:red, "live"] is passed through the appropriate filter
#    to produce an HTML snippet (string), meaning we have an array of strings
#      ["*Latin* is a ", "<span color="#FF0000">live</span>", "language, with...", ...]
#
#  * the array is joined to form one string
#      "*Latin* is a <span color="#FF0000">live</span> language, with ..."
#
#  * that string is processed by Textile to produce an HMTL paragraph
#      "<b>Latin</b> is a <span color="#FF0000">live</span> language, with ..."
#
# This order is important because Textile markers could surround a {} block;
# e.g.
#   I am *so {red:excited} I have to write in bold*!!!"
#
# Also, note that the string contents of a Filter must be Textile-processed as
# well; e.g.
#   I went {red:down to the _river_ to pray}.
#   NOTE: This is not done and probably won't be.
#
# Note: Only one paragraph at a time should be sent to TextParser.parse.
#
class TextParser
  private :initialize

  def TextParser.parse(string)
    array  = step1(string)     # Split into String and Array objects
    array  = step2(array)      # Turn Filter objects into HTML
    string = array.join("")    # Now one big paragraph...
    returning(RedCloth.new(string)) { |r|
      r.hard_breaks = false
      r.no_span_caps = true
      r.to_html
    }
  end

    # Find any {}-delimited strings and turn them into Filter objects.
    # See TextParser documentation for an example.
  def TextParser.step1(string)
    re = / \{ .*? \}  |  [^{}]+ /mx
    string.scan(re).map { |str|
      if str =~ /\{ (.*?):(.*?) \}/mx
        filter_name = $1.intern
        filter_args = $2.split('|')
        [filter_name, filter_args].flatten
      else
        str
      end
    }
  end

    # Turn Filter objects into HTML (run through textile) so that
    # we return an array of strings.  Strings in the input array
    # are passed through untouched.
  def TextParser.step2(array)
    array.map { |obj|
      case obj
      when String
        obj
      when Array
        name = obj.first
        args = obj.slice(1..-1)
        if Filter[name].nil?
          warn "No filter named '#{name}' has been defined"
          Filter[:default].apply(name, *args)
        else
          Filter[name].apply(*args)
        end
      end
    }
  end
end  # class TextParser


  # Example usage:
  #
  #   Filter[:bold] { |str| "<b>" + str + "</b>" }
  #
  #   Filter[:bold].apply("some text")        # -> "<b>some text</b>"
  #
class Filter
  @@index = {}
  def Filter.[](name)
    @@index[name]
  end
  def Filter.create(name, &block)
    @@index[name] = Filter.new(name, block)
  end
  def initialize(name, block)
    @name, @block = name, block
  end
  def apply(*args)
    @block.call(*args)
  end
end

Filter.create(:default) { |*args|
  args_str = args.map { |x| x.inspect }.join(':')
  %+*%{color: purple; border-bottom: 3px double}Filter[==#{args_str}==]%*+
}
Filter.create(:highlight) { |text| Filters.colour('#990066', text) }
Filter.create(:warn)      { |text| Filters.bold(text) }
Filter.create(:file)      { |text, topicn, regex| Filters.file(text, topicn, regex) }

module Filters
  class << self
    def colour(col, text)
      "%{color: #{col}}#{text}%"
    end
    def bold(text)
      "*#{text}*"
    end
    # Create a link to a file in the given topic (matching +regex+).
    # e.g.
    #   file('Exercise 5.09', '13', '^Exer.+.pdf')
    def file(text, topicn, regex)
      topicn = topicn.to_i
      regex = Regexp.compile(regex)
      path = Dirs.server_file(topicn, regex)
      title = File.extname(path).upcase.sub('.', '')
      colour = Options::RESOURCE_TITLE_COLOUR
      %[<a href="#{path}" target="_blank" title="#{title}" ] +
      %[style="color: #{colour}">#{text}</a>]
    end
  end
end
