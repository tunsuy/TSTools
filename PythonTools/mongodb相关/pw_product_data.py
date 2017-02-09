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
import json
from  xml.dom import  minidom

reload(sys)
sys.setdefaultencoding("utf-8")

if len(sys.argv) != 3 :
    print "use: " + sys.argv[0] + " did pid"
    sys.exit(1)

did = string.atoi(sys.argv[1])
pid = string.atoi(sys.argv[2])

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
mongoConn = pymongo.Connection(ip, port)
auth_flag = get_auth()
if auth_flag == 1:
    out=os.popen("/usr/bin/mongo_user admin 1").read()
    account=out.split(' ')
    mongoConn.admin.authenticate(account[0],account[1])

# mongoConn = pymongo.Connection("/tmp/mongodb-27017.sock", -1)
	
def product_data():
	userInfoTable = mongoConn.planwork.user_info
	clockRecordTable = mongoConn.planwork.clock_record

	userInfos = userInfoTable.find({}, {"_id": 0})
	for userInfo in userInfos:
		print json.dumps(userInfo, indent=4, sort_keys=True)
		userInfo_pid = userInfo["pid"]
		b_id = userInfo["b_id"]
		date = userInfo["date"]
		r_b_id = userInfo["r_b_id"]
		sf_id = userInfo["sf_id"]
		clockRecord = clockRecordTable.find_one({"did":did, "pid":pid}, {"_id": 0})
		print json.dumps(clockRecord, indent=4, sort_keys=True)
		if clockRecord:
			clockRecord.update({"did":did, "pid":pid}, {"$set":{"pid": userInfo_pid, "b_id": b_id, "date": date, "clocks.b_id": b_id, "clocks.r_b_id": r_b_id, "clocks.sf_id": sf_id, "clocks.date": date}})
		else:
			break
	
	clockRecord = clockRecordTable.remove({"did":did, "pid":pid})

product_data()

