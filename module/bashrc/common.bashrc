#! /bin/bash
#----------------    全局变量 init  ---------------------------
if [[ -z "$Env_Val_Inited" ]]; then
    # 基本配置
    export rXbashVersion="V0.7.8.0 beta"
    # 标记为脚本模式，此模式说明使用实现对应的封装命令
    export XMODULE="script"

    # home/xxxx
   export rNameUser=$userName
    export rDirNameTools=tools
    export rDirNameCmd=$dirNameXbash
    export rDirPathTools=$dirPathHomeTools
    export rDirPathUserHome=$dirPathHome
    # $rDirPathUserHome/xxxx
    export rDirNameCmdConfig=config
    export rDirNameCmdData=data
    export rDirNameCmdModule=module
    # $rDirPathUserHome/cmds/modiule/test
    export rDirNameCmdModuleTest=test

    # $rDirPathUserHome/xxxx
    export rDirPathCmds=${rDirPathUserHome}/${rDirNameCmd}
    # $rDirPathUserHome/cmds/xxxx
    export rDirPathCmdsConfig=$dirPathHomeCmdConfig
    export rDirPathCmdsConfigData=${rDirPathCmdsConfig}/${rDirNameCmdData}
    export rDirPathCmdsModule=${rDirPathCmds}/${rDirNameCmdModule}
    export rDirPathCmdsTest=${rDirPathCmds}/${rDirNameCmdModuleTest}

    # $rDirPathUserHome/cmds/modiule/test/xxxx
    export rFileNameCmdModuleTestBase=base.sh
    # $rDirPathUserHome/cmds/modiule/xxxx
    export rFileNameCmdModuleTools=tools.sh
    export rFileNameCmdModuleMS=maintain.sh

    # $rDirPathUserHome/cmds/modiule/tools/xxx
    export rDirNameCmdModuleTools=tools
    export rFileNameCmdModuleToolsBase=base.sh
    export rFileNameCmdModuleToolsSpecific=tools.sh

    export rDirPathCmdModuleTools=${rDirPathCmdsModule}/${rDirNameCmdModuleTools}
    export rFilePathCmdModuleToolsBase=${rDirPathCmdModuleTools}/${rFileNameCmdModuleToolsBase}
    export rFilePathCmdModuleToolsSpecific=${rDirPathCmdModuleTools}/${rFileNameCmdModuleToolsSpecific}

    # ========设定只读=========
    readonly rXbashVersion
    readonly rNameUser
    readonly rDirPathUserHome
    readonly rDirNameTools
    readonly rDirNameCmd
    readonly rDirNameCmdConfig
    readonly rDirNameCmdData
    readonly rDirNameCmdModule
    readonly rDirNameCmdModuleTest
    readonly rDirPathCmds
    readonly rDirPathCmdsConfigData
    readonly rDirPathCmdsConfig
    readonly rDirPathCmdsModule
    readonly rDirPathCmdsTest
    readonly rFileNameCmdModuleTestBase
    readonly rFileNameCmdModuleTools
    readonly rFileNameCmdModuleMS
    readonly rFilePathCmdModuleToolsSpecific
    readonly rCmdsPermissionRoot
    readonly rCmdsPermissionBase
    readonly rDirPathTools

    export Env_Val_Inited=true
fi
#----------------    bash config    ---------------------------
# 忽略特定命令
export HISTIGNORE="[   ]*:ls:ll:cd:vi:pwd:sync:exit:history*"
# 保存历史命令条数
export HISTSIZE=5000
# 以追加的方式保存命令历史
shopt -s histappend
#自动去重备份bash历史记录
if [ "$(whoami)" != "root" ];then
    filePathBashHistory=${dirPathHome}/.bash_history
    filePathBashHistoryTemp=${filePathBashHistory}_temp
    filePathBashHistoryArchive=${filePathBashHistory}_archive
    filePathBashHistoryArchiveTemp=${filePathBashHistoryArchive}_temp
    #去重
    sort -k2n $filePathBashHistory | awk '{if ($0!=line) print;line=$0}' >${filePathBashHistoryTemp}&&\
    mv $filePathBashHistoryTemp $filePathBashHistory
    #备份历史
    let lineCountMax=HISTSIZE-1
    lineCount=$(wc -l < $filePathBashHistory)
    if (($lineCount > $lineCountMax)); then
        prune_lines=$(($lineCount - $lineCountMax))
        cat $filePathBashHistory >> $filePathBashHistoryArchive \
        && sort -k2n $filePathBashHistoryArchive | awk '{if ($0!=line) print;line=$0}' >${filePathBashHistoryArchiveTemp} \
        && mv $filePathBashHistoryArchiveTemp $filePathBashHistoryArchive \
        && > $filePathBashHistory
    fi
fi
alias ..="cd .."
alias ...="cd ../.."
alias xcc='cd $OLDPWD'
alias xr="source ~/.bashrc"

#----------------    xbash config  ---------------------------
#标记为环境模式，此模式说明直接调用脚本实现
export XMODULE="env"

