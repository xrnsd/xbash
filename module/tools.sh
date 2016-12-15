#!/bin/bash
#####---------------------  说明  ---------------------------#########
# 默认规划中，不可在此文件中出现，不被函数包裹的调用，定义
# 人话，这里只放函数
#####---------------------流程函数---------------------------#########
ftExample()
{
	local ftName=函数模板
	# 1 耦合变量校验[耦合变量包含全局变量，输入参数，输入变量]
	# 3 提供可执行前提说明
	# 4 提供执行流程说明
	# 5 提供使用示例
	# -eq           //等于
	# -ne           //不等于
	# -gt            //大于
	# -lt            //小于
	# ge            //大于等于
	# le            //小于等于

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
	#=================== ${ftName}的使用示例=============
	#
	#	ftExample 无参
	#	ftExample [example]
	#	ftExample xxxx
	#=========================================================
EOF
	exit;; * )break;; esac;done

	#耦合变量校验
	local valCount=1
	if(( $#!=$valCount ))||[ -z "$example1" ]\
				||[ -z "$example2" ];then
		ftEcho -ea "[${ftName}]的参数错误 \
			[参数数量def=$valCount]valCount=$# \
			example1=$example1 \
			example2=$example2 \
			请查看下面说明:"
		ftExample -h
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
cmdName=$cmdName \n\
rCmdsPermissionBase=${rCmdsPermissionBase[@]} \n\
rCmdsPermissionRoot=${rCmdsPermissionRoot[@]} \n\
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
	"test")		ftTest "$@" ;break;;
	"shutdown")	ftBoot	shutdown ;break;;
	"reboot")	ftBoot	reboot ;break;;
	"help")		ftReadMe $rBaseShellParameter3	;break;;
	"clean_data_garbage")	ftCleanDataGarbage ; break;;
	v | V | -v |-V)	ftVersion;break;;
	vvv)	ftEcho -b xbash;		ftVersion
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
					"mtk_flashtool")		ftMtkFlashTool ; break;;
					"restartadb")		ftRestartAdb; break;;
					"monkey")		ftKillPhoneAppByPackageName com.android.commands.monkey; break;;
					"systemui")		ftKillPhoneAppByPackageName com.android.systemui; break;;
					"launcher")		ftKillPhoneAppByPackageName com.android.launcher3; break;;
					"bootanim")		ftBootAnimation $rBaseShellParameter3 $(pwd);break;;
					"gjh")			ftGjh;break;;
					# "gjh")			ftEcho -e [$rBaseShellParameter2]已关闭，请修改脚本打开
					# 			ftReadMe $rBaseShellParameter2
					# 			#java -jar ${rDirPathUserHome}/tools/xls2values/androidi18nBuilder.jar;
					# 			break;;
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
	while true; do
		case "$1" in
		a | A | -a |-A)
	cat<<EOF
=========================================================================
	命令	--- 参数/命令说明
	|// 使用格式
	|-- 参数	 ---------------- [参数权限] ----	参数说明
=========================================================================
xb ----- 系统维护
	|// xb ×××××
	|
	|-- backup	---------------- [root] ------	备份系统
	|-- restore	---------------- [root] ------	还原系统
xc ----- 常规自定义命令和扩展
	|// xc ×××××
	|
	|-- test	--------------------------	shell测试
	|-- clean_data_garbage				清空回收站
	|-- restartadb	--------------------------	重启adb服务
	|-- bootanim	--------------------------	制作开关机动画包
	|-- v 						自定义命令版本
	|-- help	--------------------------	查看自定义命令说明
	|-- vvv						系统环境关键参数查看
	|-- gjh		--------------------------	生成国际化所需的xml文件
xk ----- 关闭手机指定进程
	|// xk ×××××
	|
	|-- monkey	-----------------------------	关闭monkey
	|-- systemui	-----------------------------	关闭systemui
	|-- 应用包名	-----------------------------	关闭指定app
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
xh ----- 查看具体命令说明
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
exit;;
	xc |test | clean_data_garbage|restartadb | help | gjh)ftEcho -g;
cat<<EOF
xc	----- 常规自定义命令和扩展
	|// xc ×××××
	|
	|-- test	--------------------------	shell测试
	|-- clean_data_garbage				清空回收站
	|-- restartadb	--------------------------	重启adb服务
	|-- v 						自定义命令版本
	|-- help	--------------------------	查看自定义命令说明
	|-- vvv						系统环境关键参数查看
	|-- gjh		--------------------------	生成国际化所需的xml文件
