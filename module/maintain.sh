#!/bin/bash
#####-----------------------变量------------------------------#########
readonly rModuleName=maintain.sh
mTypeEdit=$1
mTypeBackupEdit=null

mDate=$(date -d "today" +"%Y%m%d")

mDirPathRestoreTarget=/
mDirPathStoreTarget=null
mDirPathStoreSource=null
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

#####----------------------初始化--------------------------#########
filePathCmdModuleTools=${rDirPathCmdsModule}/${rFileNameCmdModuleTools}
if [ -f $filePathCmdModuleTools ];then
    source  $filePathCmdModuleTools
else
    echo -e "\033[1;31m    初始化失败，基础库无法加载\n\
    模块=$rModuleName\n\
    filePathCmdModuleTools=$filePathCmdModuleTools\n\
    \033[0m"
fi

#####----------------------自有函数--------------------------#########

ftRestoreOperate()
{
    local ftEffect=使用tar还原系统
    while true; do
    ftEcho -y 是否开始还原
    read -n1 sel
    case "$sel" in
        y | Y )
            pathsource=$1
            mDirPathRestoreTarget=$2
            if [ -f $pathsource ];then
                if [ -d $mDirPathRestoreTarget ];then
                sudo tar -xvpzf $pathsource --exclude=$mDirPathRestoreExcludeTarget -C $mDirPathRestoreTarget \
                2>&1 |tee $mFilePathLog
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
    local ftEffect=选择还原使用的版本[备份]包

    #耦合校验
    local valCount=0
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -d $mDirPathStoreSource ];then    errorContent="${errorContent}\\n[版本包存放的设备根目录不存在]mDirPathStoreSource=$mDirPathStoreSource" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "$errorContent"
            # ftRestoreChoiceSource -h
            # return
    fi


    if [ -z "$fileList" ];then
        ftEcho -ex 在${mDirPathStoreSource}没找到有效的版本包
    else
        ftEcho -b 请${ftEffect}
        echo "[序号]        版本包名    ----------------    备注        "
        echo
        for file in $fileList
        do
            local fileBaseName=${file/.tgz/}
            local fileNameNote=${fileBaseName}.note
            local filePathNote=${dirPathBackupNote}/${fileNameNote}
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
    local ftEffect=选择还原的目标目录
    ftEcho -bh 还原的目标目录
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
        2)  echo -en "请输入目标路径："
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
}

ftEchoInfo()
{
    local ftEffect=脚本操作信息显示，用于关键操作前的确认
    local infoType=$1

    #使用示例
    while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== [ ${ftEffect} ]的使用示例=============
#
#    ftEchoInfo [editType]
#    ftEchoInfo backup/restore
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi
    exit;; * ) break;; esac;done

    #耦合校验
    local valCount=1
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$infoType" ];then    errorContent="${errorContent}\\n[显示信息类型为空]infoType=$infoType" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftEchoInfo -h
            return
    fi

    local mVersionChangs="Android build : mtk_KK  mtk_L mtk_M\n\
        Android app : 4.4\n\
        custom bash : xbash ${rXbashVersion}\n\
        tools : jdk1.6 openjdk1.7 sdk ndk flash_tool eclipse"

    ftEcho -bh 请确认下面信息
    if [ $infoType = "restore" ];then
        echo "使用的源文件为：    ${mFileNameRestoreSource}"
        echo "使用的源文件的说明：    ${mNoteRestoreSource}"
        echo "还原的目标目录为：    ${mDirPathRestoreTarget}"
        echo "还原时将忽略目录：    ${mDirPathRestoreExcludeTarget}"
        echo -e "当前系统有效修改：    \033[44m$mVersionChangs\033[0m"

    elif [ $infoType = "backup" ];then

        local btype
        if [ $mTypeBackupEdit = "cg" ];then
            btype=基础
        elif [ $mTypeBackupEdit = "bx" ];then
            btype=全部
        fi

        echo "生成备份的文件为：    ${mFileNameBackupTarget}"
        echo "生成备份文件的目录：    ${mDirPathStoreTarget}"
        echo "生成的备份的说明：    ${mNoteBackupTarget}"
        echo "生成的备份的类型：    ${btype}"
        echo -e "当前系统有效修改：    \033[44m$mVersionChangs\033[0m"
    else
        ftEcho -ex 一脸懵逼
    fi
}

