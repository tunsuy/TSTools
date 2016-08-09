#!/bin/bash
#program:
#       usage:sh autoExec.sh
#       function:auto exec FindErrorLogt.sh based on ATM/ATT
#author：唐帅
#date：2014/3/27
#last change date:2014/3/27

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#由于一些原因，暂时不登入远端打包下载，而是直接在本地提取远端文件夹
#ssh root@200.200.107.221

#cd /home/moa/log/client/
#tar -czvf android.tgz android
#tar -czvf ios.tgz ios

#exit

scp -r -P 22222 root@oa.mymobilework.cn:/home/moa/log/client/android /root/tstmpDir
scp -r -P 22222 root@oa.mymobilework.cn:/home/moa/log/client/ios /root/tstmpDir

#rm -rf /home/moa/log/client/android /home/moa/log/client/ios

cd /root/tstmpDir

#tar -zxvf android.tgz
#tar -zxvf ios.tgz

source /root/tstmpDir/FindErrorLogt.sh | tee allErrorLog.log

tar -czvf andrErrorLog.tgz androidErrorDir
tar -czvf iosErrorLog.tgz iosErrorDir

mkdir allErrorLog
mv andrErrorLog.tgz iosErrorLog.tgz ./allErrorLog

cd ./allErrorLog

#按系统时间重命名文件
mv andrErrorLog.tgz andrErrorLog.`date +%y%m%d`.tgz
mv iosErrorLog.tgz iosErrorLog.`date +%y%m%d`.tgz

cd /root/tstmpDir

#上传提取出来的错误日志到相关人员的主机上
andrtmpvar=$(ls ./allErrorLog | grep "andr" | tail -n 1)
iostmpvar=$(ls ./allErrorLog | grep "ios" | tail -n 1)
#for tmpvar in $tmpvarlt
#do
#	andr=$(echo $tmpvar | grep "andr" | tail -n 1)
#	if [ "$andr" == "" ]; then
		#iosfilename=$(basename $tmpvar)
		pscp -pw 123 -scp -r ./allErrorLog/$andrtmpvar zhk@200.200.107.38:/d:/pack/崩溃日志/ios
#	else
		#andrfilename=$(basename $tmpvar)
		pscp -pw 123 -scp -r ./allErrorLog/$iostmpvar zhk@200.200.107.38:/d:/pack/崩溃日志/android
#	fi
#done
