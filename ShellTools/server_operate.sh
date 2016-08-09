#!/bin/bash
#program:
#	usage:sh FindErrorLog.sh 
#	function:download moa-app from 0.25 and upload to 0.3
#author：唐帅
#date：2014/9/28
#last change date:2014/9/28


PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin 
export PATH

#界面初始化
function init_input(){
	echo "-------服务端常用命令使用--------"
	echo "*************请选择**************"
	echo "     1、   忘记密码"
	echo "     2、   解绑公司"
	echo "     3、 清除所有公司"
	echo "     4、 要保留的公司"
	echo "     5、 更换手机号码"
	echo "     6、   创建公司"
	echo "     7、  退出本程序"
	echo "     ........"
	echo "*********************************"
}

function get_smapd_port(){
	smapd=$(netstat -anpt |grep smapd |grep 0.0.0.0:* |tail -n 1)
	smapd_line=$(echo $smapd|tr -s ' '|cut -d' ' -f4)
	smapd_port=$(echo ${smapd_line#*:})
	echo $smapd_port
}

smapd_port=`get_smapd_port`  
#echo $smapd_port

function get_verification_code(){
	if [ -n "$smapd_port" ]  
	then  
		process=$(mdbg -p $smapd_port -o exportdomain |grep $1 -A 20 |grep $2)
		process_du=$(echo $process | cut -d',' -f7)
		domain_authwrk_left=$(echo ${process_du#*(})
		process_port=$(echo ${domain_authwrk_left%)*})
		echo "process_port: $process_port"
		mdbg -p $process_port -o setlog trace
		echo "/home/moa/log/$2/$2.log"
		tail -n 500 /home/moa/log/$2/$2.log |grep 验证码
		exit  
	else  
		echo "$smapd_port is not exit!" 
		exit
	fi
}

function change_pwd(){
	get_verification_code $1 $2
}

function exit_domain(){
	get_verification_code $1 $2
} 

function del_all_domain(){
	if [ -n "$smapd_port" ]  
	then  
		all_domain_line=$(mdbg -p $smapd_port -o exportdomain |grep did)
		for domain_arr in ${all_domain_line[*]}
		do
			domain_du=$(echo $domain_arr | cut -d',' -f2)
			domain_left=$(echo ${domain_du#*(})
			domain=$(echo ${domain_left%)*})
			regtest -o "delete did=${domain}"
		done
		exit  
	else  
		echo "$smapd_port is not exit!"  
		exit
	fi  
}

function hold_domain(){
	if [ -n "$smapd_port" ]  
	then  
		all_domain_line=$(mdbg -p $smapd_port -o exportdomain |grep did)
		for domain_arr in ${all_domain_line[*]}
		do
			domain_du=$(echo $domain_arr | cut -d',' -f2)
			domain_left=$(echo ${domain_du#*(})
			domain=$(echo ${domain_left%)*})
			if [ "$domain" != "$1" ]
			then
				regtest -o "delete did=${domain}"
			else
				continue
			fi
		done
		exit  
	else  
		echo "$smapd_port is not exit!"  
		exit
	fi  
}

function change_phone(){
	exit_domain $1
}

function set_process_log_trace(){
	pid=`pidof $1`
	for i in `echo $pid`; do
		port=`netstat -antp |grep 0.0.0.0|grep $i |awk 'NR==2'|awk -F':' '{print $2}'|awk '{print $1}'`;
		if [ -z $port ]; then
			port=`netstat -antp |grep 0.0.0.0|grep $i |awk 'NR==1'|awk -F':' '{print $2}'|awk '{print $1}'`;
		fi
		mdbg -p $port -o setlog trace;
		echo "process_port: $port"
		echo "/home/moa/log/$1/$1.log"
		tail -n 100 /home/moa/log/$1/$1.log |grep 验证码
	done
}

while true
do
	init_input
	read choose
	case $choose in
	1)
		echo "请输入所属公司账号"
		read domain
		change_pwd $domain "authwrk"
		exit	
	;;
	2)
		echo "请输入所属公司账号"
		read domain
		exit_domain $domain "rosterwrk"
		exit
	;;
	3)
		del_all_domain
		exit
	;;
	4)
		echo "请输入想要保留的公司账号"
		read holddomain
		hold_domain $holddomain
		exit
	;;
	5)
		echo "请输入所属公司账号"
		read domain
		change_phone $domain
		exit
	;;
	6)
		set_process_log_trace "regwrk"
		exit
	;;
	7)
		exit
	;;
	*)
		echo " 请输入正确的选项...."
	esac
done
