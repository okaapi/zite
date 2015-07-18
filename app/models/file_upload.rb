class FileUpload

  def self.upload( site, pagename, file )
  
	  # see whether there are any files associated with this
	  files = Dir.glob( File.join( Rails.root , 'public/storage', site, pagename, '*' ) )
	  files.delete_if {|f| File.directory?(f) }
	      
	  # sanitize and get file/directory names   
	  filename = File.basename( file.original_filename).gsub(/[^\w._-]/,'').downcase
	  
	  site_directory = File.join( Rails.root , 'public/storage', site)
	  # does the site_directory exist?
	  if ! Dir.exists? site_directory
	    Dir.mkdir site_directory
	  end      
	  
	  directory = File.join( Rails.root , 'public/storage', site, pagename )
	  # does the directory exist?
	  if ! Dir.exists? directory
	    Dir.mkdir directory
	  end
	
	  # copy the old file if necessary
	  path = File.join( directory, filename )
	  if File.exists? path
	    newfilename = File.basename(filename, File.extname(filename) ) + '.' +
	         Time.now.to_s.gsub(/\D/,'') + File.extname(filename) 
	    newpath = File.join( directory, newfilename )
	    FileUtils.cp( path, newpath )
	  end
	
	  # write the new file
	  File.open(path, "wb") { |f| f.write(file.read) }
	  
  end
  
  def self.delete( site, pagename, filename )
  
    directory = File.join( Rails.root , 'public/storage', site, pagename )
    path = File.join( directory, filename )

    if File.exists? path
      File.delete( path )
    end
    
  end  

end