ftSetBackupDevDir()
{
    local ftEffect=选择备份包存放的设备
    # 初始化设备列表[mCmdsModuleDataDevicesList]
    ftInitDevicesList 4096

    #使用示例
    while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== [ ${ftEffect} ]的使用示例=============
#
#    ftSetBackupDevDir 无参
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi
    exit;; * ) break;; esac;done

    #耦合校验
    local valCount=0
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$rNameUser" ];then    errorContent="${rNameUser}\\n[默认用户名为空]rNameUser=$rNameUser" ; fi
    if [ -z "$mCmdsModuleDataDevicesList" ];then    errorContent="${errorContent}\\n[可用的版本包备份存储设备列表为空]mCmdsModuleDataDevicesList=${mCmdsModuleDataDevicesList[@]}" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftSetBackupDevDir -h
            return
    fi

    ftEcho -b 请${ftEffect}

    local devTarget
    local devTargetDir
    local index=0;

    for dev in ${mCmdsModuleDataDevicesList[*]}
    do
        echo [ ${index} ] $dev 可用$(ftDevAvailableSpace $dev)
        # echo [ ${index} ] ${mCmdsModuleDataDevicesList[$index]}
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
            echo
            devTargetDir=${mCmdsModuleDataDevicesList[$dir]}
            break;
         fi
         ftEcho -e 错误的选择：$dir
    done

    # 还原用
    mDirPathStoreSource=$devTargetDir/backup/os/${rNameUser};

    if [ $mTypeEdit = "backup" ];then
        # 备份用
        mDirPathStoreTarget=$devTargetDir/backup/os/${rNameUser};
        if [ ! -d $mDirPathStoreTarget ];then
            mkdir -p $mDirPathStoreTarget
            echo ${mDirPathStoreTarget}不存在已创建
        fi
    elif [ ! -d $mDirPathStoreSource ];then
        ftEcho -ex [$mDirPathStoreSource]不存在,将退出
    fi
}

ftSetBackupType()
{
    local ftEffect=选择备份类型
    mTypeBackupEdit=$1
    if [ -z "$mTypeBackupEdit" ];then
        ftEcho -b 请${ftEffect}
        echo -e "[1]\t基础"
        echo -e "[2]\t全部"
        echo

        while true; do
        echo -en "请选择备份类型(默认基础):"
        read -n1 typeIndex
        #设定默认值
        if [ ${#typeIndex} == 0 ]; then
            typeIndex=1
        fi
        case $typeIndex in
        1)        mTypeBackupEdit=cg; break;;
        2)        mTypeBackupEdit=bx; break;;
         n | N | q |Q)    exit;;
        * )        ftEcho -e 错误的选择：$typeIndex ;echo "输入1,2 选择    输入n，q离开";break;;
        esac
        done
    fi

    mFileNameBackupTargetBase=backup_${mTypeBackupEdit}_${rNameUser}_${mDate}
    mFileNameBackupTarget=${mFileNameBackupTargetBase}.tgz
    mFileNameBackupLog=${mFileNameBackupTargetBase}.log
    mFilePathVersion=${mDirPathStoreTarget}/$mFileNameBackupTarget
}

