#! /bin/bash
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
if [ -f $rFilePathCmdModuleToolsSpecific ];then
    source  $rFilePathCmdModuleToolsSpecific
    #bash PS1 配置
    export PROMPT_COMMAND='ftSetBashPs1ByGitBranch -b'
    export ENV_XBASH_INIT_STATED=1

    alias xd='ftMtkFlashTool'
    alias xb='ftMaintainSystem'
    alias xc='export XCMD=xc;ftMain'
    alias xss='ftPowerManagement reboot'
    alias xs='ftPowerManagement shutdown'
    alias xbh='export XCMD=xbh;cat $filePathBashHistoryArchive $filePathBashHistory |grep $2'
    alias xu='export XCMD=xu;gedit  $filePathUserConfig $filePathXbashTragetBashrcBase $filePathXbashTragetBashrcConfigBase'

    if [ ! -z `which git` ];then
        alias xgla='ftGitLogShell -a'
        alias xgl='ftGitLogShell 20'
        alias xgll='ftGitLogShell 100'
        alias xch='ftGitCheckoutBranchByName'

        export PROMPT_COMMAND='\
        ftSetBashPs1ByGitBranch
        if [[ $(history 1 | { read x y; echo $y; }) =~ "git" ]];then
         ftSetBashPs1ByGitBranch
        fi'
        alias xbranch="git branch|grep"
    fi

    #命令选项快速适配
    complete -W "backup restore" xb
    complete -W "restartadb test clean_data_garbage  -v -vvv -ft" xc
else
    echo -e "\033[1;31mXbash函数加载失败[ToolsPath=$rFilePathCmdModuleToolsSpecific]\033[0m"
    export ENV_XBASH_INIT_STATED=-1
fi

if [ ! -z `which todos` ]&&[ ! -z `which fromdos` ];then
    alias unix2dos=todos
    alias dos2unix=fromdos
fi

if [ -d "$ANDROID_SDK" ];then
    alias xl='export XCMD=xl;\
                adb logcat -c;\
                adb logcat | grep '
    alias xtext='adb shell input text'
    #输入制定暗码
    alias xam='adb shell am start -a android.intent.action.CALL tel:'
    alias xlc='adb logcat | grep androidrun -i'
    alias xk='ftKillPhoneAppByPackageName'
    alias xle='export XCMD=xle;adb logcat "*:E"'
    alias .9='export XCMD=.9;${rDirPathTools}/sdk/5.1/tools/draw9patch'

    alias xqselect='adb shell am start -n com.mtk.select/com.mtk.select.SelectActivity'
    alias xqsetting='adb shell am start -n com.android.settings/com.android.settings.Settings'
    alias xqlauncher='adb shell am start -n com.android.launcher3/com.android.launcher3.Launcher'
    alias xqcamera='adb shell am start -n com.android.camera2/com.android.camera.CameraActivity'
    alias xqchanglogo='adb shell am start -n com.sprd.bootres/com.sprd.bootres.BootResSelectActivity'
    alias xqfactorytest='adb shell am start -n com.android.factorytest/com.android.factorytest.FTSamHomeActivity'
    alias xqchooseBootAnimation='adb shell am start -n com.android.settings/com.android.settings.ChooseBootAnimationActivity'
    alias xqcamera_test_sub='adb shell am start -n com.mediatek.factorymode/com.mediatek.factorymode.camera.SubCamera'

    # adb logcat -v process | grep $(adb shell ps | grep com.android.systemui | awk '{print $2}')
    # adb logcat |grep Displayed #获取activity 显示时间
    complete -W "123456" xl
    complete -W "systemui monkey launcher com.android.systemui com.android.launcher3 com.android.commands.monkey" xk
    complete -W "push pull sync shell emu logcat forward jdwp install uninstall bugreport backup restore help version wait-for-device start-server kill-server get-state get-serialno get-devpath status-window remount root usb reboot" adb
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