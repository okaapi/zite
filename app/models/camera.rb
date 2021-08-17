

class Camera
  def self.launch( operands )

    operand_list = operands.split
    filter = operand_list[0]
    page = operand_list[1] ? operand_list[1] : 'camera'
    
    out = ""
    out << "<h2> #{filter} Camera </h2>"

    directory = File.join( Rails.root , '../okaapi', 'public', 'camera')
    if Dir.exists? directory    
      
      datelist = Dir.entries(directory).reject{|entry| entry =~ /^\.{1,2}$/}.sort.reverse 
          #_by { |a| File.stat(File.join(directory,a)).mtime }.reverse
      
      datelist.each do |date|
        datedirectory = File.join( directory, date )  
        imagefiles = Dir.entries(datedirectory).sort                                   
        if imagefiles.find{|each| ( each.include? filter )}
          out << "<h3> #{Camera.degarble(date)} <small><a href='/camera_directory_delete/#{filter}/#{date}/#{page}' " 
          out <<     " onclick='return confirm(\"Are you sure?\")'> delete </a></small> </h3>"                 
          imagefiles.each do |imagefile|
            if imagefile.include? filter and !imagefile.include? 'avi' and !imagefile.include? 'mp4'
              t = imagefile.gsub(/#{filter}/,'').gsub(/.jpg/,'')
              out << "<img src='/camera/#{date}/#{imagefile}' width='64' style='border:2px solid white' title='#{t}' "
              out << " onclick=\"this.style.width='64px'\" ondblclick=\"this.style.width='500px'\" >\n"
            end
          end
          out << "<br><a href='/camera/#{date}/#{filter}.avi'>video.avi</a>"
          out << "&nbsp;<a href='/camera/#{date}/#{filter}.mp4'>video.mp4</a>"
        end
        
      end
      
    else
      out << "camera directory empty"
    end
    return out
  end
  
  def self.launch_last( operands )

    operand_list = operands.split
    filter = operand_list[0]
    
    out = ""

    directory = File.join( Rails.root , '../okaapi', 'public', 'camera')
    if Dir.exists? directory    
      
      datelist = Dir.entries(directory).reject{|entry| entry =~ /^\.{1,2}$/}.sort.reverse
        #_by { |a| File.stat(File.join(directory,a)).mtime }.reverse
      date = datelist.first
      datedirectory = File.join( directory, date )  
      imagefiles = Dir.entries(datedirectory).sort.reverse
      imagefiles.each do |imagefile|
        if imagefile.include? filter and !imagefile.include? 'avi'
          t = imagefile.gsub(/#{filter}/,'').gsub(/.jpg/,'')
          out << "<img src='/camera/#{date}/#{imagefile}' title='#{t}' >"
          break
        end
      end
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
  
  def self.delete( filter, date )
    directory = File.join( Rails.root , '../okaapi', 'public', 'camera', date)
    if Dir.exists? directory
      datelist = Dir.entries( directory ) 
      datelist.each do |filename|
        if filename.include? filter
          File.delete( File.join( directory, filename ) ) if File.exists?( File.join( directory, filename ) )
        end
      end
      if ( Dir.entries( directory ) ).count == 2
        Dir.delete directory
      end
    end
  end
  
end
