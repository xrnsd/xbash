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
	if [ -f ${mRoDirPathCmdModule}/${mRoFileNameCmdModuleTools} ];then
		source  ${mRoDirPathCmdModule}/${mRoFileNameCmdModuleTools}
	else
		echo -e "\033[1;31m函数[${mRoDirPathCmdModule}/tools]加载失败\033[0m"
		exit
	fi


#####-------------------执行------------------------------#########
ftTiming
ftLog
ftMain 2>&1|tee -a $mFilePathLog
# echo $mUserPwd | sudo -S chmod 777 $mFilePathLog
ftTiming
exit
