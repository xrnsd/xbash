
dir1=/media/xrnsd_d_data1/W14.16.4/idh.code/

ft1()
{
cd $dir1
source build/envsetup.sh
mmm  packages/apps/Launcher4
adb install -r  ${dir1}out/target/product/generic/system/app/launcher4.apk
cd ~
}

ft2()
{
cd /media/xrnsd_d_data1/edit/
for var in `ls`; do mv -f "$var" `echo "$var" |sed 's/....$/_wgx.png/'`; done
}

create_menu1(){
	    echo -e "\t1.替换前缀"
	    echo -e "\t2.替换后缀"
	}
ft3()
{
    str1='s/'
    str2='$/'
    str3='/'
    str4='s/^'
    strPath=/media/xrnsd_d_data1/temp/edit
        echo -en "\t\t替换长度:"
	    read  length1
	    echo -en "\t\t替换字符串:"
	    read  strNew
		for((i=1;i<=$length1;i++));
			do
				strLength=${strLength}.;
			done
		cd $strPath
	    create_menu1

	 while true; do
	    echo -en "\t\t请选择:"
	    read -n1 option1
	    case $option1 in
	    1)   for var in `ls`; do mv -f "$var" `echo "$var" |sed ${str4}${strLength}${str3}${strNew}${str3}` ; done; break;;
	    2)   for var in `ls`; do mv -f "$var" `echo "$var" |sed ${str1}${strLength}${str2}${strNew}${str3}` ; done; break;;
	    *)  echo "请输入1,2.............";;
	    esac
	done
}

