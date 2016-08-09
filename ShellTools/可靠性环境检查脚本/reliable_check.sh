#!/bin/bash

#1.获取主机的管理IP

dmz_ip=`ifconfig eth1 |grep "inet addr"|cut -f 2 -d ":"|cut -f 1 -d " "`

#2.设置发送人和收件人
sender=23728@sangfor.com # 发信人的email
reciver=23728@sangfor.com # 收信人的email
subject="Reliable Report from $dmz_ip" # 邮件的标题
smtp='200.200.0.12' # 修改这里，邮件服务器地址

#发送邮件
send_mail(){
(
  sleep 5
  for comm in "help sangfor.com" "mail from:$sender"
  do
     echo "$comm"
     sleep 3
  done
  #设置发送人员列表
  echo $reciver | sed 's/,/\n/g'| while read user
  do
	sleep 3
	echo "rcpt to:$user"
  done
  sleep 2
  #设置发送数据
  
  for data in "data" "From: <$sender>" "To:`echo $reciver|sed 's/,/;/g'`" "Subject: $subject" "Date: `date` +0800" "Mime-Version: 1.0" "content-Type: text/plain"
  do
     echo "$data"
     sleep 3
  done 
   test -r $OUTFILE && cat $OUTFILE
   echo "." 
   sleep 5)|telnet $smtp  25 
}

# 在当前目录下保存检查的结果输出
OUTFILE="/sf/log/reliable_check_`date +%m-%d_%H%M`.txt"
TMP1="./tmp1.txt"
TMP2="./tmp2.txt"
if [ -f $OUTFILE ]; then
	rm -f $OUTFILE
else
	touch $OUTFILE
fi

