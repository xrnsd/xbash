#!/bin/bash
#####---------------------  说明  ---------------------------#########
# 不可在此文件中出现不被函数包裹的调用或定义
# 人话，这里只放函数
# complete -W "example example" ftExample
#####---------------------示例函数---------------------------#########
ftExample()
{
    local ftEffect=函数模板_nodisplay

    while true; do case "$1" in
    e | -e |--env) cat<<EOF
#===================[   ${ftEffect}   ]的使用环境说明=============
#
#    工具依赖包 example
#=========================================================
EOF
      return;;
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftExample 无参
#    ftExample [example]
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #环境校验
    if [ -z `which example` ]||[ -z `which example` ];then
        ftExample -e
        return
    fi
    #耦合校验
    local valCount=1
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$example1" ];then    errorContent="${errorContent}\\n[示例1]example1=$example1" ; fi
    if [ -z "$example2" ];then    errorContent="${errorContent}\\n[示例2]example2=$example2" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftExample -h
            return
    fi
}

#####---------------------工具函数---------------------------#########
ftMain()
{
    local ftEffect=早期工具主入口
    while true; do
    case $1 in
    "clean_data_garbage")    ftCleanDataGarbage
                break;;
    test)     ftTest "$@"
                break;;
    -v | --version )        echo \"Xrnsd extensions to bash\" $rXbashVersion
                break;;
    -h)    ftReadMe -a
                break;;
    ft | -ft ) ftReadAllFt | column -t
                break;;
    vvv | -vvv)            ftEcho -b xbash;        echo \"Xrnsd extensions to bash\" $rXbashVersion
                ftEcho -b java;        java -version
                ftEcho -b gcc;        gcc -v
                break;;
    restartadb)    ftRestartAdb
                break;;
    *)    ftEcho -e "命令[${XCMD}]参数=[$1]错误，请查看命令使用示例";ftReadMe $XCMD; break;;
    esac
    done
}

ftReadAllFt()
{
        local ftEffect=显示tools下所有实现说明_nodisplay

        local key="local ftEffect="
        for effectName in $(cat ~/${dirNameXbash}/module/tools.sh |grep '^ft')
        do
            effectDescription=$(cat ~/${dirNameXbash}/module/tools.sh |grep  -C 3 $effectName|grep "$key")
            effectDescription=${effectDescription//$key/}
            effectDescription=$(echo $effectDescription |sed s/[[:space:]]//g)
            if [[ ${effectDescription: -9} = "nodisplay" ]];then
                continue;
            fi
            effectName=${effectName//()/}
            #echo "$effectName $effectDescription"

            printf "%40s    " $effectName;echo $effectDescription
        done
}

ftReadMe()
{
    local ftEffect=工具命令使用说明_nodisplay
    while true; do
        case "$1" in
    a | A | -a |-A)
    cat<<EOF
=========================================================
简写命令说明 [只封装了部分实现]
=========================================================
命令 ---- 参数/命令说明
    |// 使用格式
    |  参数  ----------------- [参数权限] ----  参数说明
=========================================================
xb ----- 系统维护
    |// xb ×××××
    |
    |  backup  ---------------- [root] --------  备份系统
    |  restore  --------------- [root] --------  还原系统
    |
xc ----- 常规自定义命令和扩展
    |// xc ×××××
    |
    |  v  -------------------------------------  自定义命令版本
    |  vvv  -----------------------------------  系统环境关键参数查看
    |  help                                      查看自定义命令说明
    |  test  ----------------------------------  shell测试
    |  restartadb                                重启adb服务
    |  clean_data_garbage  --------------------  快速清空回收站
    |
xk ----- 关闭手机指定进程
    |// xk ×××××
    |
    |  monkey  --------------------------------  关闭monkey
    |  systemui                                  关闭systemui
    |  应用包名  ------------------------------  关闭指定app
    |
xl ----- 过滤 android 含有tag的所有等级的log
    |// xl tag
    |
xle ---- 过滤 android 含有tag的E级log
    |// xle tag
    |
xbh ---- 根据标签过滤命令历史
    |// xbh 标签
    |
==============================================================
=======                     无参部分                 =========
==============================================================

xgl ----- 简单查看最近15次git log
xr ------ 重新加载xbash配置文件
xd ------ mtk下载工具
xu ------ 打开xbash配置
.9 ------ 打开.9工具
xs ------ 关机
xss ----- 重启

EOF
    if [ "$XMODULE" = "env" ];then    return ; fi
exit;;
    esac
done
}

ftKillPhoneAppByPackageName()
{
    local ftEffect=kill掉包名为packageName的应用
    local packageName=$1

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftKillPhoneAppByPackageName [packageName]
#    ftKillPhoneAppByPackageName com.android.settings
#=========================================================
EOF

    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    local valCount=1
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$packageName" ];then    errorContent="${errorContent}\\n[应用包名]packageName=$packageName" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftKillPhoneAppByPackageName -h
            return
    fi

    #adb连接状态检测
    adb wait-for-device
    local adbStatus=$(adb get-state)
    if [ "$adbStatus" != "device" ];then
        ftEcho -e "adb连接状态[$adbStatus]异常,请重新尝试"
        return
    fi
    #确定包存在
    if [ ! -z "$(adb shell pm list packages|grep $packageName)" ];then
        adb root
        adb remount
        pid=`adb shell ps | grep $packageName | awk '{print $2}'`
        adb shell kill $pid
    else
        ftEcho -e 包名[${packageName}]不存在，请确认
        while [ ! -n "$(adb shell pm list packages|grep $packageName)" ]; do
            ftEcho -y 是否重新开始
            read -n 1 sel
            case "$sel" in
                y | Y )
                    ftKillPhoneAppByPackageName $packageName
                    break;;
                * )if [ "$XMODULE" = "env" ];then    return ; fi
                    exit;;
        esac
        done
    fi
}

ftRestartAdb()
{
    local ftEffect=重启adb sever

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftRestartAdb [无参]
#=========================================================
EOF

    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    local valCount=0
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$rUserPwd" ];then    errorContent="${errorContent}\\n[默认用户密码]rUserPwd=$rUserPwd" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -eax "$errorContent \\n请查看下面说明:"
            ftRestartAdb -h
            return
    fi
    echo $rUserPwd | sudo -S echo test >/dev/null
    echo $rUserPwd | sudo -S adb kill-server >/dev/null
    echo
    echo "server kill ......"
    sleep 2
    echo $rUserPwd | sudo -S adb start-server >/dev/null
    echo "server start ......"
    adb devices
}

