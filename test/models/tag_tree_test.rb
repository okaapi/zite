require 'test_helper'

class TagTreeTest < ActiveSupport::TestCase
   
  test 'basics' do
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
  end
 
  test 'first_term' do
    first, remainder = TagTree.first_term( ' red green blue ')
    assert_equal first, 'red'
    assert_equal remainder, 'green blue'
  end
  
  test 'first_term empty' do
    first, remainder = TagTree.first_term( ' ')
    assert_equal first, ' '
    assert_equal remainder, ''    
  end  
  
end

