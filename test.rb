

def test_method( i )
  return "called test #{i} method"
end

p eval 'test_method 5'

p Dir["lib/*.rb"]