dirPathHomeCmdConfigBashrc=${dirPathHomeCmdConfig}/bashrc
if [ -f $rFilePathCmdModuleToolsSpecific ];then
    source  $rFilePathCmdModuleToolsSpecific
    #bash PS1 配置
    export PROMPT_COMMAND='ftSetBashPs1ByGitBranch -b'
    export ENV_XBASH_INIT_STATED=1

    alias xd='ftMtkFlashTool'
    alias xb='ftMaintainSystem'
    alias xss='ftPowerManagement reboot'
    alias xtt='subl ${rDirPathCmds}/test/base.sh'
    alias xs='ftPowerManagement shutdown'
    alias xk='ftKillPhoneAppByPackageName'
    alias xc='export XCMD=xc;ftMain'
    alias xch='ftGitCheckoutBranchByName'
    alias xbh='export XCMD=xbh;cat $filePathBashHistoryArchive $filePathBashHistory |grep $2'
    alias xu='export XCMD=xu;gedit  $filePathUserConfig $filePathXbashTragetBashrcConfigBase'
    alias xh='ftMain -ft|grep'

    if [ ! -z `which git` ];then
        gitVersionMin="2.6.0"
        gitVersionNow=$(git --version)
        gitVersionNow=${gitVersionNow//git version/}
        gitVersionNow=$(echo $gitVersionNow |sed s/[[:space:]]//g)

        if [[ $(ftVersionComparison $gitVersionMin $gitVersionNow) = "<" ]];then
            alias xgl='git log --date=format-local:'%y%m%d-%H\:%M\:%S' --pretty=format:"%C(green)%<(17,trunc)%ad %Cred%<(8,trunc)%an%Creset %Cblue%h%Creset %s %C(yellow) %d" -15'
            alias xgll='git log --date=format-local:'%y%m%d-%H\:%M\:%S' --pretty=format:"%C(green)%<(17,trunc)%ad %Cred%<(8,trunc)%an%Creset %Cblue%h%Creset %s %C(yellow) %d" -100'
        else
            #git log --pretty=format:'%Cblue%h%Creset %<(40,trunc)%s [%C(green)%<(21,trunc)%ai%x08%x08%Creset %Cred%an%Creset%C(yellow)%d%Creset]'
            alias xgl='git log --pretty=format:"%C(green)%<(21,trunc)%ai%x08%x08%Creset %Cred%<(8,trunc)%an%Creset %Cblue%h%Creset %s %C(yellow) %d" -15'
            alias xgll='git log --pretty=format:"%C(green)%<(21,trunc)%ai%x08%x08%Creset %Cred%<(8,trunc)%an%Creset %Cblue%h%Creset %s %C(yellow) %d" -100'
        fi

        export PROMPT_COMMAND='\
        ftSetBashPs1ByGitBranch
        if [[ $(history 1 | { read x y; echo $y; }) =~ "git" ]];then
         ftSetBashPs1ByGitBranch
        fi'
        alias xcheckout='git checkout vendor/mediatek/proprietary/scripts'
        alias xbranch="git branch|grep"
    fi

    #命令选项快速适配
    complete -W "backup restore" xb
    complete -W "systemui monkey launcher" xk
    complete -W "restartadb test clean_data_garbage  -v -vvv -ft" xc
else
    echo -e "\033[1;31mXbash函数加载失败[ToolsPath=$rFilePathCmdModuleToolsSpecific]\033[0m"
    export ENV_XBASH_INIT_STATED=-1
fi

if [ ! -z `which todos` ]&&[ ! -z `which fromdos` ];then
    alias unix2dos=todos
    alias dos2unix=fromdos
fi

if [ -d "vendor/sprd" ];then
        alias xversion='cat packages/apps/Settings/src/com/android/settings/DeviceInfoSettings.java|grep "custom_build_version";\
                                cat packages/apps/Settings/src/com/android/settings/DeviceInfoSettings.java|grep "findPreference(KEY_BUILD_NUMBER).setSummary";\
                                cat packages/apps/ValidationTools/src/com/sprd/validationtools/itemstest/SystemVersionTest.java|grep -C 1 "platformVersion.setText(getString(R.string.build_number)"'
        alias xmodel='cat build/tools/buildinfo.sh|grep "ro.product.model=";\
                               cat build/tools/buildinfo.sh|grep "ro.product.brand=";\
                               cat build/tools/buildinfo.sh|grep "ro.product.name=";\
                               cat build/tools/buildinfo.sh|grep "ro.product.device=";\
                               cat device/sprd/scx20/sp7731c_1h10_32v4/sp7731c_1h10_32v4_oversea.mk |grep "product.model.num";\
                               cat frameworks/base/core/res/res/values/strings.xml |grep "wifi_tether_configure_ssid_default"'
        alias xcamera='cat device/sprd/scx20/sp7731c_1h10_32v4/BoardConfig.mk|grep "CAMERA_SUPPORT_SIZE :=";\
                                cat device/sprd/scx20/sp7731c_1h10_32v4/BoardConfig.mk|grep "LZ_CONFIG_CAMERA_TYPE :="'

        alias xnum='echo "隐藏[Select]：";cat packages/apps/Dialer/src/com/android/dialer/SpecialCharSequenceMgr.java|grep "MMI_SELECT";\
                                echo "IMEI码显示：";cat packages/apps/Dialer/src/com/android/dialer/SpecialCharSequenceMgr.java|grep "MMI_IMEI_DISPLAY";\
                                echo "IMEI码编辑：";cat packages/apps/Dialer/src/com/android/dialer/SpecialCharSequenceMgr.java|grep "WRITE_IMEI";\
                                echo "工厂模式：";cat packages/apps/Dialer/src/com/android/dialer/SpecialCharSequenceMgr.java|grep "MMI_FACTORYMODE";\
                                echo "开关机动画修改：";cat packages/apps/Dialer/src/com/android/dialer/SpecialCharSequenceMgr.java|grep "LOGO_CHANGE"'
fi