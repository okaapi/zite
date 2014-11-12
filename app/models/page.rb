class Page < ActiveRecord::Base
  validates :user_id, :presence => true
  validate :id_valid  
  before_create :name_downcase
  before_save :name_downcase
  before_update :name_downcase

  def self.get_latest( pagename )
    Page.where( name: pagename ).order( updated_at: :asc ).last
  end
  
  def self.get_layout( pagename )
    center = Page.get_latest( pagename )
    header = get_panel_or_default( pagename, 'header')
    menu = ( center and center.menu == 'true' ) ? get_panel_or_default( pagename, 'menu') : nil
    left = get_panel_or_default( pagename, 'left')
    right = get_panel_or_default( pagename, 'right')
    footer = get_panel_or_default( pagename, 'footer')
    return header, menu, left, center, right, footer
  end
  
  def self.get_css
    p = Page.get_latest( 'css')
    css = p ? p.content : ""    
    css = css.gsub(/<p>/i,'').gsub(/<\/p>/i,'').gsub(/<br \/>/i,'')
             .gsub(/&nbsp;/i,' ').gsub(/<pre>/i,'').gsub(/<\/pre>/i,'')
  end
  
  def self.get_panel( pagename, panelname )
    Page.get_latest( pagename + '_' + panelname)
  end
  
  def self.get_panel_or_default( pagename, panelname )
    # first we check for HOME_PAGE_LEFT
    panel = Page.get_latest( pagename + '_' + panelname)
    if ! panel
      # if that doesn't exist, then we check for HOME_LEFT
      rootname = pagename.split('_')[0]
      panel = Page.get_latest( rootname + '_' + panelname )   
      if ! panel
        # and if that doesn't exist we check for LEFT
        panel = Page.get_latest( panelname )
      end
    end  
    return panel
  end

  def self.basepage( pagename )
    u_p = (pagename||'').split('_')
    if u_p.count > 1
      if u_p[ u_p.count-1 ].casecmp('header') == 0 or u_p[ u_p.count-1 ].casecmp('menu') == 0 or 
        u_p[ u_p.count-1 ].casecmp('left') == 0 or u_p[ u_p.count-1 ].casecmp('right') == 0 or 
        u_p[ u_p.count-1 ].casecmp('footer') == 0 
        return u_p[0..u_p.count-2].join('_')
      end
    end
    (pagename||'')
  end
    
  def display( role = 'user' )

    if ! self.content
      self.content = 'empty page' 
      self.save
    end

    # parse include directive
    c = Page.parse_include( self.content, role )
    c = Page.parse_roles( c, role )  
    c = Page.parse_pagelink( c )  
    c = Page.parse_pin( c )  
    c = Page.parse_adminlink( c, role ) 
    c = Page.parse_imagelink( c, self.name )
    return c    
    
  end
  
  def self.editabilities
    ['admin', 'self', 'editor']
  end
  def editable_by_user( role, user_id = nil )
  
    case self.editability
    when 'admin'
      ( role == 'admin' )  
    when 'self'
      ( ( role == 'editor' and user_id == self.user_id ) or role == 'admin' ) 
    when 'editor'
      ( role == 'admin' or role == 'editor' )
    else # neither 'user' nor 'any' can edit
      false  
    end  
    
  end
  
  def self.visibilities
    ['any', 'user', 'editor', 'self', 'admin']
  end
  def visible_by_user( role, user_id = nil )
  
    case self.visibility
    when 'admin'
      ( role == 'admin' )
    when 'self'
      ( ( role == 'editor'and user_id == self.user_id ) or role == 'admin' ) 
    when 'editor'
      ( role == 'editor' or role == 'admin' ) 
    when 'user'
      ( role == 'editor' or role == 'admin' or role == 'user' )
    else # = 'any'
      true  
    end  
    
  end  
  
  private
  
  def name_downcase
    self.name = self.name.downcase if self.name
  end
  
  def id_valid
    begin
      Auth::User.find(user_id)
    rescue
      errors.add( :user_id, "has to be valid")
      false
    end
  end
  
  # strip out <%= include pagename %> and replace 'pagename' with the content
  # of that page...
  def self.parse_include( str, role )
    c = str
    include_names = c.scan(/<%=\s+include\s+([\w]+)\s+%>/)      
    include_names.each do | p_name |
      page = Page.get_latest( p_name)
      inclusion = page ? page.display( role ) : ( '<%= include ' + p_name[0] + ': not found %>' ) 
      c = c.gsub( /<%=\s+include\s+#{p_name[0]}\s+%>/, inclusion )
    end    
    return c
  end
  
  def self.parse_pagelink( str )
    c = str
    links = c.scan(/<%=\s+pagelink\s+([|&;,.'"\w\s]+?)\s+%>/)      
    links.each do | linktext |
      link = linktext[0].split(',')
      link.each {|l| l[0].strip!}
      linktarget = link[0]
      linkdisplay = link[1] ? link[1] : linktarget     
      linkdisplay.gsub!(/"/,'')
      sub = '<a href="/' + linktarget + '" class="pagelink">' + linkdisplay + '</a>'
      c = c.gsub( /<%=\s+pagelink\s+#{linktext[0]}\s+%>/, sub )
    end    
    return c
  end

  def self.parse_imagelink( str, pagename )
    c = str
    links = c.scan(/<%=\s+imagelink\s+([.=,\w\s]+?)\s+%>/)    
    links.each do | linktext |
      link = linktext[0].split(',')
      link.each {|l| l[0].strip!}
      linktarget = '/storage/' + pagename + '/' + link[0]
      imagespecs = link[1] ? link[1] : ""
      sub = '<a href="' + linktarget + '"> <img src="' + linktarget + '"' + imagespecs + '> </a>'
      c = c.gsub( /<%=\s+imagelink\s+#{linktext[0]}\s+%>/, sub )
    end    
    return c
  end    
  
  def self.parse_adminlink( str, role = nil )
    c = str
    links = c.scan(/<%=\s+adminlink\s+([,.'"\w\s]+?)\s+%>/)      
    links.each do | linktext |
      link = linktext[0].split(',')
      link.each {|l| l[0].strip!}
      linktarget = link[0]
      linkdisplay = link[1] ? link[1] : linktarget     
      linkdisplay.gsub!(/"/,'')
      sub = (role == "admin") ? ('<a href="/' + linktarget + '" class="adminlink">' + linkdisplay + '</a>') : ''
      c = c.gsub( /<%=\s+adminlink\s+#{linktext[0]}\s+%>/, sub )
    end    
    return c
  end  
    
  def self.parse_roles( str, role = nil  )
    
    c = str    
    # this could be expanded to other roles... but then admin would not see user stuff etc...
    ['admin','editor'].each do |roledef|
      links = c.scan(/<%=\s+#{roledef}\s+([<>\/,'"\w\s]+?)\s+%>/)   
      links.each do | linktext |
        case role
        when 'admin'
          sub = (roledef == 'admin' or roledef == 'editor') ? linktext[0] : ''
        when 'editor'
          sub = (roledef == 'editor') ? linktext[0] : ''
        else
          sub = ''
        end
        c = c.gsub( /<%=\s+#{roledef}\s+#{linktext[0]}\s+%>/, sub )
      end 
    end
   
    return c   
  end

  def self.parse_pin( str )
    c = str
    pins = c.scan(/<%=\s+pin\s+([<>\(\)\/,=:.;#-_'!&"\?\w\s]+?)\s+%>/)
    pins.each do | p |
      pintext = p[0]
      pintext = pintext.gsub(/[\?]/,'\\?')
      pinmatch = pintext.gsub(/[\(]/,'\\(').gsub(/[\)]/,'\\)') 
      sub = '<div class="pindiv">  ' + pintext + '  </div>'
      c = c.gsub( /<%=\s+pin\s+#{pinmatch}\s+%>/, sub )
    end    
    return c
  end  
   
end
