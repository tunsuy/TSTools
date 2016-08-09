#!/bin/bash
#program:
#       usage:sh imsendmsg.sh -account xx [-gid xx] -msg xxx -n xx -p xx num
#       function:auto_send user's message by moa_client
#author:唐帅
#date：2014/4/8
#last change date:2014/4/8

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

startmsg=$4
for((i=0;i<$9;i++))
do
	imsend $1 $2 $3 $startmsg $5 $6 $7 $8
	startmsg=$(($startmsg+1))
done
