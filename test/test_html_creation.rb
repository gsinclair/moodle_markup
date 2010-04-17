#
# This file was a scratchy start and will be deleted once the few, if any, good
# bits are stripped from it.
#

require 'rubygems'
require 'stringio'
require 'extensions/string'
require 'pp'
require 'dfect/auto'

class String
  def unpack
    unless self =~ /^\[(.+)\]\s*$/
      raise StandardError, "unpack: improperly formatted line: #{self}"
    end
    $1
  end
end

class Markup
  NL = "\n"
  def initialize(str)
    @data = str.split(NL)
  end
  def Markup.from_file(path)
    Markup.new(File.read(path))
  end
  def result
    out = StringIO.new
    out << read_heading << NL
  end
  def read_heading
    line = next_line.unpack
    n = expect line, /^Topic (\d+)$/
    "<h2>#{lookup_topic_title(n)}</h2>"
  end
  def next_line
    line = @data.shift until line.nil? or line.empty?
  end
  def lookup_topic_title(n)
    "Topic 16: Coordinate geometry"
  end
  def expect(str, re, n=1)
    error "Expected #{re}" unless match = line.match(re)
    case m = match[n]
    when /\d+/
      m.to_f
    else
      m
    end
  end
  def error(msg=nil)
    raise StandardError, msg
  end
end

def Dfect.E(expected, actual)
  T(expected.pp_s) { expected == actual }
end

Dfect.options = { :debug => false }

D .< { @markup = Markup.from_file("data/input1.txt") }
D "Low-level methods" do
  L @markup.class
  E "<h2>Topic 16: Coordinate geometry</h2>", @markup.read_heading
end

