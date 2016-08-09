#!/bin/bash
#program:
#       usage:sh install_server_packet.sh date
#       function:auto_install server packet
#author：唐帅
#date：2014/8/27
#last change date:2014/8/27

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#创建一些目录与文件
if [ -d /root/packet ]; then
	rm -rf /root/packet
fi

mkdir /root/packet
chmod 777 /root/packet

passwd="123"
ip="200.200.107.38"
dir="C:/Program\ Files/Sangfor/SSL/LogKeeper/htdocs/pack/server/$1/*"
	
function gain_packet(){

	/bin/rpm -qa | grep -q expect

	if [ $? -ne 0 ]; then
    		echo "please install expect"
    		exit 1
	fi
	expect -c "
    		spawn scp -p zhk@$ip:/\"$dir\" /root/packet
    		expect {
			\"yes/no\" {send \"yes\r\"; exp_continue;}
			\"*assword\" {set timeout 300; send \"$passwd\r\";}
		}	
	expect eof"	

	#scp -r zhk@200.200.107.38:"/C:/Program\ Files/Sangfor/SSL/LogKeeper/htdocs/pack/server/$1" /root/packet
	
	if [ $? -eq 0 ]; then	
		cd /root/packet
		for modelname in `ls`
		do
			tar zxvf $modelname
			rm -f $modelname
		done
	fi
}

	
function install(){
	if [ "$2" == "production" ] ; then
		echo "production_environment" > /usr/bin/production_environment
	fi

	for dir in `ls -rt`
	do
		if [ -d $dir ]; then
			cd $dir
			./install.sh
			if [ $? != 0 ]; then
				echo !!!!!!!!!!!!!!!!!!!!!!!!!!!
				echo !!!!$dir install failed!!!!
				echo !!!!!!!!!!!!!!!!!!!!!!!!!!!
#				exit 1;
			fi
			cd -
		fi
	done

	chmod 777 /home/moa/log -R
	/etc/init.d/moa restart
}

if [ $# -ne 2 ]; then
	echo "usage:sh install_server_packet.sh date test|production"
	echo "date: date of server-packet . eq:8-26"
else
	gain_packet $1
	install
fi




