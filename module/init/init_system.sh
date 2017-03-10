#!/bin/bash
#开发环境初始化工具
#================预定流程=========================
# 1 检测环境
#     系统版本
#     系统位数

# 2 检测联网

# 3开始初始化
#     添加软件源
#     更新软件源
#     更新系统软件
#     根据环境安装软件包

# 4其他修改
#     cmds相关
#     建立目录
#     .bashrc
#     deb文件安装
#     hosts
#     /home/xxx/xxx默认目录

# 5最后修改[未实现脚本自动化]
#     .ccache相关
#     GTK主题，图标主题
#     fstab，磁盘自动挂载
#     chrome 相关
#     sublime text 相关
#     文件默认打开方式

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
#     cmds相关
#     .bashrc
#     建立目录
#     deb文件安装
#     /home/xxx/xxx默认目录
#====================    root权限  ===================
#     .bashrc
#     hosts

#====================    暂时未脚本化的修改  ===================
#     fstab，磁盘自动挂载
#     chrome 相关
#     sublime text 相关
#     文件默认打开方式

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
#     read -s -p "将变身奥特曼，请输入密码：" typeIndex
#     echo $typeIndex | sudo -S su
# fi
#使用自定义root用户bash配置
sudo mv /root/.bashrc /root/bahrc_base_backup
sudo ln -s /home/wgx/cmds/config/bashrc_root_work_lz /root/.bashrc
#升级hosts
sudo cp data/hosts /etc/hosts
}

ftUpdateSoftware()
{
#     添加软件源
#     更新软件源
#     更新系统软件
#     根据环境安装软件包
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
    local devList=${rListDevEnv[$sel]}
    listTargetVersionSoftwareName=${rListDevEnvCorrespondSftware["$devList"]}
    eval listTargetVersionSoftware=\${$listTargetVersionSoftwareName[@]}
    echo $rUserPwd | sudo -S apt-get install -y ${listTargetVersionSoftware[*]}
}
