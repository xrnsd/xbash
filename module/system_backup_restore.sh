#!/bin/bash
#####----------------------变量--------------------------#########

	#将要执行的操作
		mTypeEdit=$1

	#用户主目录
		mNameUser=`who | awk '{print $1}'|sort -u`

	#变量
		mDate=$(date -d "today" +"%Y%m%d")

		mTypeBackupEdit=null
		mDirPathStoreTarget=null
		mFileNameBackupTarget=null
		mNoteBackupTarget=null
		mFileNameBackupLog=null
		mFileNameBackupTargetBase=null

		mDirPathStoreSource=null
		mDirPathRestoreExcludeTarget=null
		mDirPathRestoreTarget=/
		mFilePathRestoreSource=null
		mFileNameRestoreSource=null
		mFileNameRestoreSourceBase=null
		mNoteRestoreSource=null
		mDirPathLog=${mDirNameHome}/log

	#同步选项
		isSynchronous=false
	#同步目录
		#mDirPathSynchronous1=
		#mDirPathSynchronous2=



#####----------------------函数--------------------------#########


	ftRestoreOperate()
	{
		echo -en "是否开始还原[y/n]"
		while true; do
		   read -n1 sel
		   case "$sel" in
			 y | yes )
				pathsource=$1
				mDirPathRestoreTarget=$2
				if [ -f $pathsource ];then
					if [ -d $mDirPathRestoreTarget ];then
					sudo tar -xvpzf $pathsource --exclude=$mDirPathRestoreExcludeTarget -C $mDirPathRestoreTarget
					else
						echo 未找到目录:${mDirPathRestoreTarget}
					fi
				else
					echo 未找到版本包:${pathsource}
				fi;break;;
			 n | N | q |Q)  exit;;
			 * )  ftEcho -e 错误的选择：$sel ;echo "输入n，q，离开"
		   esac
		done
	}

	ftRestoreChoiceSource()
	{

		local index=0;
		local filelist=`ls $mDirPathStoreSource|grep '.tgz'`
		local dir_backup_note=${mDirPathStoreSource}/.notes

		#文件数量获取
		#filenumbers= ls -l /media/data_self/backup/os |grep '.tgz'|grep "^-"|wc -l
		#b=${a/123/321};将${a}里的第一个123替换为321\

		if [ -z "$filelist" ];then
			echo 在${mDirPathStoreSource}没找到有效的版本包
			exit
		else
			ftEcho -t 请选择备份的版本包
			echo "[序号]		版本包名	----------------	   备注		"
			echo
			for file in $filelist
			do
				local file_base_name=${file/.tgz/}
				local file_name_note=${file_base_name}.note
				local path_note=${dir_backup_note}/${file_name_note}
				if [ -f $path_note ];then
					local note=`cat $path_note`
				else
					local note=缺失版本说明，建议视为无效
				fi
				fileNoteList[$index]=$note
				fileList2[$index]=$file
				echo [${index}] ${file_base_name}"   ----------------   "${note}
				index=`expr $index + 1`
			done
			echo
			echo -en "请输入版本包对应的序号(回车默认0):"
			read -n1 tIndex
			#设定默认值
			if [ ${#tIndex} == 0 ]; then
				tIndex=0
			fi
			echo
			mFileNameRestoreSource=${fileList2[$tIndex]}
			mFileNameRestoreSourceBase=${mFileNameRestoreSource/.tgz/}
			mFilePathRestoreSource=${mDirPathStoreSource}/${mFileNameRestoreSource}
			mNoteRestoreSource=${fileNoteList[$tIndex]}
			echo
		fi
	}

	ftRestoreChoiceTarget()
	{
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
				echo --------目录不存在----------
				fi
				customdir=null ; break;;
			0 | n | no | q |Q)  exit;;
			* )    ftEcho -e 错误的选择：$sel ;echo  "选择输入1,2 离开输入0，n，no，q"
		esac
		done
		echo
	}
	
	ftEcho()
	{
	#=================== example=============================
	#
	#		ftEcho [option] [Content] 
	#		ftEcho e 错误的选择1 
	#=========================================================
		option=$1
		Content=$2
		while true; do
		case $option in
			e | E | -e | -E)  echo -e "\033[31m$Content\033[0m"; break;;
			t | T | -t | -T)  echo -e "\e[41;33;1m   =========== $Content ============= \e[0m"; break;;
			b | B | -b | -B)  echo;echo -e "\e[41;33;1m   =========== $Content ============= \e[0m";echo; break;;
			* ) exit ;
		esac
		done
	}

	ftEchoInfo()
	{
		ftEcho -b 请确认下面信息
		local path=${mDirNameHome}cmds/config/version/read.me
		local mVersionChangs=`cat $path`

		local infoType=$1
		if [ $infoType = "restore" ];then

			echo 使用的源文件为：		${mFileNameRestoreSource}
			echo 使用的源文件的说明：	${mNoteRestoreSource}
			echo 还原的目标目录为：	${mDirPathRestoreTarget}
			echo 还原时将忽略目录：	${mDirPathRestoreExcludeTarget}
			echo 当前系统有效修改：	${mVersionChangs}

		elif [ $infoType = "backup" ];then
			mFileNameBackupTargetBase=backup_${mTypeBackupEdit}_${mNameUser}_${mDate}
			mFileNameBackupTarget=${mFileNameBackupTargetBase}.tgz
			mFileNameBackupLog=${mFileNameBackupTargetBase}.log
			
			local btype
			if [ $mTypeBackupEdit = "cg" ];then
				btype=基础
			elif [ $mTypeBackupEdit = "bx" ];then
				btype=全部
			fi

			echo 生成的备份文件为：	${mFileNameBackupTarget}
			echo 生成备份文件的目录：	${mDirPathStoreTarget}
			echo 生成的备份的说明：	${mNoteBackupTarget}
			echo 生成的备份的类型：	${btype}
			echo 当前系统有效修改：	${mVersionChangs}
		else
	 		echo ------------------一脸懵逼----------------------
		fi
		echo
	}


	ftSetBackupDevDir()
	{
		ftEcho -t 请选择备份包存放的设备

		local devTarget
		local devTargetDir
		local devDir=/media
		local dirList=`ls $devDir`
		local dirList2[0]=${mDirNameHome/$mNameUser\//$mNameUser}
		local index=0;
		#遍历/media目录
		echo [0] ${dirList2[0]}
		for dir in $dirList
		do
			#临时挂载设备
			if [ ${dir} == $mNameUser ]; then
			  	local dirTempList=`ls ${devDir}/${dir}`
	  			for dirTemp in $dirTempList
				do
					index=`expr $index + 1`
					dir=${dir}/${dirTemp}
					echo [${index}]  ${devDir}/${dir}
					dirList2[$index]=$dir
				done
			else
			#长期挂载设备
			index=`expr $index + 1`
			echo [${index}]  ${devDir}/${dir}
			dirList2[$index]=$dir
			fi
		done

		echo
		while true; do
			echo -en "请选择存放备份文件的设备[0~$index,q](回车默认当前用户目录):"
			read -n1 dir
			#设定默认值
			  if [ ${#dir} == 0 ]; then
			  	dir=0
			  fi
			  if [ ${dir} == "q" ]; then
			  	exit
			  elif [ -n "$(echo $dir| sed -n "/^[0-$index]\+$/p")" ];then 
			  	devTarget=${dirList2[$dir]}
				devTargetDir=${devDir}/${devTarget}
				#插入home目录
				if [ "$dir" -eq "0" ];then
					devTargetDir=${dirList2[$dir]}
				fi
				break;
			  fi
			  ftEcho -e 错误的选择：$dir
		  done
		echo

		mDirPathStoreTarget=$devTargetDir/backup/os/${mNameUser};
		mDirPathStoreSource=$devTargetDir/backup/os/${mNameUser};

		if [ ! -d $mDirPathStoreTarget ];
			then echo 目录不存在已创建
			mkdir -p $mDirPathStoreTarget
		fi
	}

	ftSelBackupType()
	{
		ftEcho -t 备份类型
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
		[1]* )
			mTypeBackupEdit=cg; break;;
		[2]* )
			mTypeBackupEdit=bx; break;;
	 	n | N | q |Q)  exit;;
		* )  ftEcho -e 错误的选择：$typeIndex ;echo "选择输入1,2 离开输入n，q";;
		esac
		done
	}

	ftSetRestoreType()
	{
		ftEcho -t 还原配置
		echo -e "[1]\t忽略home"
		echo -e "[2]\t不忽略"

		while true; do
			echo
			echo -en "请选择还原设置(回车默认忽略home):"
			read -n1 typeIndex

			#设定默认值
			if [ ${#typeIndex} == 0 ]; then
				mDirPathRestoreExcludeTarget=$mDirNameHome
				break
			fi

			case $typeIndex in
			[1]* ) mDirPathRestoreExcludeTarget=$mDirNameHome;break;;

			[2]* )mDirPathRestoreExcludeTarget=; break;;
			n | no | q |Q)  exit;;
			* ) ftEcho -e 错误的选择：$typeIndex ;echo "选择输入1,2 离开输入n，no，q";;
		esac
		done
	}

	ftBackupOs()
	{
		echo -en "是否开始备份[y/n]"
		while true; do
		   read -n1 sel
		   case "$sel" in
			 y | yes )
				#写版本备注
				ftAddNote $mDirPathStoreTarget $mFileNameBackupTargetBase
				#清理临时文件
				ftAutoCleanTemp

				ftEcho -b 开始生成系统版本包

				if [ $mTypeBackupEdit = "cg" ];then
					sudo tar -cvpzf  ${mDirPathStoreTarget}/$mFileNameBackupTarget \
					--exclude=/proc \
					--exclude=/android \
					--exclude=/lost+found \
					--exclude=/mnt \
					--exclude=/sys \
					--exclude=/.Trash-0 \
					--exclude=/media \
					--exclude=${mDirNameHome}workspaces \
					--exclude=${mDirNameHome}workspace \
					--exclude=${mDirNameHome}download \
					--exclude=${mDirNameHome}packages \
					--exclude=${mDirNameHome}Pictures \
					--exclude=${mDirNameHome}projects \
					--exclude=${mDirNameHome}backup \
					--exclude=${mDirNameHome}media  \
					--exclude=${mDirNameHome}temp \
					--exclude=${mDirNameHome}tools \
					--exclude=${mDirNameHome}cmds \
					--exclude=${mDirNameHome}code \
					--exclude=${mDirNameHome}log  \
					--exclude=${mDirNameHome}doc  \
					--exclude=${mDirNameHome}.AndroidStudio2.1 \
					--exclude=${mDirNameHome}.thumbnails \
					--exclude=${mDirNameHome}.software \
					--exclude=${mDirNameHome}.cache \
					--exclude=${mDirNameHome}.local \
					--exclude=${mDirNameHome}.other \
					--exclude=${mDirNameHome}.gvfs / \
					 2>&1 |tee ${mDirPathLog}/${mFileNameBackupLog}

					#记录版本包校验信息
					ftAddMd5 $mDirPathStoreTarget $mFileNameBackupTargetBase
				elif [ $mTypeBackupEdit = "bx" ];then
					sudo tar -cvpzf  ${mDirPathStoreTarget}/${mFileNameBackupTarget} \
					--exclude=/proc \
					--exclude=/android \
					--exclude=/lost+found  \
					--exclude=/mnt  \
					--exclude=/sys  \
					--exclude=${mDirNameHome}.AndroidStudio2.1 \
					--exclude=${mDirNameHome}backup \
					--exclude=${mDirNameHome}.software \
					--exclude=${mDirNameHome}download \
					--exclude=${mDirNameHome}log  \
					--exclude=${mDirNameHome}temp \
					--exclude=${mDirNameHome}Pictures \
					--exclude=${mDirNameHome}projects \
					--exclude=${mDirNameHome}workspaces \
					--exclude=${mDirNameHome}.cache \
					--exclude=${mDirNameHome}.thumbnails \
					--exclude=${mDirNameHome}.local \
					--exclude=${mDirNameHome}.other \
					--exclude=${mDirNameHome}.gvfs \
					--exclude=/media / \
					2>&1|tee  ${mDirPathLog}/${mFileNameBackupLog}

					#记录版本包校验信息
					ftAddMd5 $mDirPathStoreTarget $mFileNameBackupTargetBase
				else
			 		echo ------------------你想金包还是银包呢----------------------
				fi
				break;;
			 n | N | q |Q)  exit;;
			 * )  ftEcho -e 错误的选择：$sel ;echo  "输入n，q，离开";;
		   esac
		done
	}


	ftAddNote()##记录note
	{
		local str_date=$(date -d "today" +"%Y%m%d")
		local str_time=$(date -d "today" +"%Y%m%d_%H%M%S")
		local dir_backup_root=${1}
		local dir_backup_note=${dir_backup_root}/.notes
		local version_name=${2}
		local file_name_default=.note.list
		local file_name_note=${version_name}.note

		if [ -d ${dir_backup_root} ]&&[ ! -d ${dir_backup_note} ];then
				mkdir ${dir_backup_note}
				echo 新建备注存储目录:${dir_backup_note}
    	fi

		local path_default=${dir_backup_root}/${file_name_default}
		local path_note=${dir_backup_note}/${file_name_note}

		if [ ! -f $path_default ]; then
			touch $path_default;echo "【 create by wgx 】">$path_default
		fi

		#note文件行数
		lines=$(sed -n '$=' $path_default)
		lines=$((lines/2))
		let lines=lines+1

		local strVersion="[ "${lines}" ] "${version_name}

		local tt="请输入版本   ["${version_name}"]  相应的说明:"
		echo -en $tt
		read note
		#写入备注总文件
		sed -i "1i ==========================================" $path_default
		sed -i "1i $strVersion           $note" $path_default
		#写入版本独立备注
		sudo echo $note>$path_note

		mNoteBackupTarget=$note
	}

	ftAddMd5()
	{
		local dir_backup_root=${1}
		local dir_backup_md5=${dir_backup_root}/.md5s
		local version_name=${2}
		local file_name_md5=${version_name}.md5

		ftEcho -b 开始记录版本包校验信息

		if [ -d ${dir_backup_root} ]&&[ ! -d ${dir_backup_md5} ];then
				mkdir ${dir_backup_md5}
				echo 新建版本包校验信息存储目录:${dir_backup_md5}
    		fi

		local path_file=${dir_backup_root}/${version_name}.tgz
		local path_md5=${dir_backup_md5}/${file_name_md5}

		md5=`md5sum $path_file | awk '{print $1}'`
		sudo echo $md5>$path_md5

		echo
		echo "记录完成"
		echo

	}

	ftCheckMd5()
	{
		local dir_backup_root=${1}
		local dir_backup_md5=${dir_backup_root}/.md5s
		local version_name=${2}
		local file_name_md5=${version_name}.md5

		ftEcho -b 开始校验版本包，确定有效性

		if [ -d ${dir_backup_root} ]&&[ -d ${dir_backup_md5} ];then
			local path_file=${dir_backup_root}/${version_name}.tgz
			local path_md5=${dir_backup_md5}/${file_name_md5}
			if [ -f ${path_md5} ];then
				md5Base=`cat $path_md5`
				md5Now=`md5sum $path_file | awk '{print $1}'`
				if [ "$md5Base"x != "$md5Now"x ]; then
					echo 校验失败，版本包：${version_name}无效
					exit
				else
					echo 版本包：${version_name}校验成功
				fi
			else
				echo 校验信息查找失败
				exit
			fi
		else
			echo 校验信息查找失败
			exit
    	fi

	}

	ftAutoCleanTemp()
	{
		ftEcho -t 开始清理临时文件

		sudo apt-get autoclean
		sudo apt-get clean
		sudo apt-get autoremove
		sudo apt-get install -f
		sudo rm -R /var/cache/apt/archives
	}
	
	ftSynchronous()
	{
		if [ $isSynchronous = "true" ];then
			echo -en "是否开始同步[y/n]"
			while true; do
			   read sel
			   case "$sel" in
					 y | yes )
					echo 开始同步...........................................................
					for d in $mDirPathSynchronous1 $mDirPathSynchronous2 ;
					do
						find $mDirPathStoreTarget -regex ".*\.tgz\|.*\.list" -exec cp {} -u -n -v $d \; ;
					done
					echo 同步结束！
					break;;
				 n | no | q |Q)  exit;;
				 * )   ftEcho -e 错误的选择：$sel ;echo "输入n，no，q，离开"
			   esac
			done
		fi
	}
	
	#记录版本包软件和硬件信息
	ftAddOrCheckSystemHwSwInfo()
	{
	#=================== example=============================
	#
	#		ftAddOrCheckSystemHwSwInfo [type] [path] [path]
	#		ftAddOrCheckSystemHwSwInfo check 
	#=========================================================
	
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
	local infoHw32x64=$(uname -m|sed s/[[:space:]]//g)
	
	local returns=通过
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
		if [ ${typeEdit} == "add" ]; then
			ftEcho -b 记录版本包相关系统信息

			echo $infoHwCpu 		>$filePathVersionCpu
			echo $infoHwMainboard 	>$filePathVersionMainboard
			echo $infoHwSystem 		>$filePathVersionSystem
			echo $infoHw32x64 		>$filePathVersion32x64
		
		elif [ ${typeEdit} == "check" ]; then
			ftEcho -b 检查版本包和当前系统兼容程度

			if [ ! -f $filePathVersionCpu ]||[ ! -f $filePathVersionMainboard ]||[ ! -f $filePathVersionSystem ]||[ ! -f $filePathVersion32x64 ]; then
				echo  版本包相关系统信息损坏
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
			echo Version=$infoHwCpuVersion
			echo baseion=$infoHwCpu
				ftSel CPU
				returns=结束
			fi
			if [[ "$infoHwMainboardVersion" != "$infoHwMainboard" ]]; then
			echo Version= $infoHwMainboardVersion
			echo baseion=$infoHwMainboard
				ftSel 主板
				returns=结束
		  	fi
			if [[ "$infoHwSystemVersion" != "$infoHwSystem" ]]; then
			echo Version= $infoHwSystemVersion
			echo baseion=$infoHwSystem
				echo 系统版本不一致，将自动退出
				returns=未通过，
		  	fi
			if [[ "$infoHw32x64Version" != "$infoHw32x64" ]]; then
			echo Version= $infoHw32x64Version
			echo baseion=$infoHw32x64
				echo 系统版本的位数不一致，将自动退出
				returns=失败
		  	fi

			echo 版本包：${dirNameBackupInfoVersion}系统兼容性检测${returns}
		  	if [ "$infoHw32x64Version"  = "失败" ]; then
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
		local title=$1
		echo -en "$1有变动,是否忽悠[y/n]"
		while true; do
		   read -n1 sel
		   case "$sel" in
			 y | yes )
				echo 已忽略$1;break;;
			 n | N | q |Q)  exit;;
			 * )  ftEcho -e 错误的选择：$sel ;echo "不忽略请输入n，q"
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
				ftAddOrCheckSystemHwSwInfo check $mDirPathStoreSource $mFileNameRestoreSourceBase&&
				#检查版本包有效性
				ftCheckMd5 $mDirPathStoreSource $mFileNameRestoreSourceBase&&
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
				#记录版本包相关系统信息
				ftAddOrCheckSystemHwSwInfo add $mDirPathStoreTarget $mFileNameBackupTargetBase&&
				#备份
				ftBackupOs $backupType22&&
				#同步
				ftSynchronous 
		else
	 		echo ------------------不知道你想干嘛！----------------------
		fi
	else
 		echo ------------------请转换为root用户后重新运行----------------------
	fi
