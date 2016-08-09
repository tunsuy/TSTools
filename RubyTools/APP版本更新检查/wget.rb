require 'open-uri' 
require 'uri'

html = open('http://200.200.107.38/').read(2000000) 

END_CHARS = %{.,'?!:;}
puts URI.extract(html, ['http']).collect { |u| END_CHARS.index(u[-1]) ? u.chop : u }