ftSetRestoreType()
{
    local ftEffect=选择还原时忽略的目录
    #耦合校验
    local valCount=1
    local errorContent=
    if (( $#>$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ ! -d "$rDirPathUserHome" ];then    errorContent="${errorContent}\\n[默认用户的home目录不存在]rDirPathUserHome=$rDirPathUserHome" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "$errorContent"
            # ftSetRestoreType -h
            # return
    fi

    local typeIndex=$1
    if [ -z "$typeIndex" ];then
        ftEcho -b 请${ftEffect}
        echo -e "[1]\t忽略home"
        echo -e "[2]\t不忽略"
        echo

        while true; do
            echo -en "请选择还原设置(回车默认忽略home):"
            read -n1 typeIndex

            #设定默认值
            if [ ${#typeIndex} == 0 ]; then
                typeIndex=1
            fi
            case $typeIndex in
            1 | 2)break;;
            n | N | q |Q)    exit;;
            * )        ftEcho -e 错误的选择：$typeIndex ;echo "选择输入1,2 离开输入n，q";break;;
        esac
        done
    fi
    while true; do
        case $typeIndex in
        1 )        mDirPathRestoreExcludeTarget=$rDirPathUserHome;break;;
        2 )        mDirPathRestoreExcludeTarget=; break;;
    esac
    done
}

ftBackupOs()
{
    local ftEffect=生成版本包
    ftEcho -bh 开始更新排除列表
    #/home/wgx/cmds/data/excludeDirsBase.list
    fileNameExcludeBase=excludeDirsBase.list
    fileNameExcludeAll=excludeDirsAll.list
    mFilePathExcludeBase=${rDirPathUserHome}/${rDirNameCmd}/${rDirNameCmdData}/${fileNameExcludeBase}
    mFilePathExcludeAll=${rDirPathUserHome}/${rDirNameCmd}/${rDirNameCmdData}/${fileNameExcludeAll}

    mDirPathsExcludeBase=(/proc \
                /android \
                /lost+found \
                /mnt \
                /sys \
                /.Trash-0 \
                /media \
                /var/tmp \
                /var/log \
                ${rDirPathUserHome}/workspaces \
                ${rDirPathUserHome}/workspace \
                ${rDirPathUserHome}/download \
                ${rDirPathUserHome}/packages \
                ${rDirPathUserHome}/Pictures \
                ${rDirPathUserHome}/projects \
                ${rDirPathUserHome}/backup \
                ${rDirPathUserHome}/media  \
                ${rDirPathUserHome}/temp \
                ${rDirPathUserHome}/tools \
                ${rDirPathUserHome}/cmds \
                ${rDirPathUserHome}/code \
                ${rDirPathUserHome}/log  \
                ${rDirPathUserHome}/doc  \
                ${rDirPathUserHome}/.AndroidStudio2.1 \
                ${rDirPathUserHome}/.thumbnails \
                ${rDirPathUserHome}/.software \
                ${rDirPathUserHome}/.cache \
                ${rDirPathUserHome}/.local \
                ${rDirPathUserHome}/.wine \
                ${rDirPathUserHome}/.other \
                ${rDirPathUserHome}/.gvfs)

    mDirPathsExcludeAll=(/proc \
                /android \
                /lost+found  \
                /mnt  \
                /sys  \
                /media \
                /var/tmp \
                /var/log \
                ${rDirPathUserHome}/.AndroidStudio2.1 \
                ${rDirPathUserHome}/backup \
                ${rDirPathUserHome}/.software \
                ${rDirPathUserHome}/download \
                ${rDirPathUserHome}/log  \
                ${rDirPathUserHome}/temp \
                ${rDirPathUserHome}/Pictures \
                ${rDirPathUserHome}/projects \
                ${rDirPathUserHome}/workspaces \
                ${rDirPathUserHome}/.cache \
                ${rDirPathUserHome}/.thumbnails \
                ${rDirPathUserHome}/.local \
                ${rDirPathUserHome}/.other \
                ${rDirPathUserHome}/.gvfs)

    local dirsExclude
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

    ftEcho -bh 开始${ftEffect}
    sudo tar -cvPzf  $mFilePathVersion --exclude-from=$fileNameExclude / \
     2>&1 |tee $mFilePathLog

    # tar -cvPzf  --exclude-from=$fileNameExclude / | pigz -1 >$mFilePathVersion \
    # 2>&1 |tee $mFilePathLog
}

