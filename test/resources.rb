
D "TopicDocument (resource 1)" do
  text = %{
    <Coordinate geometry skills worksheet> 5.23 F (pdf) file:^A030.+worksheet.pdf
      A summary of (nearly?) all the skills taught in this topic.
      {-file:Solutions|PDF|A030*SOLUTIONS.pdf}
  }.trim.tabto(0).chomp
  r = Resource.new(text, 16)
  T { Resource === r }
  Eq r.topic_number, 16
  Eq r.title,        "Coordinate geometry skills worksheet"
  Eq r.level,        "5.23"
  Eq r.category,     "F"
  Eq r.filetype,     "PDF"
  Eq r.file_re,      /^A030.+worksheet.pdf/
  Eq r.description, %{
    A summary of (nearly?) all the skills taught in this topic.
    {-file:Solutions|PDF|A030*SOLUTIONS.pdf}
  }.trim.tabto(0).chomp
end

D "TopicDocument (resource 2)" do
  text = %{
    <y = mx + b interactive> 5.23 U (ggb) file:interactive.ggb
      Manipulate the values of _m_ and _b_ in this GeoGebra file, and see the effect
      they have on the graph.
  }.trim.tabto(0).chomp
  r = Resource.new(text, 16)
  T { Resource === r }
  Eq r.topic_number, 16
  Eq r.title,        "y = mx + b interactive"
  Eq r.level,        "5.23"
  Eq r.category,     "U"
  Eq r.filetype,     "GGB"
  Eq r.file_re,      /interactive.ggb/
  Eq r.description, %{
    Manipulate the values of _m_ and _b_ in this GeoGebra file, and see the effect
    they have on the graph.
  }.trim.tabto(0).chomp
end

D "TopicDocument (resource 3)" do
  text = %{
    <Further equations of straight lines> 5.3 F,PS (pdf) file:^Further
      Textbook exercise with more challenging questions on finding the equations of
      straight lines.
  }.trim.tabto(0).chomp
  r = Resource.new(text, 16)
  T { Resource === r }
  Eq r.topic_number, 16
  Eq r.title,        "Further equations of straight lines"
  Eq r.level,        "5.3"
  Eq r.category,     "F,PS"
  Eq r.filetype,     "PDF"
  Eq r.file_re,      /^Further/
  Eq r.description, %{
    Textbook exercise with more challenging questions on finding the equations of
    straight lines.
  }.trim.tabto(0).chomp
end

D "TopicDocument (resource 4)" do
  text = %{
    <Graphing straight line families> 5.123 U (gsp) file:^Graphing
      A GSP file encouraging you to think about the relationship between a linear
      equation and the corresponding graph. Essentially a teaching resource, but
      useful for independent study. {warn:Only works if you have Geometers Sketchpad
      installed.}
  }.trim.tabto(0).chomp
  topic_num = rand(30)
  r = Resource.new(text, topic_num)
  T { Resource === r }
  Eq r.topic_number, topic_num
  Eq r.title,        "Graphing straight line families"
  Eq r.level,        "5.123"
  Eq r.category,     "U"
  Eq r.filetype,     "GSP"
  Eq r.file_re,      /^Graphing/
  Eq r.description, %{
    A GSP file encouraging you to think about the relationship between a linear
    equation and the corresponding graph. Essentially a teaching resource, but
    useful for independent study. {warn:Only works if you have Geometers Sketchpad
    installed.}
  }.trim.tabto(0).chomp
end

D "TopicDocument (resource 5)" do
  text = %{
    <Gradient product of perpendicular lines> 5.1 U,F,PS,R (gsp) file:^Gradient
      Explore the relationship between the gradients of two lines when they become
      perpendicular. {warn:Only works if you have Geometers Sketchpad installed.}
  }.trim.tabto(0).chomp
  r = Resource.new(text, 16)
  T { Resource === r }
  Eq r.topic_number, 16
  Eq r.title,        "Gradient product of perpendicular lines"
  Eq r.level,        "5.1"
  Eq r.category,     "U,F,PS,R"
  Eq r.filetype,     "GSP"
  Eq r.file_re,      /^Gradient/
  Eq r.description, %{
    Explore the relationship between the gradients of two lines when they become
    perpendicular. {warn:Only works if you have Geometers Sketchpad installed.}
  }.trim.tabto(0).chomp
end

D "TopicDocument (invalid resource 1)" do
  text = %{
    <King's Gambit Declined> 5.4 U (gsp) file:^Gradient
      This resource is erroneous because 5.4 is an invalid level.
  }.trim.tabto(0).chomp
  E { r = Resource.new(text, 7) }
end

D "TopicDocument (invalid resource 2)" do
  text = %{
    <King's Gambit Declined> 5.2 U,T (gsp) file:^Gradient
      This resource is erroneous because T is an invalid category.
  }.trim.tabto(0).chomp
  E { r = Resource.new(text, 7) }
end

