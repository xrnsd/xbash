#####----------------------初始化demo环境--------------------------#######
# 函数
if [ -f ${mRoDirPathCmdModule}/${mRoFileNameCmdModuleTools} ];then
	source  ${mRoDirPathCmdModule}/${mRoFileNameCmdModuleTools}
else
	echo -e "\033[1;31m函数加载失败\033[0m"
fi

dirNameDebug=temp
dirPathHome=/home/${mRoNameUser}/${dirNameDebug}
dirPathHomeDebug=/home/${mRoNameUser}/${dirNameDebug}
if [ -d $dirPathHome ];then
	if [ ! -d $dirPathDebug ];then
		mkdir  $dirPathDebug
		ftEcho -s 测试用目录[$dirPathDebug]不存在，已新建
	fi
	cd $dirPathDebug
else
	echo -e "\033[1;31m初始化demo环境失败\033[0m"
fi

#####----------------------demo函数--------------------------#########