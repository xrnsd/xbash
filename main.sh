#! /bin/bash
#####----------------------变量--------------------------#########
source  $(cd `dirname $0`; pwd)/data/value

#####---------------------工具函数---------------------------#########
source  ${mRoDirPathCmdTools}tools

#####---------------------流程函数---------------------------#########
source  ${mRoDirPathCmdTools}base

#####-------------------执行------------------------------#########
ftTiming
ftMain 2>&1|tee $mRoFilePathLog
#ftMain
ftTiming
exit
