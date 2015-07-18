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
  def is_admin( user )
    ( user and user.admin? )
  end
  def if_image( page, f )
    ext = File.extname( f )
    target = page.file_target( f )
    ext = ext.downcase
    case ext
    when '.jpg', '.gif', '.png', '.ico'
      "<img src=\"#{target}\" width=40 >".html_safe    
    when '.pdf'
      link_to image_tag( "pdf.ico", width: 20 ), target   
    else
      ext
    end
  end  
  def file_encoding( f )
    File.basename( f ).encoding.to_s
  end
  def file_basename( f )
    File.basename( f ).force_encoding("ASCII-8BIT") 
  end

end
