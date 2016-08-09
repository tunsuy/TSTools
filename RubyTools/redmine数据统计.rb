require 'CSV'
require 'pathname'

#获取脚本当前路径
PATH = Pathname.new(File.dirname(__FILE__)).realpath

#读取csv文件路径
rFilePath = "#{PATH}/issues.csv"
#写入csv文件路径
versionBugNumFilePath = "#{PATH}/versionBugNum.csv"
moduleBugNumFilePath = "#{PATH}/moduleBugNum.csv"
versionPersonWeightFilePath = "#{PATH}/versionPersonWeight.csv"
leaveIssuePersonFilePath = "#{PATH}/leaveIssuePerson.csv"
onlineIssuePersonsFilePath = "#{PATH}/onlineIssuePersons.csv"

#声明变量
versionBugNum = []
versions = []
versionPersonWeight = []
assignPersons = []
weight = []
modules = []
issueTypes = []
personLiables = []
onlineIssuePersons = []
personLiableIssueNum = []
moduleBugNum = []
leaveIssuePerson = []
status = []
versionsFinished = []

#读取csv文件及其字段
CSV.open(rFilePath, 'r') do |file|  
    versions << file[18]       #读取版本列
	assignPersons << file[8]      #读取指派给列
	weight << file[21]      #读取工作粒度列
	modules << file[15]        #读取模块列
	issueTypes << file[2]         #读取跟踪列
	personLiables << file[17] 	 #读取责任人列
	status << file[4]       #读取问题状态列
  versionsFinished << file[22] #读取解决版本列
end 

#去重并排序
versionsUniq = versions.uniq.sort

#统计每个版本的bug成员
versionsUniq.each do |versionUniq|
	versions.each_with_index do |version,index|
		if version == versionUniq 
			if issueTypes[index] == "错误" || issueTypes[index] == "网上问题"
				if status[index] != "拒绝"
					versionBugNum << [assignPersons[index],versionUniq]
				end
			end
		end
	end
end

versionBugNumUniq = versionBugNum.uniq #去重

#统计每个版本对应成员的bug总数
versionBugNumUniq.each_with_index do |vbnu,index|
	count = 0
	versionBugNum.each do |vbn|
		count += 1 if vbn == vbnu
	end
	versionBugNumUniq[index] << count
end

versionBugNumUniq = versionBugNumUniq.sort #排序
#puts versionBugNumUniq
#统计每个模块的bug
versionsUniq.each do |versionUniq|
	versions.each_with_index do |version,index|
		if version == versionUniq
			if issueTypes[index] == "错误" || issueTypes[index] == "网上问题"
				if status[index] != "拒绝"
					moduleBugNum << [modules[index],versionUniq]
				end
			end
		end
	end
end

moduleBugNumUniq = moduleBugNum.uniq #去重

#统计每个模块对应版本的bug总数
moduleBugNumUniq.each_with_index do |vbnu,index|
	count = 0
	moduleBugNum.each do |vbn|
		count += 1 if vbn == vbnu
	end
	moduleBugNumUniq[index] << count
end

moduleBugNumUniq = moduleBugNumUniq.sort #排序

#统计每个版本的工作粒度
#assignPersons = assignPersons.sort
#versionsUniq.each do |versionUniq|
#	versions.each_with_index do |version,index|
#    puts status[index]
#    if status[index] == "已回归" || status[index] == "已解决"
#      if version == versionUniq
#       if issueTypes[index] == "功能"
#          versionPersonWeight << [assignPersons[index],versionUniq,weight[index]]
#        end
#      end
#    end
#  end
#end

#puts versionsFinished.uniq
versionsFinishedUniq = versionsFinished.uniq.sort

versionsFinishedUniq.each do |versionUniq|
	versionsFinished.each_with_index do |version,index|
    puts status[index]
    if status[index] == "已回归" || status[index] == "已解决"
      if version == versionUniq
        if issueTypes[index] == "功能"
          versionPersonWeight << [assignPersons[index],versionUniq,weight[index]]
        end
      end
    end
	end
end

#versionPersonWeightUniq = versionPersonWeight.uniq #去重

#统计每个版本对应成员的工作粒度
#versionPersonWeightUniq.each_with_index do |vbnu,index|
#	count = 0
#	versionPersonWeight.each_with_index do |vbn,item|
#      if "#{vbn}" == "#{vbnu}" && issueTypes[item] == "功能"
#        count += (weight[item].to_i)
#      end
#	end
#	versionPersonWeightUniq[index] << count
#end

versionPersonWeight = versionPersonWeight.sort
puts versionPersonWeight
#puts versionPersonWeight
persionWeight = []
count = versionPersonWeight[0][2].to_i
for i in 1...versionPersonWeight.length
	if versionPersonWeight[i][0] == versionPersonWeight[i-1][0] && versionPersonWeight[i][1] == versionPersonWeight[i-1][1]
		if i == (versionPersonWeight.length-1)
			count += versionPersonWeight[i][2].to_i
			persionWeight << [versionPersonWeight[i][0],versionPersonWeight[i][1],count]
		else
			count += versionPersonWeight[i][2].to_i
		end
	else
		persionWeight << [versionPersonWeight[i-1][0],versionPersonWeight[i-1][1],count]
		count = versionPersonWeight[i][2].to_i
	end
end
#puts versionPersonWeight
#persionWeight = persionWeight.sort #排序

