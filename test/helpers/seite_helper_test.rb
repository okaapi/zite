require 'test_helper'

class SeiteHelperTest < ActionView::TestCase

  setup do
	ZiteActiveRecord.site( 'testsite45A67' ) 
    @wido = users(:wido)
    @wido_user = users(:user)
    @page = pages(:one)
  end
  	    
  test "admin" do
    assert is_admin( @wido )
  end
  
  test "not admin" do
    assert_not is_admin( @wido_user )
  end  
  
  test "img tag" do
    assert if_image( @page, 'flowers.jPg') =~ /<img/
  end
  
  test "pdf tag" do
    assert if_image( @page, 'flowers.PdF') =~ /<img(.*)pdf\.ico/
  end  

end