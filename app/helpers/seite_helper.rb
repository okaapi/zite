module SeiteHelper
  
  def editable( seite, user )
    if seite
      return seite.editable_by_user( user ? user.role : nil, user ? user.id : nil )
    else
      nil
    end
  end
  def viewable( seite, user )
    if seite
      return seite.visible_by_user( user ? user.role : nil, user ? user.id : nil )
    else
      nil
    end
  end  
  def prettyversion( t )
    t.getlocal.strftime("%H:%M %m-%d-%Y")
  end
  def if_image( pagename, f )
    ext = File.extname( f )
    target = file_target( pagename, f )
    ext = ext.downcase
    case ext
    when '.jpg', '.gif', '.png', '.ico'
      "<img src=#{target} width=20 >".html_safe    
    when '.pdf'
      link_to image_tag( "pdf.ico", width: 20 ), target   
    else
      ext
    end
  end  
  def file_target( pagename, f )
    File.join( '/storage', pagename, File.basename( f ) )
  end
  def file_grab_target( pagename, f )
    #File.join( root_url, 'storage', pagename, File.basename( f ) )
    file_target( pagename, f )
  end  
  def center_class( left, right )
    if !left and !right 
      'center_only'
    elsif left and !right
      'center_with_left'
    elsif !left and right
      'center_with_right'
    else
      'center_with_left_and_right'
    end
  end

end