EOF
exit;;
	xb | backup | restore)ftEcho -g;
cat<<EOF
xb	----- 系统维护
	|// xb ×××××
	|
	|-- backup	---------------- [root] ------	备份系统
	|-- restore	---------------- [root] ------	还原系统
EOF
exit;;
xk | monkey | systemui)ftEcho -g;
cat<<EOF
xk	----- 关闭手机指定进程
	|// xk ×××××
	|
	|-- monkey	-------------------------------	关闭monkey
	|-- systemui	-----------------------------	关闭systemui
	|-- 应用包名	-----------------------------	关闭指定app
EOF
exit;;
	xt)
cat<<EOF
xt ----- 检测shell脚本，语法检测和测试运行
	|// xt 脚本文件名
EOF
exit;;
	xh)
cat<<EOF
xh ----- 查看具体命令说明
	|// xh 命令名
EOF
exit;;
	*)ftReadMe -a;break;;
	esac
done
}

ftVersion()
{
	echo \"Xrnsd extensions to bash\" $rXbashVersion
}




#####---------------------工具函数---------------------------#########
ftKillPhoneAppByPackageName()
{
	local ftName=根据应用包名杀死应用
	local packageName=$1

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
	#=================== ${ftName}的使用示例=============
	#
	#	ftKillPhoneAppByPackageName [packageName]
	#	ftKillPhoneAppByPackageName com.android.settings
	#=========================================================
EOF
	exit;; * )break;; esac;done

	#耦合变量校验
	local valCount=1
	if(( $#!=$valCount ))||[ -z "$packageName" ];then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量def=$valCount]valCount=$# \
				packageName=$packageName \
				请查看下面说明:"
		  ftKillPhoneAppByPackageName -h
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
	if(( $#!=$valCount ))||[ -z "$mUserPwd" ];then
		ftEcho -eax "函数[${ftName}]的参数错误 \
			[参数数量def=$valCount]valCount=$# \
			mUserPwd=$mUserPwd"
	fi

	local ftName=重启adb sever
	echo $mUserPwd | sudo -S adb kill-server
	echo
	sleep 2
	echo $mUserPwd | sudo -S adb start-server
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
	exit;; * )break;; esac;done

	#耦合变量校验
	local valCount=1
	if (( $#>$valCount ))||[ -z "$rDirPathUserHome" ]\
				||[ -z "$rNameUser" ];then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量def=$valCount]valCount=$# \
				rDirPathUserHome=$rDirPathUserHome \
				rNameUser=$rNameUser \
				请查看下面说明:"
		  ftInitDevicesList -h
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
	local ftName=清空回收站
	ftInitDevicesList

	#耦合变量校验
	local valCount=0
	if(( $#!=$valCount ))||[ -z "$mCmdsModuleDataDevicesList" ];then
		ftEcho -ex "函数[${ftName}]的参数错误 \
[参数数量def=$valCount]valCount=$# \
mCmdsModuleDataDevicesList=${mCmdsModuleDataDevicesList[@]}"
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

	#耦合变量校验
	local valCount=0
	if(( $#!=$valCount ))||[ -z "$tempDirPath" ]\
				||[ -z "$rDirPathTools" ];then
		ftEcho -eax "函数[${ftName}]的参数错误 \
				[参数数量def=$valCount]valCount=$# \
				tempDirPath=$tempDirPath \
				rDirPathTools=$rDirPathTools"
	fi
	local toolDirPath=${rDirPathTools}/sp_flash_tool_v5.1548

	cd $toolDirPath&&
	echo "$mUserPwd" | sudo -S ./flash_tool&&
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
	exit;; * )break;; esac;done

	#耦合变量校验
	local valCount=3
	if(( $#!=$valCount ))||[ -z "$type" ]\
						||[ -z "$isCreate" ]\
						||[ -z "$path" ];then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量def=$valCount]valCount=$# \
				type=$type \
				isCreate=$isCreate \
				path=$path \
				请查看下面说明:"
		  ftFileDirEdit -h
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
	exit;; * )break;; esac;done

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

ftEcho()
{
#=================== example=============================
#
#	 ftEcho [option] [Content]
#	 ftEcho e 错误的选择1
#	\033[47;30m  47背景色配置 30前景色配置
#=========================================================
	local ftName=工具信息提示
	option=$1
	option=${option:-'未制定显示信息'}
	valList=$@
	#除第一个参数外的所有参数列表，可正常打印数组
	content="${valList[@]/$option/}"

	while true; do
	case $option in
	#错误信息显示，对字符串的缩进敏感
	e | E | -e | -E)		echo -e "\033[1;31m$content\033[0m"; break;;
	#错误信息显示，显示退出，对字符串的缩进敏感
	ex | EX | -ex | -EX)	echo -e "\033[1;31m$content\033[0m";sleep 3;exit;;
	#执行信息，对字符串的缩进敏感
	s | S | -s | -S)		echo;echo -e "\033[42;37m$content\033[0m"; break;;
	# 标题，不换行，对字符串的缩进敏感
	b | B| -b | -B)		echo -e "\e[41;33;1m =========== $content ============= \e[0m"; break;;
	# 标题，换行，对字符串的缩进敏感
	bh | BH | -bh | -BH)	echo;echo -e "\e[41;33;1m =========== $content ============= \e[0m";echo; break;;
	#特定信息显示,y/n，对字符串的缩进敏感
	y | Y | -y | -Y)		echo;echo -en "${content}[y/n]"; break;;
	#错误信息多行显示,对字符串的缩进不敏感,包含数组会显示不正常
	ea| EA | -ea | -EA)	for val in ${content[@]}
				do
					echo -e "\033[1;31m$val\033[0m";
				done
				break;;
	#错误信息多行显示，对字符串的缩进不敏感,包含数组会显示不正常
	eax| EAX | -eax | -EAX)	for val in ${content[@]}
				do
					echo -e "\033[1;31m$val\033[0m";
				done
				exit;;
	# 特定信息显示,命令说明的格式
	g | G | -g | -G)cat<<EOF
