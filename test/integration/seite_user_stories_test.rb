require 'test_helper'

class SeiteUserStoriesTest < ActionDispatch::IntegrationTest
  
  setup do
    @user_arnaud = Auth::User.new( username: 'arnaud', email: 'arnaud@gmail.com', 
                                 active: 'confirmed',
                                 password: 'secret', password_confirmation: 'secret')
    @user_arnaud.save!  
    
    @wido = Auth::User.find_by_username('wido_admin')
    # need to change <#= #> to <%= %>
    pages = Page.all
    pages.each do |page|
      if page.content
        page.content = page.content.gsub(/<#=/,'<%=').gsub(/#>/,'%>')
      end
      page.user_id = @wido.id
      page.save!  
    end
          
  end

  #
  test "viewing a page not logged in" do
     
    # refresh the time stamps    
    one = pages( :one )
    one.id_will_change!      
    one_header = pages( :one_header )
    one_header.id_will_change!
    sleep( 1 )
    one.save!
    one_header.save!
    one_old = pages( :one_header_older)
   
    path = File.join( Rails.root , 'public', 'c', 'home' ) + '.html'    
    File.delete( path ) if File.exists? path

    get_via_redirect "/"
    assert_response :success
    assert_select '.header', 'HOME HEADER'
    assert_select '.menu', 'HOME MENU'      
    assert_select '.left', 'HOME LEFT' 
    assert_select '.center', 'Home Page'
    assert_select '.right', 'HOME RIGHT' 
    assert_select '.footer', 'HOME FOOTER'
    assert File.exists? path
    
    get_via_redirect "/talks"
    assert_response :success
    assert_select '.center', 'protected content...'
     
  end
      
  #
  test "viewing a page logged in" do
  
    # enters correct password and gets logged in and session is created
    xhr :post, "/_prove_it", claim: "arnaud", password: "secret"
    assert_response :success
    assert_equal flash[:notice], 'arnaud logged in'
    
    # refresh the time stamps    
    one = pages( :one )
    one.id_will_change!      
    one_header = pages( :one_header )
    one_header.id_will_change!
    sleep( 1 )
    one.save!
    one_header.save!
    one_old = pages( :one_header_older)
   
    path = File.join( Rails.root , 'public', 'c', 'home' ) + '.html'    
    File.delete( path ) if File.exists? path

    get "/"
    assert_response :success
    assert_select '.header', 'HOME HEADER'
    assert_select '.menu', 'HOME MENU'      
    assert_select '.left', 'HOME LEFT' 
    assert_select '.center', 'Home Page'
    assert_select '.right', 'HOME RIGHT' 
    assert_select '.footer', 'HOME FOOTER'
    assert_not File.exists? path
    
    get "/talks"
    assert_response :success
    assert_select '.center', 'protected content...'
     
  end
  
  #
  test "viewing a page logged in as admin" do
  
    # enters correct password and gets logged in and session is created
    xhr :post, "/_prove_it", claim: "wido_admin", password: "secret"
    assert_response :success
    assert_equal flash[:notice], 'wido_admin logged in'
    
    # refresh the time stamps    
    one = pages( :one )
    one.id_will_change!      
    one_header = pages( :one_header )
    one_header.id_will_change!
    sleep( 1 )
    one.save!
    one_header.save!
    one_old = pages( :one_header_older)
    
    get "/"
    assert_response :success
    assert_select '.header', 'HOME HEADER'
    assert_select '.menu', 'HOME MENU'      
    assert_select '.left', 'HOME LEFT' 
    assert_select '.center', 'Home Page'
    assert_select '.right', 'HOME RIGHT' 
    assert_select '.footer', 'HOME FOOTER'
    
    get "/talks"
    assert_response :success
    assert_select '.center', 'Talks'
     
  end
    
  
end