ftInitDevicesList()
{
    local ftEffect=初始化存储设备的列表
    local devNameDirPathList=`df -lh | awk '{print $1}'`
    local devMountDirPathList=(`df -lh | awk '{print $6}'`)
    # 设备最小可用空间，小于则视为无效.单位M
    local devMinAvailableSpace=${1:-'0'}
    devMinAvailableSpace=$(echo $devMinAvailableSpace | tr '[A-Z]' '[a-z]')
    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftInitDevicesList [devMinAvailableSpace 单位默认为MB]
#    ftInitDevicesList 4096M
#    ftInitDevicesList 4096G
#    ftInitDevicesList 409600K
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    local devMinAvailableSpaceTemp=$devMinAvailableSpace
    devMinAvailableSpaceTemp=${devMinAvailableSpaceTemp//g/}
    devMinAvailableSpaceTemp=${devMinAvailableSpaceTemp//m/}
    devMinAvailableSpaceTemp=${devMinAvailableSpaceTemp//k/}
    devMinAvailableSpaceTemp=${devMinAvailableSpaceTemp//b/}
    local valCount=1
    local errorContent=
    if (( $#>$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$rNameUser" ];then    errorContent="${errorContent}\\n[默认用户名]rNameUser=$rNameUser" ; fi
    if [ -z "$rDirPathUserHome" ];then    errorContent="${errorContent}\\n[默认用户的home目录]rDirPathUserHome=$rDirPathUserHome" ; fi
    if ( ! echo -n $devMinAvailableSpaceTemp | grep -q -e "^[0-9][0-9]*$" );then    errorContent="${errorContent}\\n[可用空间限制]devMinAvailableSpace=$devMinAvailableSpace" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftInitDevicesList -h
            return
    fi

    local indexDevMount=0
    local indexDevName=0
    local dirPathHome=(${rDirPathUserHome/$rNameUser\//$rNameUser})
    local sizeHome=$(ftDevAvailableSpace $dirPathHome true)

    if [[ $devMinAvailableSpace =~ "g" ]]||[[ $devMinAvailableSpace =~ "gb" ]];then
            devMinAvailableSpace=${devMinAvailableSpace//g/}
            devMinAvailableSpace=$(( devMinAvailableSpace * 1024 ))

    elif [[ $devMinAvailableSpace =~ "m" ]]||[[ $devMinAvailableSpace =~ "mb" ]];then
            devMinAvailableSpace=${devMinAvailableSpace//m/}

    elif [[ $devMinAvailableSpace =~ "k" ]]||[[ $devMinAvailableSpace =~ "kb" ]];then
            devMinAvailableSpace=${devMinAvailableSpace//kb/}
            devMinAvailableSpace=${devMinAvailableSpace//k/}
            let devMinAvailableSpace=devMinAvailableSpace/1024
    fi

    unset mCmdsModuleDataDevicesList
    if (($sizeHome>=$devMinAvailableSpace));then
        mCmdsModuleDataDevicesList=$dirPathHome
        indexDevMount=1;
    fi
    #开始记录设备文件
    for dir in ${devNameDirPathList[*]}
    do
            devMountDirPath=${devMountDirPathList[indexDevName]}
            if [[ $dir =~ "/dev/s" ]]&&[[ $devMountDirPath != "/" ]];then
                    sizeTemp=$(ftDevAvailableSpace $devMountDirPath true)
                    # 确定目录已挂载,设备可用空间大小符合限制
                    if mountpoint -q $devMountDirPath&&(($sizeTemp>=$devMinAvailableSpace));then
                        mCmdsModuleDataDevicesList[$indexDevMount]=$devMountDirPath
                        indexDevMount=`expr $indexDevMount + 1`
                    fi
            fi
            indexDevName=`expr $indexDevName + 1`
    done
    export mCmdsModuleDataDevicesList
}

ftCleanDataGarbage()
{
    local ftEffect=清空回收站
    ftInitDevicesList

    while true; do case "$1" in
    e | -e |--env) cat<<EOF
#===================[   ${ftEffect}   ]的使用环境说明=============
#
#    禁止在高权限下运行,转化普通用户后，再次尝试
#=========================================================
EOF
      return;;
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftCleanDataGarbage [无参]
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #环境校验
    if [ `whoami` != $rNameUser ]||[ "$(whoami)" = "root" ]; then
        ftCleanDataGarbage -e
        return
    fi
    #耦合校验
    local valCount=0
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$mCmdsModuleDataDevicesList" ];then    errorContent="${errorContent}\\n[被清空回收站的设备的目录列表]mCmdsModuleDataDevicesList=${mCmdsModuleDataDevicesList[@]}" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftCleanDataGarbage -h
            return
    fi

    local dirPathLocal=$(pwd)
    for dirDev in ${mCmdsModuleDataDevicesList[*]}
    do
         local dir=null
        if [ -d ${dirDev}/.Trash-1000 ];then
            dir=${dirDev}/.Trash-1000
        elif [ -d ${dirDev}/.local/share/Trash ];then
            dir=${dirDev}/.local/share/Trash
        fi
        if [ -d $dir ];then
            cd $dir

            mkdir empty
            rsync --delete-before -d -a -H -v --progress --stats empty/ files/
            rm -rf files/*
            rm -r empty

        fi
    done
    cd $dirPathLocal
}

ftMtkFlashTool()
{
    local ftEffect=mtk下载工具
    local tempDirPath=`pwd`
    local toolDirPath=${rDirPathTools}/sp_flash_tool_v5.1612.00.100
    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftMtkFlashTool 无参
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    local valCount=0
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$rDirPathTools" ];then    errorContent="${errorContent}\\n[mtk下载工具存放目录为空]rDirPathTools=$rDirPathTools" ; fi
    if [ ! -d "$toolDirPath" ];then    errorContent="${errorContent}\\n[mtk下载工具路径不存在]toolDirPath=$toolDirPath" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftMtkFlashTool -h
            return
    fi

    cd $toolDirPath&&
    echo "$rUserPwd" | sudo -S ${rDirPathTools}/sp_flash_tool_v5.1612.00.100/flash_tool
    cd $tempDirPath
}

ftFileDirEdit()
{
    local ftEffect=路径合法性校验
    type=$1
    isCreate=$2
    path=$3

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftFileDirEdit [type] [isCreate] [path]
#
#    文件存在，创建，返回1
#    ftFileDirEdit -f true /home/xian-hp-u16/cmds/${rFileNameCmdModuleTestBase}
#
#    文件夹存在，创建，返回1
#    ftFileDirEdit -d true /home/xian-hp-u16/cmds/${rFileNameCmdModuleTestBase}
#
#    判断文件夹是否为空，空，返回2 非空，返回3,非文件夹，返回4
#    ftFileDirEdit -e false /home/xian-hp-u16/cmds
#    echo $?
#===============================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    local valCount=3
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$type" ];then    errorContent="${errorContent}\\n[操作参数]type=$type" ; fi
    if [ -z "$isCreate" ];then    errorContent="${errorContent}\\n[是否新建]isCreate=$isCreate" ; fi
    if [ -z "$path" ];then    errorContent="${path}\\n[被操作的目录或路径]path=$path" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
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
            ftEcho -e "函数[${ftEffect}]参数错误，请查看函数使用示例"
            ftFileDirEdit -h
            ;;
    esac
    done
}

ftEcho()
{
    local ftEffect=工具信息提示
    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftEcho        内容    # 直接显示内容
#    ftEcho    -b    内容    # 标题，不换行，对字符串的缩进敏感
#    ftEcho    -bh    内容    # 标题，换行，对字符串的缩进敏感
#    ftEcho    -e    内容    # 错误信息显示，对字符串的缩进敏感
#    ftEcho    -ex    内容    # 错误信息显示，显示完退出，对字符串的缩进敏感
#    ftEcho    -ea    内容    # 错误信息多行显示，对字符串的缩进不敏感,包含内置数组会显示不正常
#    ftEcho    -eax    内容    # 错误信息多行显示，对字符串的缩进不敏感,包含内置数组会显示不正常，显示完退出
#    ftEcho    -y    内容    # 特定信息显示,y/n，对字符串的缩进敏感
#    ftEcho    -s    内容    # 执行信息，对字符串的缩进敏感
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    local valCount=1
    local errorContent=
    if (( $#<$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -z "$errorContent" ];then
            echo -e "$errorContent \\n请查看下面说明:"
            ftEcho -h
            return
    fi

    option=$1
    option=${option:-'未制定显示信息'}
    valList=$@
    if [ ${#valList[@]} -eq 2 ];then
        content=$(content |sed s/[[:space:]]//g)
    else
        #除第一个参数外的所有参数列表，可正常打印数组
        content="${valList[@]/$option/}"
        content=${content/ /}
    fi
    while true; do
    case $option in

    e | E | -e | -E)        echo -e "\033[1;31m$content\033[0m"; break;;
    ex | EX | -ex | -EX)    echo -e "\033[1;31m$content\033[0m"
                sleep 3
                if [ "$XMODULE" = "env" ];then    return ; fi
                exit;;
    s | S | -s | -S)        echo -e "\033[1;33m$content\033[0m"; break;;
    b | B| -b | -B)        echo -e "\e[41;33;1m =========== $content ============= \e[0m"; break;;
    bh | BH | -bh | -BH)    echo;echo -e "\e[41;33;1m =========== $content ============= \e[0m";echo; break;;
    y | Y | -y | -Y)        echo;echo -en "${content}[y/n]"; break;;
    ea| EA | -ea | -EA)    for val in ${content[@]}
                do
                    echo -e "\033[1;31m$val\033[0m";
                done
                break;;

    eax| EAX | -eax | -EAX)    for val in ${content[@]}
                do
                    echo -e "\033[1;31m$val\033[0m";
                done
                exit;;
    # 特定信息显示,命令说明的格式
    g | G | -g | -G)
    ftEcho -s “命令 参数 -h 可查看参数具体说明”
    cat<<EOF
=========================================================================
命令    --- 参数/命令说明
    |// 使用格式
    |  参数     ---------------- [参数权限] ----    参数说明
=========================================================================
EOF
break;;
    * )    echo $option ;break;;
    esac
    done
}

ftTiming()
{
    local ftEffect=脚本操作耗时记录

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
        hour=$time5时
    else
        hour=""
    fi
    if [ "$time4" -ne "0" ];then
        minute=$time4分
    else
        minute=""
    fi
    if [ "$time3" -ne "0" ];then
        second=$time3秒
    else
        second=""
    fi
    if [ "$time3" -eq "0" ]&&[ "$time4" -eq "0" ] &&[ "$time5" -eq "0" ];then
        ftEcho -s 1秒没到就结束了
    else
        ftEcho -s "本技能耗时${hour}${minute}${second}  !"
    fi
    mTimingStart=
}

complete -W "create new" ftBootAnimation
ftBootAnimation()
{
    local ftEffect=生成开关机动画
    local typeEdit=$1
    local dirPathAnimation=$2
    local dirPathBase=$(pwd)

    while true; do case "$1" in    h | H |-h | -H)
        cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#    请进入动画资源目录后执行xc bootanim xxx
#    ftBootAnimation [edittype] [path]
#
#    直接生成动画包，不做其他操作，不确认资源文件是否有效
#    ftBootAnimation create /home/xxxx/test/bootanimation2
#
#    初始化生成bootanimation2.zip所需要的东东，然后生成动画包
#    ftBootAnimation new /home/xxxx/test/bootanimation2
#============================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;; esac;done

    #耦合校验
    local valCount=2
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$dirPathAnimation" ];then    errorContent="${errorContent}\\n[动画资源目录]dirPathAnimation=$dirPathAnimation" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
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
            ftEcho -e "函数[${ftEffect}]运行出现错误，请查看函数"
            echo dirNamePackageName=$dirNamePackageName
            echo fileConfig=$fileConfig
        fi

        cd $dirPathAnimation
        zip -r -0 ${dirNamePackageName} */* ${fileConfig} >/dev/null
        cd $dirPathBase

        while true; do
        ftEcho -y 已生成${dirNamePackageName}，是否清尾
        read -n 1 sel
        case "$sel" in
            y | Y )
                local filePath=/home/${rNameUser}/${dirNamePackageName}
                if [ -f $filePath ];then
                    while true; do
                    echo
                    ftEcho -y 有旧的${dirNamePackageName}，是否覆盖
                    read -n 1 sel
                    case "$sel" in
                        y | Y )    break;;
                        n | N)    mv $filePath /home/${rNameUser}/${dirNamePackageName/.zip/_old.zip};break;;
                        q |Q)    exit;;
                        * ) ftEcho -e 错误的选择：$sel
                            echo "输入q，离开" ;;
                    esac
                    done
                fi
                mv ${dirPathAnimation}/${dirNamePackageName} $filePath&&
                rm -rf $dirPathAnimation
                break;;
            n | N| q |Q)  exit;;
            * )    ftEcho -e 错误的选择：$sel
                echo "输入n，q，离开";;
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
            filelist=$(ls $dirPathAnimationSourceRes)
            local dirPathLocal=$PWD
            cd $dirPathAnimationSourceRes
            for file in $filelist
            do
                if [ ! -f "$file" ];then
                    ftEcho -ex 动画资源包含错误类型的文件[${file}]，请确认
                fi
            done
            cd $dirPathLocal
        fi

        dirPathAnimationTraget=/home/${rNameUser}/${dirNameAnimation}

        ftFileDirEdit -e false $dirPathAnimationTraget
        if [ -d $dirPathAnimationTraget ]||[ $? -eq   "3" ];then
            while true; do
            ftEcho -y ${ftEffect}的目标文件[${dirPathAnimationTraget}]夹非空，是否删除重建
            read -n 1 sel
            case "$sel" in
                y|Y) rm -rf $dirPathAnimationTraget
                        break;;
                n|N|q|Q)  exit;;
                *) ftEcho -e 错误的选择：$sel
                    echo "输入n，q，离开";;
            esac
            done
        fi
        mkdir  -p ${dirPathAnimationTraget}/${dirNamePart0}
        mkdir      ${dirPathAnimationTraget}/${dirNamePart1}
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
        # 480           250       15
        # 图片的宽    图片的高   每秒显示的帧数
        # p                1            0            part0
        # 标识符    循环的次数  阶段切换间隔时间 对应图片的目录
        # p             0             10             part1
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
        ftEcho -e "函数[${ftEffect}]参数错误，请查看函数使用示例"
        ftBootAnimation -h
        break;;
    esac
    done
}

ftGjh()
{
    local ftEffect=生成国际化所需的xml文件

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftGjh 无参数
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    local valCount=0
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$rDirPathUserHome" ];then    errorContent="${errorContent}\\n[默认用户的home目录]rDirPathUserHome=$rDirPathUserHome" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftGjh -h
            return
    fi

    local filePath=${rDirPathUserHome}/tools/xls2values/androidi18nBuilder.jar
    if [ -f $filePath ];then
        $filePath
    else
        ftEcho -e "[${ftEffect}]找不到[$filePath]"
    fi
}

ftTest()
{
    local ftEffect=函数demo调试

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftTest 任意参数
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    local dirNameCmdModuleTest=test
    local filePathCmdModuleTest=${rDirPathCmdsModule}/${dirNameCmdModuleTest}/${rFileNameCmdModuleTestBase}
    #耦合校验
    local valCount=1
    local errorContent=
    if [ ! -d "$rDirPathCmdsModule" ];then    errorContent="${errorContent}\\n[xbash模块路径不存在]rDirPathCmdsModule=$rDirPathCmdsModule" ; fi
    if [ ! -f "$filePathCmdModuleTest" ];then    errorContent="${errorContent}\\n[测试模块不存在]filePathCmdModuleTest=$filePathCmdModuleTest" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftTest -h
            return
    fi

    local dirPathLocal=$PWD
    $filePathCmdModuleTest "$@"
    cd $dirPathLocal
}

ftPowerManagement()
{
    local ftEffect=延时免密码关机重启
    local edittype=$1
    local timeLong=$2
    timeLong=${timeLong:-$2}
    timeLong=${timeLong:-'10'}

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#    ftPowerManagement 关机/重启 时间/秒
#    ftPowerManagement shutdown/reboot 100
#    xs 时间/秒 #制定时间后关机,不带时间则默认十秒
#    xss 时间/秒 #制定时间后重启,不带时间则默认十秒
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    local errorContent=
    if [ -z "$rUserPwd" ];then    errorContent="${errorContent}\\n[用户密码为空]rUserPwd=$rUserPwd" ; fi
    if [ -z "$edittype" ];then    errorContent="${errorContent}\\n[操作参数为空]edittype=$edittype" ; fi
    if ( ! echo -n $timeLong | grep -q -e "^[0-9][0-9]*$" );then    errorContent="${errorContent}\\n[倒计时时长无效]timeLong=$timeLong" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftPowerManagement -h
            return
    fi

    while true; do
    case "$edittype" in
        shutdown )
        for i in `seq -w $timeLong -1 1`
        do
            echo -ne "\033[1;31m\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b将在${i}秒后关机，ctrl+c 取消\033[0m"
            sleep 1
        done
        echo -e "\b\b"
        echo $rUserPwd | sudo -S shutdown -h now
        break;;
        reboot)
        for i in `seq -w $timeLong -1 1`
        do
            echo -ne "\033[1;31m\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b将在${i}秒后重启，ctrl+c 取消\033[0m";
            sleep 1
        done
        echo -e "\b\b"
        echo $rUserPwd | sudo -S reboot
        break;;
        * ) ftEcho -e 错误的选择：$sel
            echo "输入q，离开"
            break;;
    esac
    done
}

