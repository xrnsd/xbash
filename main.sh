#! /bin/bash
#####------------------变量------------------------------#########
readonly rModuleName=main.sh

mDirPathXbashTraget=$(cd `dirname $0`; pwd)
mDirNameXbashTragetConfig=config
mDirPathXbashTragetConfig=${mDirPathXbashTraget}/${mDirNameXbashTragetConfig}
mFileNameXbashTragetConfigBase=config_base
mFilePathXbashTragetConfigBase=${mDirPathXbashTragetConfig}/${mFileNameXbashTragetConfigBase}

#####------------------初始化------------------------------#########
if [ -f $mFilePathXbashTragetConfigBase ];then
	source  $mFilePathXbashTragetConfigBase
	#函数
	if [ -f ${rDirPathCmdsModule}/${rFileNameCmdModuleTools} ];then
		source  ${rDirPathCmdsModule}/${rFileNameCmdModuleTools}
	else
echo -e "\033[1;31m	函数加载失败\n\
模块=$rModuleName\n\
toolsPath=${rDirPathCmdsModule}/${rFileNameCmdModuleTools}\n\
\033[0m"
exit
	fi
else
echo -e "\033[1;31m	全局配置加载失败\n\
模块=$rModuleName\n\
mFilePathXbashTragetConfigBase=$mFilePathXbashTragetConfigBase\n\
\033[0m"
exit
fi

#####-------------------执行------------------------------#########
ftTiming
ftLog
ftMain $@ 2>&1|tee -a $mFilePathLog
ftTiming
exit