#统计成员遗留问题
status.each_with_index do |type,index|
	if "#{type}" == "新建" || "#{type}" == "进行中" || "#{type}" == "后续再解决"
		if issueTypes[index] == "错误" || issueTypes[index] == "问题" || issueTypes[index] == "网上问题"
			leaveIssuePerson << [assignPersons[index]]
		end
	end
end

leaveIssuePersonUniq = leaveIssuePerson.uniq

#统计每个成员的遗留问题
leaveIssuePersonUniq.each_with_index do |vbnu,index|
	count = 0
	leaveIssuePerson.each_with_index do |vbn,item|
		count += 1 if vbn == vbnu
	end
	leaveIssuePersonUniq[index] << count
end

#统计网上问题数
issueTypes.each_with_index do |issue,index|
	if issue == "网上问题" && status[index] != "拒绝"
		onlineIssuePersons << personLiables[index]
	end
end

onlineIssuePersonsOnes = []

#将多维数组变成一维数组
#onlineIssuePersonsOne = onlineIssuePersons.flatten
onlineIssuePersons.each do |item|
    item.to_s.split(", ").each do |subItem|
      onlineIssuePersonsOnes << subItem.to_s
    end
end

onlineIssuePersonsUniqs = []
onlineIssuePersonsUniq = onlineIssuePersonsOnes.uniq #去重

#统计每个成员的网上问题数
onlineIssuePersonsUniq.each_with_index do |vbnu,index|
	count = 0
	onlineIssuePersonsOnes.each_with_index do |vbn,item|
		count += 1 if vbn == vbnu
	end
	#onlineIssuePersonsUniq[index] << count
	onlineIssuePersonsUniqs << [onlineIssuePersonsUniq[index],count]
end

#输出两列结果函数
def output_twoCols_result(name,type,filePath,inputData)
	CSV.open(filePath, 'w') do |writer|
		title = [name]
		title << [type]
		writer << title
		inputData.each do |item|
			item[0] = "未指定" if item[0].empty?
			writer << [item[0],item[1]]
		end
		writer << [nil, nil]
	 end
 end

#输出三列结果函数
def output_threeCols_result(name,versionU,filePath,inputData)
	CSV.open(filePath, 'w') do |writer|
		title = [name]
		for i in 0...versionU.length-1
			title << versionU[i] #if versionU[i] != ""
		end
		#versionU.each do |version|
		#	title << version
		#end
		title << "总数"
		writer << title
		personBug = [inputData[0][0]]
		if inputData[0][1] != versionU[0]
			count = 1
			versionPre = inputData[0][1]
			#puts versionPre
			vpi = 0
			versionU.each_with_index do |item,index|
				vpi = index if item == versionPre
			end
			#puts vpi
			vpi.to_i.times do
				personBug << ""
			end
		end
		personBug << inputData[0][2]
		#personBug[0][0] = "未指定" if personBug[0][0].empty?
		for i in 1...inputData.length
			if "#{inputData[i][0]}" == "#{inputData[i-1][0]}" 
				if i == inputData.length - 1
					personBug << inputData[i][2]
					sum = 0
					personBug[1...personBug.length].each do |item|
						sum += item.to_i
					end
					#personBug << sum
					while personBug.length != title.length-1 do
						personBug << ""
					end
					personBug << sum
					personBug[0] = "未指定" if personBug[0].empty?
					writer << personBug
				else
					vni = 0 
					vpi = 0
					versionNow = inputData[i][1]
					versionPre = inputData[i-1][1]
					versionU.each_with_index do |item,index|
						vni = index if item == versionNow
						vpi = index if item == versionPre
					end
					num = vni - vpi
					jg = num - 1
					jg.times do
						personBug << ""
					end
					personBug << inputData[i][2]
				end
			else
				sum = 0
				personBug[1...personBug.length].each do |item|
				#puts "kaishi"
					#puts item
					sum += item.to_i
				end
				#puts "hhhhh"
				#personBug << sum
				while personBug.length != title.length-1 do
					personBug << ""
				end
				personBug << sum
				personBug[0] = "未指定" if personBug[0].empty?
				writer << personBug
				personBug = [inputData[i][0]]
				#puts versionU[1]
				if inputData[i][1] != versionU[0]
					count = 1
					versionPre = inputData[i][1]
					#puts versionPre
					vpi = 0
					versionU.each_with_index do |item,index|
						vpi = index if item == versionPre
					end
					#puts vpi
					vpi.to_i.times do
						personBug << ""
					end
				end
				personBug << inputData[i][2]
			end
		end
		writer << [nil, nil]
	end
end

#输出：个人BUG数 排名，每个迭代
output_threeCols_result("姓名",versionsUniq,versionBugNumFilePath,versionBugNumUniq)

#输出：每个模块bug数
output_threeCols_result("模块",versionsUniq,moduleBugNumFilePath,moduleBugNumUniq)

#输出：每个版本成员工作粒度总和
#output_threeCols_result("姓名",versionsUniq,versionPersonWeightFilePath,persionWeight)

output_threeCols_result("姓名",versionsFinishedUniq,versionPersonWeightFilePath,persionWeight)

#输出每个成员遗留问题
output_twoCols_result("姓名","遗留问题总数",leaveIssuePersonFilePath,leaveIssuePersonUniq)

#输出每个成员的网上问题数
output_twoCols_result("姓名","网上问题总数",onlineIssuePersonsFilePath,onlineIssuePersonsUniqs)
 