ftReduceFileList()
{
    local ftEffect=精简动画帧文件

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftReduceFileList 保留的百分比 目录
#    ftReduceFileList 60 /home/xxxx/temp
#
#    ftReduceFileList 目录
#    ftReduceFileList /home/xxxx/temp
# 由于水平有限，实现对60%和50%之类的比例不敏感
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

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

    #耦合校验
    local valCount=2
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$percentage" ];then    errorContent="${errorContent}\\n[百分比取值为空]percentage=$percentage" ; fi
    if [ -z "$dirPathFileList" ];then    errorContent="${errorContent}\\n[目标目录为空]dirPathFileList=$dirPathFileList" ; fi
    if ( ! echo -n $percentage | grep -q -e "^[0-9][0-9]*$");then    errorContent="${errorContent}\\n[百分比取值无效，只能是数字]percentage=$percentage" ; fi
    if (( $percentage<0 ))||(( $percentage>100 ));then    errorContent="${errorContent}\\n[百分比取值无效 0<=*<=100]percentage=$percentage" ; fi
    if [ ! -d "$dirPathFileList" ];then    errorContent="${errorContent}\\n[目标目录]dirPathFileList=$dirPathFileList" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftReduceFileList -h
            return
    fi
    ftFileDirEdit -e false $dirPathFileList
    if [ $? -eq "2" ];then
        ftEcho -ex 空的资源目录，请确认[${dirPathFileList}]是否存在资源文件
    # else
    #     for file in `ls $dirPathFileList`
    #     do
    #         if [ ! -f $file ];then
    #             ftEcho -e 资源目录包含不是文件的东东：[${dirPathFileList}/${file}]
    #         fi
    #     done
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
        #     if [ $editType = "del" ];then
        #         echo del_file=$file
        #     elif [ $editType = "surplus" ];then
        #         continue;
        #     fi
        # else
        #     if [ $editType = "del" ];then
        #         continue;
        #     elif [ $editType = "surplus" ];then
        #         echo del_file=$file
        #     fi
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
    local ftEffect=批量重命名文件
    # local extensionName=$1
    local dirPathFileList=$1
    local lengthFileName=$2
    lengthFileName=${lengthFileName:-'4'}

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    不指定文件名长度默认为4
#    ftReNameFile 目录
#    ftReNameFile /home/xxxx/temp
#    ftReNameFile 目录 修改后的文件长度
#    ftReNameFile /home/xxxx/temp 5
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    local valCount=2
    local errorContent=
    if (( $#>$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -d "$dirPathFileList" ];then    errorContent="${errorContent}\\n[目标目录不存在]dirPathFileList=$dirPathFileList" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
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
    local ftEffect=设备可用空间
    local devDirPath=$1
    local isReturn=$2

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftDevAvailableSpace [devDirPath] [[isReturn]]
#    ftDevAvailableSpace /media/test
#    ftDevAvailableSpace /media/test true
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    local valCount=2
    local errorContent=
    if (( $#>$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -d "$devDirPath" ];then    errorContent="${errorContent}\\n[设备路径不存在]devDirPath=$devDirPath" ; fi
    if [ ! -d "$rDirPathCmdsData" ];then    errorContent="${errorContent}\\n[xbash的data目录不存在]rDirPathCmdsData=$rDirPathCmdsData" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftDevAvailableSpace -h
            return
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

#########################
##                                                     ##
##              ini文件操作实现            ##
##                                                     ##
#########################

ftGetKeyValueByBlockAndKey()
{
    local ftEffect=读取ini文件指定字段
    local filePath=$1
    local blockName=$2
    local keyName=$3

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftGetKeyValueByBlockAndKey [文件] [目标块TAG] [键名]
#    value=$(ftGetKeyValueByBlockAndKey /temp/odbcinst.ini PostgreSQL Setup)
#     value表示对应字段的值
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi
    exit 1;; * )break;; esac;done

    #耦合校验
    local valCount=3
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -f "$filePath" ];then    errorContent="${errorContent}\\n[文件不存在]filePath=$filePath"
    else
        testBockName=$(cat $filePath|grep $blockName)
        testKeyName=$(cat $filePath|grep $keyName)
        if [ -z "$blockName" ];then    errorContent="${errorContent}\\n[目标块TAG为空]blockName=$blockName"
        elif [ -z "$testBockName" ];then    errorContent="${errorContent}\\n[目标块TAG不存在]blockName=$blockName" ; fi
        if [ -z "$keyName" ];then    errorContent="${errorContent}\\n[目标块TAG为空]keyName=$keyName"
        elif [ -z "$testKeyName" ];then    errorContent="${errorContent}\\n[目标块TAG不存在]keyName=$keyName" ; fi
    fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftGetKeyValueByBlockAndKey -h
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
    local ftEffect=修改ini文件指定字段
    local filePath=$1
    local blockName=$2
    local keyName=$3
    local keyValue=$4

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftSetKeyValueByBlockAndKey [文件] [目标块TAG] [键名] [键对应的值]
#    ftSetKeyValueByBlockAndKey /temp/odbcinst.ini PostgreSQL Setup 1232
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi
    exit 1;; * )break;; esac;done

    #耦合校验
    local valCount=4
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -f "$filePath" ];then    errorContent="${errorContent}\\n[目标ini文件不存在]filePath=$filePath"
    else
        testBockName=$(cat $filePath|grep $blockName)
        testKeyName=$(cat $filePath|grep $keyName)
        testKeyValue=$(cat $filePath|grep $keyValue)
        if [ -z "$blockName" ];then    errorContent="${errorContent}\\n[目标块TAG为空]blockName=$blockName"
        elif [ -z "$testBockName" ];then    errorContent="${errorContent}\\n[目标块TAG不存在]blockName=$blockName" ; fi
        if [ -z "$keyName" ];then    errorContent="${errorContent}\\n[目标Key为空]keyName=$keyName"
        elif [ -z "$testKeyName" ];then    errorContent="${errorContent}\\n[目标Key不存在]keyName=$keyName" ; fi
        if [ -z "$keyName" ];then    errorContent="${errorContent}\\n[目标Key对应的Value为空]keyValue=$keyValue"
        elif [ -z "$testKeyName" ];then    errorContent="${errorContent}\\n[目标Key对应的Value不存在]keyValue=$keyValue" ; fi
    fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftSetKeyValueByBlockAndKey2 -h
            return
    fi

    return`sed -i "/^\[$blockName\]/,/^\[/ {/^\[$blockName\]/b;/^\[/b;s/^$keyName*=.*/$keyName=$keyValue/g;}" $filePath`
}


ftCheckIniConfigSyntax()
{
    local ftEffect=校验ini文件，确认文件有效
    #============ini文件模板=====================
    # # 注释１
    # [block1]
    # key1=val1

    # # 注释２
    # [block2]
    # key2=val2
    #===========================================

    local filePath=$1
    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftCheckIniConfigSyntax [file path]
#    ftCheckIniConfigSyntax 123/config.ini
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi
    exit 1;; * )break;; esac;done

    #耦合校验
    local valCount=1
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -f "$filePath" ];then    errorContent="${errorContent}\\n[目标ini文件不存在]filePath=$filePath" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftCheckIniConfigSyntax -h
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
            #不是字段=值 形式的检测是否是目标块TAG
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

#######################结束

