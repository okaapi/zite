



=begin
when <%= ... create tree node, set it to "current branch"
when text, add it to current branch
when %> set current branch to ancestor of "current branch"
=end

class Tree
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
end
  
def print_tree (node, indent )
  node.children.each do |c|
    if c.class == Tree
      print_tree( c, indent + '  ')
    else
      if node.parent
        puts node.parent.id.to_s + ':' + node.id.to_s + indent + c
      else
        puts 0.to_s + ':' + node.id.to_s + indent + c
      end
    end
  end
end

def process_tree( node )
  kids = []
  node.children.each do |c|
    if c.class == Tree
      kids << process_tree( c)
    else
      kids << c
    end
  end
  words = kids.join(' ').split(' ')
  if node.parent
    words[0]  + '(' + words[1..-1].join(' ') + ')'
  else
    words.join(' ')
  end
end
  
  
root = Tree.new( nil )

original = "a <%= B <%= C c %> d d <%= E <%= F f %> g %> h %> <%= I i %> j"

current = root
str = original
while str.size > 0  
  open = str.index('<%=')
  close = str.index('%>')
  if !open and !close
    # there are no more tags...  add the remainder to the current node
    current.children << str
    str = ''
  elsif open and open > 0 and close and close > 0
    i = ( open < close ) ? open : close
    # there is text beween now and the next tag
    current.children << str[0..(i-1)]
    str = str[i..-1]        
  elsif open and open == 0
    # create a new tree node with the current tree as parent
    new_node = Tree.new( current )
    current.children << new_node
    current = new_node
    str = str[3..-1]
  elsif close and close == 0    
    current = current.parent
    str = str[2..-1]    
  elsif close and close > 0
    # there is text beween now and the next tag
    current.children << str[0..(close-1)]
    str = str[close..-1]      
  elsif open and open > 0
    current.children << str[0..(open-1)]
    str = str[open..-1]       
  else  puts
    puts "can this be? #{open} #{close}"
  end

end

puts
puts
p original
puts "--------------------------"
print_tree( root, '' )
puts "--------------------------"
p process_tree( root )