=========================================================================
命令	--- 参数/命令说明
	|// 使用格式
	|-- 参数	 ---------------- [参数权限] ----	参数说明
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
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== 函数${ftName}的使用示例============
#	请进入动画资源目录后执行xc bootanim xxx
#	ftBootAnimation [edittype] [path]
#	生成bootanimation2.zip,进入已new处理或解压的文件夹后可运行
#	ftBootAnimation create /home/xxxx/test/bootanimation2
#	初始化生成bootanimation2.zip所需要的东东，然后生成动画包
#	ftBootAnimation new /home/xxxx/test/bootanimation2
#============================================================
EOF
	exit;; * )break;; esac;done

	#耦合变量校验
	local valCount=2
	if(( $#!=$valCount ))||[ -z "$dirPathAnimation" ];then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量def=$valCount]valCount=$# \
				dirPathAnimation=$dirPathAnimation \
				请查看下面说明:"
		ftBootAnimation -h
	fi

	while true; do case "$typeEdit" in
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
			* )
				ftEcho -e 错误的选择：$sel
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
		ftBootAnimation -h;; esac;done
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
	exit;; * )break;; esac;done

	#耦合变量校验
	local valCount=0
	if(( $#!=$valCount ))||[ -z "$rDirPathUserHome" ];then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量def=$valCount]valCount=$# \
				rDirPathUserHome=$rDirPathUserHome \
				请查看下面说明:"
		ftGjh -h
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
	exit;; * )break;; esac;done

	#耦合变量校验
	local valCount=0
	if(( $#!=$valCount ))||[ -z "$rDirPathUserHome" ]\
				||[ -z "$rDirNameLog" ];then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量def=$valCount]valCount=$# \
				rDirPathUserHome=$rDirPathUserHome \
				rDirNameLog=$rDirNameLog \
				请查看下面说明:"
		ftLog -h
	fi
	#初始化命令log目录

	local diarNameCmdLog=null
	if [ -z "$rBaseShellParameter2" ];then
		diarNameCmdLog=other
	else
		while true; do case $XCMD in
		xk)
			diarNameCmdLog=${XCMD}_ftKillPhoneAppByPackageName
			break;;
		*)
			diarNameCmdLog=${XCMD}_${rBaseShellParameter2}
			break;;
		esac;done
	fi

	dirPath=${rDirPathUserHome}${rDirNameLog}/${diarNameCmdLog}

	#不存在新建命令log目录
	if [ ! -d "$dirPath" ];then
		mkdir $dirPath
	fi

	export mFilePathLog=${dirPath}/$(date -d "today" +"%y%m%d_%H:%M:%S").log
	touch $mFilePathLog

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
	exit;; * )break;; esac;done

	#耦合变量校验
	local dirNameCmdModuleTest=test
	local filePathCmdModuleTest=${rDirPathCmdsModule}/${dirNameCmdModuleTest}/${rFileNameCmdModuleTestBase}
	if [ -z "$rDirPathCmdsModule" ]\
			||[ ! -f "$filePathCmdModuleTest" ];then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量def=$valCount]valCount=$# \
				filePathCmdModuleTest=$filePathCmdModuleTest \
				请查看下面说明:"
		ftTest -h
	fi

	$filePathCmdModuleTest "$@"
}

