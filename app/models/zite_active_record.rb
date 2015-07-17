class ZiteActiveRecord < ActiveRecord::Base

    self.abstract_class = true
  
    def initialize(*args)
      super
      self.site = Rails.configuration.site
    end
    def self.default_scope
      where site: Rails.configuration.site
    end
 
 end
  
