# this is to include modules from the lib directory...
include Questions

class Page < ZiteActiveRecord
  validates :user_id, :presence => true
  validate :id_valid  
  before_create :name_downcase
  before_save :name_downcase
  before_update :name_downcase

#-----------------------------------------------------------------------------------------
#
# all pages are stored with their time stamps; for display, get the most recent one
#  
  def self.get_latest( pagename )
    page = Page.where( name: pagename ).order( updated_at: :asc ).last
  end
  
#-----------------------------------------------------------------------------------------
#
# a layout consists of pages from the Page table, with "center" the main page (the one
# that whose name is "pagename" in the Page table; each of these components is referred to
# as a "panel"
#
#  |-----------------------------------------|
#  |                header                   |
#  |-----------------------------------------|
#  |                 menu                    |
#  |-----------------------------------------|
#  |      |                          |       |
#  | left |         center           | right |
#  |      |                          |       |
#  |-----------------------------------------|
#  |                footer                   |
#  |-----------------------------------------|
#   
  def self.get_layout( pagename )
    center = Page.get_latest( pagename )
    header = get_panel_or_default( pagename, 'header')
    menu = ( center and center.menu == 'true' ) ? get_panel_or_default( pagename, 'menu') : nil
    left = get_panel_or_default( pagename, 'left')
    right = get_panel_or_default( pagename, 'right')
    footer = get_panel_or_default( pagename, 'footer')
    return header, menu, left, center, right, footer
  end

#-----------------------------------------------------------------------------------------
#
# given a "center" panel name, there are different ways to define "left" panels for it
# (example "HOME_PAGE") in order of decreasing specificity: 
#   1) HOME_PAGE_LEFT - this will only be used for "HOME_PAGE"
#   2) HOME_LEFT - this will also be used for all pages that start with "HOME_"
#   3) LEFT - this is the default left panel for all pages
#
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

#-----------------------------------------------------------------------------------------
#
# basepage strips a trailing _header, _menu, _left, _right, or _footer of the page name
#
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

#-----------------------------------------------------------------------------------------
#
# get_panel joins the basepage name with the panel name via a "_"  
#
  def self.get_panel( pagename, panelname )
    Page.get_latest( pagename + '_' + panelname)
  end  
     
#-----------------------------------------------------------------------------------------
#
# css is a special pagename, it is inserted in the <HEADER> tag of every page
#
  def self.get_css
    p = Page.get_latest( 'css')
    css = p ? p.content : ""    
    css = css.gsub(/<p>/i,'').gsub(/<\/p>/i,'').gsub(/<br \/>/i,'')
             .gsub(/&nbsp;/i,' ').gsub(/<pre>/i,'').gsub(/<\/pre>/i,'')
  end
  
#-----------------------------------------------------------------------------------------
#
# meta is the meta description for search engines; if it is not defined, use the one of
# the index page; if that is not defined, use the page name 
#
  def get_meta_desc
    if self.meta_desc
      self.meta_desc
    else   
      page = Page.get_latest( 'index' )
      if page and page.meta_desc
        page.meta_desc
      else
        self.name
      end
    end
  end
  
    
#-----------------------------------------------------------------------------------------
#
# display parses the content (<%= %> tags) and then returns the parsed content; if there is 
# no content, display an 'empty page message'
#  
  def display( role = 'user' )

    if self.content.nil?
      self.content = 'empty page' 
    end
    return parse_content( role )    
    
  end
  
