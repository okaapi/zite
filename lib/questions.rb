def questions( str )
  out = ''
  str.each do |s|
    out << "<p> #{s}?</p><br>"
  end
  return out
end