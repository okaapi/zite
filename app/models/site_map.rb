class SiteMap < ActiveRecord::Base
  validates_uniqueness_of :external
  validates_uniqueness_of :internal
  
  def self.by_external( site )
    if s = self.find_by_external( site )
      s.internal
    else 
      site
    end
  end
  
  def self.by_internal( site )
    if s = self.find_by_internal( site )
      s.external
    else 
      site
    end
  end  
  
end
