#
# <%= questions "aaa bbb" %>
#
# -->>  aaa?
# -->>  bbb?
#
#need to add to page.rb and config/initializers

module Questions
  def questions( str )
    out = ''
    str.split(' ').each do |s|
      out << "<p> #{s}?</p><br>"
    end
    return out
  end
end
