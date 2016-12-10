#!/bin/bash
if [ $# != 2 ]
then
         echo "Please input two parameter,like  '2016-05-20 12:00' "
         exit 200;
fi
#check /etc/profile exits 'export TZ' environment,if exits ,delete
function checkProfile(){
  returnStr=`grep -ri 'export TZ' /etc/profile`
  if [ "$returnStr" !=  ""  ]
   then
     sed -i -e '/export TZ/d'  /etc/profile
       
  fi
}
checkProfile
#check time format
function isValidDate(){  
    date -d "$1" "+%F"|grep -q "$1" 2>/dev/null 
    if [ $? = 0 ]; then  
    echo "input:" $1 $2 
    else 
    echo "Time format is not correct ,please input like '2016-05-20 12:00' " 
    fi  
}
isValidDate $1 $2
CURTIME=`date "+%Y-%m-%d %H:%M" `;
echo "now:" $CURTIME
function timeExport(){
    if [ "$2" == 1 ]
     then
     timeFormat=`awk 'BEGIN{printf "%.2f\n",'$1'/3600}'`
     echo $1
     echo $timeFormat
     hour=`echo $timeFormat|awk -F '.' '{print $1}'`
     mins=`echo $timeFormat|awk -F '.' '{print $2}'`
     minm=`awk 'BEGIN{printf "%.0f\n",0.'$mins'*60}'`
     timeRetrunHour=`expr $hour + 8`
      
     ###分钟计算
     echo "input min:"$3
     inputmin=`echo $3|awk -F ':' '{print $2}'`
     nowmin=`date |awk '{print $4}'|awk -F ':' '{print $2}'`
     echo $nowmin
     echo $inputmin
     if [ "$nowmin" -gt "$inputmin" ]
      then 
       let hour=$hour-1
     fi
       
     timeRetrunTime=$timeRetrunHour:$minm
     echo "export TZ=RPC-$timeRetrunTime"     
    fi
       if [ "$2" == 2 ]
        then
     timeFormat=`awk 'BEGIN{printf "%.2f\n",'$1'/3600}'`
     echo $1
     echo $timeFormat
     hour=`echo $timeFormat|awk -F '.' '{print $1}'`
     mins=`echo $timeFormat|awk -F '.' '{print $2}'`
     minm=`awk 'BEGIN{printf "%.0f\n",0.'$mins'*60}'`
     let timeRetrunHour=$hour-8
     echo $timeRetrunHour
          ###分钟计算
     echo "input min:"$3
     inputmin=`echo $3|awk -F ':' '{print $2}'`
     nowmin=`date |awk '{print $4}'|awk -F ':' '{print $2}'`
     echo $nowmin
     echo $inputmin
     if [ "$nowmin" -gt "$inputmin" ]
      then 
       let hour=$hour-1
     fi 
     timeRetrunTime=$timeRetrunHour:$minm
          if [ "$timeRetrunHour" -lt 0 ]
        then
           echo "export TZ=RPC-${timeRetrunTime#-}"
        else
           echo "export TZ=RPC+$timeRetrunTime"
         fi
     fi
}
 
Sys_data=`date -d  "$CURTIME" +%s`    #把当前时间转化为Linux时间
In_data=`date -d  "$1 $2" +%s`
  if [ $In_data -ge $Sys_data ]
   then
    interval=`expr $In_data - $Sys_data`  #计算2个时间的差
    timeExport $interval 1 $2
     else
    interval=`expr  $Sys_data - $In_data`  
    timeExport $interval 2 $2
  fi
echo $interval
