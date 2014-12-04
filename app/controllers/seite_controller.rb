class SeiteController < ApplicationController
  skip_before_action :verify_authenticity_token #, only: :file_upload
  
  def index
        
    @seiten_name = params[:seite] || 'index'
            
    @header, @menu, @left, @center, @right, @footer = Page.get_layout( @seiten_name )
    @css = Page.get_css
    
    if !@center and @user 
      redirect_to page_update_path( seite: @seiten_name )
    elsif @center and !@user
      cached_content = render
      if Rails.configuration.page_caching
        @center.cache( cached_content )
      end
    else
      render
    end
   
  end
  
  def pageupdate
    
    if ! @user
      redirect_to root_path, alert: "need to login first..."
      return
    end

    @seiten_name = params[:seite]
      
    # filter out bad names...
    if ! (  /^[a-z][0-9a-z_]*/.match(@seiten_name)  )
      redirect_to root_path, 
        alert: "bad page name '#{@seiten_name}'... can only contain lower case 
          english letters, numbers and '_', and cannot start with number or '_'"
      return      
    end

    # create new page if required    
    @pages = Page.where( name: @seiten_name ).order( updated_at: :desc )
    if @pages.count == 0
      @page = Page.new( name: @seiten_name, content: "" )
    # editing a previous version
    elsif params[:updated_at]  
      @page = @pages.find_by_updated_at( params[:updated_at] )
    # editing the most recent one
    else
      @page = @pages.first
    end
    # remember last editor, and set this page to current editor
    @lastuser = User.find( @page.user_id ) if @page.user_id
    @page.user_id = @user.id
    
    # see whether page is editable
    if ! @page.editable_by_user( @user ? @user.role : nil, @user ? @user.id : nil )
      redirect_to root_path, alert: "not authorized..."
      return    
    end
    
    # see whether there are any files associated with this
    @files = Dir.glob( File.join( Rails.root , 'public', 'storage', @seiten_name, '*' ) )
    @files.delete_if {|f| File.directory?(f) }

    render

  end
  
  def pageupdate_save

    # save even if the user isn't logged in anymore... they were logged in
    # when they started editing the page...
    @page = Page.new( content: params[:content], name: params[:name],
                      user_id: params[:user_id], menu: params[:menu],
                      lock: params[:lock], editor: params[:editor],
                      visibility: params[:visibility], 
                      editability: params[:editability] )
    begin
      @page.save!
      @page.uncache
      redirect_to seite_path( seite: Page.basepage( params[:name] ) ), 
                              notice: "page #{@page.name} saved..."
    rescue Exception => e           
      redirect_to root_path,  alert: "problems saving page... #{e}"
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
        newfilename = File.basename(filename, File.extname(filename) ) + '.' +
             Time.now.to_s.gsub(/\D/,'') + File.extname(filename) 
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

  
end
