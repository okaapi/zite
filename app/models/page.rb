class Page < ActiveRecord::Base
  validates :user_id, :presence => true
  validate :id_valid  
  before_create :name_downcase
  before_save :name_downcase
  before_update :name_downcase

  def self.get_latest( pagename )
    page = Page.where( name: pagename ).order( updated_at: :asc ).last
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

    if self.content.nil?
      self.content = 'empty page' 
    end
    return parse_content( role )    
    
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
  
  def cache( content )
    path = File.join( Rails.root , 'public', self.name ) + '.html'    
    File.open(path, "w") { |f| f.write( content[0].force_encoding('ISO-8859-1') ) }
  end
  
  def uncache
    path = File.join( Rails.root , 'public', self.name ) + '.html'  
    if File.exists? path
      File.delete( path )
    end
  end
  
  def self.uncache_all
    pages = self.all
    pages.each { |p| p.uncache }
  end
    
  def self.good_name?
    
  end
  
  private
  
  def name_downcase
   @name = @name.downcase if @name
  end
  
  def id_valid
    begin
      User.find(user_id)
    rescue
      errors.add( :user_id, "has to be valid")
      false
    end
  end
  
  #
  #   execute directives in <%= ....  %> brackets
  #
  #  
  def parse_content( role )
    
    root = TagTree.parse( self.content, '<%=', '%>' )
    parsed = root.process do |depth, str|
      if depth > 0         
        func, operands = TagTree.first_term( str )
        case func
        when 'include'
          page = Page.get_latest( operands )
          page ? page.display( role ) : ( '<% include ' + operands + ': not found %>' )
        when 'pagelink', 'adminlink'
          link = operands.split(',')
          link.each {|l| l[0].strip!}
          linktarget = link[0]
          linkdisplay = link[1] ? link[1] : linktarget     
          linkdisplay.gsub!(/"/,'')
          if ( func == 'adminlink' and role == 'admin' ) or func == 'pagelink'            
            "<a href=\"/#{linktarget}\" class=\"#{func}\">#{linkdisplay}</a>"
          else
            ''
          end
        when 'imagelink'
          link = operands.split(',')
          link.each {|l| l[0].strip!}
          linktarget = '/storage/' + self.name + '/' + link[0]
          imagespecs = link[1] ? link[1] : ""
          "<a href=\"#{linktarget}\"> <img src=\"#{linktarget}\" #{imagespecs}> </a>" 
        when 'admin', 'editor'
          case role
          when 'admin'
            (func == 'admin' or func == 'editor') ? operands : ''
          when 'editor'
            (func == 'editor') ? operands : ''
          else
            sub = ''
          end
        when 'pin'
          "<div class=\"pindiv\">  #{operands}  </div>"
        when 'questions'
          eval 'questions ' + operands
        else
          '<B>Bad Call to #{func}</B>'
        end
      else
        str
      end
    end  
  
    return parsed
  end  
   
end
