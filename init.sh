#!/bin/bash
#####-----------------------变量初始化------------------------------#########

# 获取xbash所在目录 获取用户名,用户名对应密码
# 根据 config/example.config 新建 config/用户名.config，在.gitignore中插入记录
# 根据 module/bashrc/example.bashrc 新建 module/bashrc用户名.bashrc ，在.gitignore中插入记录

diaNameLocal="Xrnsd-extensions-to-bash"
dirPathLocal=$(cd "$(dirname "$0")";pwd)
isFail=

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
done||isFail=userPassword

#####-----------------------配置文件生成------------------------------#########
# git config
if [ -z `which git` ];then
        echo $userPasswdLocal | sudo -S apt-get install  git ||(echo git安装失败，请重新安装;return)
fi
filePathGitConfig=/home/${userNameLocal}/.gitconfig
if [ ! -f "$filePathGitConfig" ];then
    echo -en "请输入git用户名:"
    read -s gitName&&git config --global user.name "$gitName"
    echo -en "请输入git邮箱或联系方式:"
    read -s gitemailUrl&&git config --global user.email "$gitemailUrl"
    echo "已自动初始化gitconfig,需要修改的请查看$filePathGitConfig"
fi||isFail=gitConfig

filePathXbashGitgnore=${dirPathLocal}/.gitignore
# config
        fileNameXbashConfigNew=${userNameLocal}.config
        dirPathXbashConfigBashrc=${dirPathLocal}/config/bashrc
        filePathXbashConfigExample=${dirPathXbashConfigBashrc}/expmale.config
        filePathXbashConfigNew=${dirPathXbashConfigBashrc}/${fileNameXbashConfigNew}

        tagUserNameBase="export\ userName="
        tagUserNameNew="export\ userName=$userNameLocal"
        tagdirPathXbashBase="export\ dirPathXbash="
        tagdirPathXbashNew="export\ dirPathXbash=$dirPathLocal"
        taguserPasswordBase="export\ userPassword="
        taguserPasswordNew="export\ userPassword=$userPasswdLocal"

        cp $filePathXbashConfigExample $filePathXbashConfigNew

        sed -i "s:$tagUserNameBase:$tagUserNameNew:g" $filePathXbashConfigNew
        sed -i "s:$tagdirPathXbashBase:$tagdirPathXbashNew:g" $filePathXbashConfigNew
        sed -i "s:$taguserPasswordBase:$taguserPasswordNew:g" $filePathXbashConfigNew

        echo "config/${fileNameXbashConfigNew}" >> $filePathXbashGitgnore||isFail=xbashConfig

# bash
        fileNameXbashModuleBashrcNew=${userNameLocal}.bashrc
        dirPathXbashModuleBashrc=${dirPathLocal}/module/bashrc
        filePathXbashModuleBashrcExample=${dirPathXbashModuleBashrc}/expmale.bashrc
        filePathXbashModuleBashrcNew=${dirPathXbashModuleBashrc}/${fileNameXbashModuleBashrcNew}

        cp $filePathXbashModuleBashrcExample $filePathXbashModuleBashrcNew

        tagDirPathHomeCmdBase="dirPathHomeCmd=\${dirPathHome}/\${dirNameXbash}"
        tagDirPathHomeCmdNew="dirPathHomeCmd=$dirPathLocal"

        sed -i "s:$tagDirPathHomeCmdBase:$tagDirPathHomeCmdNew:g" $filePathXbashModuleBashrcNew

        echo "module/bashrc/${fileNameXbashModuleBashrcNew}" >> $filePathXbashGitgnore||isFail=xbashConfigGone

#.inputrc 
        fileNameXbashModuleBashrcInputrc=.inputrc
        filePathXbashModuleBashrcInputrc=${dirPathXbashModuleBashrc}/${fileNameXbashModuleBashrcInputrc}

#自定义配置
#1 bashrc PS1 显示git branch 名字
#2 bashrc 历史 自动备份去重复
#3 

#####-----------------------配置生效------------------------------#########
dirPathHomeLocal=/home/${userNameLocal}
filePathHomeLocalConfig=${dirPathHomeLocal}/.bashrc

mv ${filePathHomeLocalConfig} ${filePathHomeLocalConfig}_backup
ln -s $filePathXbashModuleBashrcNew $filePathHomeLocalConfig

filePathHomeLocalConfigInputrc=${dirPathHomeLocal}/${fileNameXbashModuleBashrcInputrc}
mv ${filePathHomeLocalConfigInputrc} ${filePathHomeLocalConfigInputrc}_backup
ln -s $filePathXbashModuleBashrcInputrc $filePathHomeLocalConfigInputrc

if [ ! -z `which git` ];then
    cd $dirPathLocal
    git add -A
    git commit -m "added config by $userNameLocal" >/dev/null||isFail=gitCommit
    echo "commit config by $userNameLocal"
fi

#####------------------初始化结果信息显示-----------------------#########
if [[ -z "$isFail" ]]; then
    echo "$diaNameLocal 初始化成功"
else
    echo "初始化失败,错误信息：$isFail"
fi