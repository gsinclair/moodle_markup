
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
  #   Filter.create(:bold) { |str| "<b>" + str + "</b>" }
  #
  #   Filter[:bold].apply("some text")        # -> "<b>some text</b>"
  #
class Filter
  @@index = {}
  @@backup = {}
  def Filter.[](name)
    @@index[name]
  end
  def Filter.create(name, &block)
    if @@index.key? name
      @@backup[name] = @@index[name]
    end
    @@index[name] = Filter.new(name, block)
  end
  def Filter.destroy(name)
    if @@backup.key? name
      @@index[name] = @@backup[name]
    else
      @@index.delete(name)
    end
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
Filter.create(:red)       { |text, topicn, regex| Filters.colour('#FF0000', text) }

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
