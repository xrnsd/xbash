#!/bin/bash
#####-----------------------变量------------------------------#########
readonly rModuleName=test/base.sh
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

ftDebug()
{
	local ftName=调试用，实时跟踪变量变化

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
#=================== ${ftName}的使用示例===================
#
#	 trap 'echo “行:$LINENO, a=$a,b=$b,c=$c”' DEBUG
#	 根据需要修改 a，b，c
#	rIsDebug设为true
#	 ftDebug [任意命令]
#	 ftDebug echo test
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
	#  	ftEcho -ex 当前非调试模式
	# fi

}
#####----------------------demo函数--------------------------#########
