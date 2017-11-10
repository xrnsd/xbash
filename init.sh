#!/bin/bash
#####-----------------------变量初始化------------------------------#########

# 获取xbash所在目录 获取用户名,用户名对应密码
# 根据 config/example.config 新建 config/用户名.config，在.gitignore中插入记录
# 根据 module/bashrc/example.bashrc 新建 module/bashrc用户名.bashrc ，在.gitignore中插入记录

diaNameLocal="Xrnsd-extensions-to-bash"
dirPathLocal=$(cd "$(dirname "$0")";pwd)

userNameLocal=$(who am i | awk '{print $1}'|sort -u)
if [ "${S/ /}" != "$S" ];then
    userNameLocal=$(whoami)
fi

userPasswdLocal=def_null
status=1
while [[ status -ne "0" ]]; do
    if [[ $userPasswdLocal != "def_null" ]]; then
        echo -e "\033[1;31m密码错误,请重新输入\033[0m";
    fi
    echo -en "请输入用户密码:"
    read -s userPasswdLocal
    echo $userPasswdLocal | sudo -S echo 2> /dev/null
    status=$?
done 

#####-----------------------配置文件生成------------------------------#########
filePathXbashGitgnore=${dirPathLocal}/.gitignore
# config
            fileNameXbashConfigNew=${userNameLocal}.cofig
            dirPathXbashConfig=${dirPathLocal}/config
            filePathXbashConfigExample=${dirPathXbashConfig}/example.cofig
            filePathXbashConfigNew=${dirPathXbashConfig}/${fileNameXbashConfigNew}

            tagUserNameBase="userName="
            tagUserNameNew="userName=$userNameLocal"
            tagdirPathXbashBase="dirPathXbash="
            tagdirPathXbashNew="dirPathXbash=$dirPathLocal"
            taguserPasswordBase="userPassword="
            taguserPasswordNew="userPassword=$userPasswdLocal"

            cp $filePathXbashConfigExample $filePathXbashConfigNew

            sed -i "s:$tagUserNameBase:$tagUserNameNew:g" $filePathXbashConfigNew
            sed -i "s:$tagdirPathXbashBase:$tagdirPathXbashNew:g" $filePathXbashConfigNew
            sed -i "s:$taguserPasswordBase:$taguserPasswordNew:g" $filePathXbashConfigNew

            echo "config/${fileNameXbashConfigNew}" >> $filePathXbashGitgnore

# bash
            fileNameXbashModuleBashrcNew=${userNameLocal}.bashrc
            dirPathXbashModuleBashrc=${dirPathLocal}/module/bashrc
            filePathXbashModuleBashrcExample=${dirPathXbashModuleBashrc}/expmale.bashrc
            filePathXbashModuleBashrcNew=${dirPathXbashModuleBashrc}/${fileNameXbashModuleBashrcNew}

            cp $filePathXbashModuleBashrcExample $filePathXbashModuleBashrcNew

            tagDirPathHomeCmdBase="dirPathHomeCmd=\${dirPathHome}/\${dirNameXbash}"
            tagDirPathHomeCmdNew="dirPathHomeCmd=$dirPathLocal"

            sed -i "s:$tagDirPathHomeCmdBase:$tagDirPathHomeCmdNew:g" $filePathXbashModuleBashrcNew

            echo "module/bashrc/${fileNameXbashModuleBashrcNew}" >> $filePathXbashGitgnore

#####-----------------------配置生效------------------------------#########
dirPathHomeLocal=/home/${userNameLocal}
filePathHomeLocalConfig=/${dirPathHomeLocal}/.bashrc

mv ${filePathHomeLocalConfig} ${filePathHomeLocalConfig}_backup
ln -s $filePathXbashModuleBashrcNew $filePathHomeLocalConfig

if [ ! -z `which git` ];then
    cd $dirPathLocal
    git add -A
    git commit -m "added config by $userNameLocal"
fi