#检查主机是否有core产生
function check_core(){
	CorePath=" /sf/data/reliable_core/"
	#1 查看有无core文件,  ls /sf/data/local/dump/*core* 命令查看/sf/data/local/dump/目录下是否有core文件生成.
	#2 有则检查不通过,同时收集这些文件信息给研发.

	ls /sf/data/local/dump/*core*
	if [ $? -eq 0 ]; then
		echo "CORE : [ERROR] there is core files in ls /sf/data/local/dump/*core*, please check in the $CorePath." >> $OUTFILE
		echo "/sf/data/local/dump/*core* -lt:" >> $OUTFILE
		ls /sf/data/local/dump/*core* -lt >> $OUTFILE
		if [ ! -d "$CorePath" ]; then 
			mkdir "$CorePath" 
		fi
		echo "!!!!!!!!!!!!!!!!!!!And the core file is move to $CorePath!!!!!!!!!!!!!!!!!!!" >> $OUTFILE
		#`mv /sf/data/local/dump/*core* /sf/data/reliable_core/`
	else
		echo "CORE : [OK] There is no new core files." >> $OUTFILE
	fi
}
#遍历虚拟机的镜像目录
function ergodic(){
for file in ` ls $1`
do
                cmd =`echo "$1"/"$file" `
                if [ -d "$cmd"] #如果 file存在且是一个目录则为真
                then
                      ergodic $1"/"$file
                else
                      local path=$1"/"$file #得到文件的完整的目录
                      local name=$file       #得到文件的名字
                      #做自己的工作.
					  cd "$1"
					  is_split_brain.sh  `pwd`|grep  "file(s) is ok">tmp.txt
	                  IS_File_OK=1
	                  TMPVALUE='cat /sf/log/tmp.txt'
	                  if [ "$TMPVALUE" == "file(s) is ok" ]; then
                      IS_File_OK=0
	                  fi
	                 rm tmp.txt
	                 if [ $? -ne 0 ]; then
                     IS_File_OK=0
	                 fi
	                 if [ $IS_File_OK -eq 0 ]; then
                     echo "$name : [ERROR] $name is split brain" >> $OUTFILE
	                 else
                     echo "$name : [OK] $name is  is OK" >> $OUTFILE
	                 fi					  
               fi
done
}
# 检查虚拟机是否有脑裂
function check_is_split_brain(){
    
     #遍历虚拟机镜像目录下各个文件，查看是否有脑裂情况的出现，如果有的话，记录脑裂的虚拟机信息   
     INIT_PATH="/sf/data/vs/gfs/rep2/images/cluster"
     ergodic $INIT_PATH    
	 


}
#hosts peer status check
function check_peer_status()
{ 
    hosts=`/sf/sbin/get_nodes_status.pl | awk -F ':' '{print $1}'`
    peer_num=$(($host_num-1))
	for host in $hosts
    do
        echo -e "check peer status: $host"
        res=`ssh "$host" gluster peer status 2>/dev/null | grep 'Peer in Cluster (Connected)' | wc -l`
        if [ $res != $peer_num ]; then
            echo -e "$RED ERROR ! ! ! gluster peer error in $host $DEFAULT">>$OUTFILE
        fi
    done
}
# # 检查最近24小时是否有宕机
# function detect_device_health(){
	# RESULT=`find /aclog/lkcd/Crashed* -mtime -1 -type d -print`
	# if test "`echo $RESULT | grep Crashed`" ; then
		# echo "lkcd : [ERROR] There is lkcd files in /aclog/lkcd/,please do something." >> $OUTFILE
		# cat /aclog/lkcd/lkcd.log >> $OUTFILE
		# lkcd_cnf -r | head -n 30 >> $OUTFILE		
	# else
		# echo "lkcd : [OK] In the last 24 hours, there is no new lkcd file." >> $OUTFILE
	# fi
# }

#检查内存使用情况
function check_mem(){
	#1.1 查看meminfo信息, 如果(Cached+MemFree)/MemTotal<20%,则认为内存使用有问题,检查不通过.
	CACHED=`cat /proc/meminfo | grep "^Cached:" | awk '{print $2}'`
	MEMFREE=`cat /proc/meminfo | grep MemFree | awk '{print $2}'`
	MEMTOTAL=`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`

	let FREERATE=$(( $(($CACHED+$MEMFREE))*100/$MEMTOTAL ))

	if [ $FREERATE -le 20 ]; then
		echo "memory : [ERROR] free mem rate: $FREERATE%, less than 20%;" >> $OUTFILE
	else
		echo "memory : [OK] free mem rate: $FREERATE%" >> $OUTFILE
	fi
}

#检查磁盘使用情况
function check_disk_usage(){
	# 磁盘使用情况, 运行df命令， 如果任何一个分区的使用率超过95%，则检查不通过
	df | awk '{print $1, $5}' > $TMP1
	cat $TMP1 | awk -F"%" '{print $1}' | sed -e '1d' > $TMP2
	DISKUSE=`cat $TMP2 | awk '{print $2}'`
	ISOK=1

	for RATE in $DISKUSE; do
		if [ $RATE -ge 95 ]; then
			DISKINFO=`grep "$RATE" $TMP1`
			ISOK=0
			echo "DISK : [ERROR] $DISKINFO " >> $OUTFILE
		fi
	done
	if [ $ISOK -eq 1 ]; then
		echo "DISK : [OK] disk use rate lower than 95%" >> $OUTFILE
	fi
}


function check_uptime(){
	echo "*******reliable environment check *******" >>$OUTFILE
	UT=`uptime`
	echo "uptime :$UT" >>$OUTFILE
}

#检查卷是否可用，主机是否离线
function check_rep2(){
# 查看/sf/data/vs/gfs/rep2目录是否可写, 进入rep2目录,使用echo 123 > 1.txt命令.然后观察有无生成1.txt文件,并且里面的内容是123.若无则不通过. 
# 之后使用rm 1.txt删除刚刚生成的文件.若不能删除则检查不通过.这个主要检查/rep2目录是否可写，不可写的情况说明卷只读，主机可能掉线。
	echo 123 > /sf/data/vs/gfs/rep2/1.txt
	TMPVALUE=`cat /sf/data/vs/gfs/rep2/1.txt`
	IS_REP2_OK=1
	if [ $TMPVALUE -ne 123 ]; then
        IS_REP2_OK=0
	fi
	rm /sf/data/vs/gfs/rep2/1.txt
	if [ $? -ne 0 ]; then
        IS_REP2_OK=0
	fi
	if [ $IS_REP2_OK -eq 0 ]; then
        echo "rep2 : [ERROR] /rep2 directory can not write，it is read only" >> $OUTFILE
	else
        echo "rep2 : [OK] /rep2 directory is OK" >> $OUTFILE
	fi
}


check_uptime
check_mem
check_disk_usage
check_rep2
check_core
check_peer_status
check_is_split_brain
#detect_device_health

#输出结果
send_mail

rm -rf $TMP1 $TMP2

