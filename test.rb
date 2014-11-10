

def pro a
  a.each
end

str = "a <%= B <%= C c %> d <%= E <%= F f %> g %> h <%= I i %> j"
p str

split1 = str.split('<%=')


split2 = []
split1.each do |s|
  sp = s.split('%>')
  sp.each { |s| s.strip! }  
  sp = sp[0] if sp.count == 1
  split2 << sp
end

p split2



=begin
a <%= b <%= c %> d <%= e %> f %> g <%= h %> i

[a, [b, [c], d, [e], f], g, [h]] 

[a, 
 [b,   -
  [c], -
  d, 
  [e], -
  f],
 ] 
 g, 
 [h],  -
 i
]
=end
