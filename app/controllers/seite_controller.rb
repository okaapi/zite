class SeiteController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :file_upload
  
  def index
    
    @seiten_name = params[:seite] || 'home'
      
    #if @seiten_name and @seiten_name.include? "_" and !user
    #  redirect_to seite_path( seite: @seiten_name.split('_').first )
    #end
        
    @header, @menu, @left, @center, @right, @footer = Page.get_layout( @seiten_name )
    @css = Page.get_css
    
    if !@center
      redirect_to page_update_path( seite: @seiten_name )
    elsif ! @center.editable_by_user( @user ? @user.role : nil, @user ? @user.id : nil )
      render alert: "not authorized..."
    else
      begin
        render
      rescue Exception => e
        render inline: "#{e}"
      end
    end
    
  end

  def pageupdate
    
    @seiten_name = params[:seite]
      
    if ! @user
      redirect_to root_path, alert: "need to login first..."
      return
    end
    
    # filter out bad names...
    if !@seiten_name or @seiten_name == ''
      redirect_to root_path, alert: "bad page name #{@seiten_name}..."
      return      
    end

    # create new page if required    
    @pages = Page.where( name: @seiten_name ).order( updated_at: :desc )
    if @pages.count == 0
      @page = Page.new( name: @seiten_name, content: "", user_id: @user.id )
    # editing a previous version
    elsif params[:updated_at]  
      @page = @pages.find_by_updated_at( params[:updated_at] )
    # editing the most recent one
    else
      @page = @pages.first
    end
    
    # see whether page is editable
    if ! @page.editable_by_user( @user ? @user.role : nil, @user ? @user.id : nil )
      redirect_to root_path, alert: "not authorized..."
      return    
    end
      
    # see whether there are any files associated with this
    @files = Dir.glob( File.join( Rails.root , 'public', 'storage', @seiten_name, '*' ) )
    @files.delete_if {|f| File.directory?(f) }

    begin
      render
    rescue Exception => e
      render inline: "#{e}"
    end

  end
  
  def pageupdate_save
        

    pagename = page_params[:name] || ''
    u_p = page_params[:name].split('_')
    if u_p.count > 1
      if u_p[ u_p.count-1 ].casecmp('header') == 0 or u_p[ u_p.count-1 ].casecmp('menu') == 0 or 
        u_p[ u_p.count-1 ].casecmp('left') == 0 or u_p[ u_p.count-1 ].casecmp('right') == 0 or 
        u_p[ u_p.count-1 ].casecmp('footer') == 0 
        returnpage = u_p[0..u_p.count-2].join('_')
      else
        returnpage = pagename
      end
    else
      returnpage = pagename
    end
    
    if @user
      @page = Page.new( page_params )
      @page.user_id = @user.id
      begin
        @page.save
        redirect_to seite_path( seite: returnpage ), notice: "page #{@page.name} saved..."
      rescue Exception => e           
        redirect_to root_path,  alert: "problems saving page... #{e}"
      end      
    else
      redirect_to seite_path( seite: returnpage )
    end
          
  end
  
  def file_upload
    
    @pagename = params[:seite]
      
    if params[:file]
          
      # see whether there are any files associated with this
      @files = Dir.glob( File.join( Rails.root , 'public', 'storage', @pagename, '*' ) )
      @files.delete_if {|f| File.directory?(f) }
          
      # sanitize and get file/directory names   
      filename = File.basename(params[:file].original_filename).gsub(/[^\w._-]/,'').downcase
      directory = File.join( Rails.root , 'public', 'storage', @pagename )

      # does the directory exist?
      if ! Dir.exists? directory
        Dir.mkdir directory
      end
    
      # copy the old file if necessary
      path = File.join( directory, filename )
      if File.exists? path
        newfilename = File.basename(filename, File.extname(filename) ) + 
             SecureRandom.urlsafe_base64(8)  + File.extname(filename) 
        newpath = File.join( directory, newfilename )
        FileUtils.cp( path, newpath )
      end
    
      # write the new file
      File.open(path, "wb") { |f| f.write(params[:file].read) }
    
      redirect_to page_update_path( seite: @pagename),  notice: "uploaded file"
      
    else
      
      redirect_to page_update_path( seite: @pagename)
      
    end
    
  end
  
  def file_delete
    @pagename = params[:seite]
    directory = File.join( Rails.root , 'public', 'storage', @pagename )
    filename = params[:filename]
    path = File.join( directory, filename )

    if File.exists? path
      File.delete( path )
    end
    
    redirect_to page_update_path( seite: @pagename),  notice: "file deleted"
  end
  
  private
  
  def page_params
    params.permit(:content, :name, :user_id, :visibility, :editability, :menu, :lock, :editor)
  end
  
end
