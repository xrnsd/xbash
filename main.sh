#! /bin/bash
#####------------------变量------------------------------#########
	readonly mRoModuleName=main.sh

	mDirPathXbashTraget=$(cd `dirname $0`; pwd)
	mDirNameXbashTragetConfig=config
	mDirPathXbashTragetConfig=${mDirPathXbashTraget}/${mDirNameXbashTragetConfig}
	mFileNameXbashTragetConfigBase=base.config
	mFilePathXbashTragetConfigBase=${mDirPathXbashTragetConfig}/${mFileNameXbashTragetConfigBase}

#####------------------初始化------------------------------#########
	if [ -f $mFilePathXbashTragetConfigBase ];then
		source  $mFilePathXbashTragetConfigBase
		#函数
		if [ -f ${mRoDirPathCmdModule}/${mRoFileNameCmdModuleTools} ];then
			source  ${mRoDirPathCmdModule}/${mRoFileNameCmdModuleTools}
		else
	echo -e "\033[1;31m	函数加载失败\n\
	模块=$mRoModuleName\n\
	toolsPath=${mRoDirPathCmdModule}/${mRoFileNameCmdModuleTools}\n\
	\033[0m"
	exit
		fi
	else
	echo -e "\033[1;31m	全局配置加载失败\n\
	模块=$mRoModuleName\n\
	mFilePathXbashTragetConfigBase=$mFilePathXbashTragetConfigBase\n\
	\033[0m"
	exit
	fi

#####-------------------执行------------------------------#########
ftTiming
ftLog
ftMain 2>&1|tee -a $mFilePathLog
ftTiming
exit
