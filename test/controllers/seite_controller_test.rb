require 'test_helper'

class SeiteControllerTest < ActionController::TestCase
  
  setup do 
    ZiteActiveRecord.site( 'testsite45A67' )
    @page = pages(:one)
    @wido = users(:admin)
    request.host = 'testhost45A67'	 
    if Rails.configuration.page_caching            
      delete_cache_directories_with_content
    end 
  end
  
  test "should get index" do
    get :index
    assert_response :success
            

  end
 
  test "should get index logged in" do
    admin_login_4_test
    get :index, params: { seite: 'some_page_that_does_not_exist' }
    assert_redirected_to '/_pageupdate/some_page_that_does_not_exist'
  end 
  
  test "should get pageupdate not logged in new page" do
    get :pageupdate, params: { seite: 'some_page' }
    assert_redirected_to '/'
    assert_equal flash[:alert], 'need to login first...'
  end
  
  test "should get pageupdate not authorized in existing page" do
    login_4_test
    get :pageupdate, params: { seite: 'talks' }
    assert_redirected_to '/'
    assert_equal flash[:alert], 'not authorized...'
  end  

  test "should get pageupdate logged in" do
    admin_login_4_test
    get :pageupdate, params: { seite: 'some_page7' }
    assert_response :success
  end  
  
  test "should get pageupdate for index logged in" do
    admin_login_4_test
    get :pageupdate, params: { seite: 'index' }
    assert_response :success
  end

  test "should get file list" do
  
    # check site directory does exist
    site_path = File.join( Rails.root, 'public/storage/testsite45A67')       
    if ! Dir.exists? site_path
      Dir.mkdir site_path
    end
    assert Dir.exists? site_path
    
    # check directory does exist
    path = File.join( Rails.root, 'public/storage/testsite45A67/filetest')       
    if ! Dir.exists? path
      Dir.mkdir path
    end
    assert Dir.exists? path    
    
    # write a file
    File.open((path + '/testfile'), "wb") { |f| f.write('filetest testfile seite_controller_test.rb') }
    assert File.exists? path + '/testfile'  
        
    admin_login_4_test
    get :pageupdate, params: { seite: 'filetest' }
    assert_response :success
    assert_select '.filetable'
    assert_select "tr", 2
    assert_select 'a', /testfile/ 
    
    File.delete path + '/testfile'  
    Dir.delete path
    assert_not Dir.exists? path    
    
  end    

  test "should get pageupdate for index for previous version logged in" do
    pages = Page.where( name: 'index').order( :updated_at )
    assert_equal pages.count, 3
    stamp = pages[1].updated_at
    admin_login_4_test
    get :pageupdate, params: { seite: 'index', updated_at: stamp  }
    assert_response :success
  end
    
  test "bad page name" do
    admin_login_4_test
    get :pageupdate, params: { seite: 'Some_page' }
    assert_redirected_to '/'
    assert_equal flash[:alert][0..12], 'bad page name'
    get :pageupdate, params: { seite: 'Some page' }
    assert_redirected_to '/'
    assert_equal flash[:alert][0..12], 'bad page name'  
    get :pageupdate, params: { seite: '7some_page'}
    assert_redirected_to '/'
    assert_equal flash[:alert][0..12], 'bad page name'             
  end    

  test "save update" do
    assert_equal @page.name, 'index'
    assert_difference('Page.count', 1) do
      post :pageupdate_save, params: { name: @page.name, content: "newly added content", 
        editability: @page.editability, user_id: @wido.id,
        menu: @page.menu, visibility: @page.visibility }
      assert_redirected_to '/index'
      assert_nil flash[:alert]
      assert_equal flash[:notice], 'page index saved...'             
    end
    pg = Page.get_latest( @page.name )
    assert_equal pg.content, 'newly added content'
    
  end
 
  test "save update return to base page" do

    @page = pages(:two_films)
    assert_equal @page.name, 'talks_films'
    post :pageupdate_save, params: { name: @page.name, content: @page.content, 
      editability: @page.editability, user_id: @wido.id,
      menu: @page.menu, visibility: @page.visibility }
    assert_redirected_to '/talks_films'
    
    @page = pages(:two_films_left)
    assert_equal @page.name, 'talks_films_left'    
    post :pageupdate_save, params: { name: @page.name, content: @page.content, 
      editability: @page.editability, user_id: @wido.id,
      menu: @page.menu, visibility: @page.visibility  }
    assert_redirected_to '/talks_films'
        
  end  
 
  test "upload and delete" do
          
    # first create test file to make sure it works (permissions etc) 
    path = File.join( Rails.root, 'public/storage/testsite45A67')             
    if ! Dir.exists? path
	  Dir.mkdir path
	end	
    path = File.join( Rails.root, 'public/storage/testsite45A67/test')             
    if ! Dir.exists? path
	  Dir.mkdir path
	end
	assert Dir.exists? path
    if ! File.exists? path + '/test.txt'
      File.open(path + '/test.txt', "wb") { |f| f.write("will be deleted right away") }
    end	
    assert File.exists? path + '/test.txt' 
	  
	# now clean up...
    # first ensure directory does not exit  
    if File.exists? path + '/test.txt'
      File.delete( path + '/test.txt' )
    end    
    assert_not File.exists? path + '/test.txt'  
    if Dir.exists? path
      Dir.delete path
    end
    assert_not Dir.exists? path

    # check site directory does not exit
    site_path = File.join( Rails.root, 'public/storage/testsite45A67')       
    if Dir.exists? site_path
      Dir.delete site_path
    end
    assert_not Dir.exists? site_path
         
    # upload the file
    post :file_upload, params: { seite: 'test',
      file: fixture_file_upload('test.txt','text/txt')  }
    assert File.exists? path + '/test.txt'  
      
    # upload the file again
    post :file_upload, params: { seite: 'test',
      file: fixture_file_upload('test.txt','text/txt') }
    directory = Dir.glob( path + '/test.*.txt')
    assert_equal directory.count, 1
    assert File.exists?( directory[0] )      
    File.delete( directory[0] )
      
    # delete the file
    post :file_delete, params: { seite: 'test', filename: 'test.txt'  }
    assert_not File.exists? path + '/test.txt' 
    
    delete_storage_directories_with_content
      
  end
  
  test "search not logged in" do
    post :search, params: { term: 'xylo' }
    assert_redirected_to '/'
  end
   
  test "search as regular user" do
    login_4_test
    post :search, params: { term: 'xylo' }
    assert_response :success 
	assert_equal assigns(:array_of_names).count, 1
	assert_equal assigns(:array_of_names)[0], 'search user varus'
  end

  test "search as admin user" do
    admin_login_4_test
    post :search, params: { term: 'xylo' }
    assert_response :success 
	assert_equal assigns(:array_of_names).count, 2
	assert_equal assigns(:array_of_names)[0], 'search admin'
	assert_equal assigns(:array_of_names)[1], 'search user varus'	
  end

  test "search as regular user no results" do
    login_4_test
    post :search, params: { term: 'bylo' }
    assert_response :success 
	assert_equal assigns(:array_of_names).count, 0
  end
  
  test "search as regular user no term" do
    login_4_test
    post :search
    assert_response :success 
	assert_equal assigns(:array_of_names).count, 0
  end 

  test "search as regular user term 'e'" do
    login_4_test
    post :search, params: { term: 'e' }
    assert_response :success 
	assert_equal assigns(:array_of_names).count, 20
  end  
  
  test "search as regular in page name" do
    login_4_test
    post :search, params: { term: 'varus' }
    assert_response :success 
	assert_equal assigns(:array_of_names).count, 1
	assert_equal assigns(:array_of_names)[0], 'search user varus'
  end   
  
end
