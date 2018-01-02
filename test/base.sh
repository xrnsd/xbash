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
# ===================================================================================================================================
#####-------------------------------------------------------------------------#########
#####---------------   demo函数     $2为第一个参数 -------------#########
#####---------------------------------------------------------------------------#########
# ===================================================================================================================================
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

# cd /media/data/ptkfier/code/mtk6580/code
# dirPath=/media/${rNameUser}/disk/patch
# if [[ -d "$dirPath" ]]; then
#     # ls $dirPath | while read line
#     # do
#     #    git am ${dirPath}/${line}||(git am --abort;break)
#     # done

#     git format-patch -s 172d743 -o $dirPath
# else
#     echo 设备不存在dirPath=$dirPath
# fi
filePath=~/log
if [[ -L "$filePath" ]]; then
    echo 111
fi