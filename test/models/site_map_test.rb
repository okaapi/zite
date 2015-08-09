require 'test_helper'

class SiteMapTest < ActiveSupport::TestCase
  
  setup do

  end
  
  test 'find by external' do
    assert_equal SiteMap.by_external( 'testhost45A67' ), 'testsite45A67'
  end
  
  test 'find by external no site map' do
    assert_equal SiteMap.by_external( 'nositemap' ), 'nositemap'
  end  
  
  test 'find by internal' do
    assert_equal SiteMap.by_internal( 'testsite45A67' ), 'testhost45A67'
  end
  
  test 'find by internal no site map' do
    assert_equal SiteMap.by_internal( 'nositemap' ), 'nositemap'
  end    
  
  test 'add' do
    assert_difference('SiteMap.count', 1) do
      SiteMap.create( internal: 'foo', external: 'foo' )
    end
  end
    
  test 'internal unique' do
    assert_difference('SiteMap.count', 0) do
      SiteMap.create( internal: 'testsite45A67', external: 'foo' )
    end
  end
  
  test 'external unique' do
    assert_difference('SiteMap.count', 0) do
      SiteMap.create( internal: 'foo', external: 'testhost45A67' )
    end
  end  

end

