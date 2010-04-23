
class Options
  COURSE_ID = 153
  RESOURCE_TITLE_COLOUR = "#0000FF"
  CATEGORY_COLOUR       = "#FF0000"
  MAIN_HEADING_TAG      = :h2
  SUB_HEADING_TAG       = :h4
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



  # == Lines
  #
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
  # See 
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


  # A Section object has a name and a collection of paragraphs, and it knows how
  # to render itself in HTML.  The paragraphs are fed through TextParser, so {}
  # filters are processed and the text treated as Textile and processed by
  # RedCloth.
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

  # A SelfNamingSection is just like a Section, but you don't give it a name: its
  # name is the name of the class.  For example:
  #   class Contacts < SelfNamingSection; end
  #   Contacts.new.name        # -> "Contacts"
class SelfNamingSection < Section
  def initialize(paragraphs)
    super(self.class.name, paragraphs)
  end
end

