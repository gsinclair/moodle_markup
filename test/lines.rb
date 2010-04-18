
D "Lines" do
  D "do the basics (current_line, move_on, eof?)" do
    str = %{
      Line one
      Line two
      Line three
    }.trim.tabto(0)
    Eq str, "Line one\nLine two\nLine three\n"
    lines = Lines.new(str)
    F { lines.eof? }
    Eq lines.current_line, "Line one"
    lines.move_on
    F { lines.eof? }
    Eq lines.current_line, "Line two"
    lines.move_on
    F { lines.eof? }
    Eq lines.current_line, "Line three"
    lines.move_on
    T { lines.eof? }
    N { lines.current_line }
    lines.move_on
    lines.move_on
    lines.move_on
    T { lines.eof? }
    N { lines.current_line }
  end  # basics

  D "extract paragraphs and sections" do

    D .< { @str = %{
        [Sea fever]


        I must go down to the seas again
        To the lonely sea and the sky

        And all I want is a tall ship
        And a star to steer her by
                -- Masefield

        [Upon the stair]

        Yesterday upon the stair
        I met a man who wasn't there

        He won't be there again today
        At least that's what he told me to say
                -- Billy Bragg

        [Do not go...]

        Do not go gentle into that good night
        Rage, rage against the dying of the light
                -- Thomas (paraphrased)

        [Blank section]

        [Last section]
      }.trim.tabto(0)
    }  # setup

    D "#paragraphs" do
      lines = Lines.new(@str)
      lines.paragraphs.tap do |paragraphs|
        Eq paragraphs.size, 10
        Eq paragraphs.shift, "[Sea fever]"
        Eq paragraphs.shift,
          "I must go down to the seas again\nTo the lonely sea and the sky"
        Eq paragraphs.at(-3), %{
          | Do not go gentle into that good night
          | Rage, rage against the dying of the light
          |         -- Thomas (paraphrased)
        }.trim('|').chomp
        Eq paragraphs.last, "[Last section]"
      end
    end  # paragraphs

    D "#sections" do
      lines = Lines.new(@str)
      lines.sections.tap do |sections|
        Eq sections.size, 5
        s = sections.shift
        Eq s.name, "Sea fever"
        Mt s.paragraphs[0], /\AI must go .+ the sky\Z/m
        Mt s.paragraphs[1], /\AAnd all .+ -- Masefield\Z/m
        N  s.paragraphs[2]
        s = sections.shift
        Eq s.name, "Upon the stair"
        Mt s.paragraphs[0], /\AYesterday upon .+ wasn't there\Z/m
        Mt s.paragraphs[1], /\AHe won't be .+ -- Billy Bragg\Z/m
        N  s.paragraphs[2]
        s = sections.shift
        Eq s.name, "Do not go..."
        Mt s.paragraphs[0], /\ADo not go gentle .+ -- Thomas \(paraphrased\)\Z/m
        N  s.paragraphs[1]
        s = sections.shift
        Eq s.name, "Blank section"
        T { s.paragraphs.empty? }
        s = sections.shift
        Eq s.name, "Last section"
        T { s.paragraphs.empty? }
      end
    end  # sections

  end
end

