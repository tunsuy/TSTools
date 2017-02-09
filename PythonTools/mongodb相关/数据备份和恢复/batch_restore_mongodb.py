import os,sys
	
db_stream = os.popen("echo 'show dbs' | mongo") 
db_stream = db_stream.read()
print "db_stream type: %s" % type(db_stream)
print "dbs: %s" % db_stream

dbs = db_stream.split('\n')
dbs = dbs[2:len(dbs)-2]
for index in range(0, len(dbs)):
    dbs[index] = dbs[index].split(' ')[0]
    print "db:>> %s" % dbs[index]
    os.popen("mongorestore -d %s --dir=./dump_mongodb/%s --drop" % (dbs[index],dbs[index]))
    
