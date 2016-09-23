import os,sys
	
db_stream = os.popen("echo 'show dbs' | mongo -u admin -p admin --authenticationDatabase admin") 
db_stream = db_stream.read()
print "db_stream type: %s" % type(db_stream)
print "dbs: %s" % db_stream

dbs = db_stream.split('\n')
dbs = dbs[2:len(dbs)-2]
for index in range(0, len(dbs)):
    dbs[index] = dbs[index].split(' ')[0]
    print "db:>> %s" % dbs[index]
    os.popen("mongodump -u admin -p admin --authenticationDatabase admin -d %s -o ./dump_mongodb" % dbs[index])
    
