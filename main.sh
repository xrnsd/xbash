#! /bin/bash
#####----------------------变量--------------------------#########
source  $(cd `dirname $0`; pwd)/value

#####---------------------工具函数---------------------------#########
source  ${mDirPathCmdTools}tools

#####---------------------流程函数---------------------------#########
source  ${mDirPathCmdTools}base

#####-------------------执行------------------------------#########
ftMain 2>&1|tee $mFilePathLog
#ftMain
ftTimeLong
exit
