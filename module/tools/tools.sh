 #!/bin/bash
#####---------------------  说明  ---------------------------#########
# 不可在此文件中出现不被函数包裹的调用或定义
# 人话，这里只放函数
# complete -W "example example" ftExample
#####---------------------  初始化依赖 ---------------------------#########
if [ -f $rFilePathCmdModuleToolsBase ];then
    source  $rFilePathCmdModuleToolsBase
else
    echo -e "\033[1;31mXbash函数加载失败[未找到$rFilePathCmdModuleToolsBase]\033[0m"
fi
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
    -h|-help|help|--help|HELP|-HELP|--HELP)
                ftMain -ft ; echo
                ftMain -hb
                return;;
    -hb |-HB)   ftEcho -s "bash内建命令和xbash扩展封装说明"
 cat<<EOF
====================================
命令           说明
====================================
EOF
                ftReadAllAlias| column -t
                return;;
    ft | -ft |-hc |HC )   ftEcho -s "xbash对bash扩展实现说明"
cat<<EOF
=========================================================
命令                             说明
=========================================================
EOF
                ftReadAllFt | column -t
                return;;
    vvv | -vvv)
                ftEcho -b xbash;        echo \"Xrnsd extensions to bash\" $rXbashVersion
                ftEcho -b java;        java -version
                ftEcho -b gcc;        gcc -v
                break;;
    restartadb)    ftRestartAdb
                break;;
    *)    ftEcho -s " xc -h    #查看所有说明\n xc -hb   #bash内建命令和xbash扩展封装说明\n xc -hc   #xbash对bash扩展实现说明"
            return;;
    esac
    done
}

ftAutoBuildMultiBranch()
{
    local ftEffect=多分支串行编译
    local filePathBranchList=branch.list
    local dirPathCode=$ANDROID_BUILD_TOP
    local dirPathCodeOut=$ANDROID_PRODUCT_OUT
    
    local editType=$1
    local timeLong=$2

    if (  echo -n $editType | grep -q -e "^[0-9][0-9]*$")&&[[ -z "$timeLong" ]];then
        timeLong=$editType
        edittype=
    fi
    editType=${editType:-'-b'}

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftAutoBuildMultiBranch 无参
#
#    ftAutoBuildMultiBranch -u 上传版本软件
#    ftAutoBuildMultiBranch -b 备份out
#    ftAutoBuildMultiBranch -ub或-bu 上传,备份out
#    ftAutoBuildMultiBranch -a 上传,备份out
#
#    ftAutoBuildMultiBranch 时间[秒]   延时操作
#    ftAutoBuildMultiBranch -xx 时间[秒]   延时操作
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
    local valCount=2
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
        ftEcho -s "将不会上传软件包，备份out"
    else
        editType=$(echo $editType | tr '[A-Z]' '[a-z]')
        if (( $(expr index $editType "a") != "0" ));then
             isUpload=true
             isBackupOut=true
        else
            if (( $(expr index $editType "u") != "0" ));then   isUpload=true ; fi
            if (( $(expr index $editType "b") != "0" ));then   isBackupOut=true ; fi
        fi
    fi
    if [ -d "$dirPathCodeOut" ];then
         while true; do
                    echo
                    ftEcho -y out已存在,选择
                    read -n 1 sel
                    case "$sel" in
                        y | Y | -y  |  b  | B | b )    ftBackupOrRestoreOuts
                                      break;;
                        d | D )    rm -rf $dirPathCodeOut
                                      break;;
                        n | N |q | Q |e |E)    break;;
                        * ) ftEcho -e 错误的选择：$sel
                            echo "输入n/q/e 按键跳过"
                            ;;
                    esac
            done
    fi

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
                echo branchName=$line
            done
            while true; do
                    echo
                    ftEcho -y 是否开始编译
                    read -n 1 select
                    case "$select" in
                        y | Y )
                                        if [[ ! -z "$timeLong" ]]; then
                                            tput sc
                                            for i in `seq -w $timeLong -1 1`
                                            do
                                                echo -ne "\033[1;31m将在${i}秒开始编译，ctrl+c 取消\033[0m"
                                                tput rc
                                                tput ed
                                                sleep 1
                                            done
                                        fi
                                        cat $filePathBranchList | while read line
                                        do
                                            local branchName=$line
                                            git reset --hard&&
                                            ftEcho -bh 将开始编译$branchName
                                            git checkout   "$branchName"||git reset --hard
                                            # git pull

                                            filePath=device/sprd/scx20/sp7731c_1h10_32v4/sp7731c_1h10_32v4_oversea.mk
                                            if [[ ! -z $(cat $filePath|grep "product.default.sfingerprint") ]];then
                                                git cherry-pick b8f9544&&git pull&&git push
                                            fi


                                            # ftAutoInitEnv
                                            # local cpuCount=$(cat /proc/cpuinfo| grep "cpu cores"| uniq)
                                            # cpuCount=$(echo $cpuCount |sed s/[[:space:]]//g)
                                            # cpuCount=${cpuCount//cpucores\:/}
                                            # if [[ $AutoEnv_mnufacturers = "sprd" ]]; then
                                            #             #if [ "$TARGET_PRODUCT" != "sp7731c_1h10_32v4_oversea" ];then
                                            #             source build/envsetup.sh&&
                                            #             lunch sp7731c_1h10_32v4_oversea-user&&
                                            #             kheader&&
                                            #             make -j${cpuCount} 2>&1|tee -a out/build_$(date -d "today" +"%y%m%d%H%M%S").log||break
                                            #             if [ $isUpload = "true" ];then
                                            #                 ftAutoPacket -a
                                            #             else
                                            #                 ftAutoPacket
                                            #             fi
                                            #             if [ $isBackupOut = "true" ];then
                                            #                 ftBackupOrRestoreOuts
                                            #             fi
                                            # elif [[ $AutoEnv_mnufacturers = "mtk" ]]; then
                                            #         local deviceName=`basename $ANDROID_PRODUCT_OUT`
                                            #         if [ $deviceName = "keytak6580_weg_l" ];then
                                            #             source build/envsetup.sh&&
                                            #             lunch full_keytak6580_weg_l-user&&
                                            #             mkdir out
                                            #             make -j${cpuCount} 2>&1|tee -a out/build_$(date -d "today" +"%y%m%d%H%M%S").log||break

                                            #             branchName=$(echo $AutoEnv_branchName | tr '[A-Z]' '[a-z]') #转小写
                                            #             if [[ "$branchName" != *fm* ]];then
                                            #                 make otapackage
                                            #             fi

                                            #             if [ $isUpload = "true" ];then
                                            #                 ftAutoPacket -a
                                            #             else
                                            #                 ftAutoPacket
                                            #             fi
                                            #             if [ $isBackupOut = "true" ];then
                                            #                 ftBackupOrRestoreOuts
                                            #             fi
                                            #         else
                                            #             ftAutoBuildMultiBranch -e
                                            #             return;
                                            #         fi
                                            # fi

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

