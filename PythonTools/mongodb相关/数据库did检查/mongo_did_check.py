#coding:utf-8
#!/usr/bin/python

import pymongo
import os
import sys
import string
import socket
import struct
import time
import base64
from  xml.dom import  minidom

reload(sys)
sys.setdefaultencoding("utf-8")

def get_ip():
    filename = "/etc/sangfor/moa/moa.xml"
    doc = minidom.parse(filename)
    root = doc.firstChild
    childs = root.childNodes
    ip = "/tmp/mongodb-27017.sock"
    for child in childs:
        if child.nodeType == child.TEXT_NODE:
            pass
        else:
            if child.getAttribute("name") == "mongodb_ip":
              ip = child.childNodes[0].data
    return ip
def get_port():
    filename = "/etc/sangfor/moa/moa.xml"
    doc = minidom.parse(filename)
    root = doc.firstChild
    childs = root.childNodes
    port = -1
    for child in childs:
        if child.nodeType == child.TEXT_NODE:
            pass
        else:
            if child.getAttribute("name") == "mongodb_port":
              port = child.childNodes[0].data
    return int(port)
def get_auth():
    filename = "/etc/sangfor/moa/moa.xml"
    doc = minidom.parse(filename)
    root = doc.firstChild
    childs = root.childNodes
    auth_flag = -1
    for child in childs:
        if child.nodeType == child.TEXT_NODE:
            pass
        else:
            if child.getAttribute("name") == "mongodb_need_auth":
              auth_flag = child.childNodes[0].data
    return int(auth_flag)
ip = get_ip()
port = get_port()
mongoConn = pymongo.MongoClient(ip, port)
auth_flag = get_auth()
if auth_flag == 1:
    out=os.popen("/usr/bin/mongo_user admin 1").read()
    account=out.split(' ')
    mongoConn.admin.authenticate(account[0],account[1])

collectionlist_file_path = "./transfer_mongo_collection_list.txt"
not_did_file_path = "./transfer_mongo_collection_not_did.txt"

def data_check():
	if os.path.isfile(not_did_file_path):
		os.remove(not_did_file_path)
	
	with open(collectionlist_file_path, "r") as f:
		dbs_name = f.readlines()

	for db_name in dbs_name:
		print "数据库——%s" % db_name

		db = mongoConn[db_name.strip()]
		collectionlist = db.collection_names()

		for collection in collectionlist:
			print "数据库表——%s" % str(collection)	

			data = db.get_collection(collection).find_one()
			if not data:
				continue
			index = 0
			for key in data.keys():
				if key == "did":
					break
				else:
					index += 1
				if index == len(data.keys()):
					print "该表不包含did字段，请检查实际公司字段名"
					print "==========================================="
					with open(not_did_file_path, "a") as f:
						f.write("%s.%s\n" % (db_name.strip(),collection))


def test():
	print "测试： "
	data = mongoConn['Legwork'].get_collection('Legwork.cusid').find_one()

	for key in data.keys():
		if key == "did":
			print "包含did"
			break

data_check()

test()




		



