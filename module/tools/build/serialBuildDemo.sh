#!/bin/bash
#####-----------------------变量------------------------------#########
readonly rModuleName=module/tools/build/serialBuildDemo.sh
readonly rRirPathProcessEnableId=/tmp/ProcessEnableIds
#####----------------------初始化build环境--------------------------#######
# 函数
if [ -f $rFilePathCmdModuleToolsSpecific ];then
    source  $rFilePathCmdModuleToolsSpecific
else
    echo -e "\033[1;31m    函数加载失败\n\
    模块=$rModuleName\n\
    toolsPath=$rFilePathCmdModuleToolsSpecific\n\
    \033[0m"
fi
fileNamePID=$1
echo $fileNamePID
while [[ "enable" != $(cat ${rRirPathProcessEnableId}/${fileNamePID}) ]]; do
    sleep 5
done
# =============================================================
ftEcho -s "${fileNamePID} start"
read -n1 ddd





















# =============================================================
fileNamePID=$(expr $fileNamePID + 1)
echo enable > ${rRirPathProcessEnableId}/${fileNamePID}