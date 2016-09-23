#! /bin/bash  
  
word=`echo $1`  
params=`echo $#`  
#param is ok?  
if [ $params -lt 1 ];  then  
    echo "usage:xxxxx 'yourword'"  
    echo "   eq:xxxxx %CLIENT%"
    exit  
fi  
echo "your input param is "$word

#connect mysql and read tb names  
var=$(mysql -uroot -psangfordb -e"show databases like '$word';")  

#read table names 
index=0
for i in $var;  
do  
    index=$[ index+2 ]
    if [ $index -gt 1 ]; then
    	#delete from db  
    	echo "deleting ...$i"  
    	mysql -uroot -psangfordb -e"drop database $i"  
    fi
done;  
