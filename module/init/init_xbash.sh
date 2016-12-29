#!/bin/bash
ftXrnsdExtensionsToBashInit()
{
#===================           预定流程                   =============
#
# 	1 复制工程文件到新目录cmds
#	2 读取用户密码，更新cmds的config_base
#	3 备份原始的普通用户的bash配置到cmds/dtata/bash_base_backup
#	    备份root用户的bash配置到cmds/dtata/bash_root_backup
#	4 确认3操作成功，更新对应用户的bash配置
# 	5 初始化完成
#
#=================== xbash配置初始化的使用示例=============
#
#	ftXrnsdExtensionsToBashInit 无参
#
# =========================================================


	local ftName=xbash配置初始化
	local userName=$(who am i | awk '{print $1}'|sort -u)
	userName=${userName:-`whoami | awk '{print $1}'|sort -u`}
	if [ "${S/ /}" != "$S" ];then
	    userName=$(whoami)
	fi
	local dirPathHome=/home/${userName}

	#--------------------------变量校验--------------------------
	local valCount=0
	if(( $#!=$valCount ))||[ -z "$userName" ]\
				||[ ! -d "$dirPathHome" ];then
		echo -e "	[${ftName}]参数错误 \n\
	[参数数量def=$valCount]valCount=$# \n\
	userName=$userName \n\
	dirPathHome=$dirPathHome \n\
	\033[0m"
		exit
	fi

	local dirPathPwd=$(cd `dirname $0`; pwd)/
	local dirPathXbashBase=$(dirname $dirPathPwd)
	local dirNameXbashTraget=cmds
	local dirPathXbashTraget=${dirPathHome}/${dirNameXbashTraget}

	#--------------------------复制工具文件--------------------------
	if [ -d $dirPathXbashBase ];then
		if [ ! -d $dirPathXbashTraget ];then
			mkdir -p $dirPathXbashTraget
		fi
		cp -r -f -v $dirPathXbashBase/* $dirPathXbashTraget
	fi

	#--------------------------更新用户密码--------------------------
	local dirNameXbashTragetConfig=config
	local dirPathXbashTragetConfig=${dirPathXbashTraget}/$dirNameXbashTragetConfig
	if [ ! -d $dirPathXbashTragetConfig ];then
		echo -e "\033[1;31m[${ftName}]错误[dirPathXbashTragetConfig=$dirPathXbashTragetConfig]\033[0m"
		exit
	fi
	local fileNameXbashTragetConfigBase=config_base
	local filePathXbashTragetConfigBase=${dirPathXbashTragetConfig}/${fileNameXbashTragetConfigBase}
	if [ ! -f $filePathXbashTragetConfigBase ];then
		# /home/xxxx/cmds/config/config_base
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
	# sed -i 's/被替换的内容/要替换成的内容/' file
	sed -i "s/rUserPwdBase=/rUserPwdBase=$passwd #/" $filePathXbashTragetConfigBase

	#--------------------------备份bash配置文件--------------------------
	local fileNameXbashTragetDataBashBaseBackup=bashrc_base_backup
	local fileNameXbashTragetDataBashRootBackup=bashrc_root_backup
	local filePathXbashTragetDataBashBaseBackup=${dirPathXbashTragetConfig}/${fileNameXbashTragetDataBashBaseBackup}
	local filePathXbashTragetDataBashRootBackup=${dirPathXbashTragetConfig}/${fileNameXbashTragetDataBashRootBackup}
	local filePathBashBase=/home/${userName}/.bashrc
	local filePathBashRoot=/root/.bashrc
	# 普通用户
	mv $filePathBashBase ${filePathBashBase}_base_backup
	cp -rf -v ${filePathBashBase}_base_backup $filePathXbashTragetDataBashBaseBackup
	# root用户
	echo $passwd | sudo -S mv $filePathBashRoot ${filePathBashRoot}_root_backup
	echo $passwd | sudo -S cp -rf  -v ${filePathBashRoot}_root_backup $filePathXbashTragetDataBashRootBackup

	if [ ! -f $filePathXbashTragetDataBashRootBackup ];then
		echo -e "\033[1;31m[${ftName}]错误[filePathXbashTragetDataBashRootBackup=$filePathXbashTragetDataBashRootBackup]\033[0m"
		exit
	fi

	#--------------------------更新bash配置文件--------------------------
	local fileNameXbashTragetConfig=config
	local fileNameXbashTragetConfigBashBase=bashrc_work_lz
	local fileNameXbashTragetConfigBashRoot=bashrc_root_work_lz
	local filePathXbashTragetConfigBashBase=${dirPathXbashTragetConfig}/${fileNameXbashTragetConfigBashBase}
	local filePathXbashTragetConfigBashRoot=${dirPathXbashTragetConfig}/${fileNameXbashTragetConfigBashRoot}

	# 普通用户
	#sed -i "s:dirPathHome=:dirPathHome=$dirPathHome# :" $filePathXbashTragetConfigBashBase
	cd /home/${userName}&& ln -sf $filePathXbashTragetConfigBashBase .bashrc

	# root用户
	echo $passwd|sudo -S su
	echo $passwd|sudo -S su<< EOF
	# 更新bash文件cmds对应路径
	#sed -i "s:dirPathHome=:dirPathHome=$dirPathHome# :" $filePathXbashTragetConfigBashRoot
	chown root;root $filePathXbashTragetConfigBashRoot
	ln -sf $filePathXbashTragetConfigBashRoot /root/.bashrc
EOF

	#--------------------------清除无效的文件-------------------------
	rm -rf $dirPathXbashBase

	local dirNameXbashTragetModule=module
	local dirPathXbashTragetModule=${dirPathXbashTraget}/${dirNameXbashTragetModule}
	# gnome-terminal -x bash -c "source $filePathXbashTragetConfigBase;\
	# 			source ${dirPathXbashTragetModule}/tools.sh;\
	# 			ftVersion;\
	# 			echo 初始化完成;\
	# 			read temp"
	source $filePathXbashTragetConfigBase
	source ${dirPathXbashTragetModule}/tools.sh
	ftVersion
	echo 初始化完成

}

ftXrnsdExtensionsToBashInit
