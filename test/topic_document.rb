
D "Heading" do
  D "valid construction" do
    h = Heading.new("Topic 2")
    Eq h.topic_number, 2
    Eq h.topic_name,   "Index laws"
    Eq h.html,         "<h2>Topic 2: Index laws</h2>"
  end
  D "from_section (valid and invalid)" do
    s = Section.new("Topic 2", [])
      Eq Heading.from_section(s).html, "<h2>Topic 2: Index laws</h2>"
    s = Section.new("Topic 2", ["Paragraph must be empty if it's a Heading"])
      E { Heading.from_section(s) }
    s = Section.new("Invalid heading string", ["Lorem ipsum"])
      E { Heading.from_section(s) }
  end
end

S :load_input_1 do
  input_text = File.read("test/data/input1.txt") 
  @t = TopicDocument.new(input_text)
end

D "TopicDocument (surface)" do
  S :load_input_1
  Eq @t.heading.topic_number, 16
  Eq @t.heading.topic_name,   "Coordinate geometry"
  @t.sections.tap do |sections|
    s = sections.shift
    T { Description === s }
    T { s.name == "Description" }
    T { s.paragraphs.size == 3 }
    T { s.paragraphs[1] =~ /\ANote: there is .+ and more\.\Z/m }
    s = sections.shift
    T { Resources === s }
    T { s.resources.size == 4 }
    s = sections.shift
    T { Websites === s }
    T { s.websites.size == 1 }
    s = sections.shift
    T { Note === s }
    T { s.paragraphs.size == 1 }
  end
end

S :load_output_1 do
  output_text = File.read("test/data/output1.html")
  @output1    = Lines.new(output_text).paragraphs
end

Filter.create(:red) { |text| Filters.colour('#FF0000', text) }

D "TopicDocument (deeper):" do
  S :load_input_1
  S :load_output_1
  @sections = @t.sections.dup
  D "correct heading HTML" do
    Eq @t.heading.html, @output1.shift
  end
  D "correct description HTML" do
    description = @sections.shift
    T { Description === description }
    Eq description.html.strip, @output1.shift(3).join("\n\n")
  end
  D "correct resources HTML" do
    resources = @sections.shift
    T { Resources === resources }
    Eq resources.html.strip, @output1.shift(5).join("\n\n")
  end
  D "correct websites HTML" do
    websites = @sections.shift
    T { Websites === websites }
    Eq websites.html.strip, @output1.shift(2).join("\n\n")
  end
  D "correct note HTML" do
    note = @sections.shift
    T { Note === note }
    Eq note.html.strip, @output1.shift(2).join("\n\n")
  end
end

D "TopicDocument (html) -- the big test from input file to output file" do
  input_text    = File.read("test/data/input1.txt") 
  expected_html = File.read("test/data/output1.html")
  t = TopicDocument.new(input_text)
  Eq t.html.strip, expected_html.strip
end
