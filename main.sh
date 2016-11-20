#! /bin/bash
#####----------------------变量--------------------------#########
source  $(cd `dirname $0`; pwd)/value

#####---------------------工具函数---------------------------#########
source  ${mRoDirPathCmdTools}tools

#####---------------------流程函数---------------------------#########
source  ${mRoDirPathCmdTools}base

#####-------------------执行------------------------------#########
ftMain 2>&1|tee $mRoFilePathLog
#ftMain
ftTimeLong
exit
