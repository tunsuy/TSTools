

require 'rubygems'
require 'zip'



directory = 'C:\\Users\\vv\\Desktop\\directory_to_zip\\'
zipfile_name = 'C:\\Users\\vv\\Desktop\\MOA.apk'

Zip::ZipFile::open(zipfile_name) do |zipfile|
	puts zipfile
    Dir[File.join(directory, '**', '**')].each do |file|
      zipfile.add(file.sub(directory, ''), file)
      puts file
    end
end