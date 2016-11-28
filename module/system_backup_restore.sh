#!/bin/bash
#####----------------------初始化--------------------------#########
# 变量
	mTypeEdit=$1
	mTypeBackupEdit=null

	mDate=$(date -d "today" +"%Y%m%d")

	#mDirPathSynchronous1=
	#mDirPathSynchronous2=
	mDirPathRestoreTarget=/
	mDirPathStoreTarget=null
	mDirPathStoreSource=null
	mDirPathLog=${mRoDirPathUserHome}/log
	mDirPathRestoreExcludeTarget=null

	mFilePathRestoreSource=null

	mFileNameBackupLog=null
	mFileNameBackupTarget=null
	#VersionNameBackup
	mFileNameBackupTargetBase=null
	mFileNameRestoreSource=null
	#VersionNameRestore
	mFileNameRestoreSourceBase=null

	mNoteBackupTarget=null
	mNoteRestoreSource=null

# 函数
if [ -f ${mRoDirPathCmdTools}tools ];then
	source  ${mRoDirPathCmdTools}tools
else
	echo -e "\033[1;31m函数加载失败\033[0m"
fi

#####----------------------自有函数--------------------------#########

	ftRestoreOperate()
	{
		local ftName=使用tar还原系统
		while true; do
		ftEcho -y 是否开始还原
		read -n1 sel
		case "$sel" in
			y | Y )
				pathsource=$1
				mDirPathRestoreTarget=$2
				if [ -f $pathsource ];then
					if [ -d $mDirPathRestoreTarget ];then
					sudo tar -xvpzf $pathsource --exclude=$mDirPathRestoreExcludeTarget -C $mDirPathRestoreTarget
					else
						ftEcho -e 未找到目录:${mDirPathRestoreTarget}
					fi
				else
					ftEcho -e 未找到版本包:${pathsource}
				fi;break;;
			n | N | q |Q)  exit;;
			* )
				ftEcho -e 错误的选择：$sel
				echo "输入n，q，离开";
				;;
		esac
		done
	}

	ftRestoreChoiceSource()
	{
		local ftName=选择还原使用的版本[备份]包
		local index=0;
		local fileList=`ls $mDirPathStoreSource|grep '.tgz'`
		local dirNameBackupNote=${mDirPathStoreSource}/.notes

		#耦合变量校验
		local valCount=0
		if [ $# -ne $valCount ]||[ -z "$mDirPathStoreSource" ]\
					||[ ! -d $mDirPathStoreSource ]\
					||[ ! -d $dirNameBackupNote ];then
			ftEcho -ex "函数[${ftName}]参数错误"
		fi

		#文件数量获取
		#filenumbers= ls -l /media/data_self/backup/os |grep '.tgz'|grep "^-"|wc -l
		#b=${a/123/321};将${a}里的第一个123替换为321\

		if [ -z "$fileList" ];then
			ftEcho -ex 在${mDirPathStoreSource}没找到有效的版本包
		else
			ftEcho -t 请${ftName}
			echo "[序号]		版本包名	----------------	备注		"
			echo
			for file in $fileList
			do
				local fileBaseName=${file/.tgz/}
				local fileNameNote=${fileBaseName}.note
				local filePathNote=${dirNameBackupNote}/${fileNameNote}
				if [ -f $filePathNote ];then
					local note=`cat $filePathNote`
				else
					local note=缺失版本说明，建议视为无效
				fi
				fileNoteList[$index]=$note
				fileList2[$index]=$file
				echo [ ${index} ] ${fileBaseName}"   ----------------   "${note}
				index=`expr $index + 1`
			done
			while true; do
			echo
			echo -en "请输入版本包对应的序号(回车默认0):"
			if [ ${#fileList[@]} -gt 9 ];then
				read tIndex
			else
				read -n1 tIndex
			fi
			#设定默认值
			if [ ${#tIndex} == 0 ]; then
				tIndex=0
			fi
			case $tIndex in
				[0-9]|\
				[0-9][0-9]|\
				[0-9][0-9][0-9]|\
				[0-9][0-9][0-9][0-9])
					echo
					mFileNameRestoreSource=${fileList2[$tIndex]}
					mFileNameRestoreSourceBase=${mFileNameRestoreSource/.tgz/}
					mFilePathRestoreSource=${mDirPathStoreSource}/${mFileNameRestoreSource}
					mNoteRestoreSource=${fileNoteList[$tIndex]}
					echo;break;;
				n | N | q |Q)  exit;;
				* )    ftEcho -e 错误的选择：$tIndex ;echo  "输入1,2...... 选择    输入 n，q 离开";break;;
			esac
			done
		fi
	}

	ftRestoreChoiceTarget()
	{
		local ftName=选择还原的目标目录
		ftEcho -b 还原的目标目录
		echo -e "[1]\t系统"
		echo -e "[2]\t自定义"
		echo

		while true; do
		echo -en "请输入目录对应的序号(回车默认系统[/]):"
		read -n1 option
		echo
		#设定默认值
		if [ ${#option} == 0 ]; then
			option=1
		fi
		case $option in
			1)  mDirPathRestoreTarget=/; break;;
			2)  	echo -en "请输入目标路径："
				read customdir
				if [ -d $customdir ];then
				mDirPathRestoreTarget=$customdir
				else
				ftEcho -e 目录${customdir}不存在
				fi
				customdir=null ; break;;
			n | N | q |Q)  exit;;
			* )    ftEcho -e 错误的选择：$sel ;echo  "输入1,2 选择    输入n，q 离开";break;;
		esac
		done
		echo
	}

	ftEchoInfo()
	{
		local ftName=脚本操作信息显示，用于关键操作前的确认
		ftEcho -b 请确认下面信息
		local mVersionChangs="Android build : mtk_KK  mtk_L mtk_M\n\
			Android app : 4.4\n\
			custom bash : Xrnsd-extensions-to-bash\n\
			tools : jdk1.6 openjdk1.7 sdk ndk flash_tool eclipse"

		local infoType=$1
		if [ $infoType = "restore" ];then
			echo "使用的源文件为：	${mFileNameRestoreSource}"
			echo "使用的源文件的说明：	${mNoteRestoreSource}"
			echo "还原的目标目录为：	${mDirPathRestoreTarget}"
			echo "还原时将忽略目录：	${mDirPathRestoreExcludeTarget}"
			echo -e "当前系统有效修改：	\033[44m$mVersionChangs\033[0m"

		elif [ $infoType = "backup" ];then
			mFileNameBackupTargetBase=backup_${mTypeBackupEdit}_${mRoNameUser}_${mDate}
			mFileNameBackupTarget=${mFileNameBackupTargetBase}.tgz
			mFileNameBackupLog=${mFileNameBackupTargetBase}.log

			local btype
			if [ $mTypeBackupEdit = "cg" ];then
				btype=基础
			elif [ $mTypeBackupEdit = "bx" ];then
				btype=全部
			fi

			echo "生成备份的文件为：	${mFileNameBackupTarget}"
			echo "生成备份文件的目录：	${mDirPathStoreTarget}"
			echo "生成的备份的说明：	${mNoteBackupTarget}"
			echo "生成的备份的类型：	${btype}"
			echo -e "当前系统有效修改：	\033[44m$mVersionChangs\033[0m"
		else
			ftEcho -ex 一脸懵逼
		fi
		echo
	}

	ftInitDevicesList()
	{
		local ftName=选择备份包存放的设备
		local devDir=/media
		local dirList=`ls $devDir`
		mCmdsModuleDataDevicesList[0]=${mRoDirPathUserHome/$mRoNameUser\//$mRoNameUser}
		local index=1;
		#开始记录设备文件
		for dir in $dirList
		do
			#临时挂载设备
			if [ ${dir} == $mRoNameUser ]; then
				local dirTempList=`ls ${devDir}/${dir}`
				for dirTemp in $dirTempList
				do
					mCmdsModuleDataDevicesList[$index]=${devDir}/${dir}/${dirTemp}
					index=`expr $index + 1`
				done
			else
			#长期挂载设备
			mCmdsModuleDataDevicesList[$index]=${devDir}/${dir}
			index=`expr $index + 1`
			fi
		done
		export mCmdsModuleDataDevicesList=${mCmdsModuleDataDevicesList[*]}
	}

	ftSetBackupDevDir()
	{
		local ftName=选择备份包存放的设备
		ftEcho -t 请${ftName}

		local devTarget
		local devTargetDir

		ftInitDevicesList

		#耦合变量校验
		if [ -z "$mCmdsModuleDataDevicesList" ];then
			ftEcho -ex "函数[${ftName}]参数错误"
		fi

		local index=0;
		for dev in $mCmdsModuleDataDevicesList
		do
			echo [ ${index} ] $dev
			index=`expr $index + 1`
		done

		echo
		while true; do
			echo -en "请选择存放备份文件的设备[0~`expr $index - 1`,q](回车默认当前用户目录):"
			if [ ${#mCmdsModuleDataDevicesList[@]} -gt 9 ];then
				read dir
			else
				read -n1 dir
			fi
			#设定默认值
			 if [ ${#dir} == 0 ]; then
				dir=0
			 fi
			 if [ ${dir} == "q" ]; then
				exit
			 elif [ -n "$(echo $dir| sed -n "/^[0-$index]\+$/p")" ];then
				devTargetDir=${mCmdsModuleDataDevicesList[$dir]}
				break;
			 fi
			 ftEcho -e 错误的选择：$dir
		done
		echo

		mDirPathStoreTarget=$devTargetDir/backup/os/${mRoNameUser};
		mDirPathStoreSource=$devTargetDir/backup/os/${mRoNameUser};

		if [ ! -d $mDirPathStoreTarget ];then
			mkdir -p $mDirPathStoreTarget
			echo ${mDirPathStoreTarget}不存在已创建
		fi
	}

	ftSelBackupType()
	{
		local ftName=选择备份类型
		ftEcho -t 请${ftName}
		echo -e "[1]\t基础"
		echo -e "[2]\t全部"

		while true; do
		echo
		echo -en "请选择备份类型(默认基础):"
		read -n1 typeIndex
		#设定默认值
		if [ ${#typeIndex} == 0 ]; then
			typeIndex=1
		fi
		case $typeIndex in
		1)		mTypeBackupEdit=cg; break;;
		2)		mTypeBackupEdit=bx; break;;
	 	n | N | q |Q)  	exit;;
		* )  		ftEcho -e 错误的选择：$typeIndex ;echo "输入1,2 选择    输入n，q离开";break;;
		esac
		done
	}

	ftSetRestoreType()
	{
		local ftName=选择还原时忽略的目录
		ftEcho -t 请${ftName}
		echo -e "[1]\t忽略home"
		echo -e "[2]\t不忽略"

		while true; do
			echo
			echo -en "请选择还原设置(回车默认忽略home):"
			read -n1 typeIndex

			#设定默认值
			if [ ${#typeIndex} == 0 ]; then
				typeIndex=1
			fi
			case $typeIndex in
			1 ) 		mDirPathRestoreExcludeTarget=$mRoDirPathUserHome;break;;
			2 )		mDirPathRestoreExcludeTarget=; break;;
			n | N | q |Q)	exit;;
			* )		ftEcho -e 错误的选择：$typeIndex ;echo "选择输入1,2 离开输入n，q";break;;
		esac
		done
	}

	ftBackupOs()
	{
		local ftName=生成版本包
		ftEcho -b 开始更新排除列表
		#/home/wgx/cmds/data/excludeDirsBase.list
		fileNameExcludeBase=excludeDirsBase.list
		fileNameExcludeAll=excludeDirsAll.list
		mFilePathExcludeBase=${mRoDirPathUserHome}${mRoDirNameCmd}${mRoDirNameCmdModuleData}${fileNameExcludeBase}
		mFilePathExcludeAll=${mRoDirPathUserHome}${mRoDirNameCmd}${mRoDirNameCmdModuleData}${fileNameExcludeAll}

		mDirPathsExcludeBase=(/proc \
					/android \
					/lost+found \
					/mnt \
					/sys \
					/.Trash-0 \
					/media \
					${mRoDirPathUserHome}workspaces \
					${mRoDirPathUserHome}workspace \
					${mRoDirPathUserHome}download \
					${mRoDirPathUserHome}packages \
					${mRoDirPathUserHome}Pictures \
					${mRoDirPathUserHome}projects \
					${mRoDirPathUserHome}backup \
					${mRoDirPathUserHome}media  \
					${mRoDirPathUserHome}temp \
					${mRoDirPathUserHome}tools \
					${mRoDirPathUserHome}cmds \
					${mRoDirPathUserHome}code \
					${mRoDirPathUserHome}log  \
					${mRoDirPathUserHome}doc  \
					${mRoDirPathUserHome}.AndroidStudio2.1 \
					${mRoDirPathUserHome}.thumbnails \
					${mRoDirPathUserHome}.software \
					${mRoDirPathUserHome}.cache \
					${mRoDirPathUserHome}.local \
					${mRoDirPathUserHome}.other \
					${mRoDirPathUserHome}.gvfs)

		mDirPathsExcludeAll=(/proc \
					/android \
					/lost+found  \
					/mnt  \
					/sys  \
					/media \
					${mRoDirPathUserHome}.AndroidStudio2.1 \
					${mRoDirPathUserHome}backup \
					${mRoDirPathUserHome}.software \
					${mRoDirPathUserHome}download \
					${mRoDirPathUserHome}log  \
					${mRoDirPathUserHome}temp \
					${mRoDirPathUserHome}Pictures \
					${mRoDirPathUserHome}projects \
					${mRoDirPathUserHome}workspaces \
					${mRoDirPathUserHome}.cache \
					${mRoDirPathUserHome}.thumbnails \
					${mRoDirPathUserHome}.local \
					${mRoDirPathUserHome}.other \
					${mRoDirPathUserHome}.gvfs)

		local dirsExclude=
		local fileNameExclude
		if [ $mTypeBackupEdit = "cg" ];then
			dirsExclude=${mDirPathsExcludeBase[*]}
			fileNameExclude=$mFilePathExcludeBase
		elif [ $mTypeBackupEdit = "bx" ];then
			dirsExclude=${mDirPathsExcludeAll[*]}
			fileNameExclude=$mFilePathExcludeAll
		else
			ftEcho -ex  你想金包还是银包呢
			exit
		fi

		#更新排除列表
		if [  -f $fileNameExclude ]; then
			rm -rf $fileNameExclude
		fi
		for dirpath in ${dirsExclude[@]}
		do
		 echo $dirpath >>$fileNameExclude
		done

		ftEcho -b 开始${ftName}

		sudo tar -cvPzf  ${mDirPathStoreTarget}/$mFileNameBackupTarget --exclude-from=$fileNameExclude / \
		2>&1 |tee ${mDirPathLog}/${mFileNameBackupLog}
	}

	ftAddNote()
	{
		local ftName=记录版本包相关备注
		local dateOnly=$(date -d "today" +"%Y%m%d")
		local dateTime=$(date -d "today" +"%Y%m%d_%H%M%S")
		local dirBackupRoot=$1
		local dirNameBackupNote=${dirBackupRoot}/.notes
		local versionName=$2
		local fileNameDefault=.note.list
		local fileNameNote=${versionName}.note

		#使用示例
		while true; do case "$1" in    h | H |-h | -H) cat<<EOF
		#=================== ${ftName}的使用示例===================
		#
		#	ftAddNote [dirBackupRoot] [versionName]
		#	ftAddNote $mDirPathStoreTarget $mFileNameBackupTargetBase
		#=========================================================
EOF
		exit;; * )break;; esac;done

		#耦合变量校验
		local valCount=2
		if [ $# -ne $valCount ]||[ -z "$dirBackupRoot" ]\
						         ||[ -z "$versionName" ];then
			ftEcho -e "函数[${ftName}]参数错误，请查看函数使用示例"
			ftAddNote -h
		fi

		if [ -d ${dirBackupRoot} ]&&[ ! -d ${dirNameBackupNote} ];then
				mkdir ${dirNameBackupNote}
				ftEcho -s 新建备注存储目录:${dirNameBackupNote}
		fi

		local filePathDefault=${dirNameBackupNote}/${fileNameDefault}
		local filePathNote=${dirNameBackupNote}/${fileNameNote}

		if [ ! -f $filePathDefault ]; then
			touch $filePathDefault;echo "【 create by wgx 】">$filePathDefault
		fi

		#note文件行数
		lines=$(sed -n '$=' $filePathDefault)
		lines=$((lines/2))
		let lines=lines+1

		local strVersion="[ "${lines}" ] "${versionName}

		local tt="请输入版本   ["${versionName}"]  相应的说明:"
		echo -en $tt
		read note
		#写入备注总文件
		sed -i "1i ==========================================" $filePathDefault
		sed -i "1i $strVersion           $note" $filePathDefault
		#写入版本独立备注
		sudo echo $note>$filePathNote

		mNoteBackupTarget=$note
	}

	ftMD5()
	{
		local ftName=记录和校验版本包的MD5
		local typeEdit=$1
		local dirBackupRoot=$2
		local dirBackupMd5=${dirBackupRoot}/.md5s
		local versionName=$3
		local fileNameMd5=${versionName}.md5

		#使用示例
		while true; do case "$1" in    h | H |-h | -H) cat<<EOF
		#=================== ${ftName}的使用示例===================
		#
		#	ftMD5 [type] [path] [fileNameBase/VersionName]
		#	ftMD5 check mDirPathStoreSource mFileNameRestoreSourceBase
		#=========================================================
