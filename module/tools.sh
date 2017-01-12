#!/bin/bash
#####---------------------  说明  ---------------------------#########
# 不可在此文件中出现不被函数包裹的调用或定义
# 人话，这里只放函数
#####---------------------流程函数---------------------------#########
ftExample()
{
	local ftName=函数模板
	# 1 耦合变量校验[耦合变量包含全局变量，输入参数，输入变量]
	# 3 提供可执行前提说明
	# 4 提供执行流程说明
	# 5 提供使用示例
	# -eq = 		# -ne !=
	# -gt >		# -lt <
	# ge >=		# le <=

	# ${dirPathFileList%/*}父目录路径
	# ${dirPathFileList##*/}父目录名
	# `basename /home/wgx` wgx
	# `dirname /home/wgx` /home
	# echo 文件名: ${file%.*}”
	# echo 后缀名: ${file##*.}”
	# sed -i 's/被替换的内容/要替换成的内容/' file #内容包含空格需要转义
	#sed -i "s:被替换的内容:要替换成的内容:g" file #被替换的内容为路径，内容包含空格需要转义
	#filenumbers= ls -l /media/data_self/backup/os |grep '.tgz'|grep "^-"|wc -l #文件数量获取
	#b=${a/123/321};将${a}里的第一个123替换为321\

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#
#	ftExample 无参
#	ftExample [example]
#	ftExample xxxx
#=========================================================
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
	exit;; * ) break;; esac;done

	#耦合变量校验
	local valCount=1
	if(( $#!=$valCount ))||[ -z "$example1" ]\
				||[ -z "$example2" ];then
		ftEcho -ea "[${ftName}]的参数错误 \
			[参数数量def=$valCount]valCount=$# \
			[示例1]example1=$example1 \
			[示例2]example2=$example2 \
			请查看下面说明:"
		ftExample -h
		return
	fi
}

ftWhoAmI()## #命令权限判定
{
	local ftName=命令权限判定
	local cmdName=$1

	#耦合变量校验
	local valCount=1
	if(( $#!=$valCount ))||[ -z "$cmdName" ]\
				||[ -z "$rCmdsPermissionBase" ]\
				||[ -z "$rCmdsPermissionRoot" ];then
		ftEcho -e "[${XCMD}]的参数错误 \n\
[参数数量def=$valCount]valCount=$# \n\
[命令名] cmdName=$cmdName \n\
[基础权限命令名列表]rCmdsPermissionBase=${rCmdsPermissionBase[@]} \n\
[特殊权限命令名列表]rCmdsPermissionRoot=${rCmdsPermissionRoot[@]} \n\
请查看下面说明:"
		ftReadMe $XCMD
	fi

	for cmd in ${rCmdsPermissionBase[@]}
	do
			if [ "$cmd" = "$cmdName" ]||[ "$XCMD" = "$cmdName" ];then
				commandAuthority=base
			fi
	done

	for cmd in ${rCmdsPermissionRoot[@]}
	do
			if [ "$cmd" = "$cmdName" ]||[ "$XCMD" = "$cmdName" ];then
				commandAuthority=root
			fi
	done
}

ftMain()
{
	local ftName=工具主入口
	while true; do
	case $rBaseShellParameter2 in
	-v | --version )		echo \"Xrnsd extensions to bash\" $rXbashVersion
				break;;
	test)			ftTest "$@"
				break;;
	reboot | shutdown)	ftBoot	$rBaseShellParameter2
				break;;
	clean_data_garbage)	ftCleanDataGarbage
				break;;
	-h| --help | -ft | -ftall)	ftReadMe $rBaseShellParameter3 $rBaseShellParameter2
				break;;
	vvv | -vvv)			ftEcho -b xbash;		echo \"Xrnsd extensions to bash\" $rXbashVersion
				ftEcho -b java;		java -version
				ftEcho -b gcc;		gcc -v
	break;;
	*)
		#权限约束开始
		ftWhoAmI $rBaseShellParameter2
		if [ "$commandAuthority" = "root" ]; then
			if [ `whoami` = "root" ]; then
				while true; do
				case $rBaseShellParameter2 in
					"backup")	${rDirPathCmdsModule}/${rFileNameCmdModuleMS} backup; break;;
					"restore")	${rDirPathCmdsModule}/${rFileNameCmdModuleMS} restore; break;;
				esac
				done
			else
				ftEcho -ex "当前用户权限过低，请转换为root 用户后重新运行"
			fi
		elif [ "$commandAuthority" = "base" ]; then
			if [ `whoami` = $rNameUser ]; then
				while true; do
				case $rBaseShellParameter2 in
					"mtk_flashtool")	ftMtkFlashTool ; break;;
					"restartadb")		ftRestartAdb; break;;
					"pac")			ftCopySprdPacFileList; break;;
					"monkey")		ftKillPhoneAppByPackageName com.android.commands.monkey; break;;
					"systemui")		ftKillPhoneAppByPackageName com.android.systemui; break;;
					"launcher")		ftKillPhoneAppByPackageName com.android.launcher3; break;;
					"bootanim")		ftBootAnimation $rBaseShellParameter3 $rBaseShellParameter2;break;;
					"gjh")			ftGjh;break;;
				esac
				done
			else
				ftEcho -ex "转化普通用户后，再次尝试"
			fi
		#权限约束结束
		elif [ "$commandAuthority" = "null" ]; then
			ftOther $rBaseShellParameter2
		fi
		break;;
	esac
	done
}

ftOther()
{
	while true; do
	case $XCMD in
	"xk")	ftKillPhoneAppByPackageName $rBaseShellParameter2	;break;;
	*)	ftEcho -e "命令[${XCMD}]参数=[$1]错误，请查看命令使用示例";ftReadMe $XCMD; break;;
	esac
	done
}

