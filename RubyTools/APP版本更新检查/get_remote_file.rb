require 'net/ssh'
require 'net/sftp'
require 'net/scp'

def traverse_dir(file_path)  
  if File.directory? file_path  
    Dir.foreach(file_path) do |file|  
      if file!="." and file!=".."  
        traverse_dir(file_path+"/"+file){|x| yield x}  
      end  
    end  
  else  
    yield  file_path  
  end  
end  

# Net::SSH.start('200.200.107.38', 'zhk', :password => '123') do |ssh|
   # ssh.sftp.connect do |sftp|
    # sftp.foreach(".") do |file|
      # puts file
    # end
   # ssh.scp_get("d:/pack/appbackup","E:/moa_apk")
   #end

 # end

 #Net::SCP.start('200.200.107.38', 'zhk', :password => '123') do |scp|
   #scp.upload!( 'c:/scp1.rb', '/home/oldsong/' )
 #  scp.download!( "d:/pack/appbackup","E:/moa_apk" )
 #end
 
 
