#!/bin/bash
#####-----------------------变量------------------------------#########
readonly rModuleName=test/base.sh
#####----------------------初始化demo环境--------------------------#######
# 函数
if [ -f ${rDirPathCmdsModule}/${rFileNameCmdModuleTools} ];then
	source  ${rDirPathCmdsModule}/${rFileNameCmdModuleTools}
else
	echo -e "\033[1;31m	函数加载失败\n\
	模块=$rModuleName\n\
	toolsPath=${rDirPathCmdsModule}/${rFileNameCmdModuleTools}\n\
	\033[0m"
fi

dirNameDebug=temp
dirPathHome=/home/${rNameUser}/${dirNameDebug}
dirPathHomeDebug=/home/${rNameUser}/${dirNameDebug}
if [ -d $dirPathHome ];then
	if [ ! -d $dirPathDebug ];then
		mkdir  $dirPathDebug
		ftEcho -s 测试用目录[$dirPathDebug]不存在，已新建
	fi
	cd $dirPathDebug
else
	echo -e "\033[1;31m	初始化demo环境失败\n\
	模块=$rModuleName\n\
	dirPathHome=$dirPathHome\n\
	\033[0m"
fi

ftDebug()
{
	local ftName=调试用，实时跟踪变量变化

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例===================
#
#	 trap 'echo “行:$LINENO, a=$a,b=$b,c=$c”' DEBUG
#	 根据需要修改 a，b，c
#	rIsDebug设为true
#	 ftDebug [任意命令]
#	 ftDebug echo test
#=========================================================
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
	exit;; * ) break;; esac;done

	#耦合变量校验
	if [ -z "$rIsDebug" ];then
		ftEcho -eax "函数[${ftName}]的参数错误 \
			[参数数量def=$valCount]valCount=$# \
			rIsDebug=$rIsDebug"
	fi

	 # if [ "$rIsDebug" = "true" ]; then
		$@
		trap 'echo “行:$LINENO, path_avail=$path_avail”' DEBUG
	#  else
	#  	ftEcho -ex 当前非调试模式
	# fi

}
#####----------------------demo函数--------------------------#########
ftCreate7731CSoftwareVersionPathByGitBranchName()
{
	local ftName=生成服务器上传的路径
	# ANDROID_BUILD_TOP=/media/data/ptkfier/code/sp7731c/code
	# ANDROID_PRODUCT_OUT=/media/data/ptkfier/code/sp7731c/code/out/target/product/sp7731c_1h10_32v4
	local dirPathCode=$ANDROID_BUILD_TOP
	local dirPathOut=$ANDROID_PRODUCT_OUT

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#	
#	dirPath=$(ftCreate7731CSoftwareVersionPathByGitBranchName)
#=========================================================
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
	exit;; * ) break;; esac;done

	#耦合变量校验
	local valCount=1
	if(( $#>$valCount ))||[ ! -d "$dirPathCode" ]\
			||[ ! -d "$dirPathOut" ];then
		ftEcho -ea "[${ftName}]的参数错误 \
			[参数数量def=$valCount]valCount=$# \
			[工程根目录]dirPathCode=$dirPathCode \
			[工程out目录]dirPathOut=$dirPathOut \
			请查看下面说明:"
		ftCreate7731CSoftwareVersionPathByGitBranchName -h
		return
	fi
	cd $ANDROID_BUILD_TOP
	# 分支名
	local branchName=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
	if [[ ! $branchName =~ "CT(" ]]; then
		ftEcho -ex "分支[$branchName],格式错误"
	fi

	# 版本名
	local keyVersion="findPreference(KEY_BUILD_NUMBER).setSummary(\""
	local filePathDeviceInfoSettings=${dirPathCode}/packages/apps/Settings/src/com/android/settings/DeviceInfoSettings.java
	local versionName=$(cat $filePathDeviceInfoSettings|grep $keyVersion)
	versionName=${versionName/$keyVersion/}
	versionName=${versionName/\");/}
	versionName=$(echo $versionName |sed s/[[:space:]]//g)

	projectName= # 项目名
	modelName= # 手机名
	clentName= # 客户名
	bnList=$(echo $branchName|tr ")" "\n")
	for lc in ${bnList[@]}
	do
		keyStr="CT(pmz"
		if [[ $lc =~ "$keyStr" ]]; then
			keyStr="_"
			if [[ $lc =~ "$keyStr" ]]; then
				ctList=($(echo $lc|tr "_" "\n"))
				clentName=${ctList[1]}
			fi
		fi

		keyStr="PMA("
		if [[ $lc =~ "$keyStr" ]]||[[ $lc =~ "PM(" ]]; then
			lc=${lc/$keyStr/}
			keyStr="PM("
			lc=${lc/$keyStr/}

			keyStr="_"
			if [[ $lc =~ "$keyStr" ]]; then
				pmList=($(echo $lc|tr "_" "\n"))
				projectName=${pmList[0]}
				modelName=${pmList[1]}
			fi
			
		fi
		keyStr="CP("
		if [[ $lc =~ "$keyStr" ]]&&[[ $branchName =~ "BSA(zx" ]]; then
			if [ ! -z "$clentName" ];then
				ftEcho -ex "分支[$branchName],存在歧义"
			fi
			if [[ $lc =~ "CP(f_c_" ]]; then
				keyStr="CP(f_c_"
			else
				keyStr="CP(c_"
			fi
			lc=${lc/$keyStr/}
			clentName=$(echo $lc|sed s/_//g)
		fi
	done
	# 摄像头区分永恒星或康龙
	local cameraConfig=YHX
	local filePathTraget=${dirPathCode}/vendor/sprd/modules/libcamera/oem2v0/src/sensor_cfg.c
	local tagYhx=//#define\ CAMERA_USE_KANGLONG_GC2365
	local tagKl=#define\ CAMERA_USE_KANGLONG_GC2365
	if [ -z $(cat $filePathTraget|grep "$tagYhx") ];then
		cameraConfig=KL
	fi
	#转为大写
	projectName=$(echo $projectName | tr '[a-z]' '[A-Z]') 
	clentName=$(echo $clentName | tr '[a-z]' '[A-Z]') 
	cameraConfig=$(echo $cameraConfig | tr '[a-z]' '[A-Z]') 
	versionName=$(echo $versionName | tr '[a-z]' '[A-Z]') 

	if [ $1 = "-array" ];then
		echo $projectName $clentName $cameraConfig $versionName
	else
		echo ${projectName}/${clentName}/${cameraConfig}/${versionName}
	fi
}
ftAutoUpload()
{
	local ftName=上传文件到制定smb服务器路径
	local filePathUploadSource=$1

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#
#	ftAutoUpload [example]
#	ftAutoUpload xxxx
#=========================================================
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
	exit;; * ) break;; esac;done

	# #耦合变量校验
	# local valCount=1
	# if(( $#!=$valCount ))||[ ! -f "$filePathUploadSource" ];then
	# 	ftEcho -ea "[${ftName}]的参数错误 \
	# 		[参数数量def=$valCount]valCount=$# \
	# 		[上传的源文件]filePathUploadSource=$filePathUploadSource \
	# 		请查看下面说明:"
	# 	ftAutoUpload -h
	# 	return
	# fi


	local serverIp=192.168.1.188
	local userName=server
	local pasword=123456

	local dirPathMoule=智能机软件
	local dirPathUpload=SPRD7731C/鹏明珠

	local fileNameUploadSource=$(basename $filePathUploadSource)

# smbclient //${serverIp}/${dirPathMoule}  -U $userName%$pasword<< EOF
# 	mkdir $dirPathUpload
# 	# put $filePathUploadSource ${dirPathUpload}/${fileNameUploadSource}
# EOF
 	mount //${serverIp}/${dirPathUpload}/ /media/smb/ -o iocharset=utf8,username=$userName,password=$pasword
	sudo mount -t cifs //192.168.1.188/智能机软件/SPRD7731C/鹏明珠/autoUpload /home/wgx/test -o username=server,password=123456
}