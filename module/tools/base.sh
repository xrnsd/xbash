#!/bin/bash
#####---------------------  说明  ---------------------------#########
# 不可在此文件中出现不被函数包裹的调用或定义
# 人话，这里只放函数
# complete -W "example example" ftExample
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

    if [[ ! -d "$rDirPathCmdsConfigData" ]]; then
        mkdir -p $rDirPathCmdsConfigData
        ftEcho -s "xbash的data目录:$rDirPathCmdsConfigData"
    fi

    #耦合校验
    local valCount=2
    local errorContent=
    if (( $#>$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -d "$devDirPath" ];then    errorContent="${errorContent}\\n[设备路径不存在]devDirPath=$devDirPath" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftDevAvailableSpace -h
            return
    fi

    local filePathDevStatus=${rDirPathCmdsConfigData}/devs_status
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
#    ftGetKeyValueByBlockAndKey [文件路径] [目标块TAG] [键名]
#    value=\$(ftGetKeyValueByBlockAndKey /temp/odbcinst.ini PostgreSQL Setup)
#    value表示key对应的值
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

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
            value=$(echo $line | awk -F= '{gsub(" |\t","",$2); print $2}')

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
    # ftEcho -s "$ftLanguageContent"

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
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftLanguageUtil -h
            return
    fi
    return=

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
            if [[ $dir =~ "/dev/" ]]&&[[ $devMountDirPath != "/" ]];then
                    sizeTemp=$(ftDevAvailableSpace $devMountDirPath true)
                    # 确定目录已挂载,设备可用空间大小符合限制
                    if mountpoint -q $devMountDirPath&&(($sizeTemp>=$devMinAvailableSpace));then
                        mCmdsModuleDataDevicesList[$indexDevMount]=$devMountDirPath
                        indexDevMount=`expr $indexDevMount + 1`
                    fi
            fi
            indexDevName=`expr $indexDevName + 1`
    done
    export mCmdsModuleDataDevicesList #=${mCmdsModuleDataDevicesList[*]}
}

adb()
{
    local ftEffect=adb修正工具

    local dirPathCode=$ANDROID_BUILD_TOP
    local  filePathAdbNow=$(which adb)
    local  filePathAdbLocal=/usr/bin/adb

    #环境校验
    if [ -z "$filePathAdbNow" ]||[ ! -d "$ANDROID_SDK" ];then
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

    $filePathAdbNow "$@"
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