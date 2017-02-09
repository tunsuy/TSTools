#!/bin/bash
#program:
#	usage:sh wgetmoa.sh 
#	function:download moa-app from 0.25 and upload to 0.3
#author：唐帅
#date：2014/4/16
#last change date:2014/4/16

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin 
export PATH

if [ -d /root/ts/iosapp -o -d /root/ts/androidapp ]; then
	rm -rf /root/ts/iosapp /root/ts/androidapp
fi
if [ -f /root/ts/addressTxt ]; then
        rm -f /root/ts/addressTxt
fi

#有两种方式可以实现：
#一是通过提取网页源代码中的链接来下载；二是直接将链接写死在下载路径中
#这里演示对比一下（以后可按照这个修改）：ios使用第一种方式；Android使用第二种
#很明显第一种方式更好，即使以后下载地址变了也不影响

#第一种方式
wget -P /root/ts http://200.200.0.25/app/
cat /root/ts/index.html | grep '<a' > /root/ts/addressTxt
cat /root/ts/addressTxt | cut -d = -f 4 | grep -o '.*t' > /root/ts/iostmp1
sed 's/MOA.plist/MOA.ipa/g' /root/ts/iostmp1 > /root/ts/iostmp2
sed 's/MOA-cal.plist/MOA-cal.ipa/g' /root/ts/iostmp2 > /root/ts/iosaddress

for ios in $(cat /root/ts/iosaddress)
do
	wget -P /root/ts/iosapp $ios
done

#第二种方式
wget -P /root/ts/androidapp http://200.200.0.25/app/pack/MOA.apk 

rm -f /root/ts/index.html /root/ts/iostmp1 /root/ts/iostmp2 /root/ts/iosaddress
