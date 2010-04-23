
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

