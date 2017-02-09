#coding:utf-8
#!/usr/bin/python

import os
import sys

reload(sys)
sys.setdefaultencoding("utf-8")

def cmp_txt(txt1_file, txt2_file, result_file):
	print("开始对比...")
	txt1_lines_list = []
	txt2_lines_list = []
	
	with open(txt1_file, "r") as f:
		txt1_lines_list = f.readlines()
	with open(txt2_file, "r") as f:
		txt2_lines_list = f.readlines()
	
	txt2_lines_list_tmp = txt2_lines_list
	for txt1_line in txt1_lines_list:
		has_flag = False
		txt1_key = txt1_line.split(":")[0]
		txt1_value = txt1_line.split(":")[1]
		
		for txt2_line in txt2_lines_list:
			txt2_key = txt2_line.split(":")[0]
			txt2_value = txt2_line.split(":")[1]
			
			if txt1_key == txt2_key:
			#通过collection名字来对比
				if txt1_value != txt2_value:
				#如果不相同，则写入文件
					with open(result_file, "a") as f:
						f.write("【%s】 %s\n" % (txt1_file, txt1_line))
						f.write("【%s】 %s\n" % (txt2_file, txt2_line))
						f.write("===========================\n")
				has_flag = True  #txt1中在txt2中有对应的collection名字
				txt2_lines_list_tmp.remove(txt2_line)
				break
				
		if has_flag == False:
		##txt1中在txt2中没有对应的collection名字，写入文件
			with open(result_file, "a") as f:
				f.write("【%s】 %s\n" % (txt1_file, txt1_line))
				f.write("===========================\n")
		
	for txt2_line_tmp in txt2_lines_list_tmp:
	#txt2中有多余的collection名字，写入文件
		with open(result_file, "a") as f:
			f.write("【%s】 %s\n" % (txt2_file, txt2_line_tmp))
			f.write("===========================\n")
			
					
def main():
	if len(sys.argv) != 3:
		print("请输入需要对比的文本")
		print("eg: python cmp_txt.py txt1 txt2")
		sys.exit(0)

	txt1_file = sys.argv[1]
	txt2_file = sys.argv[2]

	result_file = "./cmp_result.txt"
	if os.path.isfile(result_file):
		os.remove(result_file)
	
	cmp_txt(txt1_file, txt2_file, result_file)
	print("done!")
		
if __name__ == '__main__':
	main()
