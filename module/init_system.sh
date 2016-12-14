#!/bin/bash
#开发环境初始化工具
#================预定流程=========================
# 1 检测环境
# 	系统版本
# 	系统位数

# 2 检测联网

# 3开始初始化
# 	添加软件源
# 	更新软件源
# 	更新系统软件
# 	根据环境安装软件包

# 4其他修改
# 	cmds相关
# 	建立目录
# 	.bashrc
# 	deb文件安装
# 	hosts
# 	/home/xxx/xxx默认目录

# 5最后修改[未实现脚本自动化]
# 	.ccache相关
# 	GTK主题，图标主题
# 	fstab，磁盘自动挂载
# 	chrome 相关
# 	sublime text 相关
# 	文件默认打开方式

#======================变量=====================
source  $(cd `dirname $0`; pwd)/config/config_system_init

#####---------------------工具函数---------------------------#########
source  $(cd `dirname $0`; pwd)/tools

ftCheckEnv()
{
	local ftName=系统环境检测
}

ftCheckNetwork()
{
	local ftName=检测网络是否链接
	local timeout=5
	local target=www.baidu.com

	#获取响应状态码
	local ret_code=`curl -I -s --connect-timeout $timeout $target -w %{http_code} | tail -n1`

	if [ "x$ret_code" = "x200" ]; then
		echo 网络畅通
	else
		echo 网络不畅通
	fi
}

ftOther()
{
# 4其他修改
#====================    普通权限  ===================
# 	cmds相关
# 	.bashrc
# 	建立目录
# 	deb文件安装
# 	/home/xxx/xxx默认目录
#====================    root权限  ===================
# 	.bashrc
# 	hosts

#====================    暂时未脚本化的修改  ===================
# 	fstab，磁盘自动挂载
# 	chrome 相关
# 	sublime text 相关
# 	文件默认打开方式

local cmdsGitUrl=https://github.com/xrnsd/Xrnsd-extensions-to-bash.git
local dirsHomeCustom=(log doc cmds media temp tools backup projects download workspaces .other)


#====================    普通权限  ===================
#下载cmds
git clone $cmdsGitUrl
mv Xrnsd-extensions-to-bash cmds
#使用自定义普通用户bash配置
mv .bashrc bahrc_base_backup
ln -s cmds/config/bashrc_work_lz .bashrc
#建立目录
for dirName in ${dirsHomeCustom[@]}
do
	mkdir $dirName
done
#设定默认目录
mv data/user-dirs.dirs /home/wgx/.config/user-dirs.dirs


#====================    root权限  ===================
# if [ `whoami` != "root" ];then
# 	read -s -p "将变身奥特曼，请输入密码：" typeIndex
# 	echo $typeIndex | sudo -S su
# fi
#使用自定义root用户bash配置
sudo mv /root/.bashrc /root/bahrc_base_backup
sudo ln -s /home/wgx/cmds/config/bashrc_root_work_lz /root/.bashrc
#升级hosts
sudo cp data/hosts /etc/hosts
}

ftUpdateSoftware()
{
# 	添加软件源
# 	更新软件源
# 	更新系统软件
# 	根据环境安装软件包
	local ftName=更新系统软件

	# 开发版本
	local versionDev=null

	# 添加软件源
	for source in ${rListSoftwareSources[@]}
	do
		echo $rUserPwd | sudo -S  add-apt-repository  $source
	done
	# 更新软件源
	echo $rUserPwd | sudo -S  apt-get update
	# 更新系统软件
	echo $rUserPwd | sudo -S   apt-get upgrade
	# 根据环境安装软件包
	#开发版本公共部分
	echo $rUserPwd | sudo -S apt-get install -y  ${rListVersionSoftwarePublic[*]}
	#开发版本独立部分
	index=0
	for devEnv in ${rListDevEnv[*]}
	do
		echo [${index}]  ${devEnv}
		index=`expr $index + 1`
	done
	ftEcho -b 请选择：
	if [ ${#rListDevEnv[@]} -gt 9 ];then
		read sel
	else
		read -n1 sel
	fi

	listTargetVersionSoftwareName=${rListDevEnvCorrespondSftware["${rListDevEnv[$sel]}"]}
	eval listTargetVersionSoftware=\${$listTargetVersionSoftwareName[@]}
	echo $rUserPwd | sudo -S apt-get install -y ${listTargetVersionSoftware[*]}
}

ftUpdateHosts()
{
	local ftName=更新hosts
	local filePathHosts=/etc/hosts
	local urlCustomHosts=$1

	#使用示例
	while true; do case "$1" in    h | H |-h | -H) cat<<EOF
	#=================== ${ftName}的使用示例=============
	#使用默认hosts源
	#	ftUpdateHosts 无参
	#
	#使用自定义hosts源
	#	ftUpdateHosts [URL]
	#	ftUpdateHosts https://raw.githubusercontent.com/racaljk/hosts/master/hosts
	#=========================================================
EOF
	exit;; * )break;; esac;done

	#耦合变量校验
	local valCount=1
	if (( $#>$valCount ))||[ ! -f "$filePathHosts" ]\
				||[ ! -d "$rDirPathCmdsData" ];then
		ftEcho -ea "[${ftName}]参数错误 \
			[参数数量def=$valCount]valCount=$# \
			filePathHosts=$filePathHosts \
			rDirPathCmdsData=rDirPathCmdsData \
			请查看下面说明:"
		ftUpdateHosts -h
	fi

	# 下载hosts文件
	local url="https://raw.githubusercontent.com/racaljk/hosts/master/hosts"
	local netTool=wget
	local fileNameHostsNew="hosts.new"
	local filePathHostsNew=${rDirPathCmdsData}/${fileNameHostsNew}
	if [ ! -z "$urlCustomHosts" ];then
		url=$urlCustomHosts
	fi
	"$netTool" -q "$url" -O "$filePathHostsNew"

	# 对比hosts文件，确定有无更新
	local hostsVersionBase="Last updated:"
	local hostsVersionOld=$(cat $filePathHosts|grep "$hostsVersionBase")
	local hostsVersionNew=$(cat $filePathHostsNew|grep "$hostsVersionBase")
	if [ ! -f $filePathHostsNew ]||[ "$hostsVersionOld" = "$hostsVersionNew" ];then
		rm -f $filePathHostsNew
		ftEcho -s hosts没有更新,将退出;exit
	else
		local fileNameHostsBase=hosts.base
		local filePathHostsBase=${rDirPathCmdsData}/${fileNameHostsBase}
		if [ ! -f "$filePathHostsBase" ];then
			echo "127.0.0.1	localhost
127.0.1.1	$rNameUser

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

#added by $rNameUser" >$filePathHostsBase
		fi
		# 文件拼接
		local fileNameHostsAllNew=hosts
		local filePathHostsAllNew=${rDirPathCmdsData}/${fileNameHostsAllNew}
		cat $filePathHostsBase $filePathHostsNew>$filePathHostsAllNew
		# 覆盖文件
		echo $mUserPwd | sudo -S mv $filePathHosts ${filePathHosts}_${hostsVersionOld}
		echo $mUserPwd | sudo -S mv -f $filePathHostsAllNew $filePathHosts

	fi

}
