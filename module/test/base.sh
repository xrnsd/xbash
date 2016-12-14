#!/bin/bash
#####-----------------------变量------------------------------#########
readonly rModuleName=test.sh
#####----------------------初始化demo环境--------------------------#######
# 函数
if [ -f ${rDirPathCmdsModule}/${rFileNameCmdModuleTools} ];then
	source  ${rDirPathCmdsModule}/${rFileNameCmdModuleTools}
else
	echo -e "\033[1;31m	函数加载失败\n\
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
	echo -e "\033[1;31m	初始化demo环境失败\n\
	模块=$rModuleName\n\
	dirPathHome=$dirPathHome\n\
	\033[0m"
fi

#####----------------------demo函数--------------------------#########
# if [ $1 =="memory" -o $1 == "Memory" ];then
if [ ! $2 ]; then
	echo 11
fi
# if [ $1 ="test" -o $1 = "222" ];then 
if [ $([ ! -z $2 ]) -a $(echo -n $2 | grep -q -e "^[0-9][0-9]*$") ];then
	echo 11
else
	echo 22
fi