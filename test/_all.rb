
# Load all the unit tests, or the ones that match the filter provided.
# Assume current directory is 'rgeom'.

require 'rubygems'
require 'dfect/auto'

require 'extensions/string'
require 'pp'
gem 'awesome_print'
require 'ap'

require 'moodle_markup'  # The thing we're testing.


# The first argument allows us to decide which file(s) get loaded.
filter = Regexp.compile(ARGV.first || '.')

Dir['test/**/*.rb'].grep(filter).each do |file|
  next if file == "test/_all.rb"
  load file
end

