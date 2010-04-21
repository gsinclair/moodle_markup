# [The following is taken from the TextParser class comment]
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
#    Filter[:red, "live"],
#    "languate, with a weekly news radio program\neven being broadcase from ",
#    Filter[:wp, "Switzerland"],
#    ".  See more in\n",
#    Filter[:file, "this file", "A025*.pdf"],
#    ".  *Some occupations* using Latin include:\n* vetinarian\n*botanist\n*Latin teacher"
#   ]

D "TextParser" do

  S :text do
    @text = %{
      *Latin* is a {red:live} language, with a weekly news radio program
      even being broadcast from {wp:Switzerland}.  See more in
      {file:this file:A025.*.pdf}.  *Some occupations* using Latin include:
      * vetinarian
      * botanist
      * Latin teacher
    }.trim.tabto(0)
  end

  D "TextParser.step1" do
    S :text
    result = TextParser.step1(@text)
    Eq result.size, 7
    Eq result.shift, "*Latin* is a "
    Eq result.shift, Array[:red, "live"]
    Eq result.shift,
      " language, with a weekly news radio program\neven being broadcast from "
    Eq result.shift, Array[:wp, "Switzerland"]
    Eq result.shift, ".  See more in\n"
    Eq result.shift, Array[:file, "this file", "A025.*.pdf"]
    Eq result.shift,
      ".  *Some occupations* using Latin include:" +
      "\n* vetinarian\n* botanist\n* Latin teacher\n"
  end


  #
  # Filters created for testing TextParser.step2
  #
  Filter.create(:red)  { |text| %[<span style="color: #FF0000">#{text}</span>] }
  Filter.create(:red)  { |text| %[%{color: #FF0000}#{text}%] }
  Filter.create(:file) { |text, file_re| Filters.file_filter(text, file_re) }
  Filter.create(:wp)   { |text| %+["#{text}":http://en.wikipedia.org/#{text}]+ }
  def Filters.file_filter(text, file_re)
    %+["#{text}":http://example.com]+
  end

  D "TextParser.step2" do
    S :text
    array = TextParser.step1(@text)
      # We assume this works because it was tested in "TextParser.step1" above.
    result = TextParser.step2(array)
    Eq result.size, 7
    Eq result.shift, "*Latin* is a "
    Eq result.shift, %[%{color: #FF0000}live%]
    Eq result.shift, " language, with a weekly news radio program\neven being broadcast from "
    Eq result.shift, %+["Switzerland":http://en.wikipedia.org/Switzerland]+
    Eq result.shift, ".  See more in\n"
    Eq result.shift, %+["this file":http://example.com]+
    Eq result.shift,
      ".  *Some occupations* using Latin include:" +
      "\n* vetinarian\n* botanist\n* Latin teacher\n"
  end

  D "TextParser.parse with 'Latin' example" do
    S :text
    html = TextParser.parse(@text)
    Eq html, %{
<p><strong>Latin</strong> is a <span style="color: #FF0000;">live</span> language, with a weekly news radio program
even being broadcast from <a href="http://en.wikipedia.org/Switzerland">Switzerland</a>.  See more in
<a href="http://example.com">this file</a>.  <strong>Some occupations</strong> using Latin include:</p>
<ul>
	<li>vetinarian</li>
	<li>botanist</li>
	<li>Latin teacher</li>
</ul>
    }.trim.chomp
  end

  D "TextParser.step1 with filter spanning two lines" do
    text = %{
      Sometimes I just wanna {highlight:party all night
      with my friends}.
    }.trim.tabto(0)
    result = TextParser.step1(text)
    Eq result.size, 3
    Eq result.shift, "Sometimes I just wanna "
    T { Array === result.first }
    Eq result.shift, Array[:highlight, "party all night\nwith my friends"]
    Eq result.shift, ".\n"
  end

end  # D "TextParser"
