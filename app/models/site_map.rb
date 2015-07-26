class SiteMap < ActiveRecord::Base
  validates_uniqueness_of :external
end
