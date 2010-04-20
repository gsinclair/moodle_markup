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

S :text do
  @text = %{
    *Latin* is a {red:live} language, with a weekly news radio program
    even being broadcast from {wp:Switzerland}.  See more in
    {file:this file:A025.*.pdf}.  *Some occupations* using Latin include:
    * vetinarian
    * botanist
    * Latin teacher
  }.trim.tabto(0)
  @parser = TextParser.new("Dummy text")
end

D "TextParser#step1" do
  S :text
  result = @parser.step1(@text)
  Eq result.size, 7
  Eq result.shift, "*Latin* is a "
  Eq result.shift, Filter.new(:red, "live")
  Eq result.shift,
    " language, with a weekly news radio program\neven being broadcast from "
  Eq result.shift, Filter.new(:wp, "Switzerland")
  Eq result.shift, ".  See more in\n"
  Eq result.shift, Filter.new(:file, "this file", "A025.*.pdf")
  Eq result.shift,
    ".  *Some occupations* using Latin include:" +
    "\n* vetinarian\n* botanist\n* Latin teacher\n"
end
