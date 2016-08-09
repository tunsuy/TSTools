#!/usr/bin/ruby -w
#
require 'digest/md5'

require "rubygems"
# 这里gem用来检测系统是否安装”rubyzip“
gem 'rubyzip'
require 'zip/zip'

require 'pathname'
require 'open-uri'
require 'uri'

PATH = Pathname.new(File.dirname(__FILE__)).realpath

old_file_path = "#{PATH}/moafile/old"
new_file_path = "#{PATH}/moafile/new"
old_md5file_path = "#{PATH}/moamd5file/old/androidFileMd5.txt"
new_md5file_path = "#{PATH}/moamd5file/new/androidFileMd5.txt"
change_md5flie = "#{PATH}/moamd5file/change/androidFileMd5.txt"

def down_load(url,localfile)
  data=open(url){|f|f.read}
  open(localfile,"wb"){|f|f.write(data)}
end

def get_phone_file
	system("#{PATH}/oldmoa.bat") 
	system("#{PATH}/newmoa.bat")  
	
end

def get_file_md5(in_path,out_path)
	  md5s=Array.new
	  if File.directory?(in_path)
		Dir.new(in_path).each do |file|
		  next if file =~ /^\.+$/
		  file="#{in_path}/#{file}"
		  if File.directory?(file)
			get_file_md5(file,out_path)
		  elsif File.file?(file)
			md5="#{Digest::MD5.hexdigest(File.read(file))} #{file}"
			md5s.push(md5)
		  end
		end
	  elsif File.file?(in_path)
		md5="#{Digest::MD5.hexdigest(File.read(in_path))} #{in_path}"
		md5s.push(md5)
	  else
		puts "Ivalid File type"
		exit 2
	  end
	  afm=File.new("#{out_path}","a+")
	  md5s.each do |item|
		afm.puts item
	  end
	  afm.close
end

def cmp_str(str1,str2)
	if str1.eql?(str2)
		return true
	else
		return false
  end
end

def str_split(str)
	if str.empty?
		return false
	else
		md5 = str.split()[0]
		file_path = str.split()[1]
    return [md5,file_path]
	end
end

def gain_change_file(oldfilepath,newfilepath,changefile)
  IO.foreach("#{oldfilepath}") do |old_file|
    old_ret = str_split(old_file)
    IO.foreach("#{newfilepath}") do |new_file|
      new_ret = str_split(new_file)
      file_flag = cmp_str(old_ret[1],new_ret[1])
	  md5_flag = cmp_str(old_ret[0],new_ret[0])
      if file_flag == true && md5_flag == true
        chg_file = File.new("#{changefile}","a+")
        chg_file.puts old_ret[1]
        chg_file.close
      else
        next
      end
    end
  end
end

uri = "http://200.200.107.38/pack/MOA.apk"
apk_path = File.expand_path(File.join(File.dirname(__FILE__)))
puts "need down load apk from #{uri}"
down_load(uri, "#{apk_path}/MOA.apk")
get_phone_file

puts "开始生成MOA旧版本安装文件的MD5，请稍等..........."
get_file_md5("#{old_file_path}","#{old_md5file_path}")
puts "成功生成MD5文件"
puts "开始生成MOA新版本安装文件的MD5，请稍等..........."
get_file_md5("#{new_file_path}","#{new_md5file_path}")
puts "成功生成MD5文件"
puts "开始比较文件的变化，请稍等..........."
gain_change_file("#{old_md5file_path}","#{new_md5file_path}","#{change_md5flie}")
puts "比较完毕，请查看"
