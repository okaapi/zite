class ZiteActiveRecord < ActiveRecord::Base

    self.abstract_class = true
    @@site = nil

    def self.site( s )
      @@site = s
    end
    def self.site?
      @@site
    end    
    def initialize(*args)
      super
      self.site = @@site
    end
    def self.default_scope
      where site: @@site
    end
 
 end
  