EOF
		exit;; * )break;; esac;done

		#耦合变量校验
		local valCount=3
		if [ $# -ne $valCount ]||[ -z "$typeEdit" ]\
						         ||[ -z "$dirBackupRoot" ]\
						         ||[ -z "$versionName" ];then
			ftEcho -e "函数[${ftName}]参数错误，请查看函数使用示例"
			ftMD5 -h
		fi

		if [ ! -d ${dirBackupRoot} ];then
			ftEcho -e MD5相关操作失败，找不到$dirBackupRoot
			exit
		fi

		if [ ${typeEdit} == "-add" ]; then

			if [ ! -d ${dirBackupMd5} ];then
				mkdir ${dirBackupMd5}
				echo 新建版本包校验信息存储目录:${dirBackupMd5}
			fi

			local pathFile=${dirBackupRoot}/${versionName}.tgz
			local pathMd5=${dirBackupMd5}/${fileNameMd5}

			md5=`md5sum $pathFile | awk '{print $1}'`
			sudo echo $md5>$pathMd5

			ftEcho -s "版本${versionName}校验信息记录完成"

		elif [ ${typeEdit} == "-check" ]; then

			ftEcho -b 开始校验版本包，确定有效性

			if [ -d ${dirBackupMd5} ];then
				local pathFile=${dirBackupRoot}/${versionName}.tgz
				local pathMd5=${dirBackupMd5}/${fileNameMd5}
				if [ -f ${pathMd5} ];then
					md5Base=`cat $pathMd5`
					md5Now=`md5sum $pathFile | awk '{print $1}'`
					if [ "$md5Base"x != "$md5Now"x ]; then
						ftEcho -ex 校验失败，版本包：${versionName}无效
					else
						ftEcho -s 版本包：${versionName}校验成功
					fi
				else
					ftEcho -ex 版本包：${versionName}校验信息查找失败
				fi
			else
				ftEcho -ex 版本包：${versionName}校验信息查找失败
			fi
		fi

	}

	ftAutoCleanTemp()
	{
		local ftName=清理临时文件
		ftEcho -b 开始${ftName}

		sudo apt-get autoclean
		sudo apt-get clean
		sudo apt-get autoremove
		sudo apt-get install -f
		sudo rm -rf /var/cache/apt/archives
	}

	ftSynchronous()
	{
	local ftName=在不同设备间同步版本包
	local isSynchronous=$1
	ftInitDevicesList
	local dirPathArray=${mCmdsModuleDataDevicesList[*]}

	if [ $isSynchronous = "false" ];then
		return 1
	fi

	#耦合变量校验
	local valCount=1
	if [ $# -ne $valCount ];then
		ftEcho -ex "函数[${ftName}]参数错误，请查看函数使用示例"
	fi

	if [ $isSynchronous = "true" ];then
		while true; do
		ftEcho -y 是否开始同步
		read -n1 sel
		case "$sel" in
			y | Y )
				ftEcho -s 开始同步!
				for dirpath in ${dirPathArray[@]}
				do
					for dirpath2 in ${dirPathArray[@]}
					do
						if [ ${dirpath} != ${dirpath2} ]; then
							find $dirpath -regex ".*\.log\|.*\.list" -exec cp {} -u -n -v $dirpath2 \; ;
						fi
					done
				done
				ftEcho -s 同步结束！
				break;;
			n | N| q |Q)  exit;;
			* )
				ftEcho -e 错误的选择：$sel
				echo "输入n，q，离开";
				;;
		esac
		done
	fi
	}

	ftAddOrCheckSystemHwSwInfo()
	{
	local ftName=记录和校验版本包软件和硬件信息
	local typeEdit=$1
	local dirPathBackupRoot=$2
	local dirNameBackupInfoVersion=$3
	local dirPathBackupInfo=${dirPathBackupRoot}/.info
	local dirPathBackupInfoVersion=${dirPathBackupInfo}/${dirNameBackupInfoVersion}

	local filePathVersionCpu=${dirPathBackupInfoVersion}/cpu
	local filePathVersionMainboard=${dirPathBackupInfoVersion}/mainboard
	local filePathVersionSystem=${dirPathBackupInfoVersion}/system
	local filePathVersion32x64=${dirPathBackupInfoVersion}/32x64

	local infoHwCpu=$(dmidecode |grep -i cpu|grep -i version|awk -F ':' '{print $2}'|sed s/[[:space:]]//g)
	local infoHwMainboard=$(dmidecode |grep Name |sed s/[[:space:]]//g)
	local infoHwMainboard=$(echo $infoHwMainboard |sed s/[[:space:]]//g)
	local infoHwSystem=$(head -n 1 /etc/issue|sed s/[[:space:]]//g)
		infoHwSystem=${infoHwSystem//"\n\l"/}
		infoHwSystem=${infoHwSystem//"."/}
		infoHwSystem=${infoHwSystem//Ubuntu/Ubuntu__}
	local infoHw32x64=$(uname -m|sed s/[[:space:]]//g)

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
	#=================== ${ftName}的使用示例===================
	#
	#	ftAddOrCheckSystemHwSwInfo [type] [path] [path]
	#	ftAddOrCheckSystemHwSwInfo -check
	#=========================================================
EOF
	exit;; * )break;; esac;done

	#耦合变量校验
	local valCount=3
	if [ $# -ne $valCount ]||[ -z "$typeEdit" ]\
					         ||[ -z "$dirPathBackupRoot" ]\
					         ||[ -z "$dirNameBackupInfoVersion" ];then
		ftEcho -e "函数[${ftName}]参数错误，请查看函数使用示例"
		ftAddOrCheckSystemHwSwInfo -h
	fi

	local returns=兼容
	if [ ! -d $dirPathBackupRoot ]; then
		echo 系统信息相关操作失败
	  	exit
	else
		if [ ! -d $dirPathBackupInfo ]; then
			mkdir $dirPathBackupInfo
			echo 根系统信息记录位置不存在，已建立
		fi
		if [ ! -d $dirPathBackupInfoVersion ]; then
			mkdir $dirPathBackupInfoVersion
			echo 版本信息记录位置不存在，已建立
		fi
		if [ ${typeEdit} == "-add" ]; then
			echo $infoHwCpu 		>$filePathVersionCpu
			echo $infoHwMainboard 	>$filePathVersionMainboard
			echo $infoHwSystem 		>$filePathVersionSystem
			echo $infoHw32x64 		>$filePathVersion32x64

			ftEcho -s 版本${dirNameBackupInfoVersion}相关系统信息记录完成
		elif [ ${typeEdit} == "-check" ]; then
			ftEcho -b 检查版本包和当前系统兼容程度

			if [ ! -f $filePathVersionCpu ]||[ ! -f $filePathVersionMainboard ]||[ ! -f $filePathVersionSystem ]||[ ! -f $filePathVersion32x64 ]; then
				ftEcho -e   版本${dirNameBackupInfoVersion}相关系统信息损坏
				#显示相关信息存储路径
				echo filePathVersionCpu=$filePathVersionCpu
				echo filePathVersionMainboard=$filePathVersionMainboard
				echo filePathVersionSystem=$filePathVersionSystem
				echo filePathVersion32x64=$filePathVersion32x64
			fi
			local infoHwCpuVersion=$(sed s/[[:space:]]//g $filePathVersionCpu)
			local infoHwMainboardVersion=$(sed s/[[:space:]]//g $filePathVersionMainboard)
			local infoHwSystemVersion=$(sed s/[[:space:]]//g $filePathVersionSystem)
			local infoHw32x64Version=$(sed s/[[:space:]]//g $filePathVersion32x64)

			if [[ $infoHwCpuVersion != $infoHwCpu ]];then
			echo versionpackageInfo=$infoHwCpuVersion
			echo tragetInfo=$infoHwCpu
				ftSel CPU
				returns=${returns}，忽略CPU变化
			fi
			if [[ "$infoHwMainboardVersion" != "$infoHwMainboard" ]]; then
			echo versionpackageInfo= $infoHwMainboardVersion
			echo tragetInfo=$infoHwMainboard
				ftSel 主板
				returns=${returns}，忽略主板变化
			fi
			if [[ "$infoHwSystemVersion" != "$infoHwSystem" ]]; then
			echo versionpackageInfo= $infoHwSystemVersion
			echo tragetInfo=$infoHwSystem
				ftEcho -e  系统版本不一致，将自动退出
				returns=不兼容
			fi
			if [[ "$infoHw32x64Version" != "$infoHw32x64" ]]; then
			echo versionpackageInfo= $infoHw32x64Version
			echo tragetInfo=$infoHw32x64
				ftEcho -e 系统版本的位数不一致，将自动退出
				returns=不兼容
			fi

			ftEcho -s 版本包：${dirNameBackupInfoVersion}系统兼容性检测结果为${returns}
			if [ "$returns"  = "不兼容" ]; then
				exit
			fi

		fi
	fi
	}

	ftSel()
	{
	#=================== example=============================
	#
	#		ftSel [title]
	#		ftSel test
	#=========================================================
		local ftName=版本包软件和硬件信息校验操作选择
		local title=$1
		local valCount=1
		if [ $# -ne $valCount ]||[ -z "$title" ];then
			ftEcho -ex "函数[${ftName}]参数错误，请查看函数使用示例"
		fi
		while true; do
		ftEcho -y "$1有变动,是否忽悠"
		read -n1 sel
		case "$sel" in
			y | Y )	echo 已忽略$1;break;;
			n | N | q |Q)	exit;;
			* )
				ftEcho -e 错误的选择：$sel
				echo "输入n，q，离开";
				;;
		esac
		done
	}

#####-------------------执行------------------------------#########

	# if [ `whoami` != "root" ];then
	# 	read -s -p "密码：" typeIndex
	# 	echo $typeIndex | sudo -S su
	# fi
	if [ `whoami` = "root" ];then
		if [ $mTypeEdit = "restore" ];then
				#选择存放版本包的设备
				ftSetBackupDevDir&&
				#选择版本包
				ftRestoreChoiceSource&&
				#检查版本包和当前系统兼容程度
				ftAddOrCheckSystemHwSwInfo -check $mDirPathStoreSource $mFileNameRestoreSourceBase&&
				#检查版本包有效性
				ftMD5 -check $mDirPathStoreSource $mFileNameRestoreSourceBase&&
				#选择版本包覆盖的目标路径
				ftRestoreChoiceTarget&&
				#选择版本包覆盖的忽略路径
				ftSetRestoreType&&
				#当前配置信息显示
				ftEchoInfo restore&&
				#执行还原操作
				ftRestoreOperate $mFilePathRestoreSource $mDirPathRestoreTarget

		elif [ $mTypeEdit = "backup" ];then
				#选择存放版本包的设备
				ftSetBackupDevDir&&
				cd /&&
				#选择备份类型
				ftSelBackupType&&
				#当前配置信息显示
				ftEchoInfo backup&&
				while true; do
				ftEcho -y 是否开始备份
				read -n1 sel
				case "$sel" in
					y | Y )
					#写版本备注
					ftAddNote $mDirPathStoreTarget $mFileNameBackupTargetBase&&
					#清理临时文件
					ftAutoCleanTemp
					#备份系统生成版本包
					ftBackupOs&&
					#记录版本包校验信息
					ftMD5 -add $mDirPathStoreTarget $mFileNameBackupTargetBase&&
					#记录版本包相关系统信息
					ftAddOrCheckSystemHwSwInfo -add $mDirPathStoreTarget $mFileNameBackupTargetBase&&
					#同步
					ftSynchronous false ;break;;
					n | N | q |Q)  exit;;
					* )
					ftEcho -e 错误的选择：$sel
					echo "输入n，q，离开";
					;;
				esac
				done
		else
			ftEcho -e 不知道你想干嘛！
		fi
	else
		ftEcho -e 请转换为root用户后重新运行
	fi