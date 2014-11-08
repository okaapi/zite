class Page < ActiveRecord::Base
  validates :user_id, :presence => true
  validate :id_valid  
  before_create :name_downcase
  before_save :name_downcase
  before_update :name_downcase
  
  def self.get_layout( pagename )
    center = Page.where( name: pagename ).last
    header = get_panel_or_default( pagename, 'header')
    menu = ( center and center.menu == 'true' ) ? get_panel_or_default( pagename, 'menu') : nil
    left = get_panel( pagename, 'left')
    right = get_panel( pagename, 'right')
    footer = get_panel_or_default( pagename, 'footer')
    return header, menu, left, center, right, footer
  end
  
  def self.get_css
    p = Page.where( name: 'css').last
    css = p ? p.content : ""
    css.gsub('<p>','').gsub('</p>','').gsub('<br />','').gsub('&nbsp;',' ').gsub('<pre>','').gsub('</pre>','')
  end
  
  def self.get_panel( pagename, panelname )
    Page.where( name: pagename + '_' + panelname).last
  end
  
  def self.get_panel_or_default( pagename, panelname )
    panel = Page.where( name: pagename + '_' + panelname).last
    panel = Page.where( name: panelname ).last if !panel
    return panel
  end
  
  def display
    
    # parse include directive
    c = Page.parse_include( self.content ) 
   
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
  def self.parse_include( str )
    c = str
    include_names = c.scan(/<%=\s+include\s+([\w]+)\s+%>/)      
    include_names.each do | p_name |
      page = Page.where( name: p_name).last
      inclusion = page ? page.display : ( '<%= include ' + p_name[0] + ': not found %>' ) 
      c = c.gsub( /<%=\s+include\s+#{p_name[0]}\s+%>/, inclusion )
    end    
    return c
  end
    
end
