

class Camera
  def self.launch( filter )
    out = "<h2> #{filter} Camera </h2>"

    directory = File.join( Rails.root , '../okaapi', 'public', 'camera')
    if Dir.exists? directory    
      
      datelist = Dir.entries(directory).reject{|entry| entry =~ /^\.{1,2}$/}.sort_by { |a| File.stat(File.join(directory,a)).mtime }.reverse
      datelist.each do |date|
      
        out << "<h3> #{Camera.degarble(date)} </h3>"
        datedirectory = File.join( directory, date )        
        imagefiles = Dir.entries(datedirectory).sort_by { |a| File.stat(File.join(datedirectory,a)).mtime }
        imagefiles.each do |imagefile|
          if imagefile.include? filter
            t = imagefile.gsub(/#{filter}/,'').gsub(/.jpg/,'')
            out << "<a href='/camera/#{date}/#{imagefile}'>"
            out << "<img src='/camera/#{date}/#{imagefile}' width='64' style='border:2px solid white' title='#{t}'>"
            out << "</a>"
          end
        end
        
      end
      
    else
      out << "camera directory empty"
    end
    return out
  end
  def self.engarble( str )
    o = ""; 
    str.each_char { |c| o << (c.ord+30).chr }; 
    o
  end   
  def self.degarble( str )
    o = ""; 
    str.each_char { |c| o << (c.ord-30).chr }; 
    o
  end   
end