complete -W "-b -h" ftAutoBuildMultiBranchEnvSeparation
ftAutoBuildMultiBranchEnvSeparation()
{
    local ftEffect=多分支串行编译[环境独立]/在多个终端间串行执行命令
    local editType=$1
    editType=$(echo $editType | tr '[A-Z]' '[a-z]')

    local filePathserialBuildTool=${rDirPathCmdModuleTools}/build/serialBuildByBranchName.sh
    local dirPathProcessEnableId=/tmp/ProcessEnableIds

    while true; do case "$editType" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#    查看帮助
#    ftAutoBuildMultiBranchEnvSeparation -h
#
#    根据分支列表进行串行编译
#    ftAutoBuildMultiBranchEnvSeparation -b
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
    * ) ftAutoBuildMultiBranchEnvSeparation -h
     break;;esac;done

    #耦合校验
    if [ -z "$ANDROID_BUILD_TOP" ];then
        ftAutoBuildMultiBranch -env
        return
    fi

    local requestEnvState=$(/bin/rm -rf $dirPathProcessEnableId&&mkdir $dirPathProcessEnableId)

    #耦合校验
    local valCount=1
    local errorContent=
    if (( $#>$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$editType" ];then    errorContent="${errorContent}\\n[请指定操作]" ; fi
    if [ ! -z "$requestEnvState" ];then    errorContent="${errorContent}\\n[环境初始化异常,文件夹无法重置]requestEnvState=$requestEnvState" ; fi
    if [ ! -f "$filePathserialBuildTool" ];then    errorContent="${errorContent}\\n[串行编译工具不存在]filePathserialBuildTool=$filePathserialBuildTool" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftAutoBuildMultiBranchEnvSeparation -h
            return
    fi

    if [[ "$editType" = "-b" ]]; then
        local dirPathCode=$ANDROID_BUILD_TOP
        local filePathBranchList=${dirPathProcessEnableId}/branch.list
        cd $dirPathCode

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
        local branchArray=($(cat $filePathBranchList))
        if [ ! -z "$branchArray" ];then
                    export branchArray
                    echo enable>${dirPathProcessEnableId}/0
                    for (( index = 0; index <${#branchArray[@]}; index++ )); do
                        filePathState="${dirPathProcessEnableId}/${index}"
                        while [ ! -f "$filePathState" ]||[ "enable" != $(cat $filePathState) ]; do
                                sleep 2
                        done
                        gnome-terminal  --title="任务:${index} : 编译${branchArray[$fileNamePID]}" -x bash -c "$filePathserialBuildTool $filePathBranchList $index"
                    done
        fi
    fi
}

ftReadAllAlias()
{
        local ftEffect=显示bash内建等命令封装说明_nodisplay

        if [[ -f $filePathXbashTragetBashrcBase ]]; then
            local cmdName=
            local cmdContent=
            cat $filePathXbashTragetBashrcBase|grep alias  | while read line; do
                    cmdName=$(echo $line | awk '{split($2,b,"=");print  b[1] }')
                    cmdContent=$(echo $line | awk '{split($2,b,"=");print  b[3]}'| awk '{split($0,b,";");print  b[1]}')
                    if [[ ! -z "$cmdContent" ]]; then
                        printf "%14s  " $cmdName;echo $cmdContent
                    fi
            done
        else
            ftEcho -e "xbash配置不存在:$filePathXbashTragetBashrcBase"
        fi
}

ftReadAllFt()
{
        local ftEffect=查看xbash对bash扩展实现说明_nodisplay

        local key="local ftEffect="
        for effectName in $(cat $rFilePathCmdModuleToolsSpecific |grep '^ft')
        do
            effectDescription=$(cat $rFilePathCmdModuleToolsSpecific |grep  -C 3 $effectName|grep "$key")
            effectDescription=${effectDescription//$key/}
            effectDescription=$(echo $effectDescription |sed s/[[:space:]]//g)
            if [[ ${effectDescription: -9} = "nodisplay" ]];then
                continue;
            fi
            effectName=${effectName//()/}
            #echo "$effectName $effectDescription"

            printf "%40s  " $effectName;echo $effectDescription
        done
}

ftKillApplicationByPackageName()
{
    local ftEffect=kill掉包名为packageName的应用
    local packageName=$1

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftKillApplicationByPackageName [packageName]
#    ftKillApplicationByPackageName com.android.settings
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
            ftKillApplicationByPackageName -h
            return
    fi

    #adb连接状态检测
    adb wait-for-device
    local adbStatus=$(adb get-state)
    if [ "$adbStatus" != "device" ];then
        ftEcho -e "adb连接状态[$adbStatus]异常,请重新尝试"
        return
    fi

    while true; do case "$packageName" in
        systemui)   packageName="com.android.systemui"  ;break;;
        launcher3) packageName="com.android.launcher3"  ;break;;
        monkey)     packageName="com.android.commands.monkey"  ;break;;
    * ) break;;esac;done

    local pid=$(adb shell ps | grep $packageName | awk '{print $2}')
    if ( echo -n $pid | grep -q -e "^[0-9][0-9]*$"); then
        # adb shell am force-stop $packageName && ftEcho -s "kill $pid"
        local rootInfo=$(adb root|grep cannot)
        local remountInfo=$(adb remount|grep failed)
        if [[ ! -z "$rootInfo" ]]; then
            ftEcho -e "adb提权失败:$rootInfo"
        elif [[ ! -z "$remountInfo" ]]; then
            ftEcho -e "adb提权失败:$remountInfo"
        fi

        adb shell kill $pid&&ftEcho -s "kill $pid"
    elif [[ -z "$(adb shell pm list packages|grep $packageName)" ]]; then
         ftEcho -e 包名[${packageName}]不存在，请确认
        while [ ! -n "$(adb shell pm list packages|grep $packageName)" ]; do
            ftEcho -y 是否重新开始
            read -n 1 sel
            case "$sel" in
                y | Y )
                    # adb shell am force-stop $packageName
                    ftKillApplicationByPackageName $packageName
                    break;;
                * )if [ "$XMODULE" = "env" ];then    return ; fi
                    exit;;
            esac
        done
    fi
}

ftLogcatApplicationByPackageName()
{
    local ftEffect=打印指定log
    local packageName=$1
    local vContent=$2
    if [[ -z "$packageName" ]]; then
        adb logcat 
        return;
    fi

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#     打印所有log
#    ftLogcatApplicationByPackageName
#
#     打印包名为 com.android.settings的应用输出的log
#    ftLogcatApplicationByPackageName com.android.settings
#
#     打印包含123456的log
#    ftLogcatApplicationByPackageName 123456
#
#     打印包含123456 不包含777  的log
#    ftLogcatApplicationByPackageName 123456 7777
#
#=========================================================
EOF

    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    local valCount=2
    local errorContent=
    if (( $#>$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$packageName" ];then    errorContent="${errorContent}\\n[应用包名]packageName=$packageName" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftLogcatApplicationByPackageName -h
            return
    fi

    #adb连接状态检测
    adb wait-for-device
    local adbStatus=$(adb get-state)
    if [ "$adbStatus" != "device" ];then
        ftEcho -e "adb连接状态[$adbStatus]异常,请重新尝试"
        return
    fi

    while true; do case "$packageName" in
        systemui)   packageName="com.android.systemui"  ;break;;
        launcher3) packageName="com.android.launcher3"  ;break;;
    * ) break;;esac;done

    local pid=$(adb shell ps | grep $packageName | awk '{print $2}')
    if ( echo -n $pid | grep -q -e "^[0-9][0-9]*$"); then
            if [[ ! -z "$vContent" ]]; then
                adb logcat |grep $pid |grep -v $vContent
                return;
            fi
            adb logcat |grep $pid
    else
            if [[ ! -z "$vContent" ]]; then
                adb logcat |grep -i $packageName |grep -v $vContent
                return;
            fi
            adb logcat |grep -i $packageName
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
    if [ -z "$userPassword" ];then    errorContent="${errorContent}\\n[默认用户密码]userPassword=$userPassword" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -eax "$errorContent \\n请查看下面说明:"
            ftRestartAdb -h
            return
    fi
    echo $userPassword | sudo -S echo test >/dev/null
    echo $userPassword | sudo -S adb kill-server >/dev/null
    echo
    echo "server kill ......"
    sleep 2
    echo $userPassword | sudo -S adb start-server >/dev/null
    echo "server start ......"
    adb devices
}

