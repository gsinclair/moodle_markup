
  #
  # TopicDocument is the heart of moodle-markup.  It embodies the structure of a
  # topic's contents, taking a blob of text and extracting meaningful sections
  # like Resources and Websites.  It can then turn the whole lot into HTML.
  #
  #   t = TopicDocument.new("[Topic 16]\n\n[Description]\n\nCoordinate geometry is...")
  #   t.to_html
  #     # -> "<h2>Topic 16: Coordinate geometry</h2>\n\nCoordinate geometry is..."
  #
  # Of course the heavy lifting is done by classes such as Heading, Resources,
  # etc., which actually make up the content.  But those classes are not of great
  # interest to casual users of this library, who shouldn't need to do anything
  # other than read a text file, call TopicDocument.new and then #html.
  #
  # The input text file is restricted to the following section headings
  #
  #   [Topic nn]             -> Heading (special case; must be first section)
  #   [Description]          -> Description
  #   [Resources]            -> Resources
  #   [Websites]             -> etc.
  #   [Note]
  #   [Notes]
  #
class TopicDocument
  def initialize(string)
    @lines = Lines.new(string)
    process
  end
  attr_reader :heading, :sections
  def html
    String.new.tap { |str|
      str << @heading.html << NL
      @sections.each do |s|
        str << NL << s.html << NL
      end
      str.gsub! /\n\n\n*/, "\n\n"
    }
  end
  private
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
  def html
    out = String.new
    out << "Websites".tag(Options::SUB_HEADING_TAG) << NL
    @websites.each do |w|
      out << NL << w.html << NL
    end
    out
  end
end

class Note  < SelfNamingSection; end
class Notes < SelfNamingSection; end

