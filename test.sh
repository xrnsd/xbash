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
