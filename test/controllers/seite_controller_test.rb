require 'test_helper'

class SeiteControllerTest < ActionController::TestCase
  
  setup do 
    @page = pages(:one)
    @wido = Auth::User.find_by_username('wido_admin')
  end
  
  test "should get index" do
    get :index
    #assert_response :success
    assert_redirected_to '/c'
  end
  
  test "should get cached" do
    get :cached
    assert_response :success
  end  

  test "should get pageupdate" do
    get :pageupdate    
    assert_redirected_to '/'
  end

  test "save update" do
    post :pageupdate_save, name: @page.name, content: @page.content, 
      editability: @page.editability, 
      menu: @page.menu, visibility: @page.visibility
    assert_redirected_to '/'+@page.name
  end
  
  test "save update return to base page" do

    @page = pages(:two_films)
    assert_equal @page.name, 'talks_films'
    post :pageupdate_save, name: @page.name, content: @page.content, 
      editability: @page.editability, 
      menu: @page.menu, visibility: @page.visibility
    assert_redirected_to '/talks_films'
    
    @page = pages(:two_films_left)
    assert_equal @page.name, 'talks_films_left'    
    post :pageupdate_save, name: @page.name, content: @page.content, 
      editability: @page.editability, 
      menu: @page.menu, visibility: @page.visibility
    assert_redirected_to '/talks_films'
        
  end  
  
  test "upload and delete" do
    
    # first check directory does not exit
    path = File.join( Rails.root, 'public/storage/test')
    if File.exists? path + '/test.txt'
      File.delete( path + '/test.txt' )
    end    
    assert_not File.exists? path + '/test.txt'  
    if Dir.exists? path
      Dir.delete path
    end
    assert_not Dir.exists? path
     
    # upload the file
    post :file_upload, seite: 'test',
      file: fixture_file_upload('files/test.txt','text/txt')            
    assert File.exists? path + '/test.txt'  
      
    # delete the file
    post :file_delete, seite: 'test', filename: 'test.txt'
    assert_not File.exists? path + '/test.txt'  
      
  end
    
end
