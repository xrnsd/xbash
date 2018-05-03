#!/bin/bash
#####---------------------  说明  ---------------------------#########
# 不可在此文件中出现不被函数包裹的调用或定义
# 人话，这里只放函数
# complete -W "example example" ftExample
#####---------------------示例函数---------------------------#########
ftExample()
{
    local ftEffect=函数模板

    while true; do case "$1" in
    e | -e |--env) cat<<EOF
#===================[   ${ftEffect}   ]的使用环境说明=============
#
#    ${ftEffect}依赖包 example
#    请尝试使用 sudo apt-get install example 补全依赖
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

    local filePathCmdModuleTest=${rDirPathCmds}/${rFileNameCmdModuleTestBase}
    #耦合校验
    local valCount=1
    local errorContent=
    if [ ! -d "$rDirPathUserHome" ];then    errorContent="${errorContent}\\n[用户路径为空]rDirPathUserHome=$rDirPathUserHome" ; fi
    if [ ! -f "$filePathCmdModuleTest" ];then    errorContent="${errorContent}\\n[测试模块不存在]filePathCmdModuleTest=$filePathCmdModuleTest" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftTest -h
            return
    fi

    local dirPathLocal=$PWD
    local dirPathTemp=${rDirPathUserHome}/temp
    if [[ ! -d "$dirPathTemp" ]]; then
        mkdir $dirPathTemp||(ftEcho -e "${ftEffect} 创建demo环境目录失败:$dirPathTemp";return)
    fi
    if [[ ! -f ${dirPathLocal}/Makefile ]]&&[[ -z "$ANDROID_BUILD_TOP" ]]; then
        cd $dirPathTemp
    fi
    ftTiming -i
    $filePathCmdModuleTest "$@"
    ftTiming
    cd $dirPathLocal
}

ftAutoInitEnv()
{
    local ftEffect="初始化xbash Android build相关所需的部分环境变量"
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
        ||[ -z "$TARGET_PRODUCT" ]\
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
            local filePathPreviousBuildConfig=${dirPathOut}/previous_build_config.mk
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

                        if [ -f "$filePathPreviousBuildConfig" ];then
                                info=$(cat $filePathPreviousBuildConfig|grep $TARGET_PRODUCT)
                                if [ ! -z "$info" ];then

                                    local OLD_IFS="$IFS"
                                    IFS="-"
                                    local arrayItems=($info)
                                    IFS="$OLD_IFS"
                                    if [ "$info" = "$arrayItems" ];then
                                            ftEcho -e "${filePathPreviousBuildConfig} 信息解析失败"
                                    else
                                            local buildinfo=null
                                            for item in ${arrayItems[@]}
                                            do
                                                if [[ "$item" = "$TARGET_PRODUCT" ]]; then
                                                    buildinfo=
                                                elif [[ -z "$buildinfo" ]]; then
                                                    buildType=$item
                                                    buildinfo=$buildType
                                                fi
                                            done
                                    fi
                                fi
                        fi
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
    if [ ! -z "$branchName" ];then
        local OLD_IFS="$IFS"
        IFS=")"
        local arrayItems=($branchName)
        IFS="$OLD_IFS"
        if [ "$branchName" = "$arrayItems" ];then
                ftEcho -e "分支名:${branchName} 不合法\n分支信息解析失败"
        else
                export AutoEnv_clientName=
                export AutoEnv_projrctName=
                export AutoEnv_modelAllName=
                export AutoEnv_demandSignName=
                export AutoEnv_motherboardName=
                export AutoEnv_screenScanDirection=

                for item in ${arrayItems[@]}
                do
                        local valShort=${item:0:4}
                        local valLong=${item:0:5}

                         if [[ ${item:0:3} = "CT(" ]];then
                            valShort=${item:0:3}
                            local gitBranchInfoClientName=${item//$valShort/}
                            export AutoEnv_clientName=$gitBranchInfoClientName
                         elif [[ $valShort = "_CT(" ]];then
                            local gitBranchInfoClientName=${item//$valShort/}
                            export AutoEnv_clientName=$gitBranchInfoClientName
                         elif [[ $valShort = "_PJ(" ]];then
                            local gitBranchInfoProjrctName=${item//$valShort/}
                            export AutoEnv_projrctName=$gitBranchInfoProjrctName
                         elif [[ $valShort = "_SS(" ]];then
                            local gitBranchInfoScreenScanDirection=${item//$valShort/}
                            export AutoEnv_screenScanDirection=$gitBranchInfoScreenScanDirection
                        elif [[ $valShort = "_DM(" ]];then
                            local gitBranchInfoDemandSignName=${item//$valShort/}
                            export AutoEnv_demandSignName=$gitBranchInfoDemandSignName
                        elif [[ $valLong = "MBML(" ]];then
                            local gitBranchInfoMotherboardName=${item//$valLong/}
                            export AutoEnv_motherboardName=$gitBranchInfoMotherboardName
                        elif [[ $valLong = "_PMA(" ]];then
                            local gitBranchInfoModelAllName=${item//$valLong/}
                            export AutoEnv_modelAllName=$gitBranchInfoModelAllName
                        fi
                done
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
    ye | YE | -ye | -YE) echo -en "${content}[y/n]"; break;;
    r | R | -r | -R)        echo;echo -en "${content}"; break;;
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

    if [ -z "$mTimingStart" ]||[ "$1" = "-i" ];then
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

ftDevAvailableSpace()
{
    local ftEffect=设备可用空间
    local dirPathTraget=$1
    local isReturn=$2

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftDevAvailableSpace [dirPathTraget] [[isReturn]]
#    ftDevAvailableSpace /media/test
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    local valCount=1
    local errorContent=
    if (( $#>$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -d "$dirPathTraget" ];then    errorContent="${errorContent}\\n[设备路径不存在]dirPathTraget=$dirPathTraget" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftDevAvailableSpace -h
            return
    fi
     local devAvailableSIzeList=`df -lh | awk '{print $4}'`
     local devMountDirPathList=(`df -lh | awk '{print $6}'`)

     local indexDevName=0
     local devMountDirPath
    for size in ${devAvailableSIzeList[*]}
    do
            devMountDirPath=${devMountDirPathList[indexDevName]}
             length=${#dirPathTraget}
            if [[ "${devMountDirPath:0:$length}" = "$dirPathTraget" ]]; then
                    if [[ $size =~ "G" ]];then
                            size=${size//G/}
                            size=$(echo "$size * 1024" | bc)
                    else
                            size=${size//M/}
                    fi
                    echo $size
            fi
            indexDevName=`expr $indexDevName + 1`
    done
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

    if [[ "${filePath:0:1}" = "-" ]]; then
        local count=4
        filePath=$2
        blockName=$3
        keyName=$4

        editType=$1
        editType=$(echo $editType | tr '[A-Z]' '[a-z]')
        if (( $(expr index $editType "f") != "0" ));then   local isReadSilence=true ; fi
    fi

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftGetKeyValueByBlockAndKey [文件路径] [目标块TAG] [键名]
#    value=\$(ftGetKeyValueByBlockAndKey /temp/odbcinst.ini PostgreSQL Setup)
#    value表示key对应的值
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    local valCount=${count:-'3'}
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -f "$filePath" ];then    errorContent="${errorContent}\\n[文件不存在]filePath=$filePath"
    else
        testBockName=$(cat $filePath|grep $blockName)
        testKeyName=$(cat $filePath|grep $keyName)
        if [[ -z "$isReadSilence" ]]; then
            if [ -z "$blockName" ];then    errorContent="${errorContent}\\n[目标块TAG为空]blockName=$blockName"
            elif [ -z "$testBockName" ];then    errorContent="${errorContent}\\n[目标块TAG不存在]blockName=$blockName" ; fi
            if [ -z "$keyName" ];then    errorContent="${errorContent}\\n[目标块TAG为空]keyName=$keyName"
            elif [ -z "$testKeyName" ];then    errorContent="${errorContent}\\n[目标块TAG不存在]keyName=$keyName" ; fi
        else
            if [ -z "$blockName" ]\
                ||[ -z "$testBockName" ]\
                ||[ -z "$keyName" ]\
                ||[ -z "$testKeyName" ];then
                # echo -e "error\c"
                return;
            fi
        fi
    fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftGetKeyValueByBlockAndKey -h
            return
    fi

    local begin_block=0
    local end_block=0

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
            value=$(echo $line | awk -F= '{gsub("\t","",$2); print $2}')

            if [ "X$keyName" = "X$key" ];then
                echo $value
                break
            fi
        fi
    done
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
#    ftSetKeyValueByBlockAndKey [文件路径] [目标块TAG] [键名] [键对应的值]
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

#版本号大小对比
ftVersionComparison()
{
    local ftEffect=版本号大小比对beta

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftVersionComparison -h    #查看帮助
#
#    只能比对xx.xx格式的版本号
#    echo $(ftVersionComparison 版本1 版本2)   #比对版本1和2大小
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #耦合校验
    local valCount=2
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftVersionComparison -h
            return
    fi

    if [[ "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1" ]]; then
        echo ">"
    elif [[ "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" != "$1" ]]; then
        echo "<"
    elif [[ "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" == "$1" ]]; then
        echo "<="
    elif [[ "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1" ]]; then
        echo ">="
    fi
}

ftLanguageUtil()
{
    local ftEffect=语言缩写转换
    local ftLanguageContent=$@
    local dirPathCode=$ANDROID_BUILD_TOP
    local filePathDataBase=${rDirPathCmdsConfigData}/tools.db

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#===================[   ${ftEffect}   ]的使用示例==============
#
#    ftLanguageUtil 缩写列表
#    ftLanguageUtil “ar_IL bn_BD my_MM zh_CN”
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
        ftLanguageUtil -env
        return
    fi
    ftAutoInitEnv
    if [ $AutoEnv_mnufacturers = "sprd" ];then
            local filePathDevice=${dirPathCode}/${AutoEnv_deviceDirPath}/sp7731c_1h10_32v4_oversea.mk
    elif [[ $AutoEnv_mnufacturers = "mtk" ]]; then
            local filePathDevice=${dirPathCode}/device/keytak/keytak6580_weg_l/full_keytak6580_weg_l.mk
    fi
    local errorContent=
    if [ -z "$ftLanguageContent" ];then    errorContent="${errorContent}\\n[语言信息为空]ftLanguageContent=$ftLanguageContent" ;
    elif [ ! -f "$filePathDevice" ];then    errorContent="${errorContent}\\n[工程Device的语言配置文件不存在]filePathDevice=$filePathDevice" ; fi
    if [ ! -f "$filePathDataBase" ];then    errorContent="${errorContent}\\n[语言转化配置文件不存在]filePathDataBase=$filePathDataBase" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftLanguageUtil -h
            return
    fi
    return=

    local allList=($(ftGetKeyValueByBlockAndKey $filePathDataBase languageList allList))
    local shortList=($(ftGetKeyValueByBlockAndKey $filePathDataBase languageList shortList))

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
                return="${return} ${tragetList[index]}"
                orderIndex=`expr $orderIndex + 1`
                break;
            elif [[ $base =~ "/" ]]&&[[ $base =~ $lc ]]; then
                return="${return} [${lc}]>${tragetList[index]}>[${base}]"
                title=${lc}可能存在多种结果
            elif((${#sourceList[@]}==`expr $index + 1`));then
                ftEcho -e $title
            fi
            index=`expr $index + 1`
        done
    done
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
    if [ -z "$rDirPathCmds" ];then    errorContent="${errorContent}\\n[默认用户名]rNameUser=$rNameUser" ; fi
    if [ -z "$rDirPathUserHome" ];then    errorContent="${errorContent}\\n[默认用户的home目录]rDirPathUserHome=$rDirPathUserHome" ; fi
    if ( ! echo -n $devMinAvailableSpaceTemp | grep -q -e "^[0-9][0-9]*$" );then    errorContent="${errorContent}\\n[可用空间限制]devMinAvailableSpace=$devMinAvailableSpace" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftInitDevicesList -h
            return
    fi

    local indexDevMount=0
    local indexDevName=0
    local dirPathHome=$rDirPathUserHome #(${rDirPathUserHome/$rNameUser\//$rNameUser})
    local sizeHome=$(ftDevAvailableSpace $dirPathHome)

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
    if [[ $sizeHome -ge $devMinAvailableSpace ]]; then
        mCmdsModuleDataDevicesList=$dirPathHome
        indexDevMount=1;
    fi
    #开始记录设备文件
    for dir in ${devNameDirPathList[*]}
    do
            devMountDirPath=${devMountDirPathList[indexDevName]}
            if [[ $dir =~ "/dev/" ]]&&[[ $devMountDirPath != "/" ]];then
                    sizeTemp=$(ftDevAvailableSpace $devMountDirPath)
                    # 确定目录已挂载,设备可用空间大小符合限制
                    if [[ $devMinAvailableSpace -eq 0 ]]||(($sizeTemp>=$devMinAvailableSpace)); then
                        if mountpoint -q $devMountDirPath;then
                            mCmdsModuleDataDevicesList[$indexDevMount]=$devMountDirPath
                            indexDevMount=`expr $indexDevMount + 1`
                        fi
                    fi
            fi
            indexDevName=`expr $indexDevName + 1`
    done
    export mCmdsModuleDataDevicesList #=${mCmdsModuleDataDevicesList[*]}
}


_adb() 
{
    local ftEffect=adb修正工具对应的参数补全实现
     local curr_arg=${COMP_WORDS[COMP_CWORD]}
    case "${COMP_WORDS[1]}" in
                    -k)         COMPREPLY=( $(compgen -W 'home back menu down up lift right down  power' -- $curr_arg ) ); ;;
                    install)  COMPREPLY=( $(compgen -W "-l -r -s" -- $curr_arg ) );
                                # case "${COMP_WORDS[2]}" in
                                #                 -l|-r|-s)  if [[ ! -z "$(ls -l |grep ".apk")" ]]; then
                                #                                     COMPREPLY=( $(compgen -o filenames -W "`ls *.apk`" -- ${cur}) );
                                #                                 fi ;;
                                # esac
                                ;;
                    shell)  COMPREPLY=( $(compgen -W 'am pm input screencap screenrecord getprop dumpsys start text setprop start stop' -- $curr_arg ) );
                                case "${COMP_WORDS[2]}" in
                                                dumpsys)  COMPREPLY=( $(compgen -W 'notification cpuinfo meminfo activity' -- $curr_arg ) ); ;;
                                                input)  COMPREPLY=( $(compgen -W 'keyevent text' -- $curr_arg ) ); ;;
                                esac
                                ;;
                    logcat)  COMPREPLY=( $(compgen -W ' \"*:E\"  ' -- $curr_arg ) );
                                ;;
                    *)  COMPREPLY=( $(compgen -W 'push pull sync shell emu logcat forward jdwp install uninstall bugreport backup restore help version wait-for-device start-server kill-server get-state get-serialno get-devpath status-window remount root usb reboot disable-verity' -- $curr_arg ) ); ;;
      esac
}
complete -F _adb -A file adb
adb()
{
    local ftEffect=adb修正工具

    local dirPathCode=$ANDROID_BUILD_TOP
    local  filePathAdbNow=$(which adb)
    local  filePathAdbLocal=/usr/bin/adb
    local filePathDataBase=${rDirPathCmdsConfigData}/tools.db

    #环境校验
    # if [ -z "$filePathAdbNow" ]||[ ! -d "$ANDROID_SDK" ];then
    if [ ! -d "$ANDROID_SDK" ];then
        cat<<EOF
#===============[ ${ftEffect} ]的使用环境说明=============
#
#    Android SDK 环境异常，请查看配置
#=========================================================
EOF
        return
    fi

    if [[ -f "$filePathAdbNow" ]]; then
        local dirPathLocal=$(pwd)
        local  filePathAdb=${dirPathCode}/out/host/linux-x86/bin/adb
        if [[ "$dirPathLocal" = "$dirPathCode" ]]&&[[ -f "$filePathAdb" ]]; then
            if [[ "$filePathAdbNow" != "$filePathAdb" ]]; then
                local pid=$(lsof -i:5037  |grep adb |awk '{print $2}')
                if [[ -f "$filePathAdbLocal" ]]; then
                    echo $userPassword | sudo -S mv $filePathAdbLocal ${filePathAdbLocal}2
                fi
                ftRestartAdb
            fi
        fi
    else
        if [[ ! -f "${filePathAdbLocal}" ]]; then
            if [[ -f "${filePathAdbLocal}2" ]]; then
                echo $userPassword | sudo -S mv ${filePathAdbLocal}2 $filePathAdbLocal
            else
                local filePath=${ANDROID_SDK}/platform-tools/adb
                if [[ ! -f "$filePath" ]]; then
                    ftEcho -e "Android SDK 配置 失败，文件不存在：$filePath"
                    return;
                else
                    echo $userPassword | sudo -S ln -s  ${ANDROID_SDK}/platform-tools/adb $filePathAdbLocal
                fi
            fi
            ftRestartAdb
        fi
        filePathAdbNow=$filePathAdbLocal
    fi

    if [[ "$1" = "-k" ]]; then
        if [ ! -f "$filePathDataBase" ];then
            ftEcho -e "数据库文件不存在]filePathDataBase=$filePathDataBase"
        else
            local TagName=androidKeyCode
            local keyCode=$(ftGetKeyValueByBlockAndKey -f $filePathDataBase androidKeyCode $2)
            if [[ ! -z "$keyCode" ]]; then
                $filePathAdbNow shell input keyevent $keyCode
            else
                ftEcho -e "未知配置,请查看:$filePathDataBase"
            fi
        fi
        return
    fi

     $filePathAdbNow "$@"
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
        export PS1="$defaultPrefix[\[\033[${defaultColorConfig}m\]\w\[\033[0m\]]\[\033[33m\]$branchName: \[\033[0m\]"
    else
        export PS1="$defaultPrefix[\[\033[${defaultColorConfig}m\]\w\[\033[0m\]]: "
    fi
}

ftRmExpand()
{
    local ftEffect=rm扩展[添加回收站功能]
    local traget=$1
    local dirPathLocal=$(ftLnUtil $PWD) #解决软链接问题
    cd $PWD
    if [[ "${traget:0:1}" = "-" ]]; then
        traget=$2

        editType=$1
        editType=$(echo $editType | tr '[A-Z]' '[a-z]')
        if (( $(expr index $editType "f") != "0" ));then   local isRmSilence=true ; fi
        if (( $(expr index $editType "r") != "0" ));then   local isRmDirectory=true ; fi
    fi

    while true; do case "$1" in
    h | H |-h | -H) cat<<EOF
#========[ ${ftEffect} ]的使用示例=============
#
#     ftRmExpand xx xxx
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done


    # 耦合校验
    local errorContent=
    if [ -z "$traget" ];then    errorContent="${errorContent}\\n不知道你想干嘛" ;fi
    if [[ ! -d "$traget" ]]&&[[ ! -f "$traget" ]];then  echo "rm: 无法删除\"$traget\": 没有那个文件或目录" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftEcho -s "请参照rm 使用习惯 "
            return
    fi

    ftInitDevicesList
    local dirPathDevTrash=
    for dirPath in ${mCmdsModuleDataDevicesList[*]}
    do
        local length=${#dirPath}
        if [[ "${dirPathLocal:0:$length}" = "$dirPath" ]]; then
            local dirNameList=$(ls -a $dirPath|grep ".Trash-")
            if [[ -z "$dirNameList" ]]&&[ ! -z "$(echo $dirPath|grep /home)" ]; then
                dirNameList=".local/share/Trash"
            fi
            dirNameList=$dirNameList #假如存在多个就直接选第一个
            local dirPathDevTrash=${dirPath}/${dirNameList}/files
            break;
        fi
    done

    if [[ -d "$dirPathDevTrash" ]]; then
        if [[ -z "$isRmDirectory" ]]&&[[ -d "$traget" ]]; then
                while true; do
                        ftEcho -ye 这是目录,还删么
                        read -n 1 sel
                        sel=${sel:-'Y'}
                        case "$sel" in
                            y | Y )  break;;
                            n | N |q | Q)    echo;return;;
                            * ) ftEcho -e 错误的选择：$sel
                                echo "输入n,q，离开"
                                ;;
                        esac
                done
        fi
        local status=$(mv $traget $dirPathDevTrash 1>/dev/null 2>&1)
        if [[ ! -z "$status" ]]&&[[ -z "$isRmSilence" ]]; then
            ftEcho -s $status
        fi
    else
        ftEcho -s "未移动 $traget 到回收站"
        $(which rm) "$@"
    fi
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
