#!/bin/bash
#####-----------------------变量------------------------------#########
readonly rModuleName=module/tools/build.sh
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
dirPathProcessEnableId=/tmp/ProcessEnableIds
fileNamePID=$1
while [[ "true" != $(cat ${dirPathProcessEnableId}/${fileNamePID}) ]]; do
    sleep 1
done
# =============================================================
echo $(pwd)
read ddd





















# =============================================================
echo true > ${dirPathProcessEnableId}/$(expr $fileNamePID - 1)