ftAddNote()
{
    local ftEffect=记录版本包相关备注
    local dateOnly=$(date -d "today" +"%Y%m%d")
    local dateTime=$(date -d "today" +"%Y%m%d_%H%M%S")
    local dirPathBackupRoot=$1
    local versionName=$2
    local noteBase=$3
    local fileNameDefault=.note.list

    #使用示例
    while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== [ ${ftEffect} ]的使用示例===================
#
#    ftAddNote [dirPathBackupRoot] [versionName]
#    ftAddNote $mDirPathStoreTarget $mFileNameBackupTargetBase
#    ftAddNote $mDirPathStoreTarget $mFileNameBackupTargetBase “常规”
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi
    exit;; * ) break;; esac;done

    #耦合校验
    local valCount=2
    local errorContent=
    if (( $#<$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$dirPathBackupRoot" ];then    errorContent="${errorContent}\\n[dirPathBackupRoot为空]dirPathBackupRoot=$dirPathBackupRoot" ; fi
    if [ -z "$versionName" ];then    errorContent="${errorContent}\\n[版本包名为空]versionName=$versionName" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftAddNote -h
            return
    fi
    local dirPathBackupNote=${dirPathBackupRoot}/.notes
    local fileNameNote=${versionName}.note

    if [ -d ${dirPathBackupRoot} ]&&[ ! -d ${dirPathBackupNote} ];then
            mkdir ${dirPathBackupNote}
            ftEcho -s 新建备注存储目录:${dirPathBackupNote}
    fi

    local filePathDefault=${dirPathBackupNote}/${fileNameDefault}
    local filePathNote=${dirPathBackupNote}/${fileNameNote}

    if [ ! -f $filePathDefault ]; then
        touch $filePathDefault;echo "【 create by wgx 】">$filePathDefault
    fi

    #note文件行数
    lines=$(sed -n '$=' $filePathDefault)
    lines=$((lines/2))
    let lines=lines+1

    local strVersion="[ "${lines}" ] "${versionName}
    if [ -z "$noteBase" ];then
        local tt="请输入版本   ["${versionName}"]  相应的说明[回车默认为常规]:"
        echo
        echo -en $tt
        read note
        #未输入写入默认值
        if [ $mTypeBackupEdit = "cg" ];then
            note=${note:-'常规_默认'}
        elif [ $mTypeBackupEdit = "bx" ];then
            note=${note:-'全部_默认'}
        fi
    else
        note=$noteBase
    fi
    #写入备注总文件
    sed -i "1i ==========================================" $filePathDefault
    sed -i "1i $strVersion           $note" $filePathDefault
    #写入版本独立备注
    sudo echo $note>$filePathNote

    mNoteBackupTarget=$note
}

ftMD5()
{
    local ftEffect=记录和校验版本包的MD5
    local typeEdit=$1
    local dirPathBackupRoot=$2
    local versionName=$3
    local isExit=$4
    isExit=${isExit:-'true'}

    #使用示例
    while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== [ ${ftEffect} ]的使用示例===================
#
#    ftMD5 [type] [path] [fileNameBase/VersionName]
#    ftMD5 check mDirPathStoreSource mFileNameRestoreSourceBase
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi
    exit;; * ) break;; esac;done

    #耦合校验
    local valCount=3
    local errorContent=
    if (( $#<$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$typeEdit" ];then    errorContent="${errorContent}\\n[操作参数为空]typeEdit=$typeEdit" ; fi
    if [ -z "$dirPathBackupRoot" ];then    errorContent="${errorContent}\\n[版本包存放的设备根目录为空]dirPathBackupRoot=$dirPathBackupRoot" ; fi
    if [ -z "$versionName" ];then    errorContent="${errorContent}\\n[版本包名为空]versionName=$versionName" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftMD5 -h
            return
    fi

    local fileNameMd5=${versionName}.md5
    local dirBackupMd5=${dirPathBackupRoot}/.md5s

    if [ ! -d ${dirPathBackupRoot} ];then
        ftEcho -e MD5相关操作失败，找不到$dirPathBackupRoot
        exit
    fi

    if [ ${typeEdit} == "-add" ]; then

        if [ ! -d ${dirBackupMd5} ];then
            mkdir ${dirBackupMd5}
            echo 新建版本包校验信息存储目录:${dirBackupMd5}
        fi

        local pathFile=${dirPathBackupRoot}/${versionName}.tgz
        local pathMd5=${dirBackupMd5}/${fileNameMd5}

        md5=`md5sum $pathFile | awk '{print $1}'`
        sudo echo $md5>$pathMd5

        ftEcho -s "版本${versionName}校验信息记录完成"

    elif [ ${typeEdit} == "-check" ]; then

        ftEcho -b 开始校验版本包，确定有效性

        if [ -d ${dirBackupMd5} ];then
            local pathFile=${dirPathBackupRoot}/${versionName}.tgz
            local pathMd5=${dirBackupMd5}/${fileNameMd5}
            if [ -f ${pathMd5} ];then
                md5Base=`cat $pathMd5`
                md5Now=`md5sum $pathFile | awk '{print $1}'`
                if [ "$md5Base"x != "$md5Now"x ]; then
                    if [ "$isExit" != "true" ]; then
                        return 8
                    fi
                    ftEcho -ex 校验失败，版本包：${versionName}无效
                else
                    ftEcho -s 版本包：${versionName}校验成功
                fi
            else
                if [ "$isExit" != "true" ]; then
                    return 8
                fi
                ftEcho -ex 版本包：${versionName}校验信息查找失败
            fi
        else
            if [ "$isExit" != "true" ]; then
                return 8
            fi
            ftEcho -ex 版本包：${versionName}校验信息查找失败
        fi
    fi

}

ftAutoCleanTemp()
{
    local ftEffect=清理临时文件
    ftEcho -bh 开始${ftEffect}

    sudo apt-get autoclean
    sudo apt-get clean
    sudo apt-get autoremove
    sudo apt-get install -f
    sudo rm -rf /var/cache/apt/archives
}

ftAddOrCheckSystemHwSwInfo()
{
    local ftEffect=记录和校验版本包软件和硬件信息
    local typeEdit=$1
    local dirPathBackupRoot=$2
    local dirNameBackupInfoVersion=$3
    local isExit=$4
    isExit=${isExit:-'true'}

    #使用示例
    while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== [ ${ftEffect} ]的使用示例===================
#
#    ftAddOrCheckSystemHwSwInfo [type] [path] [path]
#    ftAddOrCheckSystemHwSwInfo -check
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi
    exit;; * ) break;; esac;done

    #耦合校验
    local valCount=3
    local errorContent=
    if (( $#<$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$typeEdit" ];then    errorContent="${errorContent}\\n[操作参数为空]typeEdit=$typeEdit" ; fi
    if [ -z "$dirPathBackupRoot" ];then    errorContent="${errorContent}\\n[版本包存放的设备根目录为空]dirPathBackupRoot=$dirPathBackupRoot" ; fi
    if [ -z "$dirNameBackupInfoVersion" ];then    errorContent="${errorContent}\\n[版本包名为空]dirNameBackupInfoVersion=$dirNameBackupInfoVersion" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftAddOrCheckSystemHwSwInfo -h
            return
    fi

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
            echo $infoHwCpu         >$filePathVersionCpu
            echo $infoHwMainboard     >$filePathVersionMainboard
            echo $infoHwSystem         >$filePathVersionSystem
            echo $infoHw32x64         >$filePathVersion32x64

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
                if [ "$isExit" != "true" ]; then
                    return 9
                fi
                exit
            fi

        fi
    fi
}

ftSel()
{
    local ftEffect=版本包软件和硬件信息校验操作选择
    local title=$1
    local valCount=1
    if(( $#!=$valCount ))||[ -z "$title" ];then
        ftEcho -ex "函数[${ftEffect}]参数错误，请查看函数使用示例"
    fi
    while true; do
    ftEcho -y "$1有变动,是否忽悠"
    read -n1 sel
    case "$sel" in
        y | Y )    echo 已忽略$1;break;;
        n | N | q |Q)    exit;;
        * )
            ftEcho -e 错误的选择：$sel
            echo "输入n，q，离开";
            ;;
    esac
    done
}


ftBackUpDevScanning()
{
    local ftEffect=备份设备扫描,同步
    local version=$1
    local note=$2
    local devList=$3

    #使用示例
    while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== [ ${ftEffect} ]的使用示例=============
#
#    ftBackUpDevScanning [version] [note] [backup_dev_list]
#    ftBackUpDevScanning backup_cg_wgx_20161202 常规 "${mCmdsModuleDataDevicesList[*]}"
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi
    exit;; * ) break;; esac;done

    #耦合校验
    local valCount=3
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$version" ];then    errorContent="${errorContent}\\n[目标版本包名为空]version=$version" ; fi
    if [ -z "$note" ];then    errorContent="${errorContent}\\n[目标版本包的备注为空]note=$note" ; fi
    if [ -z "$devList" ];then    errorContent="${errorContent}\\n[存放版本包的设备目录列表为空]devList=${devList[@]} " ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftBackUpDevScanning -h
            return
    fi

    local md5InfoCheckfail=8
    local softwareInfoCheckfail=9
    for devDirPath in ${devList[@]}
    do
        dirPathTarget=${devDirPath}/backup/os/${rNameUser};
        if [ $dirPathTarget = $mDirPathStoreTarget ];then
            continue
        fi
        local filePathVersionTarget=${dirPathTarget}/${version}.tgz
        if [ -f "$filePathVersionTarget" ];then
            while true; do
                ftEcho -y 在设备[${devDirPath}]上存在版本包[${version}],是否同步
                read -n1 sel
                case "$sel" in
                    y | Y )
                        ftEcho -bh 开始版本包[${version}]的可用性校验

                        ftAddOrCheckSystemHwSwInfo -check $dirPathTarget $version false
                        if [ $? -eq "$softwareInfoCheckfail" ];then
                            ftEcho -e 设备[${devDirPath}]上的版本包[${version}]不兼容
                            break
                        fi

                        ftMD5 -check $dirPathTarget $version false
                        if [ $? -eq "$md5InfoCheckfail" ];then
                            ftEcho -e 设备[${devDirPath}]上的版本包[${version}]无效
                            break
                        fi

                        filePathNote=${dirPathTarget}/.notes/${version}.note
                        if [ ! -f "$filePathNote" ]||[ $note != $(cat $filePathNote) ];then
                            echo note=$note
                            echo notett=$(cat $filePathNote)
                            ftEcho -e 设备[${devDirPath}]上版本包[${version}]的备注不一致
                            break
                        fi

                        ftEcho -s 版本包[${version}]可用，开始同步
                        # 写入备注
                        ftAddNote $mDirPathStoreTarget $version $note
                        #复制版本包
                        cp -rf -v $filePathVersionTarget ${mDirPathStoreTarget}/${version}.tgz
                        #复制软硬件信息
                        cp -rf -v ${dirPathTarget}/.info/${version} ${mDirPathStoreTarget}/.info/${version}
                        #复制md5信息
                        cp -rf -v  ${dirPathTarget}/.md5s/${version}.md5 ${mDirPathStoreTarget}/.md5s/${version}.md5
                        ftEcho -s 版本包[${version}]同步结束
                        #清除权限限制
                        chmod 777 -R $mDirPathStoreTarget
                        exit;;
                    n | N | q |Q)break;;
                    * )
                    ftEcho -e 错误的选择：$sel
                    echo "输入n，q，离开";
                    ;;
            esac
            done
        fi
    done
}

