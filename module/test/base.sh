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
    if [ "$XMODULE" = "env" ];then
        return
    fi
    exit;; * ) break;; esac;done

    #耦合变量校验
    if [ -z "$rIsDebug" ];then
        ftEcho -eax "函数[${ftEffect}]的参数错误 \
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
#=================== ${ftEffect}使用环境说明=============
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
    if [ "$XMODULE" = "env" ];then
        return
    fi
    exit;;
    #出现错误之后的尝试
    x | X |-x | -X)
        isSecondTime=true
        ftEcho -s "尝试重新开始 [ftEffect]"
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
        ftEcho -ea "[${ftEffect}]的参数错误 \
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

mTimingStart=$(date +%s -d $(date +"%H:%M:%S"))
# ===================================================================================================================================
#####-------------------------------------------------------------------------#########
#####---------------   demo函数     $2为第一个参数 -------------#########
#####---------------------------------------------------------------------------#########
# ===================================================================================================================================

ddutoUpload()
{
    local ftEffect=上传文件到制定smb服务器路径
    local contentUploadSource=$1
    local dirPathUploadSourceLocal=$2

    #使用示例
    while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== [ ${ftEffect} ]的使用示例=============
#
#    ddutoUpload [源文件路径] [源文件所在目录]
#    ddutoUpload xxxx
#=========================================================
EOF
    if [ "$XMODULE" = "env" ];then
        return
    fi
    exit;; * ) break;; esac;done

    #耦合变量校验
    local valCount=2
    if(( $#!=$valCount ))||[ ! -d "$dirPathUploadSourceLocal" ] \
    ||([ ! -d "$contentUploadSource" ]&&[ ! -f "$contentUploadSource" ])\
    ||[ -d "$contentUploadSource" -a `ls $contentUploadSource|wc -w` = "0" ];then
        ftEcho -ea "[${ftEffect}]的上传源文件或目录无效 \
            [参数数量def=$valCount]valCount=$# \
            [上传的源]contentUploadSource=$contentUploadSource \
            请查看下面说明:"
        ddutoUpload -h
        return
    fi

    local serverIp=192.168.1.188
    local userName=server
    local userPassword=123456
    local dirPathServerMoule=智能机软件
    local dirPathUpload=SPRD7731C/鹏明珠/autoUpload

    local dirPathLocal=$(PWD)
    local dirPathUserHome=rDirPathUserHome
    local dirPathUploadLocal=${dirPathUserHome}/upload
    local fileNameUploadSource=$(basename $contentUploadSource)


    if [ ! -z "$mCameraType" ];then
         mv $contentUploadSource ${contentUploadSource}_${mCameraType}
    fi
    mTimingStart=$(date +%s -d $(date +"%H:%M:%S"))
    ftEcho -s "开始上传${fileNameUploadSource} 到\n\${serverIp}/${dirPathUpload}..."


    if [ ! -d $dirPathUploadLocal ];then
        mkdir $dirPathUploadLocal
    else
        ftEcho -s "尝试卸载[$dirPathUploadLocal]"
        echo $userPwd | sudo -S umount $dirPathUploadLocal
    fi
    # 直接挂载服务器模块到本地，不依赖细节
    dirPathServer=${serverIp}/${dirPathServerMoule}
    ftEcho -s "尝试挂载[//$dirPathServer] 到 $dirPathUploadLocal"
    echo $userPwd | sudo -S mount -t cifs //$dirPathServer $dirPathUploadLocal -o username=$userName,password=$userPassword

    if(( $?!=0 ));then
        ftEcho -e "挂载[//$dirPathServer] 到\n $dirPathUploadLocal\n失败"
    else
                            # 挂载成功后，创建项目文件夹目录
                            echo $userPwd | sudo -S mkdir -p ${dirPathUploadLocal}/${dirPathServerMouleContent}
                            echo $userPwd | sudo -S chmod 777 -R ${dirPathUploadLocal}/${dirPathServerMouleContent}

                            local filePathUploadServer=${dirPathUploadLocal}/${dirPathServerMouleContent}/${fileNameUploadSource}
                            ftEcho -s "开始上传${fileNameUploadSource} 到\n${serverIp}/${dirPathServerMouleContent}..."

                             if [ -f $filePathUploadServer ];then
                                mv $filePathUploadServer ${filePathUploadServer}_old
                            fi

                            cd $dirPathUploadSourceLocal

                            tar -cPv $fileNameUploadSource | pigz -1 |sshpass -p $userPassword  ssh -o StrictHostKeyChecking=no  $userName@$serverIp "gzip -d|tar -xPC /media/新卷/${dirPathServerMoule}/${dirPathServerMouleContent}"

                             # 收尾
                             ftEcho -s "${contentUploadSource}\n上传结束"
                             ftTiming
                             echo $userPwd | sudo -S umount $dirPathUploadLocal
                            cd $dirPathLocal
    fi
}
#ddutoUpload /home/wgx/download/A456_N9_3GW_PMZ_RIVO_8M_V1.0_20170414_YHX /home/wgx/download

#cd /media/data/code/7731c/out/packet
#tar -cv A453_N9_3GW_ORRO_V1.3_201611162| pigz -1 |sshpass -p '123' ssh xian@192.168.3.6 "gzip -d|tar -xPC /home/xian/test"


#LOCAL_CFLAGS += -DLIBUTILS_NATIVE=1
