#!/usr/bin/ruby -w  
#  
require 'digest/md5'  

require "rubygems"  
# 这里gem用来检测系统是否安装”rubyzip“  
gem 'rubyzip'  
require 'zip/zip'  
  
if ARGV.empty?  
        puts "usgae: #$0 path"  
        exit 0  
end  
dir_name=ARGV.shift  

def dir_md5sum(path)  
        md5s=Array.new  
        if File.directory?(path)  
                Dir.new(path).each do |file|  
                        next if file =~ /^\.+$/  
                        file="#{path}/#{file}"  
                        if File.directory?(file)  
                                dir_md5sum(file)  
                        elsif File.file?(file)  
                                md5="#{Digest::MD5.hexdigest(File.read(file))} #{file}"  
                                md5s.push(md5)  
                        end  
                end  
        elsif File.file?(path)  
                md5="#{Digest::MD5.hexdigest(File.read(path))} #{path}"  
                md5s.push(md5)  
        else  
                puts "Ivalid File type"  
                exit 2  
        end 
        afm=File.new("C:\\Users\\vv\\Desktop\\androidFileMd5.txt","r+") 
        md5s.each do |item| 
        	afm.puts item   
        end 
        afm.close
end  
  
dir_md5sum(dir_name)  

#android_file_path = "D:\\androidfile"

#dir_md5sum(android_file_path)