ftMtkFlashTool()
{
    local ftEffect=mtk下载工具
    local tempDirPath=`pwd`
    export OLDPWD=$tempDirPath
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
    echo "$userPassword" | sudo -S ${rDirPathTools}/sp_flash_tool_v5.1612.00.100/flash_tool
    cd $tempDirPath
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

        ftEcho -r  "请输入动画包的包名(回车默认animation):"
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
                local filePath=/${rDirPathUserHome}/${dirNamePackageName}
                if [ -f $filePath ];then
                    while true; do
                    echo
                    ftEcho -y 有旧的${dirNamePackageName}，是否覆盖
                    read -n 1 sel
                    case "$sel" in
                        y | Y )    break;;
                        n | N)    mv $filePath /${rDirPathUserHome}/${dirNamePackageName/.zip/_old.zip};break;;
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
            cd $dirPathAnimationSourceRes && trap 'cd $dirPathLocal;exit' SIGINT
            for file in $filelist
            do
                if [ ! -f "$file" ];then
                    ftEcho -ex 动画资源包含错误类型的文件[${file}]，请确认
                fi
            done
            cd $dirPathLocal
        fi

        dirPathAnimationTraget=/${rDirPathUserHome}/${dirNameAnimation}

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
                    ftEcho -r  请输入动画的宽:
                    read resolutionWidth
                  elif [ -z "$resolutionHeight" ]; then
                    ftEcho -r  请输入动画的高:
                    read resolutionHeight
                  elif [ -z "$frameRate" ]; then
                    ftEcho -r  请输入动画的帧率:
                    read frameRate
                  elif [ -z "$cycleCount" ]; then
                    ftEcho -r  请输入动画的循环次数:
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
    if [ -z "$userPassword" ];then    errorContent="${errorContent}\\n[用户密码为空]userPassword=$userPassword" ; fi
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
            tput sc
            for i in `seq -w $timeLong -1 1`
            do
                tput rc;tput ed
                echo -ne "\033[1;31m将在${i}秒后关机，ctrl+c 取消\033[0m"
                sleep 1
            done
            echo $userPassword | sudo -S shutdown -h now
            break;;
        reboot)
            tput sc
            for i in `seq -w $timeLong -1 1`
            do
                tput rc;tput ed
                echo -ne "\033[1;31m将在${i}秒后重启，ctrl+c 取消\033[0m";
                sleep 1
            done
            echo $userPassword | sudo -S reboot
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
        ftEcho -r  "请输入保留的百分比:"
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

