# = moodle_markup.rb
#
# A library for turning text files into HTML suitable for placing on Moodle.
#
# Designed for use by PLC Sydney Mathematics Department, and not likely to be
# useful to anyone else!
#
# Example input file:
#
#   [Topic 16]
#   
#   [Description]
#   
#   Coordinate geometry is a large topic. The programme is divided into three parts:
#    * 16a: distance, midpoint, gradient diagrams; number plane graphs
#    * 16b: distance, midpoint, gradient formulas; y = mx + b
#    * 16c: further equations of a line; regions
#   
#   Note: there is a lot of detail in the "y = mx + b" area: sketching; finding
#   equations; parallel and perpendicular lines; general form; and more.
#   
#   {highlight:Only 16a and 16b were assessed in Task 2 on 17 March 2010.}
#   
#   [Resources]
#   
#   <Coordinate geometry skills worksheet> 5.23 F file:^A030.+worksheet.pdf
#     A summary of (nearly?) all the skills taught in this topic.
#     {file:Solutions|16|A030.*SOLUTIONS.pdf}
#   
#   <Further equations of straight lines> 5.3 F,PS file:^Further.+lines.pdf
#     Textbook exercise with more challenging questions on finding the equations of
#     straight lines.
#   
#   <Graphing straight line families> 5.123 U file:^Graphing
#     A GSP file encouraging you to think about the relationship between a linear
#     equation and the corresponding graph. Essentially a teaching resource, but
#     useful for independent study. {warn:Only works if you have Geometers Sketchpad
#     installed.}
#   
#   <Gradient product of perpendicular lines> 5.2 U file:^A019 Gradient.+.gsp$
#     Explore the relationship between the gradients of two lines when they become
#     perpendicular. {warn:Only works if you have Geometers Sketchpad installed.}
#   
#   [Websites]
#   
#   <Linear graph animation> 5.1 F
#     url:http://example.com
#     Take the challenge to determine an equation from its graph, and vice versa.
#   
#   [Note]
#   
#   {red:U} = Understanding; {red:F} = Fluency; {red:PS} = Problem Solving
#
# The output contains links to the appropriate files, replaces things like
# <tt>{warn:Only works if...}</tt> with appropriately-styled HTML, contains
# images representing level of difficulty (5.1, 5.2, 5.3), and more.
#
# Errors are reported if anything in the input is not as it should be:
# - invalid level or category codes like "5.4" or "U,M"
# - invalid section title like "[See Also]"
# - resource or website info line not correctly formatted

require 'rubygems'
require 'extensions/all'
require 'redcloth'

require 'moodle_markup/01_support'
require 'moodle_markup/02_options_dirs_lines'
require 'moodle_markup/03_resource_and_website'
require 'moodle_markup/04_topic_document'
require 'moodle_markup/05_parser_and_filter'
