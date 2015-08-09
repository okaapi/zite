require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  	    
  test "prettytime" do
    assert_equal prettytime( nil ), 'sometime'
  end
  
end