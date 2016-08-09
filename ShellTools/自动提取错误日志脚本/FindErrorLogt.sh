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
	reasonLine=$(cat $iosPath/$2/$1 | grep "Reason")
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
	CausedLine=$(cat $androidPath/$2/$1 | grep "Caused by" | head -n 1)
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
	firstLine=$(cat $androidPath/$2/$1 | grep '^java' | head -n 1)
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
	for iosErrorDirTmp in "$@" 
	do
		iosErrorTxtList=$(ls $iosPath/$iosErrorDirTmp)
		for iosErrorTxt in $iosErrorTxtList 
		do
			debugTxt=$(echo $iosErrorTxt | grep "DEBUG")
			if [ "$debugTxt" != "" ]; then
				continue 
			else 
				ifExistReason=$(cat $iosPath/$iosErrorDirTmp/$iosErrorTxt | grep "Reason")
				if [ "$ifExistReason" == "" ]; then
					cp $iosPath/$iosErrorDirTmp/$iosErrorTxt ./iosErrorDir/
				else
					#函数调用：比较ios系统下两个错误日志文件中的reason行是否相同
					iosCompareTxt $iosErrorTxt $iosErrorDirTmp
					retn=$?
					if [ $retn -eq 0 ]; then
						continue 
						else
						cp $iosPath/$iosErrorDirTmp/$iosErrorTxt ./iosErrorDir/
					fi
				fi
			fi
		done
	done
}

#函数功能：android系统下错误日志的提取
function getAndrErrLog(){
	for andrErrorDirTmp in "$@"
	do
		if [ "$andrErrorDirTmp" == "28222" -o "$andrErrorDirTmp" == "91479" -o "$andrErrorDirTmp" == "38111" -o "$andrErrorDirTmp" == "53634" -o "$andrErrorDirTmp" == "40125" -o "$andrErrorDirTmp" == "15917" -o "$andrErrorDirTmp" == "98792" -o ! -d $androidPath/$andrErrorDirTmp ]; then
			continue
		else
			andrErrorTxtList=$(ls $androidPath/$andrErrorDirTmp)
			for andrErrorTxt in $andrErrorTxtList
			do
				ifExistCaused=$(cat $androidPath/$andrErrorDirTmp/$andrErrorTxt | grep "Caused by")
				if [ "$ifExistCaused" != "" ]; then
					andrCompCause $andrErrorTxt $andrErrorDirTmp
					accRtn=$?
					if [ $accRtn -eq 0 ]; then
						continue
					else
						cp $androidPath/$andrErrorDirTmp/$andrErrorTxt ./androidErrorDir/
					fi
				#	cp $androidPath/$andrErrorDirTmp/$andrErrorTxt ./androidErrorDir/
				else 
					#函数调用：比较android系统下两个错误日志文件中的前两行是否相同
					andrCompareTxt $andrErrorTxt $andrErrorDirTmp
					retn=$?
					if [ $retn -eq 0 ]; then
						continue
					else
						cp $androidPath/$andrErrorDirTmp/$andrErrorTxt ./androidErrorDir/
					fi
				fi
			done
		fi
	done
}

#函数功能：ios错误日志的界面展示
function dispIosInfo(){
	echo -e "ios系统下的崩溃日志有$1个，如下："
	iedList=$(ls ./iosErrorDir)
	for ied in $iedList
	do
		echo -e "该错误日志文件的路径为： "
		find $PWD -name "$ied"
		echo -e "---------内容如下：---------"
		cat ./iosErrorDir/$ied
	done
}

#函数功能：android错误日志的界面展示
function dispAndrInfo(){
	echo -e "android系统下的崩溃日志有$1个，如下："
	aedList=$(ls ./androidErrorDir)
	for aed in $aedList
	do
		echo -e "该错误日志文件的路径为： "
		find $PWD -name "$aed"
		echo -e "---------内容如下：---------"
		cat ./androidErrorDir/$aed
	done
}

#函数功能：界面显示信息的组织
function dispInfo(){
	if [ $1 == 0 -a $2 == 0 ]; then
		echo -e "目前为止还没有崩溃日志"
	elif [ $1 != 0 -a $2 == 0 ]; then
		echo -e "目前为止....."
		echo -e "android系统下还没有崩溃日志"
		#函数调用：ios错误日志的界面展示
		dispIosInfo $1
	elif [ $1 == 0 -a $2 != 0 ]; then
		echo -e "目前为止....."
		echo -e "ios系统下还没有崩溃日志"
		#函数调用：android错误日志的界面展示
		dispAndrInfo $2
	else 
		echo -e "目前为止....."
		#函数调用：ios、android错误日志的界面展示
		dispIosInfo $1
		dispAndrInfo $2
	fi
}

iosErrorDirList=$(ls $iosPath)
andrErrorDirList=$(ls $androidPath)
#函数调用:ios系统下错误日志的提取
getIosErrLog ${iosErrorDirList[*]}
#函数调用:android系统下错误日志的提取
getAndrErrLog ${andrErrorDirList[*]}

#统计ios系统下错误日志的个数
iosErrorTxtNum=$(ls ./iosErrorDir | wc -l)
#统计android系统下错误日志的个数
andrErrorTxtNum=$(ls ./androidErrorDir | wc -l)

#函数调用：界面显示信息的组织
dispInfo $iosErrorTxtNum $andrErrorTxtNum

exit 0
	

						
					
