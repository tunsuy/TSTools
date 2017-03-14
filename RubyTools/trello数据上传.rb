require 'csv'
require 'pathname'
require 'trello'

#获取脚本当前路径
PATH = Pathname.new(File.dirname(__FILE__)).realpath

#读取csv文件路径
#rFilePath = "#{PATH}/workReport.csv"
rFilePath = "./workReport.csv"
#puts rFilePath

#声明变量
testClass = []
testCase = []

#读取csv文件及其字段
CSV.foreach(rFilePath) do |file| 
    testClass << file[0]      #读取测试类
    testCase << file[1]      #读取测试点
end 

Trello.configure do |config|
  config.consumer_key = "xxxxxxxx"
  config.consumer_secret = "xxxxxx"
  config.oauth_token = "xxxxxx"
#  config.oauth_token_secret = TRELLO_OAUTH_TOKEN_SECRET
end

card = Trello::Card.find("EfD9x1TK") #car/board的id （URL）
puts card.name

tcindex = 0

testClass.uniq.each_with_index do |tcs,tcsIndex|
    if tcs.blank?
        next
    end

    puts tcs
    
    cktmp = card.create_new_checklist(tcs)
    ckId = cktmp.split(':')[1].split(',')[0].split('"')[1]

    puts ckId

    ck = Trello::Checklist.find(ckId)
    
    for i in tcindex...testCase.count do
        if testCase[i].blank?
	    tcindex = i
	    tcindex +=1
	    break
	end
	
	puts testCase[i]	

        ck.add_item(testCase[i],false,"bottom")
    end
end



