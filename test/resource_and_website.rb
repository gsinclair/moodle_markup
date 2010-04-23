
D "Resource (resource 1)" do
  text = %{
    <Coordinate geometry skills worksheet> 5.23 F file:^A030.+worksheet.pdf
      A summary of (nearly?) all the skills taught in this topic.
      {file:Solutions|16|A030.*SOLUTIONS.pdf}
  }.trim.tabto(0).chomp
  r = Resource.new(text, 16)
  T { Resource === r }
  Eq r.topic_number, 16
  Eq r.title,        "Coordinate geometry skills worksheet"
  Eq r.level,        "5.23"
  Eq r.category,     "F"
  Eq r.file_re,      /^A030.+worksheet.pdf/
  Eq r.description, %{
    A summary of (nearly?) all the skills taught in this topic.
    {file:Solutions|16|A030.*SOLUTIONS.pdf}
  }.trim.tabto(0).chomp
  Eq r.html, %{
<p><a href="../file.php/153/11-20/16/A030_Coordinate_geometry_skills_worksheet.pdf" target="_blank" title="PDF" style="color: #0000FF"><b>Coordinate geometry skills worksheet</b></a> <img width="60" vspace="0" hspace="0" height="10" border="0" title="5.2, 5.3" alt="5.2, 5.3" src="../file.php/153/images/23.png" /> <span style="color: #FF0000"><b>(F)</b></span>
A summary of (nearly?) all the skills taught in this topic.
<a href="../file.php/153/11-20/16/A030_Coordinate_geometry_skills_worksheet_SOLUTIONS.pdf" target="_blank" title="PDF" style="color: #0000FF">Solutions</a></p>
  }.strip
end

D "Resource (resource 2)" do
  text = %{
    <y = mx + b interactive> 5.23 U file:interactive.ggb
      Manipulate the values of _m_ and _b_ in this GeoGebra file, and see the effect
      they have on the graph.
  }.trim.tabto(0).chomp
  r = Resource.new(text, 16)
  T { Resource === r }
  Eq r.topic_number, 16
  Eq r.title,        "y = mx + b interactive"
  Eq r.level,        "5.23"
  Eq r.category,     "U"
  Eq r.file_re,      /interactive.ggb/
  Eq r.description, %{
    Manipulate the values of _m_ and _b_ in this GeoGebra file, and see the effect
    they have on the graph.
  }.trim.tabto(0).chomp
  xEq r.html, %{
  }.strip
end

D "Resource (resource 3)" do
  text = %{
    <Further equations of straight lines> 5.3 F,PS file:^Further.+lines.pdf
      Textbook exercise with more challenging questions on finding the equations of
      straight lines.
  }.trim.tabto(0).chomp
  r = Resource.new(text, 16)
  T { Resource === r }
  Eq r.topic_number, 16
  Eq r.title,        "Further equations of straight lines"
  Eq r.level,        "5.3"
  Eq r.category,     "F,PS"
  Eq r.file_re,      /^Further.+lines.pdf/
  Eq r.description, %{
    Textbook exercise with more challenging questions on finding the equations of
    straight lines.
  }.trim.tabto(0).chomp
  Eq r.html, %{
<p><a href="../file.php/153/11-20/16/Further_equations_of_straight_lines.pdf" target="_blank" title="PDF" style="color: #0000FF"><b>Further equations of straight lines</b></a> <img width="60" vspace="0" hspace="0" height="10" border="0" title="5.3" alt="5.3" src="../file.php/153/images/3.png" /> <span style="color: #FF0000"><b>(F,PS)</b></span>
Textbook exercise with more challenging questions on finding the equations of
straight lines.</p>
  }.strip
end

D "Resource (resource 4)" do
  text = %{
    <Graphing straight line families> 5.123 U file:^Graphing
      A GSP file encouraging you to think about the relationship between a linear
      equation and the corresponding graph. Essentially a teaching resource, but
      useful for independent study. {warn:Only works if you have Geometers Sketchpad
      installed.}
  }.trim.tabto(0).chomp
  r = Resource.new(text, 16)
  T { Resource === r }
  Eq r.topic_number, 16
  Eq r.title,        "Graphing straight line families"
  Eq r.level,        "5.123"
  Eq r.category,     "U"
  Eq r.file_re,      /^Graphing/
  Eq r.description, %{
    A GSP file encouraging you to think about the relationship between a linear
    equation and the corresponding graph. Essentially a teaching resource, but
    useful for independent study. {warn:Only works if you have Geometers Sketchpad
    installed.}
  }.trim.tabto(0).chomp
  Eq r.html, %{
<p><a href="../file.php/153/11-20/16/Graphing_Straight_Line_Families.gsp" target="_blank" title="GSP" style="color: #0000FF"><b>Graphing straight line families</b></a> <img width="60" vspace="0" hspace="0" height="10" border="0" title="5.1, 5.2, 5.3" alt="5.1, 5.2, 5.3" src="../file.php/153/images/123.png" /> <span style="color: #FF0000"><b>(U)</b></span>
A GSP file encouraging you to think about the relationship between a linear
equation and the corresponding graph. Essentially a teaching resource, but
useful for independent study. <strong>Only works if you have Geometers Sketchpad
installed.</strong></p>
  }.strip
end

D "Resource (resource 5)" do
  text = %{
    <Gradient product of perpendicular lines> 5.1 U,F,PS,R file:^A019 Gradient.+.gsp$
      Explore the relationship between the gradients of two lines when they become
      perpendicular. {warn:Only works if you have Geometers Sketchpad installed.}
  }.trim.tabto(0).chomp
  r = Resource.new(text, 16)
  T { Resource === r }
  Eq r.topic_number, 16
  Eq r.title,        "Gradient product of perpendicular lines"
  Eq r.level,        "5.1"
  Eq r.category,     "U,F,PS,R"
  Eq r.file_re,      /^A019 Gradient.+.gsp$/
  Eq r.description, %{
    Explore the relationship between the gradients of two lines when they become
    perpendicular. {warn:Only works if you have Geometers Sketchpad installed.}
  }.trim.tabto(0).chomp
  Eq r.html, %{
<p><a href="../file.php/153/11-20/16/A019_Gradient_product_of_perpendicular_lines.gsp" target="_blank" title="GSP" style="color: #0000FF"><b>Gradient product of perpendicular lines</b></a> <img width="60" vspace="0" hspace="0" height="10" border="0" title="5.1" alt="5.1" src="../file.php/153/images/1.png" /> <span style="color: #FF0000"><b>(U,F,PS,R)</b></span>
Explore the relationship between the gradients of two lines when they become
perpendicular. <strong>Only works if you have Geometers Sketchpad installed.</strong></p>
  }.strip
end

D "Resource (invalid resource 1)" do
  text = %{
    <King's Gambit Declined> 5.4 U file:^Gradient
      This resource is erroneous because 5.4 is an invalid level.
  }.trim.tabto(0).chomp
  E { r = Resource.new(text, 7) }
end

D "Resource (invalid resource 2)" do
  text = %{
    <King's Gambit Declined> 5.2 U,T file:^Gradient
      This resource is erroneous because T is an invalid category.
  }.trim.tabto(0).chomp
  E { r = Resource.new(text, 7) }
end

D "Resource (test topic number)" do
  text = %{
    <King's Gambit Declined> 5.2 U,F file:^Gradient
      This resource is erroneous because T is an invalid category.
  }.trim.tabto(0).chomp
  topicn = rand(30)
  r = Resource.new(text, topicn)
  Eq r.topic_number, topicn
end

D "Website (website 1)" do
  text = %{
    <Linear graph animation> 5.1 F
      url:http://www.media.pearson.com.au/schools/cw/au_sch_mcseveny_nsm9_5153_1/int/lineargraph.html
      Take the challenge to determine an equation from its graph, and vice versa.
  }.trim.tabto(0).chomp
  w = Website.new(text)
  T { Website === w }
  Eq w.title,        "Linear graph animation"
  Eq w.level,        "5.1"
  Eq w.category,     "F"
  Eq w.url, %{http://www.media.pearson.com.au/schools/cw/} \
            + %{au_sch_mcseveny_nsm9_5153_1/int/lineargraph.html}
  Eq w.description, %{
    Take the challenge to determine an equation from its graph, and vice versa.
  }.trim.tabto(0).chomp
  Eq w.html, %{
<p><a href="http://www.media.pearson.com.au/schools/cw/au_sch_mcseveny_nsm9_5153_1/int/lineargraph.html" target="_blank" style="color: #0000FF"><b>Linear graph animation</b></a> <img width="60" vspace="0" hspace="0" height="10" border="0" title="5.1" alt="5.1" src="../file.php/153/images/1.png" /> <span style="color: #FF0000"><b>(F)</b></span>
Take the challenge to determine an equation from its graph, and vice versa.</p>
  }.strip
end

