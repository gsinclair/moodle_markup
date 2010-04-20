
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
    T { s.resources.size == 5 }
    s = sections.shift
    T { Websites === s }
    T { s.websites.size == 1 }
    s = sections.shift
    T { Note === s }
    T { s.paragraphs.size == 1 }
  end
end

xD "TopicDocument (html)" do
  input_text    = File.read("test/data/input1.txt") 
  expected_html = File.read("test/data/output1.html")
  t = TopicDocument.new(input_text)
  Eq t.html, expected_html
end
