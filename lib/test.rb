require "../config/environment" unless defined?(::Rails.root)

=begin
  ZiteActiveRecord.site( 'a' )
  u = User.create( username: 'a1', email: 'a1@gmail.com', password: 'aaa', password_confirmation: 'aaa' )
  u.save!
  puts "saved user #{u.id}, name #{u.username} site #{u.site}"
  
  ZiteActiveRecord.site( 'b' )
  u = User.create( username: 'a1', email: 'a1@gmail.com', password: 'aaa', password_confirmation: 'aaa' )
  u.save!
  puts "saved user #{u.id}, name #{u.username} site #{u.site}" 
=end

 ZiteActiveRecord.site( 'a' )
 u = User.find_by_username( 'a1' )
 puts "found user #{u.id}, name #{u.username} site #{u.site}" 
 u = User.where( username: 'a1' ).first
 puts "found user #{u.id}, name #{u.username} site #{u.site}"  
 
 ZiteActiveRecord.site( 'b' )
 u = User.find_by_username( 'a1' )
 puts "found user #{u.id}, name #{u.username} site #{u.site}" 
 u = User.where( username: 'a1' ).first
 puts "found user #{u.id}, name #{u.username} site #{u.site}"  