ftBoot()
{
	local ftName=函数demo调试
	local edittype=$1
	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例=============
#	ftBoot 关机/重启 时间/秒
#	ftBoot shutdown/reboot 100
#=========================================================
EOF
	exit;; * )break;; esac;done

	#耦合变量校验
	if ( ! echo -n $rBaseShellParameter3 | grep -q -e "^[0-9][0-9]*$" )\
		||[ -z "$mUserPwd" ]\
		||[ -z "$edittype" ];then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量_def=1/2]valCount=$# \
				mUserPwd=$mUserPwd \
				edittype=$edittype \
				[时间/秒]rBaseShellParameter3=$rBaseShellParameter3 \
				请查看下面说明:"
		ftBoot -h
	fi

	local waitLong=10
	if [ ! -z "$rBaseShellParameter3" ];then
		waitLong=$rBaseShellParameter3
	fi

	while true; do
	case "$edittype" in
		shutdown )
		for i in `seq -w $waitLong -1 1`
		do
			echo -ne "\033[1;31m\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b将在${i}秒后关机，ctrl+c 取消\033[0m"
			sleep 1
		done
		echo -e "\b\b"
		echo $mUserPwd | sudo -S shutdown -h now
		break;;
		reboot)
		for i in `seq -w $waitLong -1 1`
		do
			echo -ne "\033[1;31m\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b将在${i}秒后重启，ctrl+c 取消\033[0m";
			sleep 1
		done
		echo -e "\b\b"
		echo $mUserPwd | sudo -S reboot
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
	exit;; * )break;; esac;done

	#耦合变量校验
	local valCount=2
	if(( $#!=$valCount ))||[ -z "$dirPathArray" ]\
				||[ -z "$fileTypeList" ];then
		ftEcho -e "函数[${ftName}]的参数错误 \
[参数数量def=$valCount]valCount=$# \
synchronousType=$synchronousType \
dirPathArray=${dirPathArray[@]} \
fileTypeList=$fileTypeList \
请查看下面说明:"
		ftSynchronous -h
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
	exit;; * )break;; esac;done

	#耦合变量校验
	local valCount=2
	if (( $#>$valCount ))||[ -z "$devDirPath" ]\
				||[ -z "$rDirPathCmdsData" ];then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量def=$valCount]valCount=$# \
				devDirPath=$devDirPath \
				rDirPathCmdsData=$rDirPathCmdsData \
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
	#	ftSetKeyValueByBlockAndKey2 [文件] [块名] [键名] [键对应的值]
	#	ftSetKeyValueByBlockAndKey2 /temp/odbcinst.ini PostgreSQL Setup 1232
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
				filePath=$filePath \
				blockName=$blockName \
				keyName=$keyName \
				keyValue=$keyValue \
				请查看下面说明:"
		ftSetKeyValueByBlockAndKey2 -h
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
	#	ftCheckIniConfigSyntax2 [file path]
	#	ftCheckIniConfigSyntax2 123/config.ini
	#=========================================================
EOF
	exit 1;; * )break;; esac;done

	#耦合变量校验
	local valCount=1
	if(( $#!=$valCount ))||[ ! -f "$filePath" ];then
		ftEcho -ea "函数[${ftName}]的参数错误 \
				[参数数量def=$valCount]valCount=$# \
				filePath=$filePath \
				请查看下面说明:"
		ftExample -h
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