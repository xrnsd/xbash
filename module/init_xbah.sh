#!/bin/bash
ftXrnsdExtensionsToBashInit()
{
# ===========             预定流程                =======================
#
#
# 	1 复制工程文件到新目录cmds
#	2 读取用户密码，更新cmds的base.config
#	3 备份原始的普通用户的bash配置到cmds/dtata/bash_base_backup
#	    备份root用户的bash配置到cmds/dtata/bash_root_backup
#	4 确认3操作成功，更新对应用户的bash配置
# 	5 初始化完成
#
#

	local ftName=xbash配置初始化
	local userName=`who | awk '{print $1}'|sort -u`

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
		echo -e "	[${ftName}]参数错误 \n\
	参数数量=$# \n\
	userName=$userName \n\
	dirPathHome=dirPathHome \n\
	\033[0m"
		exit
	fi
	local dirPathHome=/home/${userName}
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

	local dirNameXbashTragetConfig=config
	local dirPathXbashTragetConfig=${dirPathXbashTraget}/$dirNameXbashTragetConfig
	if [ ! -d $dirPathXbashTragetConfig ];then
		echo -e "\033[1;31m[${ftName}]错误[dirPathXbashTragetConfig=$dirPathXbashTragetConfig]\033[0m"
		exit
	fi
	# sed -i 's/被替换的内容/要替换成的内容/' file
	local fileNameXbashTragetConfigBase=base.config
	local filePathXbashTragetConfigBase=${dirPathXbashTragetConfig}/${fileNameXbashTragetConfigBase}
	if [ ! -f $filePathXbashTragetConfigBase ];then
		echo -e "\033[1;31m[${ftName}]错误[filePathXbashTragetConfigBase=$filePathXbashTragetConfigBase]\033[0m"
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
	sed -i "s/mUserPwdBase=/mUserPwdBase=$passwd/" $filePathXbashTragetConfigBase

	# 备份bash配置文件
	local fileNameXbashTragetDataBashBaseBackup=bashrc_base_backup
	local fileNameXbashTragetDataBashRootBackup=bashrc_root_backup
	local filePathXbashTragetDataBashBaseBackup=${dirPathXbashTragetConfig}/${fileNameXbashTragetDataBashBaseBackup}
	local filePathXbashTragetDataBashRootBackup=${dirPathXbashTragetConfig}/${fileNameXbashTragetDataBashRootBackup}
	local filePathBashBase=/home/${userName}/.bashrc
	local filePathBashRoot=/root/.bashrc
	mv $filePathBashBase ${filePathBashBase}_base_backup
	cp -rf -v ${filePathBashBase}_base_backup $filePathXbashTragetDataBashBaseBackup

	echo $passwd | sudo -S mv $filePathBashRoot ${filePathBashRoot}_root_backup
	echo $passwd | sudo -S cp -rf  -v ${filePathBashRoot}_root_backup $filePathXbashTragetDataBashRootBackup

	if [ ! -f $filePathXbashTragetDataBashRootBackup ];then
		echo -e "\033[1;31m[${ftName}]错误[filePathXbashTragetDataBashRootBackup=$filePathXbashTragetDataBashRootBackup]\033[0m"
		exit
	fi
	#更新bash配置文件
	local fileNameXbashTragetConfig=config
	local fileNameXbashTragetConfigBashBase=bashrc_work_lz
	local fileNameXbashTragetConfigBashRoot=bashrc_root_work_lz
	local filePathXbashTragetConfig=${dirPathXbashTraget}/${fileNameXbashTragetConfig}
	local filePathXbashTragetConfigBashBase=${filePathXbashTragetConfig}/${fileNameXbashTragetConfigBashBase}
	local filePathXbashTragetConfigBashRoot=${filePathXbashTragetConfig}/${fileNameXbashTragetConfigBashRoot}

	cd /home/${userName}&& ln -sf $filePathXbashTragetConfigBashBase .bashrc

	echo $passwd|sudo -S su
	echo $passwd|sudo -S su<< EOF
	chown root;root $filePathXbashTragetConfigBashRoot
	ln -sf $filePathXbashTragetConfigBashRoot /root/.bashrc
	EOF
	# 清除无效的文件
	rm -rf $dirPathXbashBase
}

ftXrnsdExtensionsToBashInit
