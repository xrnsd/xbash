#!/bin/bash
#####-----------------------变量------------------------------#########

# 获取xbash所在目录 获取用户名,根据 config/example.config 新建 config/用户名.config，在.gitignore中插入记录
# 根据 module/bashrc/example.bashrc 新建 module/bashrc用户名.bashrc ，在.gitignore中插入记录

key="Xrnsd-extensions-to-bash"
dirPathLocal=$(cd "$(dirname "$0")";pwd)
dirPathLocal=${dirPathLocal//$key/}
echo dirPathLocal=$dirPathLocal
# local userName=$(who am i | awk '{print $1}'|sort -u)
# userName=${userName:-`whoami | awk '{print $1}'|sort -u`}
# if [ "${S/ /}" != "$S" ];then
#     userName=$(whoami)
# fi