complete -W "-z" ftReNameFile
ftReNameFile()
{
    local ftEffect=批量重命名文件

    if [[ "$1" == "-z" ]]; then
         local editTypePrefixes=$1
         local dirPathFileList=$2
         local prefixContent=$3
         local suffixContent=$4
    else
        local dirPathFileList=$1
        local lengthFileName=$2
    fi

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    不指定文件名长度默认为4
#    ftReNameFile 目录
#    ftReNameFile /home/xxxx/temp
#    ftReNameFile 目录 修改后的文件长度
#    ftReNameFile /home/xxxx/temp 5
#
#    ftReNameFile 目录 修改后的文件长度 前缀
#    ftReNameFile -z /home/xxxx/temp test
#    ftReNameFile 目录 修改后的文件长度 前缀 文件名后缀
#    ftReNameFile -z /home/xxxx/temp test test2
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    local valCount=4
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

    local dirNameFileListRename=RenameFiles
    local dirPathFileListRename=${dirPathFileList}/${dirNameFileListRename}
    local index=0
    local lengthFileNameBase=

    if [ -d $dirPathFileListRename ];then
        rm -rf $dirPathFileListRename
    fi
    mkdir $dirPathFileListRename
    cd $dirPathFileList
    for file in `ls $dirPathFileList|tr " " "?"`
    do
        if [ $file == $dirNameFileListRename ];then
            continue
        fi

        file=${file//'?'/' '}
        file=$(echo $file |sed s/[[:space:]]//g)
        local fileName=${file%.*}
        local fileFormatName=${file##*.}

        if [[ -z  "lengthFileNameBase" ]]||[ ${#lengthFileNameBase} = "0" ]; then
                if [[ -z "$lengthFileName" ]]; then
                    lengthFileName=${#fileName}
                fi
                lengthFileNameBase=1
                while (( $lengthFileName > 0  ))
                do
                    lengthFileName=`expr $lengthFileName - 1`
                    lengthFileNameBase=$(( $lengthFileNameBase * 10 ))
                done
        fi
        fileNameBase=$((lengthFileNameBase+$index))
        if [[ -z "$editTypePrefixes" ]]; then
            fileName=${fileNameBase:1}
        fi
        cp -f "${dirPathFileList}/${file}" ${dirPathFileListRename}/${prefixContent}${fileName}${suffixContent}.${file##*.}
        index=`expr $index + 1`
    done
}

#===================    非通用实现[高度耦合]    ==========================
ftBackupOrRestoreOuts()
{
    local ftEffect=Android编译生成out相关自动维护
    local dirPathCode=$ANDROID_BUILD_TOP
    local dirPathOut=$ANDROID_PRODUCT_OUT
    local editType=$1
    local filterString=$2

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#    备份out
#    ftBackupOrRestoreOuts 无参
#    移动匹配out到当前项目
#    ftBackupOrRestoreOuts -m
#    ftBackupOrRestoreOuts -m xxx   #分支名包含xxx的out列表
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

    local valCount=2
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
    local versionInfoDateTime=$(date -d "today" +"%y%m%d[%H:%M]")
    local dirNameBranchVersion=BuildType[${buildType}]----BranchName[${branchName}]----VersionName[${versionName}]----${versionInfoDateTime}
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
        local branchName=$filterString
        if [[ -z "$filterString" ]]; then
            branchName=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
        fi
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
            ftEcho -r  "请输入对应的序号(回车默认0):"
            if (( $itemCount>9 ));then
                read tIndex
            else
                read -n 1 tIndex
            fi&&echo
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

        local fileNameGitLogInfo=git.log
        local filePathGitLogInfo=${dirPathOutTop}/${fileNameGitLogInfo}
        if [[ ! -f $filePathGitLogInfo ]]; then
            touch $filePathGitLogInfo
        fi
        echo -e "
======================================================================================================
$dirNameBranchVersion
======================================================================================================
$(git log --date=format-local:'%y%m%d-%H:%M:%S' --pretty=format:"%ad %an %h %s %d" -20)" >> $filePathGitLogInfo
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
    if [[ $AutoEnv_mnufacturers != "sprd" ]]&&[ "$TARGET_PRODUCT" != "sp7731c_1h10_32v4_oversea" ]; then
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
    #服务器具体路径[相对]
    local pathContentUploadTraget=$3
    #存放上传源的目录[绝对],为服务器挂载在本地的绝对路径
    local dirPathContentUploadSourceRoot=$4
    if [ -z "$pathContentUploadTraget" ];then
            pathContentUploadTraget=智能机软件/autoUpload
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
    local valCount=4
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
    #服务器路径[根][真实]
    local dirPathServer=/media/新卷/${pathContentUploadTraget}
    local dirPathServerLocalBase=/media/server/1.188
    local dirPathServerLocal=${dirPathServerLocalBase}/${pathContentUploadTraget}
    if [[ ! -d "$dirPathServerLocal" ]]; then
        mkdir -p $dirPathServerLocal
    fi
    # 自动添加旧软件的TAG
    if [[ ! -z "$dirPathContentUploadSourceRoot" ]]; then
        local dirPathServerLocalRoot=${dirPathServerLocal}/$(echo $dirPathContentUploadSourceRoot|sed -e "s:$dirPathContentUploadSource::g")
        if [[ -d $dirPathServerLocalRoot ]]; then
                local versionPath=$(dirname $dirPathServerLocalRoot)
                local versionName=$(basename $dirPathServerLocalRoot)

                 ls $versionPath | while read line;do
                    if [[  ${line//$versionName} != $line ]]; then
                        local dirPath=${versionPath}/${line}
                        local dirPath_old=${dirPath}_old
                        if [[ -d "$dirPath_old" ]]; then
                            dirPath_old=${dirPath_old}_old
                        fi
                        mv $dirPath $dirPath_old
                    fi
                done
        fi
    fi

    ftEcho -s "开始上传到  ${serverIp}/${pathContentUploadTraget}"
    cd $dirPathContentUploadSource && trap 'cd $dirPathLocal;exit' SIGINT
    ftTiming -i

    tar -cv  $pathContentUploadSource| pigz -1 |sshpass -p $pasword ssh $userName@$serverIp "gzip -d|tar -xPC $dirPathServer"

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
    if [[ $AutoEnv_mnufacturers != "sprd" ]]&&[ "$TARGET_PRODUCT" != "sp7731c_1h10_32v4_oversea" ]; then
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


complete -W "-a" ftAutoPacket
ftAutoPacket()
{
    # trap 'printf "变量跟踪\e[33m %-7s \e[0m \e[31m %-90s \e[0m  \n" [$LINENO]: dirPathVersionSoftwareVersion=$dirPathVersionSoftwareVersion' DEBUG
    # trap 'printf "变量跟踪\e[33m %-7s \e[0m \e[31m %-90s \e[0m  \n" [$LINENO]: dirPathVersionSoftwareVersion=$dirPathVersionSoftwareVersion' ERR
    
    local ftEffect=基于android的out生成版本软件包
    local dirPathCode=$ANDROID_BUILD_TOP
    local dirPathOut=$ANDROID_PRODUCT_OUT
    local buildType=$TARGET_BUILD_VARIANT
    local editType=$1
    local filePathDataBase=${rDirPathCmdsConfigData}/tools.db

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftAutoPacket #自动打包
#    ftAutoPacket -y #免确认自动清理out/packet
#    ftAutoPacket -u #上传到188服务器
#    ftAutoPacket -r  #添加说明
#    ftAutoPacket -p #打包
#    ftAutoPacket -ryup # 根据需要,自由组合,顺序,大小写随意
#    ftAutoPacket -a #默认启动全部流程
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
    local valCount=2
    local errorContent=
    if (( $#>$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -d "$dirPathCode" ];then    errorContent="${errorContent}\\n[工程根目录不存在]dirPathCode=$dirPathCode" ; fi
    if [ ! -d "$dirPathOut" ];then    errorContent="${errorContent}\\n[工程out目录不存在]dirPathOut=$dirPathOut" ; fi
    if [ ! -f "$filePathDataBase" ];then    errorContent="${errorContent}\\n[数据库文件不存在]filePathDataBase=$filePathDataBase" ; fi
    if [ ! -z "$errorContent" ]||[[ -z "$editType" ]];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftAutoPacket -h
            return
    fi

    local isClean=
    local isReadMe=
    local isUpload=
    local isPacket=
    local isCopy=
    local isSpecial=
    editType=$(echo $editType | tr '[A-Z]' '[a-z]')
    if (( $(expr index $editType "a") != "0" ));then
         isClean=true
         isReadMe=true
         isUpload=true
         isPacket=true
    else
        if (( $(expr index $editType "y") != "0" ));then   isClean=true ; fi
        if (( $(expr index $editType "u") != "0" ));then   isUpload=true ; fi
        if (( $(expr index $editType "r") != "0" ));then   isReadMe=true ; fi
        if (( $(expr index $editType "p") != "0" ));then   isPacket=true ; fi
        if (( $(expr index $editType "c") != "0" ));then   isCopy=true ; fi
        if (( $(expr index $editType "t") != "0" ));then
               isSpecial=true
               isPacket=true
        fi
    fi

    ftAutoInitEnv
    local dirPathLocal=$dirPathCode
    local dirNameVersionSoftware=packet
    local buildType=$AutoEnv_buildType
    local dirPathVersionSoftware=${dirPathCode}/out/${dirNameVersionSoftware}

    if [[ -d "$dirPathVersionSoftware" ]]; then
            if [[ ! -z "$isClean" ]]; then
                rm  -rf $dirPathVersionSoftware
            elif [[ -z "isUpload" ]]; then
                  while true; do
                                ftEcho -y "有旧的软件包  ${dirPathVersionSoftware}\n是否删除"
                                read -n 1 sel
                                case "$sel" in
                                    y | Y ) rm  -rf $dirPathVersionSoftware
                                               break;;
                                    n | N | q |Q)    break ;;
                                    * ) ftEcho -e 错误的选择：$sel
                                        echo "输入n，q，离开";;
                                    esac
                done
                echo
            fi
    fi

    if [[ $AutoEnv_mnufacturers = "sprd" ]]; then
            if [ "$TARGET_PRODUCT" != "sp7731c_1h10_32v4_oversea" ];then
                ftEcho -ea " ${ftEffect} 缺少平台${AutoEnv_mnufacturers}的项目${TARGET_PRODUCT}的配置\
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
            local filePathPacketScript=${rDirPathCmdsModule}/tools/pac_7731c.pl

            if [[ ! -z "$(cat $versionName|grep 451)" ]]; then
                dirPathModemBin=${dirPathModemBin}2
            fi

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

            # 生成说明文件
            if [[ ! -z "$isReadMe" ]]; then
                    ftCreateReadMeBySoftwareVersion $dirPathVersionSoftwareVersion
            fi

            # 生成软件包
            cd $dirPathVersionSoftwareVersion && trap 'cd $dirPathLocal;exit' SIGINT
            if [[ ! -z "$isCopy" ]]; then
                # cp 
                cd $dirPathLocal
                return;
            fi
            if [[ ! -z "$isPacket" ]]; then
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
            fi

            #上传服务器
            if [[ ! -z "$isUpload" ]]; then
                    ftAutoUploadHighSpeed $dirPathVersionSoftware $(basename $dirPathVersionSoftwareVersion) $dirPathUploadTraget
            fi

    elif [[ $AutoEnv_mnufacturers = "mtk" ]]; then
            local dirNamePackage="packages"
            local dirNameOtaPackage="otaPackages"
            local dirNamePackageDataBase="dataBase"
            local deviceName=`basename $ANDROID_PRODUCT_OUT`

            local dataBaseFileList=
            if [ $deviceName = "m9_xinhaufei_r9_hd" ];then
                tagName="lzProjrctConfigSoftwareDataBaseFileLIst"
                dataBaseFileList=($(ftGetKeyValueByBlockAndKey -f $filePathDataBase $tagName ${TARGET_PRODUCT}_fileList))
            elif [ $deviceName = "keytak6580_weg_l" ];then
                local dirNameModems=$(ls ${dirPathOut}/obj/ETC/BPLGUInfoCustomAppSrcP_*|grep ":")
                for dirPath in ${dirNameModems[@]}
                do
                    dirPath=${dirPath//:/}
                    for fileName in $(ls $dirPath)
                    do
                        local filePath=${dirPath}/${fileName}
                        if [[ ! -f "$filePath" ]]; then
                            ftEcho -e "文件${filePath}不存在"
                        else
                            dataBaseFileList=(${dataBaseFileList[@]} $filePath)
                        fi
                    done
                done
                dataBaseFileList=(${dataBaseFileList[@]} ${dirPathOut}/obj/CGEN/APDB_MT6580_S01_L1.MP6_W16.15)
            else
                ftEcho -ea "${ftEffect} 没有平台${AutoEnv_mnufacturers}的对应项目${deviceName}的配置\
                \n请查看下面说明:"
                ftAutoPacket -h
                return
            fi

            # system.img文件最新修改时间
            if [[ -f "${dirPathOut}/system.img" ]]; then
                    local key="最近更改："
                    local fileChangeTime=$(stat ${dirPathOut}/system.img|grep $key|awk '{print $1}'|sed s/-//g)
                    fileChangeTime=${fileChangeTime//$key/}
                    fileChangeTime=${fileChangeTime:-$(date -d "today" +"%y%m%d")}
            fi

            if [ ! -z "$AutoEnv_clientName" ];then #解析git分支,初始化客户等相关信息
                ftAutoInitEnv -bp
                local dirNameersionSoftwareVersionBase=${AutoEnv_AndroidVersion}
                local dirPathVersionSoftwareVersion=${dirPathVersionSoftware}

                if [[ ! -z "$dirNameersionSoftwareVersionBase" ]]; then
                    dirPathVersionSoftwareVersion=${dirPathVersionSoftwareVersion}/${dirNameersionSoftwareVersionBase}
                fi
                if [[ ! -z "$AutoEnv_motherboardName" ]]&&[[ ! -z "$AutoEnv_projrctName" ]]; then
                    dirPathVersionSoftwareVersion=${dirPathVersionSoftwareVersion}/${AutoEnv_motherboardName}-${AutoEnv_projrctName}
                    local val1=${AutoEnv_motherboardName}__${AutoEnv_projrctName}
                fi
                if [[ ! -z "$val1" ]]&&[[ ! -z "$AutoEnv_demandSignName" ]]; then
                    local val2=${val1}__${AutoEnv_demandSignName};
                    dirPathVersionSoftwareVersion=${dirPathVersionSoftwareVersion}/${val2}
                fi
                if [[ ! -z "$AutoEnv_deviceModelName" ]]; then
                    dirPathVersionSoftwareVersion=${dirPathVersionSoftwareVersion}/${AutoEnv_deviceModelName}
                fi
                if [[ ! -z "$AutoEnv_BandInfo" ]]; then #添加 modem 配置信息
                    dirPathVersionSoftwareVersion=${dirPathVersionSoftwareVersion}_B${AutoEnv_BandInfo}
                fi
                if [[ ! -z "$AutoEnv_FlashConfig" ]]; then #添加 flash信息
                    dirPathVersionSoftwareVersion=${dirPathVersionSoftwareVersion}_${AutoEnv_FlashConfig}
                fi

                local dirNameVeriosionBase=${AutoEnv_versionName}
                #非user版本标记编译类型
                if [ "$AutoEnv_buildType" != "user" ];then
                     dirNameVeriosionBase=${buildType}____${dirNameVeriosionBase}
                fi
                #软件版本的日期与当前时间不一致就设定编译时间
                arr=(${AutoEnv_versionName//_/ })
                length=${#arr[@]}
                length=`expr $length - 1`
                local versionNameDate=${arr[$length]}
                if [[ $versionNameDate =~ "." ]];then
                    versionNameDate=${versionNameDate%.*}
                fi
                if [ ! -z "$fileChangeTime" ]&&[ "$versionNameDate" != "${fileChangeTime}" ];then
                    export AutoEnv_SoftwareVersion_BuildTime=buildtime____${fileChangeTime}
                     dirNameVeriosionBase=${dirNameVeriosionBase}____${AutoEnv_SoftwareVersion_BuildTime}
                fi

                if [[ ! -z "$isSpecial" ]]; then
                    ftEcho -r $"请输入版本: "${dirNameVeriosionBase}"\n相应的说明[回车默认为常规]:"
                    read tag
                    tag=${tag:-'常规'}
                    dirNameVeriosionBase=${tag}____${dirNameVeriosionBase}
                fi
                dirPathVersionSoftwareVersion=${dirPathVersionSoftwareVersion}/${dirNameVeriosionBase}

                # 服务器上传路径
               local dirPathUploadTraget=

               local tagName="lzProjrctConfigBranch2CtName"
               local clientNameAll=$(ftGetKeyValueByBlockAndKey -f $filePathDataBase $tagName $AutoEnv_clientName)
                tagName="lzProjrctConfigBranch2PlatformName"
                local platformName=$(ftGetKeyValueByBlockAndKey -f $filePathDataBase $tagName $TARGET_PRODUCT)
                if [ -z "$platformName" ];then
                     dirPathUploadTraget=智能机软件/autoUpload
                elif [ -z "$clientNameAll" ];then
                     dirPathUploadTraget=智能机软件/MTK6580/autoUpload
                else
                     dirPathUploadTraget=智能机软件/${platformName}/${clientNameAll}
                fi

            else
                if [ ! -z "$fileChangeTime" ];then
                    local dirPathVersionSoftwareVersion=${dirPathVersionSoftware}/${fileChangeTime}____buildType[${buildType}]__versionName[${AutoEnv_versionName}]__$fileChangeTime
                else
                    local dirPathVersionSoftwareVersion=${dirPathVersionSoftware}/buildType[${buildType}]__versionName[${AutoEnv_versionName}]
                fi
            fi

            if [[ ! -z "AutoEnv_motherboardName" ]]; then
                dirPathUploadTraget=${dirPathUploadTraget}/${AutoEnv_motherboardName}
            fi
            local dirPathPackage=${dirPathVersionSoftwareVersion}/${dirNamePackage}
            local dirPathOtaPackage=${dirPathVersionSoftwareVersion}/${dirNameOtaPackage}
            local dirPathPackageDataBase=${dirPathVersionSoftwareVersion}/${dirNamePackageDataBase}
            local dirPathOta=${dirPathOut}/obj/PACKAGING/target_files_intermediates
            if [[ -d "$dirPathOta" ]]; then
                local otaFileList=$(ls ${dirPathOta}/${TARGET_PRODUCT}-target_files-* |grep .zip)
            else
                ftEcho -e "OTA相关包未找到"
            fi

            # 生成本地软件包
            if [[ ! -z "$isPacket" ]]; then
                    mkdir -p $dirPathVersionSoftwareVersion
                    cd $dirPathVersionSoftwareVersion && trap 'cd $dirPathLocal;exit' SIGINT

                    ftEcho -s "\n========================\n开始生成版本软件包: \n${dirNameVeriosionBase}\n路径: \n${dirPathVersionSoftwareVersion}\n========================\n"
                    #packages
                    filePathSystemImage=${dirPathOut}/system.img
                    if [[ -f "$filePathSystemImage" ]]; then
                        mkdir -p $dirPathPackage
                        # packages需要的文件列表
                        tagName="lzProjrctConfigSoftwarePackageFileLIst"
                        local fileList=($(ftGetKeyValueByBlockAndKey -f $filePathDataBase $tagName ${TARGET_PRODUCT}_fileList) preloader_${deviceName}.bin)
                        for file in ${fileList[@]}
                        do
                            local filePath=${dirPathOut}/${file}
                             if [[ ! -f "$filePath" ]]; then
                                 ftEcho -e "${filePath}\n不存在"
                                 return;
                             fi
                             printf "%-2s %-30s\n" 复制 $file
                             cp -r -f  $filePath $dirPathPackage
                        done
                    else
                        ftEcho -e "软件包不完整,请确认\n不存在  $filePathSystemImage"
                        return;
                    fi
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
                             cp -r -f  $file $dirPathOtaPackage
                        done
                    fi
                    # database
                    if [ ! -z "$dataBaseFileList" ];then
                        mkdir -p $dirPathPackageDataBase
                        for filePath in ${dataBaseFileList[@]}
                        do
                             if [[ ! -f "$filePath" ]]; then
                                 ftEcho -e "${filePath}\n不存在"
                             else
                                fileName=`basename $filePath`
                                printf "%-2s %-30s\n" 复制 $(echo $fileName | sed "s ${dirPathOut}  ")
                                 cp -r -f  $filePath $dirPathPackageDataBase
                             fi
                        done
                    fi
            fi

            # 生成说明文件
            if [[ ! -z "$isReadMe" ]]; then
                    ftCreateReadMeBySoftwareVersion $dirPathVersionSoftwareVersion
            fi

            #上传服务器
            if [[ ! -z "$isUpload" ]]; then
                    echo  11=$dirPathVersionSoftware
                    echo   22=$dirNameersionSoftwareVersionBase  
                    echo   33=$dirPathUploadTraget
                    echo   44=$dirPathVersionSoftwareVersion
                    # ftAutoUploadHighSpeed $dirPathVersionSoftware $dirNameersionSoftwareVersionBase $dirPathUploadTraget $dirPathVersionSoftwareVersion
            fi
    else
            ftEcho -ea "${ftEffect} 没有平台${AutoEnv_mnufacturers}的配置\n请查看下面说明:"
            ftAutoPacket -h
            return
    fi
    cd $dirPathLocal
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

    local fileNameReadMeTemplate=客户说明.txt
    local fileNameChangeListTemplate=修改记录.txt
    local filePathReadMeTemplate=${dirPathVersionSoftware}/${fileNameReadMeTemplate}
    local filePathChangeListTemplate=${dirPathVersionSoftware}/${fileNameChangeListTemplate}
    local versionName=$AutoEnv_versionName

    if [ ! -d "$dirPathVersionSoftware" ];then
        mkdir $dirPathVersionSoftware
    fi

    cd $dirPathCode
    ftAutoInitEnv


    #使用git 记录的修改记录
    local gitCommitListOneDay=$(git log --date=short --pretty=format:"%s" -30)
    local gitCommitListBefore=$(git log --date=short --pretty=format:"%s" -30)

# ===============================================
# =================     客户说明          ================
# ===============================================

    # if [[ "$AutoEnv_clientName" = "PMZ" ]]||[[ $AutoEnv_mnufacturers = "sprd" ]]; then
    #         #获取语言缩写列表
    #         ftAutoLanguageUtil
    #         LanguageList=(默认)${return}

    #         echo -e "$gitCommitListOneDay">$filePathReadMeTemplate
    #         seq 10 | awk '{printf("    %02d %s\n", NR, $0)}' $filePathReadMeTemplate >${filePathReadMeTemplate}.temp

    #         enterLine="\n"
    #         content="版本号 : $versionName"${enterLine}
    #         content=${content}${enterLine}"2. 语言:"
    #         content=${content}${enterLine}"$LanguageList"
    #         echo -e ${content}${enterLine}${enterLine}"3. 修改点:"| cat - ${filePathReadMeTemplate}.temp >$filePathReadMeTemplate

    #         unix2dos $filePathReadMeTemplate # 转化为windows下格式
    # fi

# ===============================================
# =================     修改记录    ==================
# ===============================================
    if [ $AutoEnv_mnufacturers = "sprd" ];then
            # 暗码清单,动画切换暗码
            local filePathPawInfo=${dirPathCode}/packages/apps/Dialer/src/com/android/dialer/SpecialCharSequenceMgr.java
            if [ -f $filePathPawInfo ];then
                    local key="    private static final String PAW_NUM_INFO ="
                    local pawNumInfo=$(cat $filePathPawInfo|grep "$key")  #获取暗码清单信息
                    pawNumInfo=${pawNumInfo//$key/};
                    pawNumInfo=${pawNumInfo//\";/};
                    pawNumInfo=${pawNumInfo//\"/};
                    pawNumInfo=$(echo $pawNumInfo |sed s/[[:space:]]//g)

                    key="    private static final String LOGO_CHANGE ="
                    local changLogoNumInfo=$(cat $filePathPawInfo|grep "$key")  #动画切换暗码信息
                    changLogoNumInfo=${changLogoNumInfo//$key/};
                    changLogoNumInfo=${changLogoNumInfo//\";/};
                    changLogoNumInfo=${changLogoNumInfo//\"/};
                    changLogoNumInfo=$(echo $changLogoNumInfo |sed s/[[:space:]]//g)
            else
                    ftEcho -e "[工程暗码配置文件不存在:]\n$filePathPawInfo"
            fi

            #摄像头配置相关
            local filePathCameraConfig=${dirPathCode}/${AutoEnv_deviceDirPath}/BoardConfig.mk
            if [ -f $filePathCameraConfig ];then
                    local keyType="LZ_CONFIG_CAMERA_TYPE := "
                    local keySizeBack="CAMERA_SUPPORT_SIZE := "
                    local keySizeFront="FRONT_CAMERA_SUPPORT_SIZE := "

                    local cameraTypeInfo=$(cat $filePathCameraConfig|grep "$keyType")
                    local cameraSizeBackMax=$(cat $filePathCameraConfig|grep "$keySizeBack")
                    local cameraSizeFrontMax=$(cat $filePathCameraConfig|grep "$keySizeFront")

                    cameraTypeInfo=${cameraTypeInfo//$keyType/};
                    cameraSizeFrontMax=${cameraSizeFrontMax//$keySizeFront/};

                    cameraSizeBackMax=${cameraSizeBackMax//${keySizeFront}$cameraSizeFrontMax/};
                    cameraSizeBackMax=${cameraSizeBackMax//$keySizeBack/};

                    cameraTypeInfo=$(echo $cameraTypeInfo |sed s/[[:space:]]//g)
                    cameraSizeFrontMax=$(echo $cameraSizeFrontMax |sed s/[[:space:]]//g)
                    cameraSizeBackMax=$(echo $cameraSizeBackMax |sed s/[[:space:]]//g)

                    sizeFcameraList=(real 2M 5M 8M)
                    sizeBcameraList=(real 2M 5M 8M 12M)
                    local cameraSizeFrontDefault=${sizeFcameraList[LZ_FCAM]}
                    local cameraSizeBackDefault=${sizeBcameraList[LZ_BCAM]}
            else
                    ftEcho -e "[相机配置文件不存在，获取失败]\n$filePathCameraConfig"
            fi

            #修改记录
            echo -e "﻿$gitCommitListBefore">$filePathChangeListTemplate
            local gitCommitListBeforeSize=$(awk 'END{print NR}' ${filePathReadMeTemplate}.temp)
            seq 10 | awk '{printf("    %02d %s\n", NR+size, $0)}' size="$gitCommitListBeforeSize" $filePathChangeListTemplate >${filePathChangeListTemplate}.temp

            local enterLine="\n"
            local content="当前版本：$versionName"${enterLine}
            content=${content}${enterLine}"摄像头类型：$cameraTypeInfo"
            content=${content}${enterLine}"默认 前/后摄大小：$cameraSizeFrontDefault/$cameraSizeBackDefault"
            content=${content}${enterLine}"真实插值 前/后摄大小：$cameraSizeFrontMax/$cameraSizeBackMax"
            # content=${content}${enterLine}"默认 RAM/ROM：$sizeRam/$sizeRom"
            content=${content}${enterLine}
            content=${content}${enterLine}"暗码清单：$pawNumInfo"
            # content=${content}${enterLine}"隐藏：*#312#*"
            # content=${content}${enterLine}"imei显示：*#06#"
            # content=${content}${enterLine}"imei编辑：*#*#3646633#*#*"
            # content=${content}${enterLine}"单项测试[列表]：*#7353#"
            # content=${content}${enterLine}"单项测试[宫格]：*#0*#"
            # content=${content}${enterLine}"三星测试：*#1234#"
            content=${content}${enterLine}"开关机动画暗码：$changLogoNumInfo"
            echo -e ${content}${enterLine}${enterLine}"修改记录："| cat - ${filePathReadMeTemplate}.temp >$filePathChangeListTemplate

            unix2dos $filePathChangeListTemplate # 转化为windows下格式

   elif [[ $AutoEnv_mnufacturers = "mtk" ]]; then
            echo -e "﻿$gitCommitListBefore">$filePathChangeListTemplate
            # local gitCommitListBeforeSize=$(awk 'END{print NR}' ${filePathChangeListTemplate})
            # seq 10 | awk '{printf("    %02d %s\n", NR+size, $0)}' size="$gitCommitListBeforeSize" $filePathChangeListTemplate >${filePathChangeListTemplate}.temp
            seq 10 | awk '{printf("    %02d %s\n", NR, $0)}' $filePathChangeListTemplate >${filePathChangeListTemplate}.temp

            local enterLine="\n"
            local content="当前版本：$versionName"${enterLine}
            content=${content}${enterLine}"隐藏指令：*#*#94127*208#*#*"
            content=${content}${enterLine}"imei编辑：*#315#*"
            content=${content}${enterLine}"imei显示：*#06#"
            content=${content}${enterLine}"imei单双切换：*#316#*"
            content=${content}${enterLine}"切换动画指令：*#868312513#*"
            content=${content}${enterLine}"切换默认动画：*#979312#*"
            content=${content}${enterLine}"测试模式：*#*#180#*#*"
            content=${content}${enterLine}"三星测试：*#0*#"
            echo -e ${content}${enterLine}${enterLine}"修改记录："| cat - ${filePathChangeListTemplate}.temp >$filePathChangeListTemplate

        #     echo -e "﻿==============================================================================\
        # "| cat - ${filePathChangeListTemplate}.temp>>$filePathChangeListTemplate

            unix2dos $filePathChangeListTemplate # 转化为windows下格式
    fi

    rm ${filePathReadMeTemplate}.temp
    rm ${filePathChangeListTemplate}.temp
}

ftAutoLanguageUtil()
{
    local ftEffect=语言缩写转化为中文
    local dirPathCode=$ANDROID_BUILD_TOP

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
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftAutoLanguageUtil -h
            return
    fi

    ftAutoInitEnv

    #获取缩写列表
    if [ $AutoEnv_mnufacturers = "sprd" ];then
                local filePathDeviceSprd=${dirPathCode}/${AutoEnv_deviceDirPath}/sp7731c_1h10_32v4_oversea.mk
                if [[ -f "$filePathDeviceSprd" ]]; then
                    local key="#PRODUCT_LOCALES := "
                    LanguageListInvalid=$(cat $filePathDeviceSprd|grep "$key")
                    key="PRODUCT_LOCALES :="
                    LanguageList=$(cat $filePathDeviceSprd|grep "$key")
                    LanguageList=${LanguageList//$LanguageListInvalid/};
                    LanguageList=${LanguageList//$key/};
                else
                    ftEcho -e "[工程文件不存在:${filePathDeviceSprd}\n，语言缩写列表 获取失败]\n$filePathPawInfo"
                    ftAutoLanguageUtil -h
                    return
                fi
   elif [[ $AutoEnv_mnufacturers = "mtk" ]]; then
                # local filePathDeviceMtk=${dirPathCode}/${AutoEnv_deviceDirPath}/full_keytak6580_weg_l.mk
                local filePathDeviceMtk=${dirPathCode}/device/keytak/keytak6580_weg_l/full_keytak6580_weg_l.mk
                if [ -f "$filePathDeviceMtk" ]; then
                     local key="#PRODUCT_LOCALES := "
                    # LanguageList=$(grep ^$key $filePathDeviceMtk)
                    LanguageListInvalid=$(cat $filePathDeviceMtk|grep "$key")
                    key="PRODUCT_LOCALES := "
                    # LanguageList=$(grep ^$key $filePathDeviceMtk)
                    LanguageList=$(cat $filePathDeviceMtk|grep "$key")
                    LanguageList=${LanguageList//$LanguageListInvalid/};
                    LanguageList=${LanguageList//$key/};
                else
                    ftEcho -e "[工程文件不存在:${filePathDeviceMtk}\n，语言缩写列表 获取失败]\n$filePathPawInfo"
                    ftAutoLanguageUtil -h
                    return
                fi
    fi

    ftLanguageUtil "${LanguageList//$key/}"
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
#    ftAutoUpdateSoftwareVersion 仅可用于 SPRD > 7731C > N9 的项目
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
    if [[ $AutoEnv_mnufacturers != "sprd" ]]&&[ "$TARGET_PRODUCT" != "sp7731c_1h10_32v4_oversea" ]; then
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
                        read -n 1 sel&&
                        echo
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

ftMonkeyTestByDevicesName()
{
    local ftEffect=自动化monkey测试 [xxx 残废 xxx]
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
    if [ -z "$rDirPathCmds" ];then    errorContent="${errorContent}\\n[用户名为空]rNameUser=$rNameUser" ; fi
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
    local filePathDataBase=${rDirPathCmdsConfigData}/tools.db

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
    if [ ! -f "$filePathDataBase" ];then    errorContent="${errorContent}\\n[数据库文件不存在]filePathDataBase=$filePathDataBase" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftGetAndroidVersionBySDKVersion -h
            return
    fi

   local tagName="androidSDK2Verison"
   local androidVersionName=$(ftGetKeyValueByBlockAndKey -f $filePathDataBase $tagName $sdkVersion)
   # echo ${androidVersionName:-'unkonwSdkVersion'}
   echo $androidVersionName
}

complete -W "backup restore" ftMaintainSystem
ftMaintainSystem()
{
    local ftEffect=ubuntu系统维护
    local fileNameMaintain=maintain.sh
    local filePathMaintain=${rDirPathCmdsModule}/tools/${fileNameMaintain}
    local filePathDb=${rDirPathCmdsConfigData}/tools.db
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
    if [ "$editType" = "backup" ]&&[ ! -f "$filePathDb" ];then    errorContent="${errorContent}\\n[数据库文件不存在]filePathDb=$filePathDb" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftMaintainSystem -h
            return
    fi

    $filePathMaintain $editType
}

ftGitLogShell()
{
    local ftEffect=git的log特定格式显示
    local editType=$1

    local isAllBranchLog=
    local BranchLogItemCount=
    if (  echo -n $editType | grep -q -e "^[0-9][0-9]*$");then
        BranchLogItemCount=$editType
    else
        editType=$(echo $editType | tr '[A-Z]' '[a-z]')
        if (( $(expr index $editType "a") != "0" ));then   isAllBranchLog=true ; fi
    fi

    while true; do case "$1" in
    e | -e |--env) cat<<EOF
#===================[   ${ftEffect}   ]的使用环境说明=============
#
#    ${ftEffect}依赖包
#    请尝试使用 sudo apt-get install git git-core git-gui git-doc 补全依赖
#=========================================================
EOF
      return;;
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftGitLogShell -a
#    ftGitLogShell 数量
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #环境校验
    if [ -z `which git` ];then
        ftGitLogShell -e
        return
    fi
    if [[ ! -z "$isAllBranchLog" ]]&&[ -z `which gitk` ]; then
        ftGitLogShell -e
        return
    fi

    #耦合校验
    local valCount=1
    local errorContent=
    if (( $#>$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftGitLogShell -h
            return
    fi

    local gitVersionMin="2.6.0"
    local gitVersionNow=$(git --version)
    gitVersionNow=${gitVersionNow//git version/}
    gitVersionNow=$(echo $gitVersionNow |sed s/[[:space:]]//g)
    local count=$BranchLogItemCount
    count=${count:-'15'}

    if [[ ! -z "$isAllBranchLog" ]]; then
       gitk --all
       return
    fi

    if [[ $(ftVersionComparison $gitVersionMin $gitVersionNow) = "<" ]];then
        git log --date=format-local:'%y%m%d-%H:%M:%S' --pretty=format:"%C(green)%<(17,trunc)%ad %Cred%<(8,trunc)%an%Creset %Cblue%h%Creset %s %C(yellow) %d" -$count
    else
        git log --pretty=format:"%C(green)%<(21,trunc)%ai%x08%x08%Creset %Cred%<(8,trunc)%an%Creset %Cblue%h%Creset %s %C(yellow) %d" -$count
    fi
}