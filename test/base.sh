#!/bin/bash
#####-----------------------变量------------------------------#########
readonly rModuleName=test/base.sh
#####----------------------初始化demo环境--------------------------#######
# 函数
if [ -f $rFilePathCmdModuleToolsSpecific ];then
    source  $rFilePathCmdModuleToolsSpecific
else
    echo -e "\033[1;31m    函数加载失败\n\
    模块=$rModuleName\n\
    toolsPath=$rFilePathCmdModuleToolsSpecific\n\
    \033[0m"
fi

dirNameDebug=temp
dirPathHomeDebug=${rDirPathUserHome}/${dirNameDebug}
if [ -d $rDirPathUserHome ];then
    if [ ! -d $dirPathHomeDebug ];then
        mkdir  $dirPathHomeDebug
        ftEcho -s 测试用目录[$dirPathHomeDebug]不存在，已新建
    fi
    cd $dirPathHomeDebug
else
    echo -e "\033[1;31m    初始化demo环境失败\n\
    模块=$rModuleName\n\
    rDirPathUserHome=$rDirPathUserHome\n\
    \033[0m"
fi

# -eq =     -ne !=
# -gt  >      -ge >=
# -lt   <      le <=

# if [ $test1 = "1" -o $test2 = "1" ]&&[ $test3 = "3" -a $test4 = "4" ]
# -o 或    # -a 与

# 根据包名 过滤log
# adb logcat -v process | grep $(adb shell ps | grep com.android.systemui | awk '{print $2}')

# 把.git 以2048M为界压缩成 MTK6580L.tar. aa MTK6580L.tar. ab ......
# pigz 分包压缩 tar --use-compress-program=pigz -cvpf - .git |split -b 2048m - MTK6580L.tar. 

# adb 模拟输入
# adb shell input text "526541651651"

#算术运算
#$[ $dff+1 ]
mTimingStart=$(date +%s -d $(date +"%H:%M:%S"))
# ===================================================================================================================================
#####-------------------------------------------------------------------------#########
#####---------------   demo函数     $2为第一个参数 -------------#########
#####---------------------------------------------------------------------------#########
# ===================================================================================================================================
# cd /media/data/ptkfier/code/mtk6580L/alps
# git tag -a "$2" -m "Release version $2"
# git push origin --tags


# dirPathProcessEnableId=/tmp/ProcessEnableIds
# rm -rf $dirPathProcessEnableId
# mkdir $dirPathProcessEnableId

# for (( i = 0; i <2; i++ )); do
#     if [[ -z "$size" ]]; then
#         size=1000
#         stae=true
#     else
#         stae=false
#     fi
#     echo $stae>${dirPathProcessEnableId}/${size}
#     gnome-terminal -x bash -c "${rDirPathCmdModuleTools}/build.sh $size"
#     gnome-terminal -e 'bash -c "read dd"'  --window --tab -e 'bash -c "echo 11;read ff"'
#     size=`expr $size - 1`
# done

# 要将目录logs打包压缩并分割成多个1M的文件，可以用下面的命令：
# tar cjf - logs/ |split -b 1m - logs.tar.bz2.
# 完成后会产生下列文件：
# logs.tar.bz2.aa, logs.tar.bz2.ab, logs.tar.bz2.ac
# 要解压的时候只要执行下面的命令就可以了：
# cat logs.tar.bz2.a* | tar xj

# cd /home/wgx/code/mtk6580/code
# tar --use-compress-program=pigz -cvpf - .git |split -b 2048m - MTK6580M_$(date -d "today" +"%y%m%d%H%M%S").tgz

# 压缩
ftTar()
{
    local ftEffect=tar优化加速和分包参数封装
    local source=$1
    local traget=$2
    local splitSize=$3

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
#    ftTar 无参
#    ftTar [example]
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi; exit;;
    * ) break;;esac;done

    #环境校验
    if [ -z `which sshpass` ]||[ -z `which pigz` ];then
        ftTar -e
        return
    fi

    #耦合校验
    local valCount=3
    local errorContent=
    if (( $#>$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$source" ];then    errorContent="${errorContent}\\n[压缩源为空]"
    elif [ ! -d "$source" ]&&[ ! -f "$source" ];then errorContent="${errorContent}\\n[压缩源找不到]source=$source" ;fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftTar -h
            return
    fi

    local lastName=".tgz"
    local fileNameTarPackage=traget${lastName}

    local pathLastItemName=$(basename $source)
    pathLastItemName=${pathLastItemName%.*}
    if [[ -z "traget" ]]&&[[ ! -z  "$pathLastItemName" ]]; then
        fileNameTarPackage=$pathLastItemName
        # fileNameTarPackage=${fileNameTarPackage}_$(date -d "today" +"%y%m%d%H%M%S")
        fileNameTarPackage=${fileNameTarPackage}${lastName}
    elif [[ -d "$traget" ]]; then
        fileNameTarPackage=${traget}${fileNameTarPackage}
    else
        if [[ -z "${traget##*.}" ]]; then
            fileNameTarPackage=${traget}${lastName}
        else
            fileNameTarPackage=$traget
        fi
    fi

    echo source=$source
    echo fileNameTarPackage=$fileNameTarPackage

    # if [[ -z "$splitSize" ]]; then
    #     tar --use-compress-program=pigz -cvpf $fileNameTarPackage $source
    # else
    #     tar --use-compress-program=pigz -cvpf - $source |split -b $splitSize - $fileNameTarPackage
    # fi
}

# ftTar $2 $3 $4