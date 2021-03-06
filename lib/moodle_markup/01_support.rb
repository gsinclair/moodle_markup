
NL = "\n"

def error(msg=nil)
  if msg
    raise StandardError, msg
  else
    raise StandardError
  end
end

def returning(obj)
  yield obj
end

class Object
  def not_empty?
    not empty?
  end
end

class String
  def tag(t)
    open, close = "<#{t}>", "</#{t}>"
    open + self + close
  end
  def untag(t)
    if self =~ %r{ \A <#{t}> (.*) </#{t}> \Z }mx
      $1
    else
      self
    end
  end
end

TOPIC_NAMES = %{
  01. Significant figures and scientific notation
  02. Index laws
  03. Perimeter and area of composite shapes
  04. Rates
  05. Algebraic techniques
  06. Index laws, including negative and fractional indices
  07. Expanding binomial products
  08. Polygons, congruence and similarity
  09. Equations and inequalities
  10. Recurring decimals to fractions
  11. Earning and spending
  12. Surds
  13. Quadratic expressions
  14. Right angle triangle trigonometry and applications
  15. Circle geometry
  16. Coordinate geometry
  17. Linear equations and simultaneous equations
  18. Data
  19. Non-right-angle trigonometry and applications
  20. Compound interest and depreciation
  21. Quadratic equations and literal equations
  22. Graphing parabolas
  23. Surface area and volume
  24. Logarithms
  25. Graphs and applications
  26. Argument and proof
  27. Graphs of physical phenomena
  28. Probability and relative frequency
  29. Polynomials
  30. Functions
}.trim.split("\n").
    build_hash { |line|
      m = line.match(/^  (\d+)\. (.+)$/)
      [ m[1].to_i, m[2].strip ]
    }.
  freeze
