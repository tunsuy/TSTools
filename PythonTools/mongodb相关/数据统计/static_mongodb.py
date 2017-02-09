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

import json, ast

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

def get_db_conn():
	ip = get_ip()
	port = get_port()
	print("ip:port - %s:%s" % (ip, port))
	mongoConn = pymongo.MongoClient(ip, port)
	auth_flag = get_auth()
	if auth_flag == 1:
	    out=os.popen("/usr/bin/mongo_user admin 1").read()
	    account=out.split(' ')
	    mongoConn.admin.authenticate(account[0],account[1])
	return mongoConn

def static(db_conn, static_did, static_file):
	db_names = db_conn.database_names()
	for db_name in db_names:
	    print "数据库:>> %s" % db_name

	    db = db_conn[db_name]
	    #db = db_conn.db_name这样不行，原因不明
	    collectionlist = db.collection_names()

	    for collection in collectionlist:
			print "数据库表:>> %s" % collection	

			count = db[collection].find({"did": static_did}).count()
			with open(static_file, "a") as f:
						f.write("%s.%s: %s\n" % (db_name.strip(), collection, count))

def main():
	if len(sys.argv) != 2:
		print("请输入需要统计的公司did")
		print("eg: python static_mongodb.py 10000")
		sys.exit(0)

	did = sys.argv[1]

	static_file = "./static_mongodb.txt"
	if os.path.isfile(static_file):
		os.remove(static_file)

	db_conn = get_db_conn()
	static(db_conn, int(did), static_file)

if __name__ == '__main__':
	main()