ft4()
{

PS3='Choose your favorite vegetable: ' # 设置提示符字串.

echo

select vegetable in "beans" "carrots" "potatoes" "onions" "rutabagas"
do
  echo
  echo "Your favorite veggie is $vegetable."
  echo "Yuck!"
  echo
  break  # 如果这里没有 'break' 会发生什么?
done
exit 0
}
ft66()
{
strBackTime=$(date -d "today" +"%Y%m%d_%H%M%S")
	appName=$1
	file1=/media/xrnsd_d_data1/backup/apps/7715/${appName}.ftremarks
	echo $file1
	if [ -f $file1  ];
				then
				touch $file1
				fi
    	echo -en "\t\t输入版本${strBackTime}\t的备注:"
    	read -n1 option1
    	option1 =${strBackTime}==${option1}
    	option1 >> $file1
}
ft8()
{
echo "sdcweds wew wqedwq wcw   wqedwe  " |tr -s "*"
}
ft9()
{
	#file name
	local file_name_default=remark
	local file_name_view=$(date -d "today" +"%Y%m%d_%H%M%S")
	#folder name
	local folder_remarks=remarks
	#directory
	local  dir_backup_root=/media/xrnsd_d_data1/test

	#path
	local path_default=${dir_backup_root}/${file_name_default}
	if [ ! -f $path_default ];
				then
				touch $path_default
				fi
	echo -en "备份完成，请输入版本备注:\t"
	 read str_remark
	 str_remark=${file_name_view}':='$str_remark
	sed -i "1i$str_remark" $path_default
}
    ftRenameFiles()
    {
    	    str1='s/'
	    str2='$/'
	    str3='/'
	    str4='s/^'
	    strPath=/home/ptkfier/download/854
		echo -en "\t\t替换长度:"
		    read  length1
		    echo -en "\t\t替换字符串:"
		    read  strNew
			for((i=1;i<=$length1;i++));
				do
					strLength=${strLength}.;
				done
			cd $strPath
		    create_menu1

		 while true; do
		    echo -en "\t\t请选择:"
		    read -n1 option1
		    case $option1 in
		    1)  echo ; for var in `ls`; do mv -f "$var" `echo "$var" |sed ${str4}${strLength}${str3}${strNew}${str3}` ; done; break;;
		    2)  echo   ;for var in `ls`; do mv -f "$var" `echo "$var" |sed ${str1}${strLength}${str2}${strNew}${str3}` ; done; break;;
		    *)  echo "请输入1,2.............";;
		    esac
		done;echo
    }
    msg1()
    {
	whiptail --title "消息框测试" --msgbox "来，点一个" 10 60
    }
    msg2()
    {
	if (whiptail --title "Test Yes/No Box" --yesno "Choose between Yes and No." 10 60) then
	    echo "You chose Yes. Exit status was $?."
	else
	    echo "You chose No. Exit status was $?."
	fi
    }
    msg3()
    {
    	if (whiptail --title "Test Yes/No Box" --yes-button "好的" --no-button "不要"  --yesno "Which do you like better?" 10 60) then
	    echo "You chose Skittles Exit status was $?."
	else
	    echo "You chose M&M's. Exit status was $?."
	fi
    }
    msg4()
    {
	PET=$(whiptail --title "Test Free-form Input Box" --inputbox "What is your pet's name?" 10 60 Wigglebutt 3>&1 1>&2 2>&3)

	exitstatus=$?
	if [ $exitstatus = 0 ]; then
	    echo "Your pet name is:" $PET
	else
	    echo "You chose Cancel."
	fi
    }
    #msg5
    #{

	# {
	#    for ((i = 0 ; i <= 100 ; i+=20)); do
	#	sleep 1
	#	echo $i
	#    done
	#} | whiptail --gauge "Please wait while installing" 6 60 0
    #}
    fttestqw()
    {
	touch >~/temp/hj.conf
    	if (whiptail --title "编译环境配置" --yes-button "MTK" --no-button "SPRD"  --yesno "请选择你需要的编译环境" 10 60) 		then
	    	echo "0" | update-alternatives --config java >~/temp/hj.conf
	    	echo "0" | update-alternatives --config javac >~/temp/hj.conf
	    	echo "当前环境为MTK"
	else
	    	echo "1" | update-alternatives --config java >~/temp/hj.conf
	    	echo "1" | update-alternatives --config javac >~/temp/hj.conf
	    	echo "当前环境为SPRD"
	fi
    	rm -rf ~/temp/hj.conf
    }
   msg6()
    {
	#!/bin/bash
	OPTION=$(whiptail --menu "编译环境配置" 15 60 4 \
	"1" "MTK" \
	"2" "SPRD"   3>&1 1>&2 2>&3)

	exitstatus=$?
	if [ $exitstatus = 0 ]; then

		if [ ! -d ~/temp ];then
		   mkdir ~/temp
		fi
		if [ ! -f ~/temp ];then
		   touch ~/temp/hj.conf
		fi
		while true; do
		    case $OPTION in
		    "1")
		    	#echo "0" | update-alternatives --config java >~/temp/hj.conf
		    	#echo "0" | update-alternatives --config javac >~/temp/hj.conf
		    	echo "已修改当前环境为：MTK"; break;;
		    "2")
		    	#echo "1" | update-alternatives --config java >~/temp/hj.conf
		    	#echo "1" | update-alternatives --config javac >~/temp/hj.conf
		    	echo "已修改当前环境为：SPRD"; break;;
		    *)  echo "错误的选择，请查看脚本";exit;;
		    esac
		done
		rm -rf ~/temp/hj.conf
	else
	    echo "已退出环境配置"
	fi
    }

    fttest2()
    {
    		local count=1
    		adb reboot;
    		while true; do
    			if [ $? == 1 ];then
		   		echo 第${count}次重启;let count=count+1;sleep 90;adb reboot;
			fi
		done
    }
    fttest3()
    {

    	echo ========还原的源文件列表=============
	filelist=`ls /media/data_self/other/edit|grep '.png'`
	#文件数量获取
	#filenumbers= ls -l /media/data_self/backup/os |grep '.tgz'|grep "^-"|wc -l
	index=0;
	cd /media/data_self/other/edit
	for file in $filelist
	do
		file_old=$file
		filelist2[$index]=$file
		index=`expr $index + 1`
		file=${file//./_}
		file=${file//_png/.png}
		echo $file
		mv $file_old $file
	done
    }
    fttest4()
    {
    	echo ========任务列表===========
    	cat ~/cmds/notepad/event.list
    	echo -en 是否打开文件?
	read index
	if [ ${#index} == 0 ]; then
	    gedit ~/cmds/notepad/event.list
      	fi
    }
    extract() {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1     ;;
        *.tar.gz)    tar xzf $1     ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar e $1     ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xf $1      ;;
        *.tbz2)      tar xjf $1     ;;
        *.tgz)       tar xzf $1     ;;
        *.zip)       unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}
	ftAdbTouchTest()
	{
	min=1
	max=10000
	while [ $min -le $max ]
	do
	    echo 第${min}次滑动
	    min=`expr $min + 1`
	    			#  x	y   x	y
	    adb shell input swipe 0 900 350 900
	    adb shell input swipe 1000 900 650 900
	done
	}

	ftReadFingerprintList()
	{
		#echo 'x@2w4ea' | sudo -S adb kill-server
		adb root
		adb remount
		echo 指纹列表：
		adb shell ls data/data/com.android.settings/files
	}
    #fttest4
    #ftRenameFiles
    #ftAdbTouchTest
    #ftReadFingerprintList
    ft1()
    {
    	monkeypid=`adb shell "ps" | awk '/com.android.commands.monkey/{print $2}'`
    	adb shell kill $monkeypid
    }
	ft12()
	{
	min=1
	max=1000000000
	while [ $min -le $max ]
	do
	    echo 第${min}次点击
	    min=`expr $min + 1`
	    			#  x	y   x	y
	    #adb shell input swipe 0 900 350 900
	    #adb shell input swipe 1000 900 650 900
	    adb shell input tap 540 1000
	done
	}
	ftPullLogPhone()
	{
	logSDirPhone=storage/emulated/0/mtklog
	logSDirSD=/storage/sdcard1/mtklog
	logTPatchEmui=/home/xian-hp-u16/log/m400/m400_0301_emui3.1_ud
	logTPatchBase=/home/xian-hp-u16/log/m400/m400_0301_base_ud
	adb root
	adb remount
	adb pull $logSDirPhone $logTPatchBase
	}

	ftPullLogSd()
	{
	logSDirPhone=storage/emulated/0/mtklog
	logSDirSD=/storage/sdcard1/mtklog
	logTPatchEmui=/home/xian-hp-u16/log/m400/m400_0301_emui3.1_ud
	logTPatchBase=/home/xian-hp-u16/log/m400/m400_0301_base_ud
	adb root
	adb remount
	adb pull $logSDirSD $logTPatchEmui
	}
    	ftDump()
    	{
	pid=`adb shell "ps" | awk '/com.android.launcher3/{print $2}'`
    	#adb shell kill $pid
    	adb root;adb shell debuggerd -b $pid;adb pull /data/tombstones ~/temp
	#ps |grep process name  根据process名字，获取 pid。
	#debuggerd -b <pid>即可打印出堆栈。
	#或者debuggerd <pid> 会直接生成tombstone文件到/data/tombstones目录。
    	}
    	ftDocker()
    	{

		uuid=`ls -l /dev/disk/by-uuid/ |grep sda1`
		echo
    		echo $uuid
    	}
	fttt1()
	{
	 	PortID=5037
		PortID_Pid=`lsof -i:$PortID | grep $PortID | awk '{print $2}'`
	    	if [ "$PortID_Pid" = "" ];then
		   	echo 端口5037未被占用
			else echo 'x@2w4ea' | sudo -S kill $PortID_Pid
		fi
	}
	ftdtd2()
	{
	 	PortID=u0
		PortID_Pid=`adb shell ps | grep $PortID | awk '{print $9}'`
	    	echo $PortID_Pid
	}
	ftReboots()
	{
	min=1
	max=100000


	#phoneLogDir=/storage/emulated/0/edllog
	#resultInfo=`adb shell ls $phoneLogDir`
	#resultInfo=`echo $resultInfo|grep "No such file or directory"`
	#if [ "$resultInfo" != "" ];then
	#	adb shell mkdir $phoneLogDir
    	#fi

	while [ $min -le $max ]
	do
		#adb状态检测
		adbStatus=`adb get-state`
		if [ $adbStatus =  "device" ];then



		    #查看剩余空间
		    freeSize=`adb shell df /mnt/shell/emulated |grep "/mnt/shell/emulated"| awk '{print $4}'`
		    freeSize=${freeSize//M/};
		    freeSize=`echo ${freeSize%.*}`
		    if [[ $freeSize -gt  100 ]];then
		    	echo 第${min}次重启
		    	adb reboot
		    	min=`expr $min + 1`
		    	sleep 110
		    fi

		    #echo m400_0425_eng_new >/sys/class/android_usb/android0/iSerial
		    #过滤5秒log
		    #sleep 15 && kill 0 &
		    #errorInfo=`adb logcat|grep Read-only`
	    	    #if [ "$errorInfo" != "" ];then
	    	    #	echo $errorInfo
		    #fi
	    	else
		    	echo adb状态异常&&break
	    	fi
	done
	}
#	ftReboots




dev1=/media/data_self
dev2=/media/data_out
dev3=/media/data_code


dir_backup=backup

dir_backup_type=os


dir1=${db4}${d1}${db1}        #/home/xian-hp-u16/backup/
dir2=${da5}${db1}             #/media/xrnsd_hdd1/backup/os
dir3=/home/xian-hp-u16/log/









ft111()
{
	create_menu1

	while true; do
	echo -en "\t\t请选择磁盘:"
	read -n1 option1
	echo
	case $option1 in
	1)  if [ ! -d $dir1 ];
			   then echo 目录不存在已创建
			   mkdir -p $dir1
				fi
				strBackDirectory=$dir1; break;;
	2)    if [ -d $dir2 ];
				then
				strBackDirectory=$dir2
				else
				echo --------环境错误：检查备份磁盘是否挂载------
				strBackDirectory=$dir1
				fi ; break;;
	3)  read mypath
	       if [ -d $mypath ];
				then
				strBackDirectory=$mypath
				else
				echo --------路径错误----------
				strBackDirectory=$dir1
				fi
				mydir="zdy"; break;;
	0)  echo "结束备份"; exit;;

	*)  echo "请输入1,2.............";
	    echo "按０离开";;
	esac
	done

}



	backup_target_dir()
	{
	 local devDir=/media
	echo ======== 备份的目标列表=============
	dirList=`ls $devDir`
	index=0;
	for dir in $dirList
	do
		echo [${index}]  ${dir}
		dirList2[$index]=$dir
		index=`expr $index + 1`
	done
	echo -en "请选择:"
	read -n1 dir
	echo
	devTarget=${dirList2[$dir]}
	devTargetDir=${devDir}/${devTarget}
	echo $devTargetDir
	echo
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
				echo 新建备注存储目录
    	fi

		local path_default=${dir_backup_root}/${file_name_default}
		local path_note=${dir_backup_note}/${file_name_note}

		if [ ! -f $path_default ]; then
			touch $path_default;echo "【 create by wgx 】">$path_default
		fi

		#bug文件行数
		lines=$(sed -n '$=' $path_default)
		lines=$((lines/2))
		let lines=lines+1


		local strVersion="[ "${lines}" ] "${version_name}

		echo $version_name
		echo -en "请输入上面版本相应的备注:"
		read note
		#写入备注总文件
		sed -i "1i ==========================================" $path_default
		sed -i "1i $strVersion           $note" $path_default
		#写入版本独立备注
		echo $note>$path_note

	}

	ftReadNote()
	{
		local dir_backup_root=${1}
		local dir_backup_note=${dir_backup_root}/.notes
		local version_name=${2}
		local file_name_default=${version_name}.notelist
		local file_name_note=${version_name}.note
		local path_default=${dir_backup_root}/${file_name_default}
		local path_note=${dir_backup_note}/${file_name_note}

		note=`cat $path_note`
		echo ${version_name}"     --------------------------    "${note}
		echo
		
		
		
			cnt=1
	   for var in `ls`; 
	   do
	   filename = ${var%.*}
	   extension=${var##*.} 
	   if  [ $cnt -gt 9 ] ; then
		mv $var ${cnt}.${extension}
	else
		mv $var 0${cnt}.${extension}
	fi
	   let "cnt=$cnt+1" 
	done;
	
	}

	    
	GetSoftwareID()
{

  defaultSel=
  while :
  do
	echo -en "请选择存放备份文件的设备:"
	read -n1 answers
      
      if [ ${#answers} == 0 ]; then
	  answers="00000"
	  elif [ ${answers} == "q" ]; then
	  	exit
      fi
      
      InputLen=${#answers}
      if [ $InputLen -gt 4 ]; then
	  RET=`expr match $answers "[0-9]*$"`
	  if [ ${RET} -gt 0 ]; then
	     echo $answers
	      break;
	  fi
      fi
      ftPrintError $answers
  done
}
fteee()
{
	  while :
	  do
		echo -en "请选择存放备份文件的设备:"
		read -n1 dir
		  if [ ${#dir} == 0 ]; then
		  	devTargetDir=${dirList2[$dir]}
			break;
		  elif [ ${dir} == "q" ]; then
		  	exit
		  elif [ "$dir" -gt 0 ] 2>/dev/null ;then 
		  	devTarget=${dirList2[$dir]}
			devTargetDir=${devDir}/${devTarget}
			break;
		  fi
	  done
}
	fttt()
	{
	
	#=================== example=============================
	#
	#		fttt [type] [isCreate] [path]
	#		fttt f true /home/xian-hp-u16/cmds/test.sh
	#		echo $?
	#=========================================================
	
		ftName=路径合法性校验
		type=$1
		isCreate=$2
		path=$3
		if [ $type = "f" ];then
		
			if [ -f $path ];then
				return 1
			elif [ $isCreate = "true" ];then
				touch $path
				return 1
			else
				return 0
			fi
			
		elif [ $type = "d" ];then
		
			if [ -d $path ];then
				return 1
			elif [ $isCreate = "true" ];then
				mkdir -p $path
				return 1
			else
				return 0
			fi
			
		else
			echo 函数[[${ftName}]]调用时使用了错误参数
			return 0
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
	
	if [ ! -d $dirPathBackupRoot ]; then
		echo 系统信息相关操作失败
	  	exit
	else
		if [ ! -d $dirPathBackupInfo ]; then
			#mkdir $dirPathBackupInfo
			echo $dirPathBackupInfo
			echo 根系统信息记录位置不存在，已建立
		fi	
		if [ ! -d $dirPathBackupInfoVersion ]; then
			#mkdir $dirPathBackupInfoVersion
			echo $dirPathBackupInfo
			echo 版本信息记录位置不存在，已建立
		fi
		if [ ${typeEdit} == "add" ]; then
			echo $infoHwCpu 		>$filePathVersionCpu
			echo $infoHwMainboard 	>$filePathVersionMainboard
			echo $infoHwSystem 		>$filePathVersionSystem
			echo $infoHw32x64 		>$filePathVersion32x64
		
		elif [ ${typeEdit} == "check" ]; then
			local infoHwCpuVersion=$(sed s/[[:space:]]//g $filePathVersionCpu)
			local infoHwMainboardVersion=$(sed s/[[:space:]]//g $filePathVersionMainboard)
			local infoHwSystemVersion=$(sed s/[[:space:]]//g $filePathVersionSystem)
			local infoHw32x64Version=$(sed s/[[:space:]]//g $filePathVersion32x64)

			if [[ $infoHwCpuVersion != $infoHwCpu ]];then
			echo Version=$infoHwCpuVersion
			echo baseion=$infoHwCpu
				ftSel CPU
			fi
			if [[ "$infoHwMainboardVersion" != "$infoHwMainboard" ]]; then
			echo Version= $infoHwMainboardVersion
			echo baseion=$infoHwMainboard
				ftSel 主板
		  	fi
			if [[ "$infoHwSystemVersion" != "$infoHwSystem" ]]; then
			echo Version= $infoHwSystemVersion
			echo baseion=$infoHwSystem
				echo 系统版本不一致，将自动退出
				exit
		  	fi
			if [[ "$infoHw32x64Version" != "$infoHw32x64" ]]; then
			echo Version= $infoHw32x64Version
			echo baseion=$infoHw32x64
				echo 系统版本的位数不一致，将自动退出
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
			 * ) echo  ftPrintError $sel ;echo "不忽略请输入n，q"
		   esac
		done
	}
	
	ftAddOrCheckSystemHwSwInfo add /home/wgx/temp 22
