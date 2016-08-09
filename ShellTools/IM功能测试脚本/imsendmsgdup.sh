#!/bin/bash
#program:
#       usage:sh imsendmsg.sh -account xx [-gid xx] -msg xxx num
#       function:auto exec FindErrorLogt.sh based on ATM/ATT
#author：唐帅
#date：2014/4/8
#last change date:2014/4/8

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

accountlist=$(rostertest -gap | grep "login_account" | head -n $5 | awk -F = '{printf $2}')

for acnt in $accountlist
do
        imsend $1 $2 $3 $4 -n $acnt -p 12345
done
