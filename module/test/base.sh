#!/bin/bash
#####-----------------------变量------------------------------#########
readonly rModuleName=test/base.sh
#####----------------------初始化demo环境--------------------------#######
# 函数
if [ -f ${rDirPathCmdsModule}/${rFileNameCmdModuleTools} ];then
    source  ${rDirPathCmdsModule}/${rFileNameCmdModuleTools}
else
    echo -e "\033[1;31m    函数加载失败\n\
    模块=$rModuleName\n\
    toolsPath=${rDirPathCmdsModule}/${rFileNameCmdModuleTools}\n\
    \033[0m"
fi

dirNameDebug=temp
dirPathHome=/home/${rNameUser}/${dirNameDebug}
dirPathHomeDebug=/home/${rNameUser}/${dirNameDebug}
if [ -d $dirPathHome ];then
    if [ ! -d $dirPathDebug ];then
        mkdir  $dirPathDebug
        ftEcho -s 测试用目录[$dirPathDebug]不存在，已新建
    fi
    cd $dirPathDebug
else
    echo -e "\033[1;31m    初始化demo环境失败\n\
    模块=$rModuleName\n\
    dirPathHome=$dirPathHome\n\
    \033[0m"
fi

ftDebug()
{
    local ftEffect=调试用，实时跟踪变量变化

    #使用示例
    while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== [ ${ftEffect} ]的使用示例===================
#
#     trap 'echo “行:$LINENO, a=$a,b=$b,c=$c”' DEBUG
#     根据需要修改 a，b，c
#    rIsDebug设为true
#     ftDebug [任意命令]
#     ftDebug echo test
#=========================================================
EOF
    if [ $XMODULE = "env" ];then
        return
    fi
    exit;; * ) break;; esac;done

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
    #      ftEcho -ex 当前非调试模式
    # fi

}



# complete -W "example example" ftExample
ftExample()
{
    local ftEffect=函数模板
    local isSecondTime=false

    #使用示例
    while true; do case "$1" in
    #使用环境说明
    e | -e |--env) cat<<EOF
#=================== ${ftName}使用环境说明=============
#
#    工具依赖包 example
#=========================================================
EOF
      return;;
    #方法使用说明
    h | H |-h | -H) cat<<EOF
#=================== [ ${ftEffect} ]的使用示例=============
#
#    ftExample 无参
#    ftExample [example]
#=========================================================
EOF
    if [ $XMODULE = "env" ];then
        return
    fi
    exit;;
    #出现错误之后的尝试
    x | X |-x | -X)
        isSecondTime=true
        ftEcho -s "尝试重新开始 [ftName]"
    break;;
    * ) break;;esac;done

    #工具环境校验校验
    if [ -z `which example` ]||[ -z `which example` ];then
        ftExample -e
    fi
    #耦合变量校验
    local valCount=1
    if(( $#!=$valCount ))||[ -z "$example1" ]\
                ||[ -z "$example2" ];then
        ftEcho -ea "[${ftName}]的参数错误 \
            [参数数量def=$valCount]valCount=$# \
            [示例1]example1=$example1 \
            请查看下面说明:"
        if [ $isSecondTime = "false" ];then
            ftExample -x
        fi
        ftExample -h
        return
    fi
}




# -eq =     # -ne !=
# -gt >        # -lt <
# ge >=        # le <=

# if [ $test1 = "1" -o $test2 = "1" ]&&[ $test3 = "3" -a $test4 = "4" ]
# -o 或    # -a 与

# ${dirPathFileList%/*}父目录路径
# ${dirPathFileList##*/}父目录名
# `basename /home/wgx` wgx
# `dirname /home/wgx` /home
# echo 文件名: ${file%.*}”
# echo 后缀名: ${file##*.}”
# sed -i 's/被替换的内容/要替换成的内容/' file #内容包含空格需要转义
#sed -i "s:被替换的内容:要替换成的内容:g" file #被替换的内容为路径，内容包含空格需要转义
#filenumbers= ls -l /media/data_self/backup/os |grep '.tgz'|grep "^-"|wc -l #文件数量获取
#b=${a//123/321};将${a}里的所有123替换为321\
# 分割字符串成数组bnList=$(echo $branchName|tr ")" "\n")

# note=${note:-'常规'}

# ===================================================================================================================================
#####-------------------------------------------------------------------------#########
#####---------------   demo函数     $2为第一个参数 -------------#########
#####---------------------------------------------------------------------------#########
# ===================================================================================================================================
