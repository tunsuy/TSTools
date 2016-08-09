#!/bin/bash
#program:
#	usage:sh FindErrorLog.sh 
#	function:find out android and ios system error log
#author：唐帅
#date：2014/2/28
#last change date:2014/3/4

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin 
export PATH

#创建一些目录与文件
if [ ! -d ./iosErrorDir -o ! -d ./androidErrorDir ]; then
	mkdir iosErrorDir;mkdir androidErrorDir
fi
if [ ! -f ./iosReasonTxt -o ! -f ./androidTwoTxt -o ! -f ./andrCausedTxt ]; then
	touch iosReasonTxt;touch androidTwoTxt;touch andrCausedTxt
fi

#保存错误日志文件的目录路径
iosPath=/root/tstmpDir/ios/sangfor
androidPath=/root/tstmpDir/android/sangfor

#函数功能：比较ios系统下两个错误日志文件中的reason行是否相同
function iosCompareTxt(){  
	reasonLine=$(cat $iosPath/$1 | grep "Reason")
	ifRsLox=$(echo $reasonLine | grep "0x")
	if [ "$ifRsLox" == "" ]; then
		rLp=$(echo ${reasonLine//\[/\\\[})
		rLpn=$(echo ${rLp//\]/\\\]})
		rLpx=$(echo ${rLpn//\*/\\\*})
		rLph=$(echo ${rLpx//\-/\\\-})
		ifDiffReason=$(cat ./iosReasonTxt | grep "$rLph")
		if [ "$ifDiffReason" == "" ]; then
			echo "$reasonLine" >> ./iosReasonTxt
			return 1
		else
			return 0
		fi
	else
		rLpox=$(echo $reasonLine | grep "Reason" | grep -o '.*0x')
		rLp=$(echo ${rLpox//\[/\\\[})
		rLpn=$(echo ${rLp//\]/\\\]})
		rLpx=$(echo ${rLpn//\*/\\\*})
		rLph=$(echo ${rLpx//\-/\\\-})
		ifDiffReason=$(cat ./iosReasonTxt | grep "$rLph")
		if [ "$ifDiffReason" == "" ]; then
			echo "$rLpox" >> ./iosReasonTxt
			return 1
		else
			return 0
		fi
	fi
}

#函数功能：比较Android系统下两个错误日志文件中的Caused行
function andrCompCause(){
	CausedLine=$(cat $androidPath/$1 | grep "Caused by" | head -n 1)
	ifCausedLineat=$(echo $CausedLine | grep '\@')
	if [ "$ifCausedLineat" == "" ]; then
		ifCsLst=$(echo $CausedLine | grep "startActivity")
		if [ "$ifCsLst" == "" ]; then
			CausedLinezf=$(echo ${CausedLine//\[/\\\[})
			CausedLineyf=$(echo ${CausedLinezf//\]/\\\]})
			CausedLinezx=$(echo ${CausedLineyf//\//\\\/})
			ifDiffCaused=$(cat ./andrCausedTxt | grep "$CausedLinezx")
			if [ "$ifDiffCaused" == "" ]; then
				echo "$CausedLine" >> ./andrCausedTxt
				return 1
			else
				return 0
			fi
		else
			CslStact=$(echo $ifCsLst | grep "startActivity")
			CausedLinezf=$(echo ${CslStact//\[/\\\[})
			CausedLineyf=$(echo ${CausedLinezf//\]/\\\]})
			CausedLinezx=$(echo ${CausedLineyf//\//\\\/})
			ifDiffCaused=$(cat ./andrCausedTxt | grep "$CausedLinezx")
			if [ "$ifDiffCaused" == "" ]; then
				echo "$CslStact" >> ./andrCausedTxt
				return 1
			else
				return 0
			fi
		fi
	else
		CausedLineat=$(echo $CausedLine | grep "Caused by" | grep -o '.*\@')
		CausedLinezf=$(echo ${CausedLineat//\[/\\\[})
		CausedLineyf=$(echo ${CausedLinezf//\]/\\\]})
		CausedLinezx=$(echo ${CausedLineyf//\//\\\/})
		ifDiffCaused=$(cat ./andrCausedTxt | grep "$CausedLinezx")
		if [ "$ifDiffCaused" == "" ]; then
			echo "$CausedLineat" >> ./andrCausedTxt
			return 1
		else
			return 0
		fi
	fi
}
 
#函数功能：比较android系统下两个错误日志文件中的前两行是否相同
 function andrCompareTxt(){ 
	firstLine=$(cat $androidPath/$1 | grep '^java' | head -n 1)
	firstLinezf=$(echo ${firstLine//\[/\\\[})
	firstLineyf=$(echo ${firstLinezf//\]/\\\]})
	firstLinezx=$(echo ${firstLineyf//\//\\\/})
	secondLine=$(cat $androidPath/$2/$1 | grep -A 1 "$firstLinezx" | tail -n 1)
	ifDiffirst=$(cat ./androidTwoTxt | grep "$firstLinezx" | tail -n 1)
	ifDiffirstzf=$(echo ${ifDiffirst//\[/\\\[})
	ifDiffirstyf=$(echo ${ifDiffirstzf//\]/\\\]})
	ifDiffirstzx=$(echo ${ifDiffirstyf//\//\\\/})
	ifDiffsecd=$(cat ./androidTwoTxt | grep -A 1 "$ifDiffirstzx" | tail -n 1)
	if [ "$ifDiffirst" != "" -a "$ifDiffsecd" != "" ]; then
	
		return 0
	else
		echo "$firstLine" >> ./androidTwoTxt
		echo "$secondLine" >> ./androidTwoTxt

		return 1
	fi
}

#函数功能：ios系统下错误日志的提取
function getIosErrLog(){
	for iosErrorTmp in "$@" 
	do
		if [ ! -d $iosPath/$iosErrorTmp ]; then
			debugTxt=$(echo $iosErrorTmp | grep "DEBUG")
			if [ "$debugTxt" != "" ]; then
				continue 
			else 
				ifExistReason=$(cat $iosPath/$iosErrorTmp | grep "Reason")
				if [ "$ifExistReason" == "" ]; then
					cp $iosPath/$iosErrorTmp ./iosErrorDir/
				else
					#函数调用：比较ios系统下两个错误日志文件中的reason行是否相同
					iosCompareTxt $iosErrorTmp
					retn=$?
					if [ $retn -eq 0 ]; then
						continue 
					else
						cp $iosPath/$iosErrorTmp ./iosErrorDir/
					fi
				fi
			fi
		fi
	done
}

#函数功能：android系统下错误日志的提取
function getAndrErrLog(){
	for andrErrorTmp in "$@"
	do
		if [ ! -d $androidPath/$andrErrorTmp ]; then
			ifExistCaused=$(cat $androidPath/$andrErrorTmp | grep "Caused by")
			if [ "$ifExistCaused" != "" ]; then
				andrCompCause $andrErrorTmp
				accRtn=$?
				if [ $accRtn -eq 0 ]; then
					continue
				else
					cp $androidPath/$andrErrorTmp ./androidErrorDir/
				fi
			#	cp $androidPath/$andrErrorDirTmp/$andrErrorTxt ./androidErrorDir/
			else 
				#函数调用：比较android系统下两个错误日志文件中的前两行是否相同
				andrCompareTxt $andrErrorTmp
				retn=$?
				if [ $retn -eq 0 ]; then
					continue
				else
					cp $androidPath/$andrErrorTmp ./androidErrorDir/
				fi
			fi
		fi
	done
}


iosErrorDirList=$(ls $iosPath)
andrErrorDirList=$(ls $androidPath)
#函数调用:ios系统下错误日志的提取
getIosErrLog ${iosErrorDirList[*]}
#函数调用:android系统下错误日志的提取
getAndrErrLog ${andrErrorDirList[*]}
			
					
