#
# This file is scratchy but good.  It will probably need to be separated into
# smaller files, and it will certainly need to have unit tests written for most
# of the classes.
#

require 'rubygems'
require 'extensions/all'
require 'dev-utils/debug'
require 'ruby-debug'

NL = "\n"

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
end

class Line < String
  SQBR_RE = /^ \[ (.+) \] \s*/x
  # Is this a "square bracket" line?
  def sqbr?
    (self =~ SQBR_RE).not_nil?
  end
  def plain_text?
    not sqbr?
  end
  # If this is a "square bracket" line, return or yield the contents.
  def sqbr
    if self =~ SQBR_RE
      if block_given?
        return (yield $1)
      else
        return $1
      end
    end
  end
end

# A collection of Line objects, with methods to support the extraction of
# paragraphs (i.e. chunks of text in between section markers)
class Lines
  def initialize(string)
    @lines = string.split(NL).map { |x| Line.new(x.strip) }
    @index = 0  # We're pointing at the first line
  end
  # Fast-forward until we find a section-starter.  Then extract sections until
  # there are no lines left to process.  Returns an array of Section objects.
  def extract_sections
    fast_forward { |line| line.sqbr? }
    returning([]) do |result|
      until eof?
        result << extract_section
      end
    end
  end
    # The current line must be a section-starter.  We consume it and the following
    # paragraphs and return a Section object.
    # If a regex +re+ is given, we expect the name of the section to match it.
  def extract_section(re=nil)
    name = current_line.sqbr || error "extract_section: Not a section header: #{l}"
    if re and not name.match(re)
      error "extract_section: Expected name to match #{re.inspect}: #{name}"
    end
    paragraphs = extract_paragraphs
    Section.new(name, paragraphs)
  end
    # From the current line until we hit a new section, consume lines of text
    # and group them into paragraphs.  Return an array of array of strings.
  def extract_paragraphs
    result = []
    loop do
      paragraph = []
      if eof? or current_line.sqbr?
        result << paragraph
        return result
      elsif current_line.empty? and paragraph.not_empty?
        result << paragraph
        paragraph = []
      else
        paragraph << current_line
      end
    end
  end
  def current_line; @lines[@index]; end
  alias l current_line
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
    @heading = Heading.new @lines.extract_section(/Topic/).name
    @sections = @lines.extract_sections.map { |s|
      case s.name
      when "Resources"
        Resources.new(s.paragraphs, @heading.topic_number)
      when "Websites"
        Websites.new(s.paragraphs)
      when "Description", "Note", "Notes"
        s
      else
        error "Invalid section heading: #{s.name}"
      end
    }
  end
  def html
    returning(StringIO.new) do |out|
      out << @heading.html << NL
      @sections.each do |s|
        out << NL << s.html << NL
      end
    end
  end
end  # class TopicDocument

class Section
  def initialize(name, paragraphs)
    @name, @paragraphs = name, paragraphs
  end
  def html
    returning(StringIO.new) do |out|
      out << NL << name.tag(:h4) << NL
      @paragraphs.each do |p|
        out << p.tag(:p) << NL
      end
    end
  end
end

class Heading
  def initialize(name)
    @n = name.match(/Topic (\w+)/).captures[0]
    error "Invalid topic number #{n}" if n > 30
  end
  def html
    "Topic #{@n}: #{topic_name(n)}".tag(:h2)
  end
  def topic_number() @n end
  def topic_name(n)
    @@topic_names ||=
      File.readlines("topic_names.txt").
      build_hash { |line| m = line.match(//); [ m[1].to_i, m[2] ] }
    @@topic_names[n]
  end
end  # class Heading

class Description < Section; end

class Resources
  def initialize(paragraphs, n)
    @resources = paragraphs.map { |p| Resource.new(p, n) }
  end
  def html
    returning(StringIO.new) do |out|
      @resources.each do |r|
        out << NL << r.html
      end
    end
  end
end

class Websites
  def initialize(paragraphs)
    @websites = paragraphs.map { |p| Website.new(p) }
  end
end

class Note < Section; end
class Notes < Section; end

class Resource
  def initialize(paragraph, topic_number)
    # Process the paragraph into bits, taking account of the structure:
    #   <Coordinate geometry skills worksheet> 5.23 F (pdf) file:^A030.+worksheet.pdf
    #     A summary of (nearly?) all the skills taught in this topic.
    #     {-file:Solutions|PDF|A030*SOLUTIONS.pdf}
    @topic_number = topic_number
    @title = nil
    @_5123 = nil
    @fupsr = nil
    @type  = nil
    @file_re = nil
    @description = nil
  end
end

class Website
  def initialize(paragraph)
    # Process the paragraph into bits, taking account of the structure:
    #   <Linear graph animation> 5.23 F
    #     Take the challenge to determine an equation from its graph, and vice versa.
    @title = nil
    @_5123 = nil
    @fupsr = nil
    @description = nil
  end
end
