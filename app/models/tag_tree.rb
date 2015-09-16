
#
#  TagTree.parse takes a string with opening and closing tags (like <%= %>)
#  and parses it into a tress structure
#  the process method then takes a block that can process the string between
#  the tags as required
#  tags can be nested! (unlike erb)
#
#  simple example at the end of this file
#
class TagTree
  @@id = 1
  attr_reader :parent
  attr_reader :id
  attr_reader :children
  attr_writer :children
  
  def initialize( parent = nil )
    @parent = parent
    @children = []
    @id = @@id
    @@id += 1
  end
  
  def process( depth=0, &block )
    kids = []
    self.children.each do |c|
      if c.class == self.class
        kids << c.process( depth+1, &block )
      else
        kids << c
      end
    end
    block.call( depth, kids.join(' ') )
  end
  
  def self.parse( original, tag_open, tag_close )
    current = tree_root = self.new
    str = original
    while str.size > 0  
      str.strip!
      open = str.index(tag_open)
      close = str.index(tag_close)
      if !open and !close
      # there are no more tags...  add the remainder to the current node
        current.children << str
        str = ''
      elsif open and open > 0 and close and close > 0
        i = ( open < close ) ? open : close
        # there is text beween now and the next tag
        current.children << str[0..(i-1)].strip
        str = str[i..-1]        
      elsif open and open == 0
        # create a new tree node with the current tree as parent
        new_node = self.new( current )
        current.children << new_node
        current = new_node
        str = str[3..-1]
      elsif close and close == 0
        # close current tree node 
        current = current.parent
        str = str[2..-1]    
      elsif close and close > 0
        # there is text beween now and the next tag
        current.children << str[0..(close-1)].strip
        str = str[close..-1]      
      elsif open and open > 0
        current.children << str[0..(open-1)].strip
        str = str[open..-1]       
      else
        # this is not possible...
        # return nil
      end
      if !current
        return tree_root
      end
    end
    return tree_root
  end
  
  def self.first_term( str )
    terms = str.split(' ')
    if terms.size > 1
      return terms[0].strip, terms[1..-1].join(' ').strip
    else
      return str, ''
    end
  end

end

=begin
original = "a <%= B <%= C c %> d d <%= E <%= F f %> g %> h %> <%= I i %> j"
root = TagTree.parse( original, '<%=', '%>' )
result = root.process do |depth, str|
  if depth > 0 
    func, operands = TagTree.first_term( str )
      "#{func}(#{operands})"
  else
    str
  end
end
assert_equal result, "a B(C(c) d d E(F(f) g) h) I(i) j"
=end

