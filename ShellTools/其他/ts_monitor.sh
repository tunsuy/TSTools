#! /bin/bash 
 
mem_quota=20 
hd_quota=50 
cpu_quota=80 
 
 
# watch memory usage 
 
watch_mem() 
{ 
  memtotal=`cat /proc/meminfo |grep "MemTotal"|awk '{print $2}'` 
  memfree=`cat /proc/meminfo |grep "MemFree"|awk '{print $2}'` 
  cached=`cat /proc/meminfo |grep "^Cached"|awk '{print $2}'` 
  buffers=`cat /proc/meminfo |grep "Buffers"|awk '{print $2}'` 
 
  mem_usage=$((100-memfree*100/memtotal-buffers*100/memtotal-cached*100/memtotal)) 
 
  if [ $mem_usage -gt $mem_quota ];then 
     mem_message="WARN! The Memory usage is over than $mem_usage%" 
     return 1 
  else 
     return 0 
  fi 
} 
 
 
# watch disk usage 
 
watch_hd() 
{ 
  sda1_usage=`df |grep 'sda1'|awk '{print $5}'|sed 's/%//g'` 
  sdc1_usage=`df |grep 'sdc1'|awk '{print $5}'|sed 's/%//g'` 
  lv_home_usage=`df |grep '/home'|awk '{print $4}'|sed 's/\%//g'` 
   
  if [ $sda1_usage -gt $hd_quota ] || [ $sdc1_usage -gt $hd_quota ] || [ $lv_home_usage -gt $hd_quota ]; then 
     hd_message="WARN! The Hard Disk usage is over than $hd_quota%" 
     return 1 
  else 
     return 0 
  fi 
} 
 
 
# watch cpu usage in one minute 
 
get_cpu_info() 
{ 
  cat /proc/stat|grep '^cpu[0-9]'|awk '{used+=$2+$3+$4;unused+=$5+$6+$7+$8} END{print used,unused}' 
} 
 
watch_cpu() 
{ 
  time_point=`get_cpu_info` 
  cpu_usage=`echo $time_point |awk '{used=$1;total=$1+$2;print used*100/total}'` 
  
  if [[ $cpu_usage > $cpu_quota ]]; then 
     cpu_message="WARN! The CPU Usage is over than $cpu_quota%" 
     return 1 
  else 
     return 0 
  fi 
} 
 
proc_cpu_top10() 
{ 
  proc_busiest=`ps aux|sort -nk3r|head -n 11` 
} 
 
report=/root/server_report.log 

while(true)
do
	watch_mem 
	if [ $? -eq 1 ]; then 
	   date >> $report 
	   echo "$mem_message" >> $report
	   echo "================================"
	fi 
	 
	watch_hd 
	if [ $? -eq 1 ]; then 
	   date >> $report 
	   echo "$hd_message" >> $report 
	   echo "================================"
	fi 
	 
	watch_cpu 
	if [ $? -eq 1 ]; then 
	   date >> $report 
	   echo "$cpu_message" >> $report 
	   proc_cpu_top10 
	   echo "CPU useage top10 are ： "
	   echo "$proc_busiest" >> $report 
	   echo "================================"
	fi 
done
 
