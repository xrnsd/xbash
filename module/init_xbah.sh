#!/bin/bash
ftXrnsdExtensionsToBashInit()
{
	local ftName=xbash配置初始化
	local userName=`who | awk '{print $1}'|sort -u`
	local dirPathHome=/home/${userName}

	# 特使实现，对外没有特殊要求

	#使用示例
	#=================== xbash配置初始化的使用示例=============
	#
	#	ftXrnsdExtensionsToBashInit 无参
	#=========================================================

	#耦合变量校验
	local valCount=0
	if [ $# -ne $valCount ]||[ -z "$userName" ]\
			         ||[ ! -d "$dirPathHome" ];then
		echo -e "\033[1;31m[${ftName}]参数错误[userName=$userName,dirPathHome=$dirPathHome]\033[0m"
		exit
	fi
	local dirPathPwd=$(cd `dirname $0`; pwd)/
	local dirPathXbashBase=$(dirname $dirPathPwd)
	local dirNameXbashTraget=cmds
	local dirPathXbashTraget=${dirPathHome}/${dirNameXbashTraget}
	if [ -d $dirPathXbashBase ];then
		if [ ! -d $dirPathXbashTraget ];then
			mkdir -p $dirPathXbashTraget
		fi
		cp -r -f -v $dirPathXbashBase $dirPathXbashTraget
	fi

	status=1
	while [[ status -ne "0" ]]; do
		echo "请输入用户密码:"
		read   passwd
		echo $passwd | sudo -S echo 2> /dev/null
		status=$?
	done&&

	local dirNameXbashTragetData=data
	local dirPathXbashTragetData=${dirPathXbashTraget}/$dirNameXbashTragetData
	if [ ! -d $dirPathXbashTragetData ];then
		echo -e "\033[1;31m[${ftName}]错误[dirPathXbashTragetData=$dirPathXbashTragetData]\033[0m"
		exit
	fi
	# sed -i 's/被替换的内容/要替换成的内容/' file
	local fileNameXbashTragetDataValue=vlaue
	local filePathXbashTragetDataValue=${dirPathXbashTragetData}/$fileNameXbashTragetDataValue
	if [ ! -f $filePathXbashTragetDataValue ];then
		echo -e "\033[1;31m[${ftName}]错误[filePathXbashTragetDataValue=$filePathXbashTragetDataValue]\033[0m"
		exit
	fi
	status=1
	passwd=null
	while [[ status -ne "0" ]]; do
		echo -en "请输入用户密码:"
		read -s passwd
		echo $passwd | sudo -S echo 2> /dev/null
		status=$?
	done
	sed -i "s/mUserPwdBase=/mUserPwdBase=$passwd/" $filePathXbashTragetDataValue

	#更新bash配置文件

	# 清除无效的文件
	rm -rf dirPathXbashBase
}

ftXrnsdExtensionsToBashInit