#-----------------------------------------------------------------------------------------
#
# editability defines what class of users can edit a page; it can also be limited to one
# specific user; admin can edit any page
#
#                       user-role  
#  page-editability       admin   editor   self-editor   user   all-else
#                   admin    X  |   -    |     -       |  -   |  -
#                    self    X  |   -    |     X       |  -   |  -
#                  editor    X  |   X    |     X       |  -   |  -
#                all-else    X  |   -    |     -       |  -   |  -
#  
    
  def self.editabilities
    ['admin', 'self', 'editor']
  end
  def self.editor_roles
    ['admin', 'editor']
  end
  def editable_by_user( role, user_id = nil )  
  
    case self.editability
    # if editability is 'admin' only admin can edit
    when 'admin'
      ( role == 'admin' )  
    # if editability is 'self', owner user and 'admin' can edit
    when 'self'
      ( ( role == 'editor' and user_id == self.user_id ) or role == 'admin' )
    # if editability is 'editor', 'editor' and 'admin' can edit 
    when 'editor'
      ( role == 'admin' or role == 'editor' )
    # if editability is for some reason unspecified, admin can still edit
    else 
      ( role == 'admin' )
    end  
    
  end
  
#-----------------------------------------------------------------------------------------
#
# visibility defines what class of users can view a page; it can also be limited to one
# specific user; admin can view any page
#
#                       user-role  
#  page-visibility        admin   editor   self-editor   user   all-else
#                   admin    X  |   -    |     -       |  -   |  -
#                    self    X  |   -    |     X       |  -   |  -
#                  editor    X  |   X    |     X       |  -   |  -
#                     any    X  |   X    |     X       |  X   |  X
#                all-else    X  |   -    |     -       |  -   |  -
# 

  def self.visibilities
    ['any', 'user', 'editor', 'self', 'admin'] # nil... anything else
  end
  def visible_by_user( role, user_id = nil )
   
    case self.visibility
    when 'admin'
      ( role == 'admin' )
    when 'self'
      ( ( role == 'editor' and user_id == self.user_id ) or role == 'admin' ) 
    when 'editor'
      ( role == 'editor' or role == 'admin' ) 
    when 'user'
      ( role == 'editor' or role == 'admin' or role == 'user' )
    when 'any'
      true  
    else # anything else!
      ( role == 'admin' )
    end  
    
  end  
  
#-----------------------------------------------------------------------------------------
#
# utilities for files attached to pages - storage location public/storage/sitename
#
  def file_list
    files = Dir.glob( File.join( Rails.root , 'public', 'storage', self.site, self.name, '*' ) )
    files.delete_if {|f| File.directory?(f) }
    return files 
  end
  
  def file_target( f )
    File.join( '/storage', self.site, self.name, File.basename( f ) ).force_encoding("ASCII-8BIT") 
  end

#-----------------------------------------------------------------------------------------
#
# utilities for caching pages - cache location public/cache/sitename
#  
  def cache( content, cache_dir )
    cache_directory = File.join( Rails.root , 'public/cache', cache_dir )    
	if ! Dir.exists? cache_directory
	  Dir.mkdir cache_directory
	end     
    path = File.join( Rails.root , 'public/cache', cache_dir, self.name ) + '.html'    
    to_write = content[0] + ' cached'
    File.open(path, "w") { |f| f.write( to_write.force_encoding('ISO-8859-1') ) }
  end
  
  def uncache( cache_dir )
    path = File.join( Rails.root , 'public/cache', cache_dir, self.name ) + '.html'  
    if File.exists? path
      File.delete( path )
    end
  end
  
  def self.uncache_all( cache_dir )
    pages = self.all
    pages.each { |p| p.uncache( cache_dir ) }
  end
  
  private
  
#-----------------------------------------------------------------------------------------
#
# valiudators
#
  def name_downcase
   @name = @name.downcase if @name
  end
  
  def id_valid
    begin
      User.by_id(user_id)
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
          linktarget = '/storage/' + self.site + '/' + self.name + '/' + link[0]
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
          "<div class=\"pindiv panel panel-default\"><div class=\"pinmargin panel-body \">  #{operands}  </div></div>"
        # look for these in the lib folder...
=begin
        when 'ginit'
          eval 'ginit ' + operands        
        when 'gmap'
          eval 'gmap ' + operands
        when 'gmarker'
          eval 'gmarker ' + operands
        when 'gline'
          eval 'gline ' + operands
=end                 
        when 'questions'
          eval 'Questions::questions ' + operands
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
