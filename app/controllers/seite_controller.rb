class SeiteController < ApplicationController
  #skip_before_action :verify_authenticity_token #, only: :file_upload
  
  def beckman
    logger.info( '**** BECKMAN')
    logger.info( params )
  end
  
  def index
        
    @seiten_name = params[:seite] || 'index'	
    @header, @menu, @left, @center, @right, @footer = Page.get_layout( @seiten_name )
    @css = Page.get_css
    @meta_desc = @center.get_meta_desc if @center

    if !@center and @current_user and Page.editor_roles.include? @current_user.role
      redirect_to page_update_path( seite: @seiten_name )
    elsif @center and !@current_user
      cached_content = render
      if Rails.configuration.page_caching    
        seite_logger( "caching #{cached_content[0..200]}" )
        #
        # pages are cached in the same directory for all 'external' sites pointing
        # to the same internal site
        # @center.cache( cached_content, SiteMap.by_internal( @center.site ) )
        #
        @center.cache( cached_content, @center.site )
      end
    else
      render
    end
   
  end
  
  def pageupdate
    

    if ! @current_user
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
      @page = @pages.where( updated_at: params[:updated_at] ).take
    # editing the most recent one
    else
      @page = @pages.first
    end
    # remember last editor, and set this page to current editor
    @lastuser = User.where( id: @page.user_id ).first if @page.user_id
    @page.user_id = @current_user.id
    
    # see whether page is editable
    if ! @page.editable_by_user( @current_user ? @current_user.role : nil, 
                                 @current_user ? @current_user.id : nil )
      redirect_to root_path, alert: "not authorized..."
      return    
    end
    
    # see whether there are any files associated with this
    @site = @current_user_session.site
    
    render

  end
  
  def pageupdate_save

    # save even if the user isn't logged in anymore... they were logged in
    # when they started editing the page...
    @page = Page.new( content: params[:content], name: params[:name],
                      meta_desc: params[:meta_desc],
                      user_id: params[:user_id], menu: params[:menu],
                      lock: params[:lock], editor: params[:editor],
                      visibility: params[:visibility], 
                      editability: params[:editability] )
    begin
      @page.save!
      @page.uncache( SiteMap.by_internal( @page.site )  )
      redirect_to seite_path( seite: Page.basepage( params[:name] ) ), 
                              notice: "page #{@page.name} saved..."
    rescue Exception => e           
      redirect_to root_path,  alert: "problems saving page... #{e}"
    end  
          
  end
  
  def file_upload    
    @pagename = params[:seite]
    @site = @current_user_session.site
      
    if params[:file]          
      FileUpload.upload( @site, @pagename, params[:file] )    
      redirect_to page_update_path( seite: @pagename),  notice: "uploaded file"      
    else      
      redirect_to page_update_path( seite: @pagename),  notice: "nothing uploaded"   
    end
    
  end
  
  def file_delete
    @pagename = params[:seite]
    @site = @current_user_session.site
        
    FileUpload.delete( @site, @pagename, params[:filename] )    
    redirect_to page_update_path( seite: @pagename),  notice: "file deleted"
    
  end
  
  def camera_directory_delete
    @camera = params[:filter]
    @page = params[:page]
    @date = params[:date]
    Camera.delete( @camera, @date)
    redirect_to root_path( seite: @page),  notice: "#{@camera} #{@date} #{Camera.degarble(@date)} deleted"
    
  end
    
  def search
  
    if ! @current_user
      redirect_to root_path, alert: "need to login first..."
    else
	  @term = params[:term]   
      @array_of_names = Page.search( @current_user, @term )	
	end
    
  end
  
  private

  def seite_logger( str )
    #
    #  uncomment to turn on logging
    # logger.info( 'SEITE_CONTROLLER ' + str ) if str
    #
  end
  
end