ftVersionPackageIsCreated()
{
    local ftEffect=检查版本包是否已经存在

    #使用示例
    while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== [ ${ftEffect} ]的使用示例=============
#
#    ftVersionPackageIsCreated 无参
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi
    exit;; * ) break;; esac;done

    #耦合校验
    local valCount=0
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$mFilePathVersion" ];then    errorContent="${errorContent}\\n[将生成版本包路径为空]mFilePathVersion=$mFilePathVersion" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
            ftVersionPackageIsCreated -h
            return
    fi

    if [ -f $mFilePathVersion ];then
        ftEcho -y 版本[${mFileNameBackupTargetBase}]已存在，是否覆盖
        while true; do
        read -n1 sel
        case "$sel" in
            y | Y )        break;;
            n | N| q |Q)    exit;;
            * )        ftEcho -e 错误的选择：$sel
                    echo "输入n，q，离开";
                    ;;
        esac
        done
    fi
}

ftSynchronous()
{
    local ftEffect=在不同设备间同步版本包
    local dirPathArray=$1
    local fileTypeList=$2

    #使用示例
    while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== [ ${ftEffect} ]的使用示例=============
#
#    ftSynchronous [dirPathArray] [fileTypeList]
#
#     所有存储设备之间同步
#    ftSynchronous "${mCmdsModuleDataDevicesList[*]}" ".*\.info\|.*\.tgz\|.*\.notes\|.*\.md5s\|.*\.info"
#
#     本次备份存储设备和指定存储设备之间同步
#    ftSynchronous "/media/data_xx $mDirPathStoreTarget" ".*\.info\|.*\.tgz\|.*\.notes\|.*\.md5s\|.*\.info"
#
#     自定义 存储设备和存储设备之间同步
#    ftSynchronous "/media/data_xx /media/data_xx" ".*\.info\|.*\.tgz\|.*\.notes\|.*\.md5s\|.*\.info"
#未实现特性
#     1 根据时间阀同步备份
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi
    exit;; * ) break;; esac;done

    #耦合校验
    local valCount=2
    local errorContent=
    if (( $#!=$valCount ));then    errorContent="${errorContent}\\n[参数数量def=$valCount]valCount=$#" ; fi
    if [ -z "$fileTypeList" ];then    errorContent="${errorContent}\\n[同步类型列表为空]fileTypeList=$fileTypeList" ; fi
    if [ -z "$dirPathArray" ];then    errorContent="${errorContent}\\n[同步设备目录列表为空]dirPathArray=${dirPathArray[@]}" ; fi
    if [ ! -z "$errorContent" ];then
            ftEcho -ea "函数[${ftEffect}]的参数错误${errorContent}\\n请查看下面说明:"
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

#####-------------------执行------------------------------#########
if [ `whoami` != "root" ];then
    ftEcho -ex 请转换为root用户后重新运行
fi

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
        ftSetBackupType&&
        # 检查版本包是否已经存在
        ftVersionPackageIsCreated&&
        #显示当前配置信息
        ftEchoInfo backup&&
        while true; do
        ftEcho -y 是否开始备份
        read -n1 sel
        echo
        case "$sel" in
            y | Y )
            #写版本备注
            ftAddNote $mDirPathStoreTarget $mFileNameBackupTargetBase&&
            #扫描设备,同步相同备份
            ftBackUpDevScanning $mFileNameBackupTargetBase $mNoteBackupTarget "${mCmdsModuleDataDevicesList[*]}"
            #清理临时文件
            ftAutoCleanTemp
            #生成版本包
            ftBackupOs&&
            #记录版本包校验信息
            ftMD5 -add $mDirPathStoreTarget $mFileNameBackupTargetBase&&
            #记录版本包相关系统信息
            ftAddOrCheckSystemHwSwInfo -add $mDirPathStoreTarget $mFileNameBackupTargetBase&&
            #同步
            # ftSynchronous "${mCmdsModuleDataDevicesList[*]}" ".*\.info\|.*\.tgz\|.*\.notes\|.*\.md5s\|.*\.info"&&
            # 清除权限限制
            chmod 777 -R $mDirPathStoreTarget
            break;;
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