ftUpdateHosts()
{
    local ftEffect=更新hosts
    local filePathHosts=/etc/hosts
    local urlCustomHosts=$1

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#使用默认hosts源
#    ftUpdateHosts 无参
#
#使用自定义hosts源
#    ftUpdateHosts [URL]
#    ftUpdateHosts https://raw.githubusercontent.com/racaljk/hosts/master/hosts
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    local valCount=1
    local errorContent=
    if (( $#>$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -f "$filePathHosts" ];then    errorContent="${errorContent}\\n[ubuntu默认hosts配置文件不存在]filePathHosts=$filePathHosts" ; fi
    if [ ! -d "$rDirPathCmdsData" ];then    errorContent="${errorContent}\\n[xbash的data目录不存在]rDirPathCmdsData=$rDirPathCmdsData" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
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
            echo "127.0.0.1    localhost
127.0.1.1    $rNameUser

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
ftBackupOrRestoreOuts()
{
    local ftEffect=维护out
    local dirPathCode=$ANDROID_BUILD_TOP
    local dirPathOut=$ANDROID_PRODUCT_OUT
    local editType=$1

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#    备份out
#    ftBackupOrRestoreOuts 无参
#    移动匹配out到单前项目
#    ftBackupOrRestoreOuts -m
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    env | -env |-ENV ) cat<<EOF
#===================[   ${ftEffect}   ]的使用环境说明=============
#
# 环境未初始化
# 使用前,请先初始化[source build/envsetup.sh;lunch xxxx]
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    if [ -z "$ANDROID_BUILD_TOP" ]||[ -z "$ANDROID_PRODUCT_OUT" ];then
        ftBackupOrRestoreOuts -env
        return
    fi

    local valCount=1
    local errorContent=
    if (( $#>$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -d "$dirPathCode" ];then    errorContent="${errorContent}\\n[工程根目录不存在]dirPathCode=$dirPathCode" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftBackupOrRestoreOuts -h
            return
    fi

    cd $ANDROID_BUILD_TOP
    #分支名

    ftAutoInitEnv
    local buildType=$AutoEnv_buildType
    local versionName=$AutoEnv_versionName
    local branchName="$AutoEnv_branchName"

    local dirNameCodeRootOuts=outs
    local dirPathCodeRootOuts=${dirPathCode%/*}/${dirNameCodeRootOuts}
    local dirNameBranchVersion=BuildType[${buildType}]----BranchName[${branchName}]----VersionName[${versionName}]----$(date -d "today" +"%y%m%d[%H:%M]")
    local dirPathOutBranchVersion=${dirPathCodeRootOuts}/${dirNameBranchVersion}

    if [ ! -d "$dirPathCodeRootOuts" ];then
        if [[ "$editType" = "-m" ]]; then
            ftEcho -e "${dirNameCodeRootOuts}为空"
            return
        fi
        mkdir -p $dirPathCodeRootOuts
    fi

    if [[ "$editType" = "-m" ]]; then
        if [[ -d "$dirPathOut" ]]; then
            ftEcho -e "out已存在 ,请先备份"
            return
        fi
        local branchName=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
        local dirPathOutList=($(ls $dirPathCodeRootOuts|grep $branchName))
        if [[ -z "$dirPathOutList" ]]; then
            ftEcho -e "未找到\n分支[$branchName]对应的out"
            return
        fi
        local itemCount=${#dirPathOutList[@]}
        local dirNameOutTraget=$dirPathOutList
        if (( $itemCount>1 ));then
            ftEcho -s 对应分支对应多个out,请选择
            local index=0
            for item in ${dirPathOutList[@]}
            do
                printf "%-4s %-4s\n" [$index] $item
                index=`expr $index + 1`
            done
            echo -en "请输入对应的序号(回车默认0):"
            if (( $itemCount>9 ));then
                read tIndex
            else
                read -n 1 tIndex
            fi
            #设定默认值
            if [ ${#tIndex} == 0 ]; then
                tIndex=0
            elif (( $itemCount<=$tIndex ))||(( $tIndex<0 ));then
                ftEcho -e "\n无效的序号:${tIndex}"
                 return
            fi
            dirNameOutTraget=${dirPathOutList[$tIndex]}
        fi
        mv ${dirPathCodeRootOuts}/${dirNameOutTraget} ${dirPathCode}/out&&
        ftEcho -s "移动 ${dirPathCodeRootOuts}/${dirNameOutTraget}\n 到  ${dirPathCode}/out"
        return
    fi

    local dirPathOutTop=${dirPathCode}/out
    if [ ! -d "$dirPathOutBranchVersion" ];then
        if [[ ! -d "$dirPathOutTop" ]]; then
             ftEcho -e "out 不存在"
             return
        fi
        if [[ ! -d "$dirPathOut" ]]; then
             ftEcho -e "out 不完整"
             dirNameBranchVersion=${dirNameBranchVersion}____section
        fi
        mv ${dirPathOutTop}/ $dirPathOutBranchVersion&&
        ftEcho -s "移动 $dirPathOutTop \n到  ${dirPathCodeRootOuts}/${dirNameBranchVersion}"
    else
        ftEcho -ex 存在相同out
    fi
}

complete -W "yhx kl" ftYKSwitch
ftYKSwitch()
{
    local ftEffect=切换永恒星和康龙配置
    local type=$1
    local dirPathCode=$ANDROID_BUILD_TOP

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftYKSwitch yhx/kl
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    e | E |-e | -E) cat<<EOF
#===================[   ${ftEffect}   ]的使用环境说明=============
#
#    ftYKSwitch 仅可用于 SPRD > 7731C > N9 的项目
#=======================================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    env | -env |-ENV ) cat<<EOF
#===================[   ${ftEffect}   ]的使用环境说明=============
#
#   环境未初始化
#   使用前,请先初始化[source build/envsetup.sh;lunch xxxx]
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
     * ) break;; esac;done

    #耦合校验
    if [ -z "$ANDROID_BUILD_TOP" ];then
        ftYKSwitch -env
        return
    fi

# 环境检测
    ftAutoInitEnv
    if [[ $AutoEnv_mnufacturers != "sprd" ]]; then
        ftYKSwitch -e
        return
    fi
    #耦合校验
    local valCount=1
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$type" ];then    errorContent="${errorContent}\\n[操作参数为空]type=$type" ; fi
    if [ ! -d "$dirPathCode" ];then    errorContent="${errorContent}\\n[工程根目录不存在]dirPathCode=$dirPathCode" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftYKSwitch -h
            return
    fi

    local filePathConfig=${dirPathCode}/${AutoEnv_deviceDirPath}/BoardConfig.mk
    local filePathTraget=${dirPathCode}/vendor/sprd/modules/libcamera/oem2v0/src/sensor_cfg.c
    local key="LZ_CONFIG_CAMERA_TYPE :="
    local configType=$(cat $filePathConfig|grep "$key")
    if [ -f $filePathConfig ]&&[ ! -z "$configType" ];then
        rm -rf ${ANDROID_PRODUCT_OUT}/obj/SHARED_LIBRARIES/camera.sc8830_intermediates

            local tagYhx="LZ_CONFIG_CAMERA_TYPE\ \:\=\ YHX"
            local tagKl="LZ_CONFIG_CAMERA_TYPE\ \:\=\ KL"
            configType=${configType//$key/}
            configType=$(echo $configType |sed s/[[:space:]]//g)
            configType=$(echo $configType | tr '[A-Z]' '[a-z]')

            if [ "$configType" != "$type" ];then
                    while true; do case "$type" in
                    yhx )
                        sed -i "s:$tagKl:$tagYhx:g" $filePathConfig
                        break;;
                    kl )
                        sed -i "s:$tagYhx:$tagKl:g" $filePathConfig
                        break;;
                    * )
                         export mCameraType=
                         ftEcho -ex 错误参数[type=$type]
                        break;;
                    esac;done
                else
                    ftEcho -e 参数相同configType=$configType type=$type
                fi
    elif [ -f $filePathTraget ];then
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
                * )
                     export mCameraType=
                    ftEcho -ex 错误参数[type=$type]
                    break;;
                esac;done
    fi
        export mCameraType=$type
}

ftAutoUploadHighSpeed()
{
    local ftEffect=上传文件到制定smb服务器路径[高速版]
    #存放上传源的目录
    local dirPathContentUploadSource=$1
    #目录下存放的目录或文件
    local pathContentUploadSource=$2
    local pathContentUploadTraget=$3
    if [ -z "$pathContentUploadTraget" ];then
        if [[ $AutoEnv_mnufacturers = "sprd" ]]; then
             pathContentUploadTraget=智能机软件/SPRD7731C/鹏明珠/autoUpload
        elif [[ $AutoEnv_mnufacturers = "mtk" ]]; then
             pathContentUploadTraget=智能机软件/MTK6580/autoUpload
        fi
    fi
    local dirPathLocal=$(pwd)

    while true; do case "$1" in
    e | -e |--env) cat<<EOF
#===================[   ${ftEffect}   ]的使用环境说明=============
#
#    依赖 sshpass pigz,请使用下面命令安装
#    sudo apt-get install sshpass pigz
#=========================================================
EOF
      return;;
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftAutoUploadHighSpeed 源存放目录 [源文件名或目录名，不要是路径] 服务器路径
#
#    路径:acb/def/123/kkk.zip
#    ftAutoUploadHighSpeed acb/def/123 kkk.zip 智能机软件/MTK6580   #上传文件kkk.zip
#
#    路径acb/def/123/kkk/ddd/XXXXXXXXX
#    ftAutoUploadHighSpeed acb/def/123 kkk 智能机软件/MTK6580 #上传目录kkk包含子目录
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #环境校验
    if [ -z `which sshpass` ]||[ -z `which pigz` ];then
        ftAutoUploadHighSpeed -e
        return
    fi
    #耦合校验
    local valCount=3
    local errorContent=
    if (( $#>$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -d "$dirPathContentUploadSource" ];then    errorContent="${errorContent}\\n上传源存放目录不存在:dirPathContentUploadSource=dirPathContentUploadSource" ;
    elif [ `ls $dirPathContentUploadSource|wc -w` = "0" ];then    errorContent="${errorContent}\\n[上传源为空目录]dirPathContentUploadSource=$dirPathContentUploadSource" ;
    elif [ -d "${dirPathContentUploadSource}/${pathContentUploadSource}" -a `ls ${dirPathContentUploadSource}/${pathContentUploadSource}|wc -w` = "0" ];then    errorContent="${errorContent}\\n[上传源为空目录]dirPathContentUploadSource=$dirPathContentUploadSource" ; fi
    if [ -z "$pathContentUploadTraget" ];then    errorContent="${errorContent}\\n服务器的存放路径未指定:pathContentUploadTraget" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftAutoUploadHighSpeed -h
            return
    fi

    local serverIp=192.168.1.188
    local userName=server
    local pasword=123456
    local dirPathServer=/media/新卷

    ftEcho -s "开始上传到  ${serverIp}/${pathContentUploadTraget}"
    cd $dirPathContentUploadSource
    mTimingStart=$(date +%s -d $(date +"%H:%M:%S"))

    tar -cv  $pathContentUploadSource| pigz -1 |sshpass -p $pasword ssh $userName@$serverIp "gzip -d|tar -xPC ${dirPathServer}/${pathContentUploadTraget}"

    cd $dirPathLocal
    ftEcho -s "上传结束"
    ftTiming
}

ftAutoUpload()
{
    local ftEffect=上传文件到制定smb服务器路径
    local contentUploadSource=$1

    while true; do case "$1" in
    e | E |-e | -E) cat<<EOF
#===================[   ${ftEffect}   ]的使用环境说明=============
#
#    ftAutoUpload 设定仅可用于 SPRD > 7731C > N9 的项目
#=======================================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftAutoUpload [源文件路径]
#    ftAutoUpload xxxx
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

# 环境检测
    ftAutoInitEnv
    if [[ $AutoEnv_mnufacturers != "sprd" ]]; then
        ftAutoUpload -e
        return
    fi
    #耦合校验
    local valCount=1
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -f "$contentUploadSource" ];then    errorContent="${errorContent}\\n[上传的源文件不存在]contentUploadSource=$contentUploadSource" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftAutoUpload -h
            return
    fi


    local serverIp=192.168.1.188
    local userName=server
    local pasword=123456

    local dirPathMoule=智能机软件
    local dirPathUpload=SPRD7731C/鹏明珠/autoUpload

    local fileNameUploadSource=$(basename $contentUploadSource)

    ftEcho -s "开始上传${fileNameUploadSource} 到\n\
 ${serverIp}/${dirPathUpload}..."
smbclient //${serverIp}/${dirPathMoule}  -U $userName%$pasword<< EOF
    mkdir $dirPathUpload
    put $contentUploadSource ${dirPathUpload}/${fileNameUploadSource}
EOF
    ftEcho -s "${contentUploadSource}\n\
 上传结束"

 if [ ! -z "$mCameraType" ];then
         mv $contentUploadSource ${contentUploadSource}_${mCameraType}
  fi
}


complete -W "-y" ftAutoPacket
ftAutoPacket()
{
    local ftEffect=基于android的out生成版本软件
    local dirPathCode=$ANDROID_BUILD_TOP
    local dirPathOut=$ANDROID_PRODUCT_OUT
    local buildType=$TARGET_BUILD_VARIANT
    local isUpload=$1

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftAutoPacket 无参
#    ftAutoPacket -y #自动打包，上传到188服务器
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    env | -env |-ENV ) cat<<EOF
#===================[   ${ftEffect}   ]的使用环境说明=============
#
# 环境未初始化
# 使用前,请先初始化[source build/envsetup.sh;lunch xxxx]
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;; esac;done

    #耦合校验
    if [ -z "$ANDROID_BUILD_TOP" ]\
            ||[ -z "$TARGET_PRODUCT" ]\
            ||[ -z "$ANDROID_PRODUCT_OUT" ]\
            ||[ -z "$TARGET_BUILD_VARIANT" ];then
        ftAutoPacket -env
        return
    fi
    local valCount=1
    local errorContent=
    if (( $#>$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -d "$dirPathCode" ];then    errorContent="${errorContent}\\n[工程根目录不存在]dirPathCode=$dirPathCode" ; fi
    if [ ! -d "$dirPathOut" ];then    errorContent="${errorContent}\\n[工程out目录不存在]dirPathOut=$dirPathOut" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftAutoPacket -h
            return
    fi
    ftAutoInitEnv
    local dirPathLocal=$PWD
    local dirNameVersionSoftware=packet
    local buildType=$AutoEnv_buildType
    local dirPathVersionSoftware=${dirPathCode}/out/${dirNameVersionSoftware}

    if [[ -d "$dirPathVersionSoftware" ]]; then
          while true; do
                        ftEcho -y "${dirPathVersionSoftware}\n已存在,是否是否删除"
                        read -n 1 sel
                        case "$sel" in
                            y | Y ) rm  -rf $dirPathVersionSoftware
                                       break;;
                            n | N | q |Q)    break ;;
                            * ) ftEcho -e 错误的选择：$sel
                                echo "输入n，q，离开";;
                            esac
        done
    fi

    if [[ $AutoEnv_mnufacturers = "sprd" ]]; then
            if [ "$TARGET_PRODUCT" != "sp7731c_1h10_32v4_oversea" ];then
                ftEcho -ea "平台${AutoEnv_mnufacturers}的项目${TARGET_PRODUCT}无效\
                \n请查看下面说明:"
                ftAutoPacket -h
                return
            fi
            local dirPathNormalBin=$dirPathOut
            local dirPathLogo=${dirPathCode%/*}/res
            local versionName=$AutoEnv_versionName
            local dirPathVersionSoftwareVersion=${dirPathVersionSoftware}/${versionName}
            local dirPathModemBin=${dirPathCode%/*}/res/packet_modem
            local softwareVersion=MocorDroid6.0_Trunk_16b_rls1_W16.29.2
            local filePathPacketScript=${rDirPathCmdsModule}/packet/pac_7731c.pl

            if [ ! -f "$filePathPacketScript" ];then
                    ftEcho -ea "[${ftEffect}]的参数错误 \
                       找不到 [sprd的打包工具]filePathPacketScript=$filePathPacketScript \
                        请查看下面说明:"
                    ftAutoPacket -h
                    return
            fi

            if [ ! -z "$buildType" ]&&[ $buildType != "user" ];then
                    versionName=${versionName}____${buildType}
                    dirPathVersionSoftwareVersion=${dirPathVersionSoftware}/${versionName}
            fi

            mkdir -p $dirPathVersionSoftwareVersion
            cd $dirPathVersionSoftwareVersion

            ftEcho -s "开始生成 ${versionName}.pac\n"
            /usr/bin/perl $filePathPacketScript \
                $versionName.pac \
                SC77xx \
                ${versionName}\
                ${dirPathNormalBin}/SC7720_UMS.xml \
                ${dirPathNormalBin}/fdl1.bin \
                ${dirPathNormalBin}/fdl2.bin \
                ${dirPathModemBin}/nvitem.bin \
                ${dirPathModemBin}/nvitem_wcn.bin \
                ${dirPathNormalBin}/prodnv.img \
                ${dirPathNormalBin}/u-boot-spl-16k.bin \
                ${dirPathModemBin}/SC7702_pike_modem_AndroidM.dat \
                ${dirPathModemBin}/DSP_DM_G2.bin \
                ${dirPathModemBin}/SC8800G_pike_wcn_dts_modem.bin \
                ${dirPathNormalBin}/boot.img \
                ${dirPathNormalBin}/recovery.img \
                ${dirPathNormalBin}/system.img \
                ${dirPathNormalBin}/userdata.img \
                ${dirPathLogo}/logo.bmp \
                ${dirPathNormalBin}/cache.img \
                ${dirPathNormalBin}/sysinfo.img \
                ${dirPathNormalBin}/u-boot.bin \
                ${dirPathNormalBin}/persist.img&&
            ftEcho -s 生成7731c使用的pac[${dirPathVersionSoftwareVersion}/${versionName}.pac]

            # 生成说明文件
            ftCreateReadMeBySoftwareVersion $dirPathVersionSoftwareVersion
            #上传服务器
            while true; do case "$isUpload" in    y | Y |-y | -Y)
                ftAutoUploadHighSpeed $dirPathVersionSoftware $(basename $dirPathVersionSoftwareVersion) $dirPathUploadTraget
            break;; * ) break;; esac;done

    elif [[ $AutoEnv_mnufacturers = "mtk" ]]; then
            local dirNamePackage="packages"
            local dirNameOtaPackage="otaPackages"
            local dirNamePackageDataBase="dataBase"
            local deviceName=`basename $ANDROID_PRODUCT_OUT`

            local key="最近更改："
            local fileChangeTime=$(stat ${dirPathOut}/system.img|grep $key|awk '{print $1}'|sed s/-//g)
            fileChangeTime=${fileChangeTime//$key/}
            fileChangeTime=${fileChangeTime:-$(date -d "today" +"%y%m%d")}

            local dataBaseFileList=
            if [ $deviceName = "m9_xinhaufei_r9_hd" ];then
                dataBaseFileList=(obj/CGEN/APDB_MT6580_S01_alps-mp-m0.mp1_W16.50 \
                                                 obj/ETC/BPLGUInfoCustomAppSrcP_MT6580_S00_MOLY_WR8_W1449_MD_WG_MP_V59_P9_1_wg_n_intermediates/BPLGUInfoCustomAppSrcP_MT6580_S00_MOLY_WR8_W1449_MD_WG_MP_V59_P9_1_wg_n)
            elif [ $deviceName = "keytak6580_weg_l" ];then
                dataBaseFileList=(obj/CGEN/APDB_MT6580_S01_L1.MP6_W16.15 \
                                            obj/ETC/BPLGUInfoCustomAppSrcP_MT6580_S00_MOLY_WR8_W1449_MD_WG_MP_V6_P7_1_wg_n.n_intermediates/BPLGUInfoCustomAppSrcP_MT6580_S00_MOLY_WR8_W1449_MD_WG_MP_V6_P7_1_wg_n.n)
            else
                ftEcho -ea "工具没有平台${AutoEnv_mnufacturers}的对应项目${deviceName}的配置\
                \n请查看下面说明:"
                ftAutoPacket -h
                return
            fi

            if [ ! -z "$AutoEnv_clientName" ];then #git解析成功获取到客户等相关信息
                ftAutoInitEnv -bp
                local dirNameersionSoftwareVersionBase=${AutoEnv_AndroidVersion}
                local dirPathVersionSoftwareVersion=${dirPathVersionSoftware}/${dirNameersionSoftwareVersionBase}/${AutoEnv_motherboardName}__${AutoEnv_projrctName}__${AutoEnv_demandSignName}/${AutoEnv_deviceModelName}
                local dirNameVeriosionBase=${AutoEnv_versionName}
                #非user版本标记编译类型
                if [ "$AutoEnv_buildType" != "user" ];then
                    local dirNameVeriosionBase=${buildType}____${dirNameVeriosionBase}
                fi
                #软件版本的日期与当前时间不一致就设定编译时间
                arr=(${AutoEnv_versionName//_/ })
                length=${#arr[@]}
                length=`expr $length - 1`
                local versionNameDate=${arr[$length]}
                if [ "$versionNameDate" != "${fileChangeTime}" ];then
                    local dirNameVeriosionBase=${dirNameVeriosionBase}____buildtime____${fileChangeTime}
                fi
                dirPathVersionSoftwareVersion=${dirPathVersionSoftwareVersion}/${dirNameVeriosionBase}
            else
                local dirPathVersionSoftwareVersion=${dirPathVersionSoftware}/${fileChangeTime}____buildType[${buildType}]__versionName[${AutoEnv_versionName}]__$fileChangeTime
            fi

            local dirPathUploadTraget=智能机软件/MTK6580/autoUpload
            if [ "$AutoEnv_clientName" = "XHF" ];then
                 dirPathUploadTraget=智能机软件/MTK6580/新华菲
            elif [ "$AutoEnv_clientName" = "DHX" ];then
                 dirPathUploadTraget=智能机软件/MTK6580/东华新
            fi
            local dirPathPackage=${dirPathVersionSoftwareVersion}/${dirNamePackage}
            local dirPathOtaPackage=${dirPathVersionSoftwareVersion}/${dirNameOtaPackage}
            local dirPathPackageDataBase=${dirPathVersionSoftwareVersion}/${dirNamePackageDataBase}

            local otaFileList=$(ls ${dirPathOut}/obj/PACKAGING/target_files_intermediates/${TARGET_PRODUCT}-target_files-* |grep .zip)
            local fileList=(boot.img \
                            cache.img \
                            lk.bin \
                            logo.bin \
                            MT6580_Android_scatter.txt \
                            preloader_${deviceName}.bin \
                            ramdisk.img \
                            recovery.img \
                            secro.img \
                            system.img \
                            userdata.img)

            mkdir -p $dirPathVersionSoftwareVersion
            mkdir -p $dirPathPackage
            mkdir -p $dirPathPackageDataBase
            cd $dirPathVersionSoftwareVersion

            ftEcho -s "开始生成版本软件包: \n${dirNameVeriosionBase}\n路径: \n${dirPathVersionSoftwareVersion}"
            #packages
            for file in ${fileList[@]}
            do
                local filePath=${dirPathOut}/${file}
                 if [[ ! -f "$filePath" ]]; then
                     ftEcho -e "${filePath}\n不存在"
                     return;
                 fi
                 printf "%-2s %-30s\n" 复制 $file
                 cp -r -f  $filePath ${dirPathVersionSoftwareVersion}/${dirNamePackage}
            done
            #otaPackages
            if [[ ! -z "$otaFileList" ]]; then
                mkdir -p $dirPathOtaPackage
                for file in ${otaFileList[@]}
                do
                     if [[ ! -f "$file" ]]; then
                         ftEcho -e "${file}\n不存在"
                         return;
                     fi
                     printf "%-2s %-30s\n" 复制 $(echo $file | sed "s ${dirPathOut}/  ")
                     cp -r -f  $file ${dirPathVersionSoftwareVersion}/${dirNameOtaPackage}
                done
            fi
            # database
            if [ ! -z "$dataBaseFileList" ];then
                for file in ${dataBaseFileList[@]}
                do
                    local filePath=${dirPathOut}/${file}
                     if [[ ! -f "$filePath" ]]; then
                         ftEcho -e "${filePath}\n不存在"
                         return;
                     fi
                    printf "%-2s %-30s\n" 复制 $(echo $file | sed "s ${dirPathOut}  ")
                     cp -r -f  $filePath ${dirPathPackageDataBase}
                done
            fi
            # 生成说明文件
            ftCreateReadMeBySoftwareVersion $dirPathVersionSoftwareVersion
            #上传服务器
            while true; do case "$isUpload" in    y | Y |-y | -Y)
                ftAutoUploadHighSpeed $dirPathVersionSoftware $dirNameersionSoftwareVersionBase $dirPathUploadTraget
            break;; * ) break;; esac;done
    fi
    cd $dirPathLocal
}

ftLanguageUtils()
{
    local ftEffect=语言缩写转换
    local ftLanguageContent=$@
    local dirPathCode=$ANDROID_BUILD_TOP

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftLanguageUtils 缩写列表
#    ftLanguageUtils “ar_IL bn_BD my_MM zh_CN”
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    env | -env |-ENV ) cat<<EOF
#===================[   ${ftEffect}   ]的使用环境说明=============
#
# 环境未初始化
# 使用前,请先初始化[source build/envsetup.sh;lunch xxxx]
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    if [ -z "$ANDROID_BUILD_TOP" ];then
        ftLanguageUtils -env
        return
    fi
    ftAutoInitEnv
    if [ $AutoEnv_mnufacturers = "sprd" ];then
            local filePathDevice=${dirPathCode}/${AutoEnv_deviceDirPath}/sp7731c_1h10_32v4_oversea.mk
    elif [[ $AutoEnv_mnufacturers = "mtk" ]]; then
            local filePathDevice=${dirPathCode}/${AutoEnv_deviceDirPath}/ProjectConfig.mk
    fi
    local errorContent=
    if [ -z "$ftLanguageContent" ];then    errorContent="${errorContent}\\n[语言信息为空]ftLanguageContent=$ftLanguageContent" ;
    elif [ ! -f "$filePathDevice" ];then    errorContent="${errorContent}\\n[工程Device的语言配置文件不存在]filePathDevice=$filePathDevice" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftLanguageUtils -h
            return
    fi

    allList=(阿拉伯语 孟加拉语 缅甸语 简体中文 繁体中文 捷克语 荷兰语 \
英语 法语 德语 希腊语 希伯来语 印地语 匈牙利语 印度尼西亚语 \
意大利语 高棉语 韩语 马来语 波斯语 葡萄牙语 葡萄牙语 \
罗马尼亚语/摩尔多瓦语  俄语 西班牙语 他加禄语/菲律宾语 \
泰语 土耳其语 乌尔都语 越南语 阿拉伯语 保加利亚语 \
加泰罗尼亚语 克罗地亚语 丹麦语 荷兰语 英语 英语 英语 \
英语 英语 英语 英语 英语 芬兰语 法语 法语 法语 德语 德语 \
德语 印地语/印度 意大利语 日语 坎纳达语/印度 拉脱维亚语 \
立陶宛语 马拉雅拉姆语/印度 挪威语 波兰语 塞尔维亚语 斯洛伐克语 \
斯洛文尼亚语 西班牙语 瑞典语 泰卢固语/印度 乌克兰语 繁体中文/香港 \
印尼语 斯瓦希里语/坦桑尼亚 阿姆哈拉语/埃塞俄比亚 孟加拉语/印度 \
希伯来语/以色列 希伯来语/以色列 南非语 罗曼什语/瑞士 缅甸语/民间 \
白俄罗斯语 爱沙尼亚语 祖鲁语/南非 阿塞拜疆语 亚美尼亚语/亚美尼亚 \
格鲁吉亚语/格鲁吉亚 老挝语/老挝 蒙古语 尼泊尔语 哈萨克语 僧加罗语/斯里兰卡 )

    shortList=(ar_IL bn_BD my_MM zh_CN zh_TW cs_CZ nl_NL \
en_US fr_FR de_DE el_GR he_IL/iw_IL hi_IN hu_HU id_ID \
it_IT km_KH ko_KR ms_MY fa_IR pt_BR pt_PT ro_RO \
ru_RU es_ES tl_PH th_TH tr_TR ur_PK vi_VN ar_EG bg_BG \
ca_ES hr_HR da_DK nl_BE en_AU en_GB en_CA en_IN en_IE\
 en_NZ en_SG en_ZA fi_FI fr_BE fr_CA fr_CH de_AT de_LI \
 de_CH hi_IN it_CH ja_JP hi_IN lv_LV lt_LT hi_IN nb_NO \
 pl_PL sr_RS sk_SK sl_SI es_US sv_SE hi_IN uk_UA zh_HK \
 in_ID sw_TZ am_ET bn_IN he_IL iw_IL af_ZA rm_CH \
 my_ZG be_BY et_EE zu_ZA az_AZ hy_AM ka_GE lo_LA \
 mn_MN ne_NP kk_KZ si_LK)

    if [ -z "$ftLanguageContent" ];then
        LanguageList=$(cat $filePathDevice|grep "PRODUCT_LOCALES :=")  #获取缩写列表
        LanguageList=${LanguageList//PRODUCT_LOCALES :=/};  #删除PRODUCT_LOCALES :=
        ftLanguageContent="$LanguageList"
    fi

    ftLanguageContent2=$(echo $ftLanguageContent|sed 's/_//g')
    ftLanguageContent2=$(echo $ftLanguageContent2|sed s/[[:space:]]//g)
    if [[ $ftLanguageContent2 =~ ^[a-zA-Z]+$ ]]; then
        sourceList=(${shortList[@]})
        tragetList=(${allList[@]})
    elif [[ $ftLanguageContent2 =~ ^[a-zA-Z] ]];then
        ftEcho -e 错误的参数:\\n${ftLanguageContent[@]}
        exit
    else
        sourceList=(${allList[@]})
        tragetList=(${shortList[@]})
    fi

    local orderIndex=0
    for lc in ${ftLanguageContent[@]}
    do
        title="参数[${lc}] 转换失败"
        index=0
        for base in ${sourceList[@]}
        do
            if [ $lc = $base ];then
                # if [ $orderIndex -eq 0 ];then
                #     echo "${tragetList[index]}(默认)"
                # else
                echo ${tragetList[index]}
                # fi
                orderIndex=`expr $orderIndex + 1`
                break;
            elif [[ $base =~ "/" ]]&&[[ $base =~ $lc ]]; then
                echo "[${lc}]>${tragetList[index]}>[${base}]"
                title=${lc}可能存在多种结果
            elif((${#sourceList[@]}==`expr $index + 1`));then
                ftEcho -e $title
            fi
            index=`expr $index + 1`
        done
    done
}

ftCreateReadMeBySoftwareVersion()
{
    local ftEffect=创建软件版本相关修改记录和版本说明
    local dirPathCode=$ANDROID_BUILD_TOP
    local dirPathOut=$ANDROID_PRODUCT_OUT
    local dirPathVersionSoftware=$1

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftCreateReadMeBySoftwareVersion [dir_path_pac_res] #生成7731c使用的pac的目录，和生成所需的文件存放的目录
#    ftCreateReadMeBySoftwareVersion out/pac
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    e | -e) cat<<EOF
#===================[   ${ftEffect}   ]的使用环境说明=============
#
#    工具依赖包 unix2dos #sudo apt-get install tofrodos
#=========================================================
EOF
      return;;
    env | -env |-ENV ) cat<<EOF
#===================[   ${ftEffect}   ]的使用环境说明=============
#
# 环境未初始化
# 使用前,请先初始化[source build/envsetup.sh;lunch xxxx]
#
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #环境校验
    if [ -z `which todos` ]||[ -z `which fromdos` ];then
        ftCreateReadMeBySoftwareVersion -e
    fi
    if [ -z "$ANDROID_BUILD_TOP" ]||[ -z "$ANDROID_PRODUCT_OUT" ];then
        ftCreateReadMeBySoftwareVersion -env
        return
    fi
    #耦合校验
    local valCount=1
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -d "$dirPathCode" ];then    errorContent="${errorContent}\\n[工程根目录不存在]dirPathCode=$dirPathCode" ; fi
    if [ ! -d "$dirPathOut" ];then    errorContent="${errorContent}\\n[工程out目录不存在]dirPathOut=$dirPathOut" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftCreateReadMeBySoftwareVersion -h
            return
    fi

    if [ ! -d "$dirPathVersionSoftware" ];then
        mkdir $dirPathVersionSoftware
    fi
    ftAutoInitEnv

    local fileNameReadMeTemplate=客户说明.txt
    local fileNameChangeListTemplate=修改记录.txt
    local filePathReadMeTemplate=${dirPathVersionSoftware}/${fileNameReadMeTemplate}
    local filePathChangeListTemplate=${dirPathVersionSoftware}/${fileNameChangeListTemplate}
    local versionName=$AutoEnv_versionName

    #获取缩写列表
    if [ $AutoEnv_mnufacturers = "sprd" ];then
                local filePathDeviceSprd=${dirPathCode}/${AutoEnv_deviceDirPath}/sp7731c_1h10_32v4_oversea.mk
                if [[ -f "$filePathDeviceSprd" ]]; then
                    local key="PRODUCT_LOCALES :="
                    LanguageList=$(cat $filePathDeviceSprd|grep "$key")
                    LanguageList=${LanguageList//$key/};
                else
                    ftEcho -e "[工程文件不存在:${filePathDeviceSprd}\n，语言缩写列表 获取失败]\n$filePathPawInfo"
                fi
   elif [[ $AutoEnv_mnufacturers = "mtk" ]]; then
                local filePathDeviceMtk=${dirPathCode}/${AutoEnv_deviceDirPath}/ProjectConfig.mk
                if [ -f "$filePathDeviceMtk" ]; then
                    local key="MTK_PRODUCT_LOCALES"
                    LanguageList=$(grep ^$key $filePathDeviceMtk)
                    LanguageList=${LanguageList//$key/};
                    LanguageList=${LanguageList//=/};
                else
                    ftEcho -e "[工程文件不存在:${filePathDeviceMtk}\n，语言缩写列表 获取失败]\n$filePathPawInfo"
                fi
    fi

    LanguageList=${LanguageList//$key/};
    LanguageList=`ftLanguageUtils "$LanguageList"`  #缩写转化为中文
    LanguageList=${LanguageList//
/ };  # 删除回车
    LanguageList=(默认)${LanguageList}

    cd $dirPathCode

    #使用git 记录的修改记录
    gitVersionMin="2.6.0"
    gitVersionNow=$(git --version)
    gitVersionNow=${gitVersionNow//git version/}
    gitVersionNow=$(echo $gitVersionNow |sed s/[[:space:]]//g)

    if version_lt $gitVersionMin $gitVersionNow; then
        # gitCommitListOneDay=$(git log --date=format-local:'%y%m%d'  --since=1.day.ago --pretty=format:" %an %ad %s")
         #gitCommitListBefore=$(git log --date=format-local:'%y%m%d'  --before=1.day.ago --pretty=format:" %an %ad %s" -1)
        gitCommitListOneDay=$(git log --date=format-local:'%y%m%d'  --since=1.day.ago --pretty=format:'%h %ad %<(8,trunc)%an %s')
        gitCommitListBefore=$(git log --date=format-local:'%y%m%d'  --before=1.day.ago --pretty=format:'%h %ad %<(8,trunc)%an %s')
    else
        gitCommitListOneDay=$(git log --date=short  --since=1.day.ago  --pretty=format:"%h %ad %an %s")
        gitCommitListBefore=$(git log --date=short  --before=1.day.ago  --pretty=format:"%h %ad %an %s")
    fi

    # 暗码清单
    local filePathPawInfo=${dirPathCode}/packages/apps/Dialer/src/com/android/dialer/SpecialCharSequenceMgr.java
    if [ -f $filePathPawInfo ];then
            local pawNumInfo=$(cat $filePathPawInfo|grep "private static final String PAW_NUM_INFO")  #获取暗码清单信息
            pawNumInfo=${pawNumInfo//private static final String PAW_NUM_INFO =/};
            pawNumInfo=${pawNumInfo//\";/};
            pawNumInfo=${pawNumInfo//\"/};
            pawNumInfo=$(echo $pawNumInfo |sed s/[[:space:]]//g)
    else
            ftEcho -e "[工程暗码清单文件不存在，获取失败]\n$filePathPawInfo"
    fi

    if [ $AutoEnv_mnufacturers = "sprd" ];then

    #摄像头配置相关
    local filePathCameraConfig=${dirPathCode}/${AutoEnv_deviceDirPath}/BoardConfig.mk
    if [ -f $filePathCameraConfig ];then
            local keyType="LZ_CONFIG_CAMERA_TYPE := "
            local keySizeBack="CAMERA_SUPPORT_SIZE := "
            local keySizeFront="FRONT_CAMERA_SUPPORT_SIZE := "

            local cameraTypeInfo=$(cat $filePathCameraConfig|grep "$keyType")
            local cameraSizeBack=$(cat $filePathCameraConfig|grep "$keySizeBack")
            local cameraSizeFront=$(cat $filePathCameraConfig|grep "$keySizeFront")

            cameraTypeInfo=${cameraTypeInfo//$keyType/};
            cameraSizeFront=${cameraSizeFront//$keySizeFront/};

            cameraSizeBack=${cameraSizeBack//${keySizeFront}$cameraSizeFront/};
            cameraSizeBack=${cameraSizeBack//$keySizeBack/};

            cameraTypeInfo=$(echo $cameraTypeInfo |sed s/[[:space:]]//g)
            cameraSizeFront=$(echo $cameraSizeFront |sed s/[[:space:]]//g)
            cameraSizeBack=$(echo $cameraSizeBack |sed s/[[:space:]]//g)
    else
            ftEcho -e "[相机配置文件不存在，获取失败]\n$filePathCameraConfig"
    fi

    #RAM/ROM
    local filePathEnvsetup=${dirPathCode}/build/envsetup.sh
    if [ -f $filePathEnvsetup ];then
            local keyRom="export sizeRom="
            local keyRam="export sizeRam="
            local sizeRom=$(cat $filePathEnvsetup|grep "$keyRom")
            local sizeRam=$(cat $filePathEnvsetup|grep "$keyRam")
            sizeRom=${sizeRom//$keyRom/};
            sizeRam=${sizeRam//$keyRam/};
    else
            ftEcho -e "[envsetup.sh不存在，获取失败]\n$filePathEnvsetup"
    fi
    fi

    #============           客户说明          ====================
    echo -e "$gitCommitListOneDay">$filePathReadMeTemplate
    seq 10 | awk '{printf("    %02d %s\n", NR, $0)}' $filePathReadMeTemplate >${filePathReadMeTemplate}.temp

    echo -e "1. 版本号：$versionName
2. 语言:
    $LanguageList
3. 修改点：\
"| cat - ${filePathReadMeTemplate}.temp >$filePathReadMeTemplate

    #============           修改记录          ====================
    echo -e "﻿$gitCommitListBefore">$filePathChangeListTemplate
    local gitCommitListBeforeSize=$(awk 'END{print NR}' ${filePathReadMeTemplate}.temp)
    seq 10 | awk '{printf("    %02d %s\n", NR+size, $0)}' size="$gitCommitListBeforeSize" $filePathChangeListTemplate >${filePathChangeListTemplate}.temp
    echo -e "﻿/////////////////////////////////////////////////////////////////////////////
///     修改记录有误要及时更正哦
///     修改记录横线以上为新修改
/////////////////////////////////////////////////////////////////////////////
当前版本：$versionName
暗码清单：$pawNumInfo
设备信息暗码：
屏幕正扫/反扫：
摄像头类型：$cameraTypeInfo
默认 前/后摄大小：$cameraSizeFront/$cameraSizeBack
默认 RAM/ROM：$sizeRam/$sizeRom
RAM 列表：$ramSizeListSel
ROM 列表：$romSizeListSel

修改记录：\
"| cat - ${filePathReadMeTemplate}.temp >$filePathChangeListTemplate

    echo -e "﻿==============================================================================\
"| cat - ${filePathChangeListTemplate}.temp>>$filePathChangeListTemplate

    # 转化为windows下格式
    unix2dos $filePathReadMeTemplate
    unix2dos $filePathChangeListTemplate

    rm ${filePathReadMeTemplate}.temp
    rm ${filePathChangeListTemplate}.temp
}

ftAutoLanguageUtil()
{
    local ftEffect=语言缩写转化为中文
    local dirPathCode=$ANDROID_BUILD_TOP
    local filePathDevice=${dirPathCode}/${AutoEnv_deviceDirPath}/sp7731c_1h10_32v4_oversea.mk

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftAutoLanguageUtil 无参
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    env | -env |-ENV ) cat<<EOF
#===================[   ${ftEffect}   ]的使用环境说明=============
#
# 环境未初始化
# 使用前,请先初始化[source build/envsetup.sh;lunch xxxx]
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    if [ -z "$ANDROID_BUILD_TOP" ];then
        ftAutoLanguageUtil -env
        return
    fi
    local valCount=0
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -d "$dirPathCode"  ];then    errorContent="${errorContent}\\n[工程根目录不存在]dirPathCode=$dirPathCode" ; fi
    if [ ! -f "$filePathDevice" ];then    errorContent="${errorContent}\\n[工程Device的make文件不存在]filePathDevice=$filePathDevice" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftAutoLanguageUtil -h
            return
    fi

    local LanguageList=$(cat $filePathDevice|grep "PRODUCT_LOCALES :=")  #获取缩写列表
    LanguageList=${LanguageList//PRODUCT_LOCALES :=/};  #删除PRODUCT_LOCALES :=
    LanguageList=`ftLanguageUtils "$LanguageList"`  #缩写转化为中文
    LanguageList=${LanguageList//
/ };  # 删除回车
    echo $LanguageList
}

ftLnUtil()
{
    local ftEffect=获取软连接的真实路径
    local lnPath=$1

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftLnUtil 软连接路径
#    ftLnUtil /home/xian-hp-u16/log/xb_backup
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    local valCount=1
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$lnPath" ];then    errorContent="${errorContent}\\n[软连接为空]lnPath=$lnPath" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftLnUtil -h
            return
    fi

    OLD_IFS="$IFS"
    IFS="/"
    arr=($lnPath)
    IFS="$OLD_IFS"

    i=${#arr[@]}
    let i--
    delDir=
    while [ $i -ge 0 ]
    do
        [[ $lnPath =~ ^/  ]] && lnRealPath=$lnPath || lnRealPath=`pwd`/$lnPath
        while [ -h $lnRealPath ]
        do
           b=`ls -ld $lnRealPath|awk '{print $NF}'`
           c=`ls -ld $lnRealPath|awk '{print $(NF-2)}'`
           [[ $b =~ ^/ ]] && lnRealPath=$b  || lnRealPath=`dirname $c`/$b
        done
        if [ "$lnRealPath" = "$lnPath" ];then
            lnPath=${lnPath%/*}
            delDir=${arr[$i]}/$delDir
        else
            echo ${lnRealPath}${delDir}
            break
        fi
        let i--
    done
}

ftAutoUpdateSoftwareVersion()
{
    local ftEffect=更新sprd7731c_N9的软件版本
    local dirPathCode=$ANDROID_BUILD_TOP

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftAutoUpdateSoftwareVersion 无参
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    e | E |-e | -E) cat<<EOF
#===================[   ${ftEffect}   ]的使用环境说明=============
#
#    ftYKSwitch 仅可用于 SPRD > 7731C > N9 的项目
#=======================================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    env | -env |-ENV ) cat<<EOF
#===================[   ${ftEffect}   ]的使用环境说明=============
#
# 环境未初始化
# 使用前,请先初始化[source build/envsetup.sh;lunch xxxx]
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

# 环境检测
    ftAutoInitEnv
    if [[ $AutoEnv_mnufacturers != "sprd" ]]; then
        ftAutoUpdateSoftwareVersion -e
        return
    fi
    #耦合校验
    if [ -z "$ANDROID_BUILD_TOP" ];then
        ftAutoUpdateSoftwareVersion -env
        return
    fi
    local valCount=1
    local errorContent=
    if (( $#>$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -d "$dirPathCode" ];then    errorContent="${errorContent}\\n[工程根目录不存在]dirPathCode=$dirPathCode" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftAutoUpdateSoftwareVersion -h
            return
    fi

    cd $ANDROID_BUILD_TOP
    #分支名
    local branchName=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    #软件版本名1
    local keyVersion="findPreference(KEY_BUILD_NUMBER).setSummary(\""
    local filePathDeviceInfoSettingsBase=packages/apps/Settings/src/com/android/settings/DeviceInfoSettings.java
    local filePathDeviceInfoSettings=${dirPathCode}/${filePathDeviceInfoSettingsBase}
    local versionNameSet=$(cat $filePathDeviceInfoSettings|grep $keyVersion)
    versionNameSet=${versionNameSet/$keyVersion/}
    versionNameSet=${versionNameSet/\");/}
    versionNameSet=$(echo $versionNameSet |sed s/[[:space:]]//g)

    local keyVersion2="R.string.build_number"
    local filePathSystemVersionTestBase=packages/apps/ValidationTools/src/com/sprd/validationtools/itemstest/SystemVersionTest.java
    local filePathSystemVersionTest=${dirPathCode}/${filePathSystemVersionTestBase}
    local versionNameTest=$(cat $filePathSystemVersionTest |sed s/[[:space:]]//g|grep -C 1 "$keyVersion2")
    versionNameTest=$(echo $versionNameTest |sed s/[[:space:]]//g)
    versionNameTest=${versionNameTest//\"/}
    versionNameTest=${versionNameTest//\\n/}
    versionNameTest=${versionNameTest//+/}
    versionNameTest=${versionNameTest//);/}
    versionNameTest=${versionNameTest//linuxVersion.setText(getString(R.string.prop_version)getPropVersion()platformVersion.setText(getString(R.string.build_number)/}

    # 更新版本号的日期段
    local dateNew=$(date -d "today" +"%Y%m%d")

    local dateOldSet=$(echo $versionNameSet | awk -F "_" '{print $NF}')
    local versionNameSetNew=${versionNameSet//$dateOldSet/$dateNew}
    local dateOldTest=$(echo $versionNameTest | awk -F "_" '{print $NF}')
    local versionNameTestNew=${versionNameTest//$dateOldTest/$dateNew}

    if [ ! -z "$1" ]&&[ "$1" = "-y" ];then
                sed -i "s:$versionNameSet:$versionNameSetNew:g" $filePathDeviceInfoSettings&&
                sed -i "s:$versionNameTest:$versionNameTestNew:g" $filePathSystemVersionTest&&
                git add $filePathDeviceInfoSettingsBase $filePathSystemVersionTestBase&&
                git commit -m "版本 ${versionNameTestNew}"
                return
    fi

     while true; do
        ftEcho -y "是否更新软件版本号"
        read -n 1 sel
        case "$sel" in
            y | Y )
                    sed -i "s:$versionNameSet:$versionNameSetNew:g" $filePathDeviceInfoSettings
                    sed -i "s:$versionNameTest:$versionNameTestNew:g" $filePathSystemVersionTest
                     while true; do
                        ftEcho -y "是否提交修改"
                        read -n 1 sel
                        case "$sel" in
                            y | Y )
                                ftEcho -s 提交开始，请稍等
                                git add $filePathDeviceInfoSettingsBase $filePathSystemVersionTestBase&&git commit -m "版本 ${versionNameTestNew}"
                                break;;
                            n | N | q |Q)    return;;
                            * ) ftEcho -e 错误的选择：$sel
                                echo "输入n，q，离开";;
                            esac
                            done
                break;;
            n | N | q |Q)    exit;;
            * ) ftEcho -e 错误的选择：$sel
                 echo "输入n，q，离开";;
        esac
        done
}

ftAutoBuildMultiBranch()
{
    local ftEffect=多版本[分支]串行编译
    local filePathBranchList=branch.list
    local dirPathCode=$ANDROID_BUILD_TOP
    local editType=$1

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftAutoBuildMultiBranch 无参
#    ftAutoBuildMultiBranch -y 上传版本软件
#    ftAutoBuildMultiBranch -yb 上传版本软件,备份out
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    env | -env |-ENV ) cat<<EOF
#===================[   ${ftEffect}   ]的使用环境说明=============
#
# 环境未初始化
# 使用前,请先初始化[source build/envsetup.sh;lunch xxxx]
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    if [ -z "$ANDROID_BUILD_TOP" ];then
        ftAutoBuildMultiBranch -env
        return
    fi
    local valCount=1
    local errorContent=
    if (( $#>$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -d "$dirPathCode" ];then    errorContent="${errorContent}\\n[工程根目录不存在]dirPathCode=$dirPathCode" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftAutoBuildMultiBranch -h
            return
    fi

    local isUpload=
    local isBackupOut=
    if [ -z "$1" ];then
        echo 将不会上传软件包，备份out
    fi
    while true; do
      case "$editType" in
                -y | -Y )
                   isUpload=true
                    break;;
                -yb | -by| -YB )
                   isUpload=true
                   isBackupOut=true
                    break;;
                * )break;;
        esac
    done


    cd $dirPathCode
    echo $PWD
    if [ ! -z "$(pgrep -f gedit)" ];then
         while true; do
                    echo
                    ftEcho -y gedit 已打开是否关闭
                    read -n 1 sel
                    case "$sel" in
                        y | Y )    kill -9 $(ps -e|grep gedit |awk '{print $1}')
                                      break;;
                        n | N |q | Q)    return;;
                        * ) ftEcho -e 错误的选择：$sel
                            echo "输入n,q，离开"
                            ;;
                    esac
            done
    fi
    git branch > $filePathBranchList&&
    gedit $filePathBranchList&&
    while [ ! -z "$(pgrep -f gedit)" ]
    do
        echo 等待中
    done
    content=`cat $filePathBranchList`
    if [ ! -z "$content" ];then
            ftEcho -b 将编译下面所有分支
            cat $filePathBranchList | while read line
            do
                echo branshName=$line
            done
            while true; do
                    echo
                    ftEcho -y 是否开始编译
                    read -n 1 select
                    case "$select" in
                        y | Y )
                                        cat $filePathBranchList | while read line
                                        do
                                            local branshName=$line
                                            #rm -rf out
                                            git reset --hard&&
                                            ftEcho -bh 将开始编译$branshName
                                            git checkout   "$branshName"&&

                                           # git pull
                                           # git cherry-pick 50ca775&&
                                           # git push origin "$branshName"

                                            ftAutoInitEnv
                                            local cpuCount=$(cat /proc/cpuinfo| grep "cpu cores"| uniq)
                                            cpuCount=$(echo $cpuCount |sed s/[[:space:]]//g)
                                            cpuCount=${cpuCount//cpucores\:/}
                                            if [[ $AutoEnv_mnufacturers = "sprd" ]]; then
                                                        #if [ "$TARGET_PRODUCT" != "sp7731c_1h10_32v4_oversea" ];then
                                                        source build/envsetup.sh&&
                                                        lunch sp7731c_1h10_32v4_oversea-user&&
                                                        kheader&&
                                                        make -j${cpuCount} 2>&1|tee -a out/build_$(date -d "today" +"%y%m%d%H%M%S").log&&
                                                        if [ $isUpload = "true" ];then
                                                            ftAutoPacket -y
                                                        else
                                                            ftAutoPacket
                                                        fi
                                                        if [ $isBackupOut = "true" ];then
                                                            ftBackupOrRestoreOuts
                                                        fi
                                            elif [[ $AutoEnv_mnufacturers = "mtk" ]]; then
                                                    local deviceName=`basename $ANDROID_PRODUCT_OUT`
                                                    if [ $deviceName = "keytak6580_weg_l" ];then
                                                        source build/envsetup.sh&&
                                                        lunch full_keytak6580_weg_l-user&&
                                                        mkdir out
                                                        make -j${cpuCount} 2>&1|tee -a out/build_$(date -d "today" +"%y%m%d%H%M%S").log&&
                                                        make otapackage&&
                                                        ftAutoPacket -y&&
                                                        if [ $isBackupOut = "true" ];then
                                                            ftBackupOrRestoreOuts
                                                        fi
                                                    else
                                                        ftAutoBuildMultiBranch -e
                                                        return;
                                                    fi
                                            fi
                                        done
                                        git reset --hard
                                       break;;
                        n | N)    break;;
                        q |Q)    exit;;
                        * ) ftEcho -e 错误的选择：$sel
                             echo "输入q，离开" ;;
                    esac
            done
    fi
    rm -f $filePathBranchList
}

ftSetBashPs1ByGitBranch()
{
    local ftEffect=根据git分支名,设定bash的PS1
    local editType=$1

    local defaultPrefix=xrnsd
    local defaultColorConfig=44
    if [ ! -z "$rNameUser" ]&&[ "$rNameUser" != "wgx" ];then
        defaultPrefix=$rNameUser
    fi
    if [ "$(whoami)" = "root" ];then
        defaultPrefix="root"
        defaultColorConfig=42
    fi
    local branchName=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    if [ ! -z "$branchName" ]&&[ "$editType" != "-b" ];then
        if [ ${#branchName} -gt "10" ];then
            branchName="\nbranchName→ ${branchName}"
        else
            branchName="branchName→ ${branchName}"
        fi
        export PS1="$defaultPrefix[\[\033[${defaultColorConfig}m\]\w\[\033[0m\]]\[\033[33m\]$branchName:\[\033[0m\]"
    else

                #export PS1='$(whoami)\[\033[42m\][\w]\[\033[0m\]:'
        export PS1="$defaultPrefix[\[\033[${defaultColorConfig}m\]\w\[\033[0m\]]:"
    fi
}

#版本号大小对比
VERSION="  1.9.1"
VERSION2="   2.2"

function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }
function version_le() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" == "$1"; }
function version_lt() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" != "$1"; }
function version_ge() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"; }
# if version_gt $VERSION $VERSION2; then
#    echo "$VERSION is greater than $VERSION2"
# fi

# if version_le $VERSION $VERSION2; then
#    echo "$VERSION is less than or equal to $VERSION2"
# fi

# if version_lt $VERSION $VERSION2; then
#    echo "$VERSION is less than $VERSION2"
# fi

# if version_ge $VERSION $VERSION2; then
#    echo "$VERSION is greater than or equal to $VERSION2"
# fi

ftAutoInitEnv()
{
    local ftEffect=初始化xbash所需的部分环境变量
    local dirPathCode=$ANDROID_BUILD_TOP
    local dirPathOut=$ANDROID_PRODUCT_OUT
    local buildType=$TARGET_BUILD_VARIANT
    local editType=$1

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftAutoInitEnv 无参
#    ftAutoInitEnv -bp #build.prop高级信息读取
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    env | -env |-ENV ) cat<<EOF
#===================[   ${ftEffect}   ]的使用环境说明=============
#
# 环境未初始化
# 使用前,请先初始化[source build/envsetup.sh;lunch xxxx]
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    if [ -z "$ANDROID_BUILD_TOP" ]\
        ||[ -z "$ANDROID_PRODUCT_OUT" ]\
        ||[ -z "$TARGET_BUILD_VARIANT" ];then
        ftAutoInitEnv -env
        return
    fi
    local valCount=2
    local errorContent=
    if (( $#>$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -d "$dirPathCode" ];then    errorContent="${errorContent}\\n[工程根目录不存在]dirPathCode=$dirPathCode" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftAutoInitEnv -h
            return
    fi

    # build.prop高级信息读取
    export AutoEnv_deviceModelName=
    export AutoEnv_deviceSoftType=
    export AutoEnv_deviceSoftVersion=
    export AutoEnv_deviceSdkVersion=
    export AutoEnv_AndroidVersion=

    local keySoftType="ro.build.type="
    local keyModel="ro.product.model="
    local keySoftVersion="ro.build.display.id="
    local keySDKVersion="ro.build.version.sdk="
    local filePathSystemBuildprop=${dirPathOut}/system/build.prop

    if [ "$2" = "-mobile" ];then
                adb wait-for-device
                local adbStatus=$(adb get-state)
                if [ "$adbStatus" = "device" ];then
                    local deviceModelName=$(adb shell cat /system/build.prop|grep "$keyModel")
                    local deviceSoftType=$(adb shell cat /system/build.prop|grep "$keySoftType")
                    local deviceSoftVersion=$(adb shell cat /system/build.prop|grep "$keySoftVersion")
                    local deviceSdkVersion=$(adb shell cat /system/build.prop|grep "$keySDKVersion")
                else
                        ftEcho -e "adb连接状态[$adbStatus]异常,请重新尝试"
                       return
                fi
    elif [ -f "$filePathSystemBuildprop" ];then
                local deviceModelName=$(cat $filePathSystemBuildprop|grep "$keyModel")
                local deviceSoftType=$(cat $filePathSystemBuildprop|grep "$keySoftType")
                local deviceSoftVersion=$(cat $filePathSystemBuildprop|grep "$keySoftVersion")
                local deviceSdkVersion=$(cat $filePathSystemBuildprop|grep "$keySDKVersion")
    elif [ "$1" = "-bp" ];then
               ftEcho -s "未找到 $filePathSystemBuildprop\n版本软件信息未获取"
               return
    fi

    if [ ! -z "$deviceSoftVersion" ];then
            deviceModelName=${deviceModelName//$keyModel/}
            deviceModelName=${deviceModelName// /_}
            deviceModelName=$(echo $deviceModelName |sed s/[[:space:]]//g)
            deviceModelName=${deviceModelName:-'null'}
            export AutoEnv_deviceModelName=$deviceModelName

            deviceSoftType=${deviceSoftType//$keySoftType/}
            deviceSoftType=$(echo $deviceSoftType |sed s/[[:space:]]//g)
            deviceSoftType=${deviceSoftType:-'null'}
            export AutoEnv_deviceSoftType=$deviceSoftType

            deviceSoftVersion=${deviceSoftVersion//$keySoftVersion/}
            deviceSoftVersion=$(echo $deviceSoftVersion |sed s/[[:space:]]//g)
            deviceSoftVersion=${deviceSoftVersion:-'null'}
            export AutoEnv_deviceSoftVersion=$deviceSoftVersion

            deviceSdkVersion=${deviceSdkVersion//$keySDKVersion/}
            deviceSdkVersion=$(echo $deviceSdkVersion |sed s/[[:space:]]//g)
            deviceSdkVersion=${deviceSdkVersion:-'null'}
            export AutoEnv_deviceSdkVersion=$deviceSdkVersion
            local AndroidVersion=$(ftGetAndroidVersionBySDKVersion $deviceSdkVersion)
            export AutoEnv_AndroidVersion=$AndroidVersion
    fi

     if [ "$editType" = "-bp" ];then
        return
    fi
    # build.prop高级信息读取 end

    local dirPathLocal=$PWD
    cd $dirPathCode

    # 项目平台
    local dirPathVendor=${dirPathCode}/vendor
    if [ -d $dirPathVendor ];then
            dirList=`ls $dirPathVendor`
            for item in $dirList
            do
                if [ $item = "sprd" ];then
                    local mnufacturers=sprd
               elif [[ $item = "mediatek" ]]; then
                    local mnufacturers=mtk
               fi
            done
    else
              ftEcho -e "未找到 $dirPathVendor\n mnufacturers[项目平台] 获取失败"
    fi

    #device路径
    export AutoEnv_deviceDirPath=
    local dirPathDevice=$(find device/ -name "$(basename $ANDROID_PRODUCT_OUT)")
    if [[ -d "$dirPathDevice" ]]; then
        export AutoEnv_deviceDirPath=$dirPathDevice
    fi

    #分支名
    local branchName=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')

    #软件版本名
    if [ $mnufacturers = "sprd" ];then
            local keyVersion="findPreference(KEY_BUILD_NUMBER).setSummary(\""
            local filePathDeviceInfoSettings=${dirPathCode}/packages/apps/Settings/src/com/android/settings/DeviceInfoSettings.java
            if [ -f $filePathDeviceInfoSettings ];then
                local versionName=$(cat $filePathDeviceInfoSettings|grep $keyVersion)
                versionName=${versionName//$keyVersion/}
                versionName=${versionName//\");/}
                versionName=$(echo $versionName |sed s/[[:space:]]//g)
            fi
   elif [[ $mnufacturers = "mtk" ]]; then
            local filePathOutBuildProp=${dirPathOut}/system/build.prop
            if [ -f $filePathOutBuildProp ];then
                    local keyVersion="ro.build.display.id="
                    local versionName=$(cat $filePathOutBuildProp|grep $keyVersion)
                    versionName=${versionName//$keyVersion/}
                    if [ ! -z "$LZ_BUILD_VERSION" ]&&[[ "$versionName" != "$LZ_BUILD_VERSION" ]]; then
                            ftEcho -e "环境与本地，软件版本不一致:\n本地:${versionName}\n环境:${LZ_BUILD_VERSION}"
                    fi
            elif [ ! -z "$LZ_BUILD_VERSION" ];then
                    local versionName=$LZ_BUILD_VERSION
            fi
    fi
    if [ -z "$versionName" ];then
        versionName=`basename $ANDROID_PRODUCT_OUT`
    fi
    versionName=${versionName// /_}
    versionName=${versionName//
/_}

    #软件编译类型
    if [ -d $dirPathOut ];then
           local filePathBuildInfo=${dirPathOut}/system/build.prop
            if [ -f $filePathBuildInfo ];then
                        local keybuildType="ro.build.type="
                        local buildTypeFile=
                        if [ -f "$filePathBuildInfo" ];then
                            buildTypeFile=$(cat $filePathBuildInfo|grep $keybuildType)
                            if [ ! -z "$buildTypeFile" ];then
                                buildTypeFile=${buildTypeFile/$keybuildType/}
                                if [ ! -z "$buildType" ]&&[ "$buildType" != "$buildTypeFile" ];then
                                    ftEcho -e "环境与本地，编译类型不一致:\n本地:$buildTypeFile\n环境:$buildType"
                                    buildType=$buildTypeFile
                                fi
                            else
                                ftEcho -e "[$filePathBuildInfo]中未找到编译类型"
                            fi
                        fi
            else
                        ftEcho -e "未找到 $filePathBuildInfo\n build Type[本地] 获取失败"
            fi
    fi

    #git分支信息解析
    local branchName=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    local key="branchName="
    local filePathGitConfigInfoLocal=${dirPathOut}/git.info
    if [ -f "$filePathGitConfigInfoLocal" ];then
        local bn=$(cat $filePathGitConfigInfoLocal|grep "$key")
        if [ ! -z "$bn" ];then
            local branchNameFile=${bn//$key/}
            if [[ "$branchNameFile" != "$branchName" ]]; then
                    ftEcho -e "环境与本地，分支不一致:\n本地:$branchNameFile\n环境:$branchName"
            fi
            branchName=$branchNameFile
        else
            echo "${key}${branchName}" >>$filePathGitConfigInfoLocal
        fi
    elif [ -d "$dirPathOut" ];then
        echo "${key}${branchName}" >$filePathGitConfigInfoLocal
    fi
    if [[ $mnufacturers = "mtk" ]]; then
            if [ ! -z "$branchName" ];then
                local OLD_IFS="$IFS"
                IFS=")"
                local arrayItems=($branchName)
                IFS="$OLD_IFS"
                if [ "$branchName" = "$arrayItems" ];then
                        ftEcho -e "分支名:${branchName} 不合法,分支信息解析失败"
                else
                        for item in ${arrayItems[@]}
                        do
                                local valShort=${item:0:4}
                                local valLong=${item:0:5}

                                 if [[ $valShort = "_CT(" ]];then
                                    gitBranchInfoClientName=${item//$valShort/}
                                 elif [[ $valShort = "_PJ(" ]];then
                                    gitBranchInfoProjrctName=${item//$valShort/}
                                elif [[ $valShort = "_DM(" ]];then
                                    gitBranchInfoDemandSignName=${item//$valShort/}
                                elif [[ $valLong = "MBML(" ]];then
                                    gitBranchInfoMotherboardName=${item//$valLong/}
                                elif [[ $valLong = "_PMA(" ]];then
                                    gitBranchInfoModelAllName=${item//$valLong/}
                                fi

                                export AutoEnv_clientName=
                                export AutoEnv_projrctName=
                                export AutoEnv_modelAllName=
                                export AutoEnv_demandSignName=
                                export AutoEnv_motherboardName=

                                export AutoEnv_clientName=$gitBranchInfoClientName
                                export AutoEnv_projrctName=$gitBranchInfoProjrctName
                                export AutoEnv_modelAllName=$gitBranchInfoModelAllName
                                export AutoEnv_demandSignName=$gitBranchInfoDemandSignName
                                export AutoEnv_motherboardName=$gitBranchInfoMotherboardName
                        done
                fi
            fi
    fi

    export AutoEnv_buildType=
    export AutoEnv_branchName=
    export AutoEnv_versionName=
    export AutoEnv_mnufacturers=

    export AutoEnv_buildType=$buildType
    export AutoEnv_branchName=$branchName
    export AutoEnv_versionName=$versionName
    export AutoEnv_mnufacturers=$mnufacturers

    cd $dirPathLocal
}

ftMonkeyTestByDevicesName()
{
    local ftEffect=自动化monkey测试
    local editType=$1
    local eventCount=$2
    local throttleTimeLong=300
    local configList=

    editType=${editType:-'-a'}
    eventCount=${eventCount:-'1000000'}
    if (  echo -n $editType | grep -q -e "^[0-9][0-9]*$");then
        eventCount=$editType
        editType=-a
    fi
    if (( $throttleTimeLong>-1 ));then
        configList=" --throttle $throttleTimeLong"
    fi

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftMonkeyTestByDevicesName #无参数 默认错误不退出,1000000次
#    ftMonkeyTestByDevicesName [eventCount]
#    ftMonkeyTestByDevicesName 1000000
#    ftMonkeyTestByDevicesName [editType]
#    ftMonkeyTestByDevicesName -b #黑名单功能
#    ftMonkeyTestByDevicesName -w #白名单功能
#    ftMonkeyTestByDevicesName [editType] [eventCount]
#    ftMonkeyTestByDevicesName -b/-w 1000000
#=========================================================
EOF
    rm -rf $dirPathMoneyLog
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    local valCount=2
    local errorContent=
    if (( $#>$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$rNameUser" ];then    errorContent="${errorContent}\\n[用户名为空]rNameUser=$rNameUser" ; fi
    if ( ! echo -n $editType | grep -q -e "^[0-9][0-9]*$")\
        &&( ! echo -n $eventCount | grep -q -e "^[0-9][0-9]*$");then    errorContent="${errorContent}\\n[事件数不是整数]eventCount=$eventCount" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftMonkeyTestByDevicesName -h
            return
    fi

    #adb连接状态检测
    adb wait-for-device
    local adbStatus=$(adb get-state)
    if [ "$adbStatus" != "device" ];then
        ftEcho -e "adb连接状态[$adbStatus]异常,请重新尝试"
        return
    fi
    #======================================================
    #==============  手机设备信息 ===========================
    #========================== ===========================
    ftAutoInitEnv -bp -mobile
    local deviceModelName=$AutoEnv_deviceModelName
    local deviceSoftType=$AutoEnv_deviceSoftType
    local SoftVersion=$AutoEnv_deviceSoftVersion
    local SDKVersion=$AutoEnv_deviceSdkVersion
    local AndroidVersion=$AutoEnv_AndroidVersion

    local logDate="$(date -d "today" +"%y%m%d")"
    local logDateTime="$(date -d "today" +"%y%m%d%H%M%S")"

    #======================================================
    #==============  monkey命令配置 =========================
    #========================== ===========================
    local dirPathLocal=$(pwd)
    local dirPathDevice=/data/local/tmp
    local dirPathDeviceSDCard=/storage/sdcard0

    local deviceSDCardState=$(adb shell ls $dirPathDeviceSDCard|grep "No such file or directory")
    if [ -z "$deviceSDCardState" ]&&[ -z "$(adb shell ls $dirPathDeviceSDCard)" ];then #空目录
        deviceSDCardState=null
    fi
    if [ -z "$deviceSDCardState" ];then
        local dirPathMoneyLog=${dirPathDeviceSDCard}/monkey/EditDevice[oneself]____softInfo[${deviceSoftType}_${AndroidVersion}___${SoftVersion}]_____${logDate}
        adb shell mkdir -p $dirPathMoneyLog
    else
        local dirPathMoneyLog=${dirPathLocal}/monkey/EditDevice[${rNameUser}]____softInfo[${deviceSoftType}_${AndroidVersion}___${SoftVersion}]____${logDate}
        mkdir -p $dirPathMoneyLog
    fi
    local dirPathMoneyLogLocal=${dirPathLocal}/monkey/PcName[${rNameUser}]____softInfo[${deviceSoftType}_${AndroidVersion}___${SoftVersion}]____${logDate}
    local filePathLogLogcat=${dirPathMoneyLog}/${logDateTime}.logcat
    local filePathLogMonkey=${dirPathMoneyLog}/${logDateTime}.monkey
    local fileNamePackageNameListWhite=${logDateTime}.whitelist
    local fileNamePackageNameListBlack=${logDateTime}.blacklist
    local FilePathXbashDataMonkeyConfigLocalWhite=${dirPathMoneyLogLocal}/${fileNamePackageNameListWhite}
    local FilePathXbashDataMonkeyConfigLocalBlack=${dirPathMoneyLogLocal}/${fileNamePackageNameListBlack}
    local FilePathXbashDataMonkeyConfigDeviceWhite=${dirPathDevice}/${fileNamePackageNameListWhite}
    local FilePathXbashDataMonkeyConfigDeviceBlack=${dirPathDevice}/${fileNamePackageNameListBlack}

    configList="${configList} --ignore-crashes --ignore-timeouts --ignore-security-exceptions "

    while true; do case "$editType" in
    -b | -B)
                local FilePathXbashDataMonkeyConfigLocalTraget=$FilePathXbashDataMonkeyConfigLocalBlack
                local FilePathXbashDataMonkeyConfigDeviceTraget=$FilePathXbashDataMonkeyConfigDeviceBlack
                break;;
    -w | -W)
                local FilePathXbashDataMonkeyConfigLocalTraget=$FilePathXbashDataMonkeyConfigLocalWhite
                local FilePathXbashDataMonkeyConfigDeviceTraget=$FilePathXbashDataMonkeyConfigDeviceWhite
                break;;
    * ) break;; esac;done

    while true; do case "$editType" in
    -a | -A)
                configList="${configList} -v -v -v "
                break;;
    -b | -B| -w | -W)
                if [ ! -z "$(pgrep -f gedit)" ];then
                     while true; do
                            echo
                            ftEcho -y gedit 已打开是否关闭
                            read -n 1 sel
                            case "$sel" in
                                y | Y )    kill -9 $(ps -e|grep gedit |awk '{print $1}')
                                            break;;
                                n | N |q |Q)    return;;
                                * ) ftEcho -e 错误的选择：$sel
                                    echo "输入n,q，离开"
                        ;; esac;done
                fi

                rm -f $FilePathXbashDataMonkeyConfigLocalBlack
                rm -f $FilePathXbashDataMonkeyConfigLocalWhite
                mkdir -p $dirPathMoneyLogLocal
                gedit $FilePathXbashDataMonkeyConfigLocalTraget&&
                while [ ! -z "$(pgrep -f gedit)" ]
                do
                    echo 等待中
                done
                if [ -f "$FilePathXbashDataMonkeyConfigLocalBlack" ];then
                    adb push $FilePathXbashDataMonkeyConfigLocalBlack $dirPathDevice
                    rm -f $FilePathXbashDataMonkeyConfigLocalBlack
                    configList="${configList} --pkg-blacklist-file $FilePathXbashDataMonkeyConfigDeviceTraget"
                    configList="${configList} -v -v -v "

                elif [ -f "$FilePathXbashDataMonkeyConfigLocalWhite" ];then
                    adb push $FilePathXbashDataMonkeyConfigLocalWhite $dirPathDevice
                    rm -f $FilePathXbashDataMonkeyConfigLocalWhite
                    configList="${configList} --pkg-whitelist-file $FilePathXbashDataMonkeyConfigDeviceTraget"
                    configList="${configList} -v -v -v "

                else
                    ftEcho -e "Monkey测试配置--pkg-xxxxlist文件不存在[$FilePathXbashDataMonkeyConfigDeviceTraget]\\n请查看下面说明:"
                    ftMonkeyTestByDevicesName -h
                    return
                fi
                break;;
    * )
                ftEcho -ea "函数[${ftEffect}]的参数错误${editType}\\n请查看下面说明:"
                ftMonkeyTestByDevicesName -h
                return
                 break;;
    esac;done

    mkdir -p $dirPathMoneyLogLocal
    local upgradeAdbPermissionsStae=$(adb root;adb remount)
    local changDeviceSerialNumber=$(adb shell "echo $logDateTime>/sys/class/android_usb/android0/iSerial")
    if [ -z "$changDeviceSerialNumber" ];then
        configList="-s $logDateTime ${configList}"
    fi

    if [ -z "$deviceSDCardState" ];then
        adb shell "echo 'monkey starting, log save in $filePathLogMonkey...' > $filePathLogMonkey"
        adb shell "monkey ${configList} $eventCount 1>> $filePathLogMonkey 2>> $filePathLogMonkey"
    else
        adb logcat "*:E" 2>&1|tee $filePathLogLogcat&
        adb shell "monkey ${configList} $eventCount" 2>&1 |tee $filePathLogMonkey
        exit
    fi

}

ftGetAndroidVersionBySDKVersion()
{
    local ftEffect=根据SDK版本获取Android版本
    local sdkVersion=$1

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftGetAndroidVersionBySDKVersion 1.0~25
#    ftGetAndroidVersionBySDKVersion 22
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    local valCount=1
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$sdkVersion" ];then    errorContent="${errorContent}\\n[SDK版本]sdkVersion=$sdkVersion" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftGetAndroidVersionBySDKVersion -h
            return
    fi

        while true; do case "$sdkVersion" in
        25) echo Android7.1              ;break;;
        24) echo Android7.0              ;break;;
        23) echo Android6.0              ;break;;
        22) echo Android5.1              ;break;;
        21) echo Android5.0              ;break;;
        19) echo Android4.4              ;break;;
        18) echo Android4.3              ;break;;
        17) echo Android4.2              ;break;;
        16) echo Android4.1              ;break;;
        15) echo Android4.0.3-4.0.4  ;break;;
        14) echo Android4.0.1-4.0.2  ;break;;
        13) echo Android3.2x             ;break;;
        12) echo Android3.1               ;break;;
        11) echo Android3.0               ;break;;
        10) echo Android2.3.3-2.3.7   ;break;;
        9) echo Android2.3-2.3.2        ;break;;
        * ) echo "unkonwSdkVersion=${sdkVersion}"; break;;esac;done

    # while true; do case "$sdkVersion" in
    #  # 26) echo "Android 8.0 Oreo"                                ;break;;
    #     25) echo "Android 7.1 Nougat"                                ;break;;
    #     24) echo "Android 7.0 Nougat"                                ;break;;
    #     23) echo "Android 6.0 Marshmallow"             ;break;;
    #     22) echo "Android 5.1 Lollipop"                       ;break;;
    #     21) echo "Android 5.0 Lollipop"                       ;break;;
    #     19) echo "Android 4.4 KitKat"                           ;break;;
    #     18) echo "Android 4.3 Jelly Bean"                     ;break;;
    #     17) echo "Android 4.2 Jelly Bean"                    ;break;;
    #     16) echo "Android 4.1 Jelly Bean"                    ;break;;
    #     15) echo "Android 4.0.3-4.0.4 Jelly Bean"        ;break;;
    #     14) echo "Android 4.0.1-4.0.2 Jelly Bean"        ;break;;
    #     13) echo "Android 3.2x Honeycomb"               ;break;;
    #     12) echo "Android 3.1 Honeycomb"                ;break;;
    #     11) echo "Android 3.0 Honeycomb"                ;break;;
    #     10) echo "Android 2.3.3-2.3.7 Gingerbread"  ;break;;
    #       9) echo "Android 2.3-2.3.2 Gingerbread"       ;break;;
    #     * ) echo "unkonwSdkVersion=${sdkVersion}"; break;;esac;done
}

complete -W "backup restore" ftMaintainSystem
ftMaintainSystem()
{
    local ftEffect=ubuntu系统维护
    local fileNameMaintain=maintain.sh
    local filePathMaintain=${rDirPathCmdsModule}/${fileNameMaintain}
    local editType=$1
    editType=${editType:-'backup'}

    while true; do case "$1" in
    e | -e |--env) cat<<EOF
#===================[   ${ftEffect}   ]的使用环境说明=============
#
#    当前用户权限过低，请转换为root 用户后重新运行
#=========================================================
EOF
      return;;
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftMaintainSystem 操作类型
#    ftMaintainSystem backup #备份系统
#    ftMaintainSystem restore #还原备份
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #环境校验
    if [ "$(whoami)" != "root" ];then
        ftMaintainSystem -e
        return
    fi
    #耦合校验
    local valCount=1
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -f "$filePathMaintain" ];then    errorContent="${errorContent}\\n[维护脚本不存在]filePathMaintain=$filePathMaintain" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftMaintainSystem -h
            return
    fi

    $filePathMaintain $editType
}