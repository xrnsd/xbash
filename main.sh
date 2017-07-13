#! /bin/bash
#####------------------变量------------------------------#########
readonly rModuleName=main.sh

mDirPathXbashTraget=$(cd `dirname $0`; pwd)
mDirNameXbashTragetConfig=config
mDirPathXbashTragetConfig=${mDirPathXbashTraget}/${mDirNameXbashTragetConfig}
mFileNameXbashTragetConfigBase=config_base
mFilePathXbashTragetConfigBase=${mDirPathXbashTragetConfig}/${mFileNameXbashTragetConfigBase}

#####------------------初始化------------------------------#########
if [ -f $mFilePathXbashTragetConfigBase ];then
    source  $mFilePathXbashTragetConfigBase
    #工具函数
    if [ -f $rFilePathCmdModuleTools ];then
        source  $rFilePathCmdModuleTools
    else
echo -e "\033[1;31m    工具函数初始化失败\n\
模块=$rModuleName\n\
toolsPath=$rFilePathCmdModuleTools\n\
\033[0m"
exit
    fi
else
echo -e "\033[1;31m    全局配置初始化失败\n\
模块=$rModuleName\n\
mFilePathXbashTragetConfigBase=$mFilePathXbashTragetConfigBase\n\
\033[0m"
exit
fi
#####---------------------流程函数---------------------------#########
ftWhoAmI()## #命令权限判定
{
    local ftEffect=命令权限判定
    local cmdName=$1

    #耦合校验
    if [ -z "$cmdName" ];then
        ftReadMe $XCMD
    fi

    local valCount=1
    if(( $#!=$valCount ))\
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
    local ftEffect=工具主入口
    while true; do
    case $rBaseShellParameter2 in
    -v | --version )        echo \"Xrnsd extensions to bash\" $rXbashVersion
                break;;
    test)            ftTest "$@"
                break;;
    reboot | shutdown)    ftBoot    $rBaseShellParameter2
                break;;
    -h| --help | -ft | -ftall)    ftReadMe $rBaseShellParameter3 $rBaseShellParameter2
                break;;
    vvv | -vvv)            ftEcho -b xbash;        echo \"Xrnsd extensions to bash\" $rXbashVersion
                ftEcho -b java;        java -version
                ftEcho -b gcc;        gcc -v
    break;;
    *)
        #权限约束开始
        ftWhoAmI $rBaseShellParameter2
        if [ "$commandAuthority" = "root" ]; then
            if [ `whoami` = "root" ]; then
                while true; do
                case $rBaseShellParameter2 in
                    "backup")    ${rDirPathCmdsModule}/${rFileNameCmdModuleMS} backup; break;;
                    "restore")    ${rDirPathCmdsModule}/${rFileNameCmdModuleMS} restore; break;;
                esac
                done
            else
                ftEcho -ex "当前用户权限过低，请转换为root 用户后重新运行"
            fi
        elif [ "$commandAuthority" = "base" ]; then
            if [ `whoami` = $rNameUser ]; then
                while true; do
                case $rBaseShellParameter2 in
                    "restartadb")        ftRestartAdb; break;;
                    "clean_data_garbage")    ftCleanDataGarbage
                break;;
                esac
                done
            else
                ftEcho -ex "转化普通用户后，再次尝试"
            fi
        #权限约束结束
        elif [ "$commandAuthority" = "null" ]; then
            while true; do
            case $XCMD in
            "xk")    ftKillPhoneAppByPackageName $rBaseShellParameter2    ;break;;
            *)    ftEcho -e "命令[${XCMD}]参数=[$1]错误，请查看命令使用示例";ftReadMe $XCMD; break;;
            esac
            done
        fi
        break;;
    esac
    done
}

ftReadAllFt()
{
        local key="local ftEffect="
        for dir in $(cat ~/cmds/module/tools.sh |grep '^ft')
        do
            name=$(cat ~/cmds/module/tools.sh |grep  -C 3 $dir|grep "$key")
            dir=${dir//()/}
            name=${name//$key/}
            name=$(echo $name |sed s/[[:space:]]//g)
            echo "$dir $name"
        done
}

ftReadMe()
{
    local ftEffect=工具命令使用说明

    # 凡调用此方法的操作产生的日志都视为无效
    local dirPathLogExpired=`ftLnUtil ${mFilePathLog%/*}`
    local dirPathLogOther=${rDirPathLog}/other
    if [ ! -d "$dirPathLogOther" ];then
        mkdir $dirPathLogOther
    fi
    if [ "$dirPathLogOther" != "$dirPathLogExpired" ]\
        &&[ $mFilePathLog != "/dev/null" ];then
        local dirPathExpired=${dirPathLogOther}/$(basename $dirPathLogExpired)
        if [ -d $dirPathExpired ];then
            echo "${dirPathLogExpired}  > $dirPathExpired "
           # mv ${dirPathLogExpired}/* $dirPathExpired
            #rm -rf $dirPathLogExpired
        else
            echo "${dirPathLogExpired}  > $dirPathExpired "
           # mv $dirPathLogExpired $dirPathExpired
        fi
        export mFilePathLog=${dirPathLogOther}/$(basename $mFilePathLog)
    fi

    while true; do
        case "$1" in
    ft | -ft )
               ftReadAllFt | column -t
                if [ "$XMODULE" = "env" ];then    return ; fi
                exit;;
    a | A | -a |-A)
    ftEcho -s “命令 参数 -h 可查看参数具体说明”
    cat<<EOF
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
    |  gjh                                       生成国际化所需的xml文件
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

xgl ----- 简单查看最近10次git log
xr ------ 使.bashrc修改生效
xd ------ mtk下载工具
xu ------ 打开xbash配置
.9 ------ 打开.9工具
xs ------ 关机
xss ----- 重启

===============    临时命令 ===================
xversion--[无参] / 查看7731C软件版本
xg6572 ----- 下载mtk6572的工程
    |// xg6572 分支名
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi
exit;;
    xc |test | clean_data_garbage|restartadb | help | gjh)ftEcho -g;
cat<<EOF
xc ----- 常规自定义命令和扩展
    |// xc ×××××
    |
    |  v  -------------------------------------  自定义命令版本
    |  gjh                                       生成国际化所需的xml文件
    |  vvv  -----------------------------------  系统环境关键参数查看
    |  -h/help                                   查看自定义命令说明
    |  test  ----------------------------------  shell测试
    |  restartadb                                重启adb服务
    |  clean_data_garbage  --------------------  快速清空回收站
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi
exit;;
    xb | backup | restore)ftEcho -g;
cat<<EOF
xb ----- 系统维护
    |// xb ×××××
    |
    |  backup  ---------------- [root] --------  备份系统
    |  restore  --------------- [root] --------  还原系统
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi
exit;;
xk | monkey | systemui)ftEcho -g;
cat<<EOF
xk ----- 关闭手机指定进程
    |// xk ×××××
    |
    |  monkey  --------------------------------  关闭monkey
    |  systemui                                  关闭systemui
    |  应用包名  ------------------------------  关闭指定app
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi
exit;;
    xt)
cat<<EOF
xt ----- 检测shell脚本，语法检测和测试运行
    |// xt 脚本文件名
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi
exit;;
    xh)
cat<<EOF
xh ----- 查看具体命令说明
    |// xh 命令名
EOF
    if [ "$XMODULE" = "env" ];then    return ; fi
exit;;
    *)ftReadMe -a;break;;
    esac
done
}

#####-------------------执行------------------------------#########
ftTiming
ftLog
ftMain $@ 2>&1|tee -a $mFilePathLog
ftTiming
exit
