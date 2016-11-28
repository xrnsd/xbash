#! /bin/bash
#####------------------初始化------------------------------#########
#变量
	if [ -f $(cd `dirname $0`; pwd)/data/value ];then
		source  $(cd `dirname $0`; pwd)/data/value
	else
		echo -e "\033[1;31m全局变量[$(cd `dirname $0`; pwd)/data/value]加载失败\033[0m"
		exit
	fi
#函数
	if [ -f ${mRoDirPathCmdTools}tools ];then
		source  ${mRoDirPathCmdTools}tools
	else
		echo -e "\033[1;31m函数[${mRoDirPathCmdTools}tools]加载失败\033[0m"
		exit
	fi


#####-------------------执行------------------------------#########
ftTiming
ftMain 2>&1|tee $mRoFilePathLog
#ftMain
ftTiming
exit