ftReadMe()
{
	local ftName=工具命令使用说明

	# 凡调用此方法的操作产生的日志都视为无效
	local dirPathLogExpired=${mFilePathLog%/*}
	local dirPathLogOther=${rDirPathCmdsLog}/other
	if [ ! -d "$dirPathLogOther" ];then
		mkdir $dirPathLogOther
	fi
	if [ $dirPathLogOther != $dirPathLogExpired ]&&[ $mFilePathLog != "/dev/null" ];then
		local dirPathExpired=${dirPathLogOther}/$(basename $dirPathLogExpired)
		if [ -d $dirPathExpired ];then
			cp ${dirPathLogExpired}/* $dirPathExpired
			rm -rf $dirPathLogExpired
		else
			mv $dirPathLogExpired $dirPathExpired
		fi
		export mFilePathLog=${dirPathLogOther}/$(basename $mFilePathLog)
	fi

	while true; do
		case "$1" in
		ft | -ft )
	cat<<EOF

ftKillPhoneAppByPackageName ---- kill掉包名为packageName的应用
ftJdkVersionTempSwitch           临时切换jdk版本
ftCopySprdPacFileList ---------- 自动复制sprd的pac相关文件
ftBackupOutsByMove               备份out
ftCleanDataGarbage ------------- 快速清空回收站
ftReduceFileList                 精简动画帧文件
ftPushAppByName ---------------- push Apk文件
ftBootAnimation                  生成开关机动画
ftMtkFlashTool ----------------- mtk下载工具
ftSynchronous                    文件同步
ftUpdateHosts ------------------ 更新hosts
ftReNameFile ------------------- 批量重命名
ftRestartAdb                     重启adb sever
ftYKSwitch                       切换永恒星和康龙配置 sever
ftBoot ------------------------- 延时免密码关机重启
ftGjh                            生成国际化所需的xml文件

EOF
	if [ $XMODULE = "env" ];then
		return
	fi
exit;;
		ftall | -ftall )
	cat<<EOF
=========================================================================
方法名 方法说明
	|// 使用格式
	|   说明
	|  方法名 参数1 参数2
例	|  方法名 参数1 参数2
=========================================================================
ftBootAnimation 生成开关机动画
	|
	|// ftBootAnimation [edittype] [path]
	|   直接生成动画包，不做其他操作，不确认资源文件是否有效
	|  ftBootAnimation create path
	|   初始化生成bootanimation2.zip所需要的东东，然后生成动画包
	|  ftBootAnimation new path
	|
ftBoot 延时免密码关机重启
	|
	|// ftBoot 关机/重启 时间/秒
	|   100秒后自动关机/重启
例	|  ftBoot shutdown/shutdown 100
	|
ftReNameFile 批量重命名
	|不指定文件名长度默认为4
	|// ftReNameFile 目录
	|// ftReNameFile 目录 文件名长度
例	|  ftReNameFile /home/xxxx/temp
例	|  ftReNameFile /home/xxxx/temp 5
	|
ftSynchronous 文件同步
	|
	|// ftSynchronous [dirPathArray] [fileTypeList]
	|   在data_xx和data_xx之间同步类型为info或tgz的文件或目录
例	|  ftSynchronous "/media/data_xx /media/data_xx" ".*\.info\|.*\.tgz"
	|
ftUpdateHosts 更新hosts
	|
	|   使用默认hosts源[https://raw.githubusercontent.com/racaljk/hosts/master/hosts]
	|// ftUpdateHosts 无参
	|   使用自定义hosts源
	|// ftUpdateHosts https://xxxx
例	|  ftUpdateHosts https://raw/hosts/master/hosts
	|
ftPushAppByName push Apk文件
	|
	|// ftPushAppByName [AppName]
	|// ftPushAppByName [filePathApk] [dirPath]
	|   push SystemUI对应的apk到手机中,前提当前bash已初始化android build环境
例	|  ftPushAppByName SystemUI
	|   push自定义apk 到/system/app
例	|  ftPushAppByName /home/xxx/xx.apk /system/app
	|
ftReduceFileList 精简动画帧文件
	|
	|// ftReduceFileList 目录
	|// ftReduceFileList 保留的百分比 目录
	|   另外输入保留比例
例	|  ftReduceFileList /home/xxxx/temp
	|   保留百分之60的文件
例	|  ftReduceFileList 60 /home/xxxx/temp
	|
ftKillPhoneAppByPackageName kill掉包名为packageName的应用
	|
	|// ftKillPhoneAppByPackageName packageName
	|
ftJdkVersionTempSwitch 临时切换jdk版本
	|
	|// ftJdkVersionTempSwitch 版本
	|   ftJdkVersionTempSwitch 1.6/1.7
	|
ftYKSwitch 切换永恒星和康龙配置
	|
	|// ftYKSwitch yhx/kl
	|
==========================================
======= 下面实现全部无参
==========================================
	|
ftCopySprdPacFileList 自动复制sprd的pac相关文件
	|
ftBackupOutsByMove 备份out
	|
ftCleanDataGarbage 快速清空回收站
	|
ftMtkFlashTool mtk下载工具
	|
ftRestartAdb 重启adb sever
	|
ftGjh 生成国际化所需的xml文件
	|
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
exit;;
		a | A | -a |-A)
	ftEcho -s “命令 参数 -h#可查看参数具体说明”
	cat<<EOF
=========================================================================
	命令	--- 参数/命令说明
	|// 使用格式
	|  参数	 ---------------- [参数权限] ----	参数说明
=========================================================================
xb ----- 系统维护
	|// xb ×××××
	|
	|  backup	---------------- [root] ------	备份系统
	|  restore	---------------- [root] ------	还原系统
xc ----- 常规自定义命令和扩展
	|// xc ×××××
	|
	|  pac		--------------------------	自动复制sprd的pac相关文件
	|  test		--------------------------	shell测试
	|  clean_data_garbage	------------------	快速清空回收站
	|  restartadb	--------------------------	重启adb服务
	|  bootanim	--------------------------	制作开关机动画包
	|	|  xc bootanim	[edittype] [path]
	|	|  xc bootanim	 create	动画资源目录	不初始化，直接生成动画包
	|	|  xc bootanim	 new	动画资源目录	初始化后生成动画包
	|
	|  v 		--------------------------	自定义命令版本
	|  help		--------------------------	查看自定义命令说明
	|  vvv		--------------------------	系统环境关键参数查看
	|  gjh		--------------------------	生成国际化所需的xml文件
xk ----- 关闭手机指定进程
	|// xk ×××××
	|
	|  monkey	-----------------------------	关闭monkey
	|  systemui	-----------------------------	关闭systemui
	|  应用包名	-----------------------------	关闭指定app
xl ----- 过滤 android 含有tag的所有等级的log
	|// xl tag
	|
xt ----- 检测shell脚本，语法检测和测试运行
	|// xt 脚本文件名
	|
//xg	---- [无参] / 搜索文件里面的字符串
	|// xg 字符串
	|
xle ----- 过滤 android 含有tag的E级log
	|// xle tag
	|
xkd	---- [无参] / 快速删除海量文件
	|// xkd 文件夹
	|
xbh ----- 根据标签过滤命令历史
	|// xbh 标签
	|
xp ----- 查看文件绝对路径
	|// xp 文件名
	|
//xh ----- 查看具体命令说明
	|// xh 命令名
	|
xgl --- [无参] / 简单查看最近10次git commit
xi ---- [无参] / 快速初始化模块编译环境
xr ---- [无参] / 使.bashrc修改生效
.  ---- [无参] / 进入上一级目录
.. ---- [无参] / 进入上两级目录
xd ---- [无参] / mtk下载工具
xu ---- [无参] / 打开.bashrc
.9 ---- [无参] / 打开.9工具
xx ---- [无参] / 休眠
xs ---- [无参] / 关机
xss --- [无参] / 重启

===============	临时命令 ===================
xversion--[无参] / 查看软件版本
xg6572 ----- 下载mtk6572的工程
	|// xg6572 分支名
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
exit;;
	xc |test | clean_data_garbage|restartadb | help | gjh)ftEcho -g;
cat<<EOF
xc	----- 常规自定义命令和扩展
	|// xc ×××××
	|
	|  pac		--------------------------	自动复制sprd的pac相关文件
	|  test		--------------------------	shell测试
	|  clean_data_garbage	------------------	快速清空回收站
	|  restartadb	--------------------------	重启adb服务
	|  bootanim	--------------------------	制作开关机动画包
	|	|  xc bootanim	[edittype] [path]
	|	|  xc bootanim	 create	动画资源目录	不初始化，直接生成动画包
	|	|  xc bootanim	 new	动画资源目录	初始化后生成动画包
	|
	|  v 		--------------------------	自定义命令版本
	|  help		--------------------------	查看自定义命令说明
	|  vvv		--------------------------	系统环境关键参数查看
	|  gjh		--------------------------	生成国际化所需的xml文件
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
exit;;
	xb | backup | restore)ftEcho -g;
cat<<EOF
xb	----- 系统维护
	|// xb ×××××
	|
	|  backup	---------------- [root] ------	备份系统
	|  restore	---------------- [root] ------	还原系统
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
exit;;
xk | monkey | systemui)ftEcho -g;
cat<<EOF
xk	----- 关闭手机指定进程
	|// xk ×××××
	|
	|  monkey	-------------------------------	关闭monkey
	|  systemui	-----------------------------	关闭systemui
	|  应用包名	-----------------------------	关闭指定app
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
exit;;
	xt)
cat<<EOF
xt ----- 检测shell脚本，语法检测和测试运行
	|// xt 脚本文件名
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
exit;;
	xh)
cat<<EOF
xh ----- 查看具体命令说明
	|// xh 命令名
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
exit;;
	*)ftReadMe -a;break;;
	esac
done
}

#####---------------------工具函数---------------------------#########
ftKillPhoneAppByPackageName()
{
	local ftName=kill掉包名为packageName的应用
	local packageName=$1

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#
#	ftKillPhoneAppByPackageName [packageName]
#	ftKillPhoneAppByPackageName com.android.settings
#=========================================================
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
	exit;; * ) break;; esac;done

	#耦合变量校验
	local valCount=1
	if(( $#!=$valCount ))||[ -z "$packageName" ];then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量def=$valCount]valCount=$# \
				[应用包名]packageName=$packageName \
				请查看下面说明:"
		ftKillPhoneAppByPackageName -h
		return
	fi

	#adb状态检测
	adbStatus=`adb get-state`
	if [ "$adbStatus" = "device" ];then
		#确定包存在
		if [ -n "$(adb shell pm list packages|grep $packageName)" ];then
			adb root
			adb remount
			pid=`adb shell ps | grep $packageName | awk '{print $2}'`
			#pid=`adb shell "ps" | awk '/com.android.systemui/{print $2}'`
			adb shell kill $pid
		else
			ftEcho -e 包名[${packageName}]不存在，请确认
		fi
	else
		ftEcho -e adb状态异常,请重新尝试
	fi
}

ftRestartAdb()
{
	#耦合变量校验
	local valCount=0
	if(( $#!=$valCount ))||[ -z "$rUserPwd" ];then
		ftEcho -eax "函数[${ftName}]的参数错误 \
			[参数数量def=$valCount]valCount=$# \
			[默认用户密码]rUserPwd=$rUserPwd"
	fi

	local ftName=重启adb sever
	echo $rUserPwd | sudo -S adb kill-server
	echo
	sleep 2
	echo $rUserPwd | sudo -S adb start-server
	echo server-start
	adb devices
}

ftInitDevicesList()
{
	local ftName=存储设备列表初始化
	local devDir=/media
	local dirList=`ls $devDir`
	# 设备最小可用空间，小于则视为无效.单位M
	local devMinAvailableSpace=${1:-'0'}
	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例===================
#
#	ftInitDevicesList [devMinAvailableSpace 单位M]
#	ftInitDevicesList 4096M
#=========================================================
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
	exit;; * ) break;; esac;done

	#耦合变量校验
	local valCount=1
	if (( $#>$valCount ))||[ -z "$rDirPathUserHome" ]\
				||[ -z "$rNameUser" ];then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量def=$valCount]valCount=$# \
				[默认用户的home目录]rDirPathUserHome=$rDirPathUserHome \
				[默认用户名]rNameUser=$rNameUser \
				请查看下面说明:"
		ftInitDevicesList -h
		return
	fi

	unset mCmdsModuleDataDevicesList

	local index=0
	mCmdsModuleDataDevicesList=(${rDirPathUserHome/$rNameUser\//$rNameUser})
	#设备可用空间大小符合限制
	sizeHome=$(ftDevAvailableSpace $mCmdsModuleDataDevicesList true)
	if [ "$sizeHome" -gt "$devMinAvailableSpace" ];then
		index=1;
	fi
	#开始记录设备文件
	for dir in $dirList
	do
		#临时挂载设备
		if [ ${dir} == $rNameUser ]; then
			local dirTempList=`ls ${devDir}/${dir}`
			for dirTemp in $dirTempList
			do
				devPathTemp=${devDir}/${dir}/${dirTemp}
				sizeTemp=$(ftDevAvailableSpace $devPathTemp true)
				# 确定目录已挂载,设备可用空间大小符合限制
				if mountpoint -q $devPathTemp&&[ "$sizeTemp" -gt "$devMinAvailableSpace" ];then
					mCmdsModuleDataDevicesList[$index]=$devPathTemp
					index=`expr $index + 1`
				fi
			done
		#长期挂载设备
		else
			devPath=${devDir}/${dir}
			size=$(ftDevAvailableSpace $devPath true)
			# 确定目录已挂载,设备可用空间大小符合限制
			if mountpoint -q $devPath&&[ "$size" -gt "$devMinAvailableSpace" ];then
				mCmdsModuleDataDevicesList[$index]=$devPath
				index=`expr $index + 1`
			fi
		fi
	done
	export mCmdsModuleDataDevicesList
}

ftCleanDataGarbage()
{
	local ftName=快速清空回收站
	ftInitDevicesList

	#耦合变量校验
	local valCount=0
	if(( $#!=$valCount ))||[ -z "$mCmdsModuleDataDevicesList" ];then
		ftEcho -ex "函数[${ftName}]的参数错误 \
[参数数量def=$valCount]valCount=$# \
[被清空回收站的设备的目录列表]mCmdsModuleDataDevicesList=${mCmdsModuleDataDevicesList[@]}"
	fi

	for dirDev in ${mCmdsModuleDataDevicesList[*]}
	do
		dir=null
		if [ -d ${dirDev}/.Trash-1000 ];then
			dir=${dirDev}/.Trash-1000
		else
			if [ -d ${dirDev}/.local/share/Trash ];then
				dir=${dirDev}/.local/share/Trash
			fi
		fi
		if [ -d $dir ];then
			cd $dir
			if [ ! -d empty ];then
				mkdir empty
			fi
			rsync --delete-before -d -a -H -v --progress --stats empty/ files/
			rm -rf files/*
		fi
	done
}

ftMtkFlashTool()
{
	local ftName=mtk下载工具
	local tempDirPath=`pwd`
	#使用示例
	while true; do case "$1" in	h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#
#	ftMtkFlashTool 无参
#=========================================================
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
	exit;; * ) break;; esac;done

	#耦合变量校验
	local valCount=0
	if(( $#!=$valCount ))||[ -z "$rDirPathTools" ]\
				||[ ! -d "$rDirPathTools" ];then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量def=$valCount]valCount=$# \
				[mtk下载工具路径]rDirPathTools=$rDirPathTools"
		ftMtkFlashTool -h
	fi
	local toolDirPath=${rDirPathTools}/sp_flash_tool_v5.1548

	cd $toolDirPath&&
	echo "$rUserPwd" | sudo -S ./flash_tool&&
	cd $tempDirPath
}

ftFileDirEdit()
{
	local ftName=路径合法性校验
	type=$1
	isCreate=$2
	path=$3

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例===================
#
#	ftFileDirEdit [type] [isCreate] [path]
#
#	文件存在，创建，返回1
#	ftFileDirEdit -f true /home/xian-hp-u16/cmds/${rFileNameCmdModuleTestBase}
#
#	文件夹存在，创建，返回1
#	ftFileDirEdit -d true /home/xian-hp-u16/cmds/${rFileNameCmdModuleTestBase}
#
#	判断文件夹是否为空，空，返回2 非空，返回3,非文件夹，返回4
#	ftFileDirEdit -e false /home/xian-hp-u16/cmds
#	echo $?
#===============================================================
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
	exit;; * ) break;; esac;done

	#耦合变量校验
	local valCount=3
	if(( $#!=$valCount ))||[ -z "$type" ]\
						||[ -z "$isCreate" ]\
						||[ -z "$path" ];then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量def=$valCount]valCount=$# \
				[操作参数]type=$type \
				[是否新建]isCreate=$isCreate \
				[被操作的目录或路径]path=$path \
				请查看下面说明:"
		ftFileDirEdit -h
		return
	fi

	while true; do
	case "$type" in
		e | E | -e | -E )
			if [ ! -d $path ]; then
			     return 4
			fi
			files=`ls $path`
			if [ -z "$files" ]; then
			     return 2
			else
			     return 3
			fi
			break;;
		f | F | -f | -F )
			if [ -f $path ];then
				return 1
			elif [ $isCreate = "true" ];then
				touch $path
				return 1
			else
				return 0
			fi
			break;;
		d | D)
			if [ -d $path ];then
				return 1
			elif [ $isCreate = "true" ];then
				mkdir -p $path
				return 1
			else
				return 0
			fi
			break;;
		* )
			ftEcho -e "函数[${ftName}]参数错误，请查看函数使用示例"
			ftFileDirEdit -h
			;;
	esac
	done
}

ftEcho()
{
	local ftName=工具信息提示
	#使用示例
	while true; do case "$1" in	h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#
#	ftEcho		内容	# 直接显示内容
#	ftEcho	-b	内容	# 标题，不换行，对字符串的缩进敏感
#	ftEcho	-bh	内容	# 标题，换行，对字符串的缩进敏感
#	ftEcho	-e	内容	# 错误信息显示，对字符串的缩进敏感
#	ftEcho	-ex	内容	# 错误信息显示，显示完退出，对字符串的缩进敏感
#	ftEcho	-ea	内容	# 错误信息多行显示，对字符串的缩进不敏感,包含内置数组会显示不正常
#	ftEcho	-eax	内容	# 错误信息多行显示，对字符串的缩进不敏感,包含内置数组会显示不正常，显示完退出
#	ftEcho	-y	内容	# 特定信息显示,y/n，对字符串的缩进敏感
#	ftEcho	-s	内容	# 执行信息，对字符串的缩进敏感
#=========================================================
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
	exit;; * ) break;; esac;done

	#耦合变量校验
	local valCount=1
	if(( $#<$valCount ));then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量def=1/2]valCount=$# "
		ftEcho -h
	fi

	option=$1
	option=${option:-'未制定显示信息'}
	valList=$@
	#除第一个参数外的所有参数列表，可正常打印数组
	content="${valList[@]/$option/}"

	while true; do
	case $option in

	e | E | -e | -E)		echo -e "\033[1;31m$content\033[0m"; break;;
	ex | EX | -ex | -EX)	echo -e "\033[1;31m$content\033[0m"
				sleep 3
				if [ $XMODULE = "env" ];then
					return
				fi
				exit;;
	s | S | -s | -S)		echo;echo -e "\033[42;37m$content\033[0m"; break;;
	b | B| -b | -B)		echo -e "\e[41;33;1m =========== $content ============= \e[0m"; break;;
	bh | BH | -bh | -BH)	echo;echo -e "\e[41;33;1m =========== $content ============= \e[0m";echo; break;;
	y | Y | -y | -Y)		echo;echo -en "${content}[y/n]"; break;;
	ea| EA | -ea | -EA)	for val in ${content[@]}
				do
					echo -e "\033[1;31m$val\033[0m";
				done
				break;;

	eax| EAX | -eax | -EAX)	for val in ${content[@]}
				do
					echo -e "\033[1;31m$val\033[0m";
				done
				exit;;
	# 特定信息显示,命令说明的格式
	g | G | -g | -G)
	ftEcho -s “命令 参数 -h#可查看参数具体说明”
	cat<<EOF
=========================================================================
命令	--- 参数/命令说明
	|// 使用格式
	|  参数	 ---------------- [参数权限] ----	参数说明
=========================================================================
EOF
break;;
	* )	echo $option ;break;;
	esac
	done
}

ftTiming()
{
	local ftName=脚本操作耗时记录

	if [ -z "$mTimingStart" ];then
		mTimingStart=$(date +%s -d $(date +"%H:%M:%S"))
		return 0;
	fi

	 #时间少于1秒默认不显示操作耗时
	 #时间时分秒各单位不显示为零的结果
	time2=$(date +%s -d $(date +"%H:%M:%S"))
	time3=$(((time2-mTimingStart)%60))
	time5=$(((time2-mTimingStart)/3600))
	time4=$((((time2-mTimingStart)-time5*3600)/60))

	if [ "$time5" -ne "0" ];then
		strS1=$time5时
	else
		strS1=""
	fi
	if [ "$time4" -ne "0" ];then
		strF1=$time4分
	else
		strF1=""
	fi
	if [ "$time3" -ne "0" ];then
		strM1=$time3秒
	else
		strM1=""
	fi
	if [ "$time3" -eq "0" ]&&[ "$time4" -eq "0" ] &&[ "$time5" -eq "0" ];then
		ftEcho -s 1秒没到就结束了
	else
		 ftEcho -s "本技能耗时${strS1}${strF1}${strM1}  !"
	fi
	mTimingStart=
}

ftBootAnimation()
{
	local ftName=生成开关机动画
	local typeEdit=$1
	local dirPathAnimation=$2
	local dirPathBase=$(pwd)

	#使用示例
	while true; do case "$1" in    h | H |-h | -H)
		cat<<EOF
#=================== 函数${ftName}的使用示例============
#	请进入动画资源目录后执行xc bootanim xxx
#	ftBootAnimation [edittype] [path]
#
#	直接生成动画包，不做其他操作，不确认资源文件是否有效
#	ftBootAnimation create /home/xxxx/test/bootanimation2
#
#	初始化生成bootanimation2.zip所需要的东东，然后生成动画包
#	ftBootAnimation new /home/xxxx/test/bootanimation2
#============================================================
EOF

	if [ $XMODULE = "script" ];then
		cat<<EOF
#=================== 命令[xc bootanim]的使用示例============
# 	重命名文件，生成配置文件，生成动画包
# 	xc bootanim new /home/xxxx/test/bootanimation2
#
# 	直接生成动画包
# 	xc bootanim create /home/xxxx/test/bootanimation2
#============================================================
EOF
	else
		return
	fi

	exit;; * ) break;; esac;done

	#耦合变量校验
	local valCount=2
	if(( $#!=$valCount ))||[ -z "$dirPathAnimation" ];then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量def=$valCount]valCount=$# \
				[动画资源目录]dirPathAnimation=$dirPathAnimation \
				请查看下面说明:"
		ftBootAnimation -h
		return
	fi
	while true; do
	case "$typeEdit" in
	create)
		#默认运行前提环境
		#所在文件夹为动画包解压生成的，也就是该参数默认只能重新打包
		local dirNamePackageName=${dirPathAnimation##*/}.zip
		local fileConfig=`ls $dirPathAnimation|grep '.txt'`

		echo -en "请输入动画包的包名(回车默认animation):"
		read customPackageName
		if [ ${#customPackageName} != 0 ];then
			dirNamePackageName=${customPackageName}.zip
		fi

		if [ -z "$dirNamePackageName" ]||[ -z "$fileConfig" ];then
			ftEcho -e "函数[${ftName}]运行出现错误，请查看函数"
			echo dirNamePackageName=$dirNamePackageName
			echo fileConfig=$fileConfig
		fi

		cd $dirPathAnimation
		zip -r -0 ${dirNamePackageName} */* ${fileConfig} >/dev/null
		cd $dirPathBase

		while true; do
		ftEcho -y 已生成${dirNamePackageName}，是否清尾
		read -n1 sel
		case "$sel" in
			y | Y )
				local filePath=/home/${rNameUser}/${dirNamePackageName}
				if [ -f $filePath ];then
					while true; do
					echo
					ftEcho -y 有旧的${dirNamePackageName}，是否覆盖
					read -n1 sel
					case "$sel" in
						y | Y )	break;;
						n | N)	mv $filePath /home/${rNameUser}/${dirNamePackageName/.zip/_old.zip};break;;
						q |Q)	exit;;
						* )
							ftEcho -e 错误的选择：$sel
							echo "输入q，离开"
							;;
					esac
					done
				fi
				mv ${dirPathAnimation}/${dirNamePackageName} $filePath&&
				rm -rf $dirPathAnimation
				break;;
			n | N| q |Q)  exit;;
			* )	ftEcho -e 错误的选择：$sel
				echo "输入n，q，离开"
				;;
		esac
		done
		break;;
	new)
		local dirNamePart0=part0
		local dirNamePart1=part1
		local fileNameDesc=desc.txt
		local fileNameLast
		local dirNameAnimation=animation

		dirPathAnimationSourceRes=$dirPathAnimation
		cd $dirPathAnimationSourceRes

		ftFileDirEdit -e false $dirPathAnimationSourceRes
		if [ $? -eq "2" ];then
			ftEcho -ex 空的动画资源，请确认[${dirPathAnimationSourceRes}]是否存在动画文件
		else
			filelist=`ls $dirPathAnimationSourceRes`
			for file in $filelist
			do
				if [ ! -f $file ];then
					ftEcho -ex 动画资源包含错误类型的文件[${file}]，请确认
				fi
			done
		fi

		dirPathAnimationTraget=/home/${rNameUser}/${dirNameAnimation}

		ftFileDirEdit -e false $dirPathAnimationTraget
		if [ -d $dirPathAnimationTraget ]||[ $? -eq   "3" ];then
			while true; do
			ftEcho -y ${ftName}的目标文件[${dirPathAnimationTraget}]夹非空，是否删除重建
			read -n1 sel
			case "$sel" in
				y|Y)
					rm -rf $dirPathAnimationTraget
					break;;
				n|N|q|Q)  exit;;
				*)
					ftEcho -e 错误的选择：$sel
					echo "输入n，q，离开"
					;;
			esac
			done
		fi
		mkdir  -p ${dirPathAnimationTraget}/${dirNamePart0}
		mkdir	  ${dirPathAnimationTraget}/${dirNamePart1}
		touch  ${dirPathAnimationTraget}/${fileNameDesc}

		#文件名去空格
		for loop in `ls -1 | tr ' '  '#'`
		do
			mv  "`echo $loop | sed 's/#/ /g' `"  "`echo $loop |sed 's/#//g' `"  2> /dev/null
		done

		local file1=${filelist[0]}
		local file1=${file1##*.}
		if [ $file1 != "jpg" ]&&[ $file1 != "png" ];then
			ftEcho -e 特殊格式[${file1}]动画资源文件，生成包大小可能异常
		fi

		#文件重命名
		index=0
		for file in $filelist
		do
			# echo “filename: ${file%.*}”
			# echo “extension: ${file##*.}”
			a=$((1000+$index))
			# 重命名图片，复制到part0
			fileNameLast=${a:1}.${file##*.}
			cp  $file  ${dirPathAnimationTraget}/${dirNamePart0}/${fileNameLast}
			index=`expr $index + 1`
		done
		# 复制最后一张图片到part1
		cp  ${dirPathAnimationTraget}/${dirNamePart0}/${fileNameLast} ${dirPathAnimationTraget}/${dirNamePart1}/${fileNameLast}

		# 输入分辨率,输入帧率,循环次数
		# 480           250   	15
		# 图片的宽    图片的高   每秒显示的帧数
		# p            	1        	0			part0
		# 标识符    循环的次数  阶段切换间隔时间 对应图片的目录
		# p 			0 			10 			part1
		# 标识符    循环的次数  阶段切换间隔时间 对应图片的目录
		local resolutionWidth
		local resolutionHeight
		local frameRate
		local cycleCount
		while [ -z "$resolutionWidth" ]||\
			[ -z "$resolutionHeight" ]||\
			[ -z "$frameRate" ]||\
			[ -z "$cycleCount" ]; do
				if [ -z "$resolutionWidth" ];then
					echo -en 请输入动画的宽:
					read resolutionWidth
			  	elif [ -z "$resolutionHeight" ]; then
					echo -en 请输入动画的高:
					read resolutionHeight
			  	elif [ -z "$frameRate" ]; then
					echo -en 请输入动画的帧率:
					read frameRate
			  	elif [ -z "$cycleCount" ]; then
					echo -en 请输入动画的循环次数:
					read cycleCount
				fi
		done

		#生成desc.txt
		echo -e "$resolutionWidth $resolutionHeight $frameRate\n\
p $cycleCount 0 part0\n\
p 0 0 part1" >${dirPathAnimationTraget}/${fileNameDesc}

		# 生成动画包
		ftBootAnimation create $dirPathAnimationTraget
		break;;
	 * )
		ftEcho -e "函数[${ftName}]参数错误，请查看函数使用示例"
		ftBootAnimation -h
		break;;
	esac
	done
}

ftGjh()
{
	local ftName=生成国际化所需的xml文件

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#
#	ftGjh 无参数
#=========================================================
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
	exit;; * ) break;; esac;done

	#耦合变量校验
	local valCount=0
	if(( $#!=$valCount ))||[ -z "$rDirPathUserHome" ];then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量def=$valCount]valCount=$# \
				[默认用户的home目录]rDirPathUserHome=$rDirPathUserHome \
				请查看下面说明:"
		ftGjh -h
		return
	fi

	local filePath=${rDirPathUserHome}/tools/xls2values/androidi18nBuilder.jar
	if [ -f $filePath ];then
		$filePath
	else
		ftEcho -e "[${ftName}]找不到[$filePath]"
	fi

}

ftLog()
{
	local ftName=初始化运行日志记录所需的参数
	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#
#	ftLog 无参数
#	初始化log记录所需的参数
#=========================================================
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
	exit;; * ) break;; esac;done

	#耦合变量校验
	local valCount=0
	if(( $#!=$valCount ))||[ -z "$rDirPathUserHome" ]\
				||[ -z "$rDirNameLog" ];then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量def=$valCount]valCount=$# \
				[默认用户的home目录]rDirPathUserHome=$rDirPathUserHome \
				[xbash的日志目录名]rDirNameLog=$rDirNameLog \
				请查看下面说明:"
		ftLog -h
		return
	fi

	#初始化命令log目录

	local diarNameCmdLog=null
	local parameterList=(xs xss -h vvv -v test restartadb)
	local fileNameLogBase=$(date -d "today" +"%y%m%d__%H%M%S")
	# 部分操作不记录日志
	for parameter in ${parameterList[*]}
	do
		if [ $parameter = $XCMD ]||[ $parameter = $rBaseShellParameter2 ];then
			export mFilePathLog=/dev/null
			return
		fi
	done

	if [ -z "$rBaseShellParameter2" ];then
		diarNameCmdLog=other
	else
		while true; do case $XCMD in
		xk)
			diarNameCmdLog=${XCMD}_ftKillPhoneAppByPackageName
			fileNameLogBase=${fileNameLogBase}_${rBaseShellParameter2}
			break;;
		*)
			diarNameCmdLog=${XCMD}_${rBaseShellParameter2}
			break;;
		esac;done
	fi

	dirPath=${rDirPathCmdsLog}/${diarNameCmdLog}

	#不存在新建命令log目录
	if [ ! -d "$dirPath" ];then
		mkdir $dirPath
	fi
	# 设定log路径
	export mFilePathLog=${dirPath}/${fileNameLogBase}.log
	touch $mFilePathLog
	# 清除高权限
	if [ `whoami` = "root" ]; then
		chmod 777 -R $dirPath
	fi
}

ftTest()
{
	local ftName=函数demo调试

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#
#	ftTest 任意参数
#=========================================================
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
	exit;; * ) break;; esac;done

	#耦合变量校验
	local dirNameCmdModuleTest=test
	local filePathCmdModuleTest=${rDirPathCmdsModule}/${dirNameCmdModuleTest}/${rFileNameCmdModuleTestBase}
	if [ ! -d "$rDirPathCmdsModule" ]||[ ! -f "$filePathCmdModuleTest" ];then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量def=$valCount]valCount=$# \
				filePathCmdModuleTest=$filePathCmdModuleTest \
				请查看下面说明:"
		ftTest -h
		return
	fi
	$filePathCmdModuleTest "$@"
}

ftBoot()
{
	local ftName=延时免密码关机重启
	local edittype=$1

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#	ftBoot 关机/重启 时间/秒
#	ftBoot shutdown/reboot 100
# 	xs 时间/秒 #制定时间后关机,不带时间则默认十秒
# 	xss 时间/秒 #制定时间后重启,不带时间则默认十秒
#=========================================================
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
	exit;; * ) break;; esac;done

	#耦合变量校验
	if [ -z "$rUserPwd" ]||[ -z "$edittype" ];then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量_def=1/2]valCount=$# \
				[默认用户密码]rUserPwd=$rUserPwd \
				[操作参数]edittype=$edittype \
				[时间/秒]rBaseShellParameter3=$rBaseShellParameter3 \
				请查看下面说明:"
		ftBoot -h
		return
	fi
	local waitLong=10
	if [ ! -z $rBaseShellParameter3 ];then
		if ( echo -n $rBaseShellParameter3 | grep -q -e "^[0-9][0-9]*$" );then
			waitLong=$rBaseShellParameter3
		else
			ftEcho -ea "函数[${ftName}]的参数错误 \
						请查看下面说明:"
			ftBoot -h
		fi
	fi


	while true; do
	case "$edittype" in
		shutdown )
		for i in `seq -w $waitLong -1 1`
		do
			echo -ne "\033[1;31m\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b将在${i}秒后关机，ctrl+c 取消\033[0m"
			sleep 1
		done
		echo -e "\b\b"
		echo $rUserPwd | sudo -S shutdown -h now
		break;;
		reboot)
		for i in `seq -w $waitLong -1 1`
		do
			echo -ne "\033[1;31m\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b将在${i}秒后重启，ctrl+c 取消\033[0m";
			sleep 1
		done
		echo -e "\b\b"
		echo $rUserPwd | sudo -S reboot
		break;;
		* )
			ftEcho -e 错误的选择：$sel
			echo "输入q，离开"
			;;
	esac
	done
}

ftSynchronous()
{
	local ftName=在不同设备间同步版本包
	local dirPathArray=$1
	local fileTypeList=$2

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#
#	ftSynchronous [dirPathArray] [fileTypeList]
#
# 	所有存储设备之间同步
#	ftSynchronous "${mCmdsModuleDataDevicesList[*]}" ".*\.info\|.*\.tgz\|.*\.notes\|.*\.md5s\|.*\.info"
#
# 	本次备份存储设备和指定存储设备之间同步
#	ftSynchronous "/media/data_xx $mDirPathStoreTarget" ".*\.info\|.*\.tgz\|.*\.notes\|.*\.md5s\|.*\.info"
#
# 	自定义 存储设备和存储设备之间同步
#	ftSynchronous "/media/data_xx /media/data_xx" ".*\.info\|.*\.tgz\|.*\.notes\|.*\.md5s\|.*\.info"
#未实现特性
# 	1 根据时间阀同步备份
#=========================================================
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
	exit;; * ) break;; esac;done

	#耦合变量校验
	local valCount=2
	if(( $#!=$valCount ))||[ -z "$dirPathArray" ]\
				||[ -z "$fileTypeList" ];then
		ftEcho -e "函数[${ftName}]的参数错误 \
[参数数量def=$valCount]valCount=$# \
[同步设备目录列表]dirPathArray=${dirPathArray[@]} \
[同步类型列表]fileTypeList=$fileTypeList \
请查看下面说明:"
		ftSynchronous -h
		return
	fi

	while true; do
	ftEcho -y 是否开始同步
	read -n1 sel
	case "$sel" in
		y | Y )
			ftEcho -bh 开始同步!

			for dirpath in ${dirPathArray[@]}
			do
			for dirpath2 in ${dirPathArray[@]}
			do
				if [ ${dirpath} != ${dirpath2} ]; then
					find $dirpath -regex "$fileTypeList" -exec cp {} -u -n -v -r $dirpath2 \;
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
}

ftPushAppByName()
{
	# ====================    设定流程      ============================

	# 确认ANDROID_PRODUCT_OUT非空,存在
	# 确认当前目录有效
	# 确认有对应模块名的apk文件存在
	# 校验adb状态
	# 确认adb权限
	# 确认手机有对应模块名的apk文件存在
	# 执行push操作

	local ftName="push Apk文件"
	local fileNameNewAppApkBase=$1
	local dirPathOut=$ANDROID_PRODUCT_OUT

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#
#	ftPushAppByName [AppName]
#	ftPushAppByName [filePathApk] [dirPath]
#	ftPushAppByName SystemUI
#	ftPushAppByName ~/xx.apk /system/data
#=========================================================
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
	exit;; * ) break;; esac;done

	#耦合变量校验
	local valCount=2
	if(( $#>$valCount ))||[ -z "$fileNameNewAppApkBase" ]\
			||(( $#==1 ))&&[ ! -d "$dirPathOut" ]\
			||(( $#==2 ))&&[ ! -f "$fileNameNewAppApkBase" ];then
		ftEcho -ea "[${ftName}]的参数错误 \
			[参数数量def=$valCount]valCount=$# \
			[目标app的名字]fileNameNewAppApkBase=$fileNameNewAppApkBase \
			[工程out目录]dirPathOut=$dirPathOut \
			请查看下面说明:"
		ftExample -h
		return
	fi
	dirList=(system/app system/priv-app)
	local filePathAppApk=null
	local filePathAppApkPhone=null

	#使用自定义apk
	if [ -f $fileNameNewAppApkBase ];then
		local filePath=$fileNameNewAppApkBase
		dirPathAppApkPhone=$2
	#不使用自定义apk
	else
		for dir in ${dirList[*]}
		do
			local filePath=${ANDROID_PRODUCT_OUT}/${dir}/${fileNameNewAppApkBase}/${fileNameNewAppApkBase}.apk
			if [ -f $filePath ];then
				filePathAppApk=$filePath
				dirPathAppApkPhone=${dir}/${fileNameNewAppApkBase}
				filePathAppApkPhone=${dirPathAppApkPhone}/${fileNameNewAppApkBase}.apk
			fi
		done
	fi

	if [ $filePath = "null" ];then
		ftEcho -ex "[$ftName]出现错误，文件[$filePathAppApk]不存在"
	fi

	# 多个adb设备id遍历
	# adb devices | while read line
	# do
	# 	if [ "$(echo $line | awk '{print $2}')" = "device" ];then
	# 		echo $(echo $line | awk '{print $1}')
	# 	fi
	# done
	#adb状态检测 ___当前没有设备或存在多个设备，状态都不是device
	if [ $(adb get-state) = "device" ];then
		#确定手机存在被覆盖的目标文件
		local statusDirAppApkPhone=$(adb shell ls $dirPathAppApkPhone)
		local statusFileAppApkPhone=$(adb shell ls $filePathAppApkPhone)
		if [[ $statusDirAppApkPhone =~ " No such file or directory" ]]\
			||(( $#==1 ))&&[[ $statusFileAppApkPhone =~ " No such file or directory" ]];then
			ftEcho -eax "[$ftName]出现错误，设备不存在 \
			dirPathAppApkPhone=$dirPathAppApkPhone \
			filePathAppApkPhone=$filePathAppApkPhone]"
		else
			# 确认adb权限
			local statusAdbRoot=$(adb root)
			# restarting adbd as root
			# adbd is already running as root
			# adbd cannot run as root in production builds
			local statusAdbRemount=$(adb remount)
			# remount succeeded
			# remount of system failed: Permission denied remount failed

			while [[ $statusAdbRoot =~ "cannot" ]]||[[ $statusAdbRemount =~ "failed" ]]; do
				echo statusAdbRoot=$statusAdbRoot
				echo statusAdbRemount=$statusAdbRemount
				ftEcho -e adb状态初始化失败,按y退出，按除y任意键重新尝试
				read -n1 sel
				case "$sel" in
					y | Y )	exit;;
					* )	statusAdbRoot=$(adb root)
						statusAdbRemount=$(adb remount)
						;;
				esac
			done
			adb push $filePathAppApk $dirPathAppApkPhone
		fi
	else
		ftEcho -e adb状态异常,请重新尝试
	fi
}

ftReduceFileList()
{
	local ftName=精简动画帧文件

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#
#	ftReduceFileList 保留的百分比 目录
#	ftReduceFileList 60 /home/xxxx/temp
#
#	ftReduceFileList 目录
#	ftReduceFileList /home/xxxx/temp
# 由于水平有限，实现对60%和50%之类的比例不敏感
#=========================================================
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
	exit;; * ) break;; esac;done

	if (( $#==2 ));then
		local percentage=$1
		local dirPathFileList=$2
	elif (( $#==1 ));then
		local dirPathFileList=$1
		local percentage=100
		echo -en "请输入保留的百分比:"
		read percentage
	fi
	local editType=del #surplus

	#耦合变量校验
	local valCount=2
	if(( $#!=$valCount ))||[ -z "$percentage" ]\
				||[ -z "$dirPathFileList" ]\
				||( ! echo -n $percentage | grep -q -e "^[0-9][0-9]*$")\
				||(( $percentage<0 ))\
				||(( $percentage>100 ))\
				||[ ! -d "$dirPathFileList" ];then
		ftEcho -ea "[${ftName}]的参数错误 \
			[参数数量def=$valCount]valCount=$# \
			[0<=*<=100]percentage=$percentage \
			[目标目录]dirPathFileList=$dirPathFileList \
			请查看下面说明:"
		ftReduceFileList -h
		return
	fi
	ftFileDirEdit -e false $dirPathFileList
	if [ $? -eq "2" ];then
		ftEcho -ex 空的资源目录，请确认[${dirPathFileList}]是否存在资源文件
	# else
	# 	for file in `ls $dirPathFileList`
	# 	do
	# 		if [ ! -f $file ];then
	# 			ftEcho -e 资源目录包含不是文件的东东：[${dirPathFileList}/${file}]
	# 		fi
	# 	done
	fi

	if (( $percentage>50 ));then
		percentage=`expr 100 - $percentage`
		editType=surplus
	fi
	continueThreshold=`expr 100 / $percentage`

	local dirNameFileListBase=${dirPathFileList##*/}
	local dirNameFileListBackup=${dirNameFileListBase}_bakup
	local dirPathFileListBackup=${dirPathFileList%/*}/${dirNameFileListBackup}
	if [ ! -d $dirPathFileListBackup ];then
		mkdir $dirPathFileListBackup
		cp -rf ${dirPathFileList}/*  $dirPathFileListBackup
	fi

	 fileList=`ls $dirPathFileList`
	index=0
	for file in $fileList
	do
		index=`expr $index + 1`
		# if (( `expr $index % $continueThreshold`== 0 ));then
		# 	if [ $editType = "del" ];then
		# 		echo del_file=$file
		# 	elif [ $editType = "surplus" ];then
		# 		continue;
		# 	fi
		# else
		# 	if [ $editType = "del" ];then
		# 		continue;
		# 	elif [ $editType = "surplus" ];then
		# 		echo del_file=$file
		# 	fi
		# fi
		if (( `expr $index % $continueThreshold`== 0 ));then
			if [ $editType = "surplus" ];then
				continue;
			fi
		elif [ $editType = "del" ];then
			continue;
		fi
		rm -f ${dirPathFileList}/$file
	done
}

ftReNameFile()
{
	local ftName=批量重命名文件
	# local extensionName=$1
	local dirPathFileList=$1
	local lengthFileName=$2
	lengthFileName=${lengthFileName:-'4'}

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#
#	不指定文件名长度默认为4
#	ftReNameFile 目录
#	ftReNameFile /home/xxxx/temp 
#	ftReNameFile 目录 修改后的文件长度
#	ftReNameFile /home/xxxx/temp 5
#=========================================================
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
	exit;; * ) break;; esac;done

	#耦合变量校验
	local valCount=2
	if(( $#>$valCount ))||[ ! -d "$dirPathFileList" ];then
		ftEcho -ea "[${ftName}]的参数错误 \
			[参数数量def=$valCount]valCount=$# \
			[修改后的文件长度]lengthFileName=$lengthFileName \
			[目标目录]dirPathFileList=$dirPathFileList \
			请查看下面说明:"
		ftReNameFile -h
		return
	fi
	ftFileDirEdit -e false $dirPathFileList
	if [ $? -eq "2" ];then
		ftEcho -ex 空的资源目录，请确认[${dirPathFileList}]是否存在资源文件
	fi
	fileList=`ls $dirPathFileList`

	local dirNameFileListRename=RenameFiles
	local dirPathFileListRename=${dirPathFileList}/${dirNameFileListRename}
	if [ -d $dirPathFileListRename ];then
		rm -rf $dirPathFileListRename
	fi
	mkdir $dirPathFileListRename
	index=0
	if [ ! -z $lengthFileName ];then
		lengthFileNameBase=1
		while (( $lengthFileName > 0  ))
		do
			lengthFileName=`expr $lengthFileName - 1`
			lengthFileNameBase=$(( $lengthFileNameBase * 10 ))
		done
	fi
	for file in $fileList
	do
		if [ $file == $dirNameFileListRename ];then
			continue
		fi
		fileNameBase=$((lengthFileNameBase+$index))
		cp -f ${dirPathFileList}/${file} ${dirPathFileListRename}/${fileNameBase:1}.${file##*.}
		index=`expr $index + 1`
	done
}

ftDevAvailableSpace()
{
	local ftName=设备可用空间
	local devDirPath=$1
	local isReturn=$2

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#
#	ftDevAvailableSpace [devDirPath] [[isReturn]]
#	ftDevAvailableSpace /media/test
#	ftDevAvailableSpace /media/test true
#=========================================================
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
	exit;; * ) break;; esac;done

	#耦合变量校验
	local valCount=2
	if (( $#>$valCount ))||[ -z "$devDirPath" ]\
				||[ -z "$rDirPathCmdsData" ];then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量def=$valCount]valCount=$# \
				[设备路径]devDirPath=$devDirPath \
				[xbash的data目录]rDirPathCmdsData=$rDirPathCmdsData \
				请查看下面说明:"
		ftDevAvailableSpace -h
	elif [ ! -d $devDirPath ];then
		ftEcho -ex "设备[$devDirPath]不存在"
	elif [ ! -d $rDirPathCmdsData ];then
		ftEcho -ex "目录[$rDirPathCmdsData]不存在"
	fi

	local filePathDevStatus=${rDirPathCmdsData}/devs_status
	local filePathTmpRootAvail=/tmp/tmp_root_avail

	if [ "${devDirPath:0:1}" = "/" ];then
		if [ ! -d ${devDirPath} ];then
			mkdir -p ${devDirPath}
		fi
	else
		pwd=`pwd`
		if [ ! -d "${pwd}/${devDirPath}" ];then
			mkdir -p ${pwd}/${devDirPath}
		fi
		devDirPath=${pwd}/${devDirPath}
	fi

	if [ -z $isReturn ]||[ $isReturn != "true" ];then
		df -h >$filePathDevStatus
	elif  $isReturn = "true" ];then
		df >$filePathDevStatus
	fi
	cat $filePathDevStatus | while read line
	do
		line_path=`echo ${line} | awk -F' ' '{print $6}'`
		line_avail=`echo ${line} | awk -F' ' '{print $4}'`
		 if [ "${line_path:0:1}" != "/" ]; then
			 continue
		 fi

		 if [ "${line_path}" = "/" ]; then
				root_avail=${line_avail}
			 #echo "root_avail:${root_avail}"
			 if [ -f $filePathTmpRootAvail ];then
				 rm $filePathTmpRootAvail
			 fi
			 echo ${root_avail} > $filePathTmpRootAvail
			 continue
		 fi

		path_length=${#line_path}
		if [ "${devDirPath:0:${path_length}}" = "${line_path}" ];then
			path_avail=${line_avail}
			if [ -f /tmp/tmp_path_avail ];then
				rm /tmp/tmp_path_avail
			fi
			echo ${path_avail} > /tmp/tmp_path_avail
			break
		fi
	done
	rm -f $filePathDevStatus

	if [ -f /tmp/tmp_path_avail ];then
		path_avail=`cat /tmp/tmp_path_avail`
		rm /tmp/tmp_path_avail
	fi
	if [ -f $filePathTmpRootAvail ];then
		root_avail=`cat $filePathTmpRootAvail`
		rm $filePathTmpRootAvail
	fi

	if [ -z ${path_avail} ];then
		 path_avail=${root_avail}
	fi

	local size
	if [ -z $isReturn ]||[ $isReturn != "true" ];then
		size=$path_avail
	elif  $isReturn = "true" ];then
		size=`expr $path_avail / 1024 `
	fi
	echo $size
}



ftGetKeyValueByBlockAndKey()
{
	local ftName=读取ini文件指定字段
	local filePath=$1
	local blockName=$2
	local keyName=$3

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#
#	ftGetKeyValueByBlockAndKey2 [文件] [块名] [键名]
#	value=$(ftGetKeyValueByBlockAndKey2 /temp/odbcinst.ini PostgreSQL Setup)
# 	value表示对应字段的值
#=========================================================
EOF
	exit 1;; * )break;; esac;done

	#耦合变量校验
	local valCount=3
	if(( $#!=$valCount ))||[ ! -f "$filePath" ]\
				||[ -z "$blockName" ]\
				||[ -z "$keyName" ];then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量def=$valCount]valCount=$# \
				filePath=$filePath \
				blockName=$blockName \
				keyName=$keyName \
				请查看下面说明:"
		ftGetKeyValueByBlockAndKey2 -h
		return
	fi

	begin_block=0
	end_block=0

	cat $filePath | while read line
	do
		if [ "X$line" = "X[$blockName]" ];then
			begin_block=1
			continue
		fi
		if [ $begin_block -eq 1 ];then
			end_block=$(echo $line | awk 'BEGIN{ret=0} /^\[.*\]$/{ret=1} END{print ret}')
			if [ $end_block -eq 1 ];then
				break
			fi

			need_ignore=$(echo $line | awk 'BEGIN{ret=0} /^#/{ret=1} /^$/{ret=1} END{print ret}')
			if [ $need_ignore -eq 1 ];then
				continue
			fi
			key=$(echo $line | awk -F= '{gsub(" |\t","",$1); print $1}')
			value=$(echo $line | awk -F= '{gsub(" |\t","",$2); print $2}')

			if [ "X$keyName" = "X$key" ];then
				echo $value
				break
			fi
		fi
	done
	return 0
}

ftSetKeyValueByBlockAndKey()
{
	local ftName=修改ini文件指定字段
	local filePath=$1
	local blockName=$2
	local keyName=$3
	local keyValue=$4

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#
#	ftSetKeyValueByBlockAndKey [文件] [块名] [键名] [键对应的值]
#	ftSetKeyValueByBlockAndKey /temp/odbcinst.ini PostgreSQL Setup 1232
#=========================================================
EOF
	exit 1;; * )break;; esac;done

	#耦合变量校验
	local valCount=4
	if(( $#!=$valCount ))||[ ! -f "$filePath" ]\
				||[ -z "$blockName" ]\
				||[ -z "$keyName" ]\
				||[ -z "$keyValue" ];then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量def=$valCount]valCount=$# \
				[目标ini文件路径]filePath=$filePath \
				[目标块TAG]blockName=$blockName \
				[目标Key]keyName=$keyName \
				[目标Key对应的Value]keyValue=$keyValue \
				请查看下面说明:"
		ftSetKeyValueByBlockAndKey2 -h
		return
	fi
	return`sed -i "/^\[$blockName\]/,/^\[/ {/^\[$blockName\]/b;/^\[/b;s/^$keyName*=.*/$keyName=$keyValue/g;}" $filePath`
}


function ftCheckIniConfigSyntax()
{
	#============ini文件模板=====================
	# # 注释１
	# [block1]
	# key1=val1

	# # 注释２
	# [block2]
	# key2=val2
	#===========================================

	local ftName=校验ini文件，确认文件有效
	local filePath=$1
	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#
#	ftCheckIniConfigSyntax [file path]
#	ftCheckIniConfigSyntax 123/config.ini
#=========================================================
EOF
	exit 1;; * )break;; esac;done

	#耦合变量校验
	local valCount=1
	if(( $#!=$valCount ))||[ ! -f "$filePath" ];then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量def=$valCount]valCount=$# \
				[目标ini文件路径]filePath=$filePath \
				请查看下面说明:"
		ftExample -h
		return
	fi

	ret=$(awk -F= 'BEGIN{valid=1}
	{
		#已经找到非法行,则一直略过处理
		if(valid == 0) next
		#忽略空行
		if(length($0) == 0) next
		#消除所有的空格
		gsub(" |\t","",$0)
		#检测是否是注释行
		head_char=substr($0,1,1)
		if (head_char != "#"){
			#不是字段=值 形式的检测是否是块名
			if( NF == 1){
				b=substr($0,1,1)
				len=length($0)
				e=substr($0,len,1)
				if (b != "[" || e != "]"){
					valid=0
				}
			}else if( NF == 2){
			#检测字段=值 的字段开头是否是[
				b=substr($0,1,1)
				if (b == "["){
					valid=0
				}
			}else{
			#存在多个=号分割的都非法
				valid=0
			}
		}
	}
	END{print valid}' $filePath)

	if [ $ret -eq 1 ];then
		return 0
	else
		return 2
	fi
}

ftUpdateHosts()
{
	local ftName=更新hosts
	local filePathHosts=/etc/hosts
	local urlCustomHosts=$1

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#使用默认hosts源
#	ftUpdateHosts 无参
#
#使用自定义hosts源
#	ftUpdateHosts [URL]
#	ftUpdateHosts https://raw.githubusercontent.com/racaljk/hosts/master/hosts
#=========================================================
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
	exit;; * ) break;; esac;done

	#耦合变量校验
	local valCount=1
	if (( $#>$valCount ))||[ ! -f "$filePathHosts" ]\
				||[ ! -d "$rDirPathCmdsData" ];then
		ftEcho -ea "[${ftName}]参数错误 \
			[参数数量def=$valCount]valCount=$# \
			[目标hosts配置文件路径，ubuntu默认]filePathHosts=$filePathHosts \
			[xbash的data目录]rDirPathCmdsData=rDirPathCmdsData \
			请查看下面说明:"
		ftUpdateHosts -h
		return
	fi

	# 下载hosts文件
	local url="https://raw.githubusercontent.com/racaljk/hosts/master/hosts"
	local netTool=wget
	local fileNameHostsNew="hosts.new"
	local filePathHostsNew=${rDirPathCmdsData}/${fileNameHostsNew}
	if [ ! -z "$urlCustomHosts" ];then
		url=$urlCustomHosts
	fi
	"$netTool" -q "$url" -O "$filePathHostsNew"

	# 对比hosts文件，确定有无更新
	local hostsVersionBase="Last updated:"
	local hostsVersionOld=$(cat $filePathHosts|grep "$hostsVersionBase"|sed s/[[:space:]]//g)
	local hostsVersionNew=$(cat $filePathHostsNew|grep "$hostsVersionBase"|sed s/[[:space:]]//g)
	if [ ! -f $filePathHostsNew ]||[ "$hostsVersionOld" = "$hostsVersionNew" ];then
		rm -f $filePathHostsNew
		ftEcho -ex hosts没有更新,将退出
	else
		local fileNameHostsBase=hosts.base
		local filePathHostsBase=${rDirPathCmdsData}/${fileNameHostsBase}
		if [ ! -f "$filePathHostsBase" ];then
			echo "127.0.0.1	localhost
127.0.1.1	$rNameUser

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

#added by $rNameUser" >$filePathHostsBase
		fi
		# 文件拼接
		local fileNameHostsAllNew=hosts
		local filePathHostsAllNew=${rDirPathCmdsData}/${fileNameHostsAllNew}
		cat $filePathHostsBase $filePathHostsNew>$filePathHostsAllNew
		# 覆盖文件
		echo $rUserPwd | sudo -S mv $filePathHosts ${filePathHosts}_${hostsVersionOld}
		echo $rUserPwd | sudo -S mv $filePathHostsAllNew $filePathHosts
	fi
}



#===================    非通用实现[高度耦合]    ==========================
ftCopySprdPacFileList()
{
	local ftName=自动复制sprd的pac相关文件
	# ANDROID_BUILD_TOP=/media/data/ptkfier/code/sp7731c/code
	# ANDROID_PRODUCT_OUT=/media/data/ptkfier/code/sp7731c/code/out/target/product/sp7731c_1h10_32v4
	local dirPathCode=$ANDROID_BUILD_TOP
	local dirPathOut=$ANDROID_PRODUCT_OUT

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#
#	ftCopySprdPacFileList 无参
#=========================================================
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
	exit;; * ) break;; esac;done

	#耦合变量校验
	local valCount=0
	if(( $#!=$valCount ))||[ ! -d "$dirPathCode" ]\
			||[ ! -d "$dirPathOut" ];then
		ftEcho -ea "[${ftName}]的参数错误 \
			[参数数量def=$valCount]valCount=$# \
			[工程根目录]dirPathCode=$dirPathCode \
			[工程out目录]dirPathOut=$dirPathOut \
			请查看下面说明:"
		ftCopySprdPacFileList -h
		return
	fi
	cd $ANDROID_BUILD_TOP
	local branchName=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
	local keyVersion="findPreference(KEY_BUILD_NUMBER).setSummary(\""
	local filePathDeviceInfoSettings=${dirPathCode}/packages/apps/Settings/src/com/android/settings/DeviceInfoSettings.java
	local versionName=$(cat $filePathDeviceInfoSettings|grep $keyVersion)
	versionName=${versionName/$keyVersion/}
	versionName=${versionName/\");/}
	versionName=$(echo $versionName |sed s/[[:space:]]//g)
	local dirPathCodeRoot=${dirPathCode%/*}
	local dirPathCodeRootPacres=${dirPathCodeRoot}/res
	local dirNameBranchVersion=${branchName}____${versionName}____$(date -d "today" +"%y%m%d[%H:%M]")
	local dirPathBranchVersion=${dirPathCodeRootPacres}/${dirNameBranchVersion}
	local fileNameList=(boot.img \
			cache.img \
			fdl1.bin \
			fdl2.bin \
			persist.img \
			prodnv.img \
			recovery.img \
			sysinfo.img \
			system.img \
			u-boot.bin \
			u-boot-spl-16k.bin \
			userdata.img\
			SC7720_UMS.xml)
	if [ -d "$dirPathBranchVersion" ];then
		rm -rf $dirPathBranchVersion
	fi
	mkdir $dirPathBranchVersion

	for fileName in ${fileNameList[*]}
	do
		filePath=${dirPathOut}/${fileName}
		if [ -f $filePath ];then
			cp -v -f $filePath $dirPathBranchVersion
		else
			ftEcho -ex 文件[$filePath]不存在
			rm -rf $dirPathBranchVersion
		fi
	done
}

ftBackupOutsByMove()
{
	local ftName=移动备份out
	# ANDROID_BUILD_TOP=/media/data/ptkfier/code/sp7731c/code
	# ANDROID_PRODUCT_OUT=/media/data/ptkfier/code/sp7731c/code/out/target/product/sp7731c_1h10_32v4
	local dirPathCode=$ANDROID_BUILD_TOP
	local dirPathOut=$ANDROID_PRODUCT_OUT

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#
#	ftBackupOutsByMove 无参
#=========================================================
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
	exit;; * ) break;; esac;done

	#耦合变量校验
	local valCount=0
	if(( $#!=$valCount ))||[ ! -d "$dirPathCode" ]\
			||[ ! -d "$dirPathOut" ];then
		ftEcho -ea "[${ftName}]的参数错误 \
			[参数数量def=$valCount]valCount=$# \
			[工程根目录]dirPathCode=$dirPathCode \
			[工程out目录]dirPathOut=$dirPathOut \
			请查看下面说明:"
		ftBackupOutsByMove -h
		return
	fi
	cd $ANDROID_BUILD_TOP
	local branchName=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
	local keyVersion="findPreference(KEY_BUILD_NUMBER).setSummary(\""
	local filePathDeviceInfoSettings=${dirPathCode}/packages/apps/Settings/src/com/android/settings/DeviceInfoSettings.java
	local versionName=$(cat $filePathDeviceInfoSettings|grep $keyVersion)
	versionName=${versionName/$keyVersion/}
	versionName=${versionName/\");/}
	versionName=$(echo $versionName |sed s/[[:space:]]//g)
	local dirPathCodeRoot=${dirPathCode%/*}
	local dirPathCodeRootOuts=${dirPathCodeRoot}/outs
	local dirNameBranchVersion=${branchName}____${versionName}_$(date -d "today" +"%y%m%d[%H:%M]")
	local dirPathOutBranchVersion=${dirPathCodeRootOuts}/${dirNameBranchVersion}
	if [ ! -d "$dirPathOutBranchVersion" ];then
		mv out/ $dirPathOutBranchVersion
	else
		ftEcho -ex 存在相同out
	fi
}


ftJdkVersionTempSwitch()
{
	local ftName=临时切换jdk版本
	local jdkVersion=$1

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#
#	ftJdkVersionTempSwitch [verison]
#	ftJdkVersionTempSwitch 1.6/7
#=========================================================
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
	exit;; * ) break;; esac;done

	#耦合变量校验
	local valCount=1
	if(( $#!=$valCount ))||[ ! -z "$jdkVersion" ];then
		ftEcho -ea "[${ftName}]的参数错误 \
			[参数数量def=$valCount]valCount=$# \
			[目标jdk版本]jdkVersion=$jdkVersion \
			请查看下面说明:"
		ftJdkVersionTempSwitch -h
		return
	fi

	while true; do case "$1" in
	1.6 | 6)	
		jdk2=/home/wgx/tools/jdk/1.6.038
		break;;
	1.7 | 7)	
		jdk2=/usr/lib/jvm/java-7-openjdk-amd64
		break;;
	 * ) break;; esac;done

	export JAVA_HOME=$jdk2
	export JRE_HOME=${JAVA_HOME}/jre
	export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
	export PATH=${JAVA_HOME}/bin:$PATH
	java -version

	
}

ftYKSwitch()
{
	local ftName=切换永恒星和康龙配置
	local type=$1
	# ANDROID_BUILD_TOP=/media/data/ptkfier/code/sp7731c/code
	local dirPathCode=$ANDROID_BUILD_TOP

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#
#	ftYKSwitch yhx/kl
#=========================================================
EOF
	if [ $XMODULE = "env" ];then
		return
	fi
	exit;; * ) break;; esac;done

	#耦合变量校验
	local valCount=1
	if(( $#!=$valCount ))||[ -z "$type" ]\
			||[ ! -d "$dirPathCode" ];then
		ftEcho -ea "[${ftName}]的参数错误 \
			[参数数量def=$valCount]valCount=$# \
			[操作参数]type=$type \
			[工程根目录]dirPathCode=$dirPathCode \
			请查看下面说明:"
		ftYKSwitch -h
		return
	fi

	local filePathTraget=${dirPathCode}/vendor/sprd/modules/libcamera/oem2v0/src/sensor_cfg.c
	local tagYhx=//#define\ CAMERA_USE_KANGLONG_GC2365
	local tagKl=#define\ CAMERA_USE_KANGLONG_GC2365

	while true; do case "$type" in
	yhx )
		sed -i "s:$tagKl:$tagYhx:g" $filePathTraget
		break;;
	kl )
		 sed -i "s:$tagYhx:$tagKl:g" $filePathTraget
		break;;
	* )	ftEcho -ex 错误参数[type=$type]
		break;; 
	esac;done
}
