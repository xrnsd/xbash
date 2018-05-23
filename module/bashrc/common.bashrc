#! /bin/bash
#----------------    bash config    ---------------------------
# 忽略特定命令
export HISTIGNORE="[   ]*:ls:ll:cd:vi:pwd:sync:exit:history*"
# 保存历史命令条数
export HISTSIZE=$bashHistorySize
## history 命令显示的格式
# export HISTTIMEFORMAT='%F %T '
## history存放的文件
# export HISTFILE=$filePathBashHistoryArchive

#自动去重备份bash历史记录
if [ "$(whoami)" != "root" ];then
    filePathBashHistory=${dirPathHome}/.bash_history
    filePathBashHistoryTemp=${filePathBashHistory}_temp
    filePathBashHistoryArchive=${filePathBashHistory}_archive
    filePathBashHistoryArchiveTemp=${filePathBashHistoryArchive}_temp
    #备份历史
    let lineCountMax=$HISTSIZE-1
    lineCount=$(wc -l < $filePathBashHistory)
    if (($lineCount > $lineCountMax)); then
        cat $filePathBashHistory >> $filePathBashHistoryArchive \
        && sort -k2n $filePathBashHistoryArchive | awk '{if ($0!=line) print;line=$0}' >${filePathBashHistoryArchiveTemp} \
        && mv $filePathBashHistoryArchiveTemp $filePathBashHistoryArchive
        #过滤需要的History
        cat $filePathBashHistoryArchive|grep -E "adb|git|cd|source|make|lunch" >$filePathBashHistory
        sort -k2n $filePathBashHistory | awk '{if ($0!=line) print;line=$0}' >${filePathBashHistoryTemp}&&\
        mv $filePathBashHistoryTemp $filePathBashHistory
        #history size 自动扩容
        lineCount=$(wc -l < $filePathBashHistory)
        let lineCount=$lineCount+1000
        if (( $lineCount>5000 ));then
            tagdirPathXbashBase="export\ bashHistorySize=5000"
            tagdirPathXbashNew="export\ bashHistorySize=$lineCount"
            sed -i "s:$tagdirPathXbashBase:$tagdirPathXbashNew:g" $filePathUserConfig
        fi
    fi
fi
#----------------    xbash config  ---------------------------
alias ..="effect=进入父目录;cd .."
alias ...="effect=进入爷目录;cd ../.."
alias xcc='effect=进入原目录;cd $OLDPWD'
alias xr="effect=更新xbash配置;source ~/.bashrc"
if [ -f $rFilePathCmdModuleToolsSpecific ];then
    export XMODULE="env" #标记为环境模式，此模式说明直接调用脚本实现
    source  $rFilePathCmdModuleToolsSpecific
    #bash PS1 配置
    export PROMPT_COMMAND='ftSetBashPs1ByGitBranch -b'
    export ENV_XBASH_INIT_STATED=1

    alias xd='effect=MTK下载工具;ftMtkFlashTool'
    alias xX='effect=字符串转大写;_xX(){  echo $1 | tr '[a-z]' '[A-Z]' ;};_xX $1'
    alias Xx='effect=字符串转小写;_Xx(){  echo $1 | tr '[A-Z]' '[a-z]' ;};_Xx $1'
    alias xkf='effect=解除文件或目录占用;fuser -m -k -i '
    alias xb='effect=系统维护;ftMaintainSystem'
    alias xc='effect=xbash主入口[旧];ftMain'
    alias xbash='ftMain'
    alias xss='effect=无密码重启[默认10s];ftPowerManagement reboot'
    alias xs='effect=无密码关机[默认10s];ftPowerManagement shutdown'
    alias xbh='effect=bash命令历史插值;cat $filePathBashHistoryArchive $filePathBashHistory |grep $2'
    alias xu='effect=打开xbash配置文件;gedit  $filePathUserConfig $filePathXbashTragetBashrcBase $filePathXbashTragetBashrcConfigBase'

    if [ ! -z `which git` ];then
        alias xgla='effect=查看本地所有分支历史;ftGitLogShell -a'
        alias xgl='effect=格式化显示20条git_log;ftGitLogShell 20'
        alias xgll='effect=格式化显示100条git_log;ftGitLogShell 100' 

        export PROMPT_COMMAND='\
        ftSetBashPs1ByGitBranch
        if [[ $(history 1 | { read x y; echo $y; }) =~ "git" ]];then
         ftSetBashPs1ByGitBranch
        fi'
        alias xbranch="effect=过滤git分支;git branch|grep -i "
    fi
    if [ -d "$JAVA_HOME" ]&&[ -d "out" ];then
        #java -jar signapk.jar platform.x509.pem platform.pk8  待签名名字.apk  签名后名字.apk "命令进行签名
        alias xAppSignature='effect=apk文件签名;java -jar out/host/linux-x86/framework/signapk.jar  build/target/product/security/platform.x509.pem build/target/product/security/platform.pk8'
    fi

    #命令选项快速适配
    complete -W "--backup --restore --sd_finish -b -r -s" xb
    # complete -W "-h -hb -hc --help restartadb test clean_data_garbage  -v -vvv -ft" xc
    _xc()
    {
        local ftEffect=bash内建命令和xbash扩展封装对应的参数补全实现
        local curr_arg=${COMP_WORDS[COMP_CWORD]}
        case "${COMP_WORDS[1]}" in
                        -)      
                                COMP_WORDS[1]="-h"
                                export COMP_WORDS=${COMP_WORDS[@]}; ;;
                        *)  COMPREPLY=( $(compgen -W '-h -hb -hc --help restartadb test clean_data_garbage  -v -vvv -ft' -- $curr_arg ) ); ;;
          esac
    }
    complete -F _xc xc
else
    echo -e "\033[1;31mXbash函数加载失败[ToolsPath=$rFilePathCmdModuleToolsSpecific]\033[0m"
    export ENV_XBASH_INIT_STATED=-1
fi

if [ ! -z `which todos` ]&&[ ! -z `which fromdos` ];then
    alias unix2dos=todos
    alias dos2unix=fromdos
fi

if [ -d "$ANDROID_SDK" ];then
    alias xl='effect=过滤adb_logcat;adb logcat -c;ftLogcatApplicationByPackageName'
    alias xtext='effect=对设备输入字符串;adb shell input text'
    alias xk='effect=干掉设备对应包名的进程;ftKillApplicationByPackageName'
    alias xlc='effect=清除指定包名的数据; adb shell pm clear'
    alias xle='effect=过滤错误的进程;adb logcat "*:E"'
    alias .9='effect=.9图片制作工具;${ANDROID_SDK}/tools/draw9patch'
    alias xds='effect=手机截图;adb shell screencap -p /sdcard/sc.png&&adb pull /sdcard/sc.png ~/download/'
    alias xdv='effect=手机录屏;adb shell screenrecord /sdcard/sv.mp4&&adb pull /sdcard/sv.mp4 ~/download/'

    alias xqselect='effect=启动隐藏;adb shell am start -n com.mtk.select/com.mtk.select.SelectActivity'
    alias xqsetting='effect=启动设置;adb shell am start -n com.android.settings/com.android.settings.Settings'
    alias xqcamera='effect=启动Camera2;adb shell am start -n com.android.camera2/com.android.camera.CameraActivity'
    alias xqlauncher='effect=启动launcher;adb shell am start -n com.android.launcher3/com.android.launcher3.Launcher'
    alias xqchanglogo='effect=启动隐藏动画;adb shell am start -n com.sprd.bootres/com.sprd.bootres.BootResSelectActivity'
    alias xqfactorytest='effect=启动工厂测试;adb shell am start -n com.android.factorytest/com.android.factorytest.FTSamHomeActivity'

    if [[ -f $rFilePathCmdModuleConfigDataBase ]]; then
        packageNameList="$(ftGetKeyValueByBlockAndKey -f $rFilePathCmdModuleConfigDataBase androidDevicePackages packageNameList)"
    fi
    complete -W "${packageNameList[@]} launcher systemui" xk
    complete -W "${packageNameList[@]} launcher" xlc
    complete -W "${packageNameList[@]} launcher systemui 123456" xl
else
    echo -e "\033[1;31m Android SDK 扩展加载失败[ANDROID_SDK=$ANDROID_SDK]\033[0m"
fi

if [ -d "vendor/mediatek" ];then
        alias xnum='echo "隐藏[Select]：";     cat packages/apps/Dialer/src/com/android/dialer/SpecialCharSequenceMgr.java|grep "MMI_SELECT"|grep "final";\
                                echo "IMEI码显示：";    cat packages/apps/Dialer/src/com/android/dialer/SpecialCharSequenceMgr.java|grep "MMI_IMEI_DISPLAY"|grep "final";\
                                echo "IMEI码编辑：";    cat packages/apps/Dialer/src/com/android/dialer/SpecialCharSequenceMgr.java|grep "MMI_IMEI_EDIT"|grep "final";\
                                echo -n "    ";     cat vendor/lz/op_cust.sh|grep "LZ_IMEI_EDIT_NUM";\
                                echo "工厂模式：";   cat packages/apps/Dialer/src/com/android/dialer/SpecialCharSequenceMgr.java|grep "MMI_FACTORY_TEST"|grep "final";\
                                echo -n "    "; cat vendor/lz/op_cust.sh|grep "LZ_FACTORY_TEST_NUM";\
                                echo "开关机动画修改：";    cat packages/apps/Dialer/src/com/android/dialer/SpecialCharSequenceMgr.java|grep "MMI_MULTI_BOOT_ANIMATION"|grep "final"'
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

        alias xnum='echo "隐藏[Select]：";    cat packages/apps/Dialer/src/com/android/dialer/SpecialCharSequenceMgr.java|grep "MMI_SELECT"|grep "final";\
                                echo "IMEI码显示：";    cat packages/apps/Dialer/src/com/android/dialer/SpecialCharSequenceMgr.java|grep "MMI_IMEI_DISPLAY"|grep "final";\
                                echo "IMEI码编辑：";    cat packages/apps/Dialer/src/com/android/dialer/SpecialCharSequenceMgr.java|grep "WRITE_IMEI"|grep "final";\
                                echo "工厂模式：";   cat packages/apps/Dialer/src/com/android/dialer/SpecialCharSequenceMgr.java|grep "MMI_FACTORYMODE"|grep "final";\
                                echo "开关机动画修改：";    cat packages/apps/Dialer/src/com/android/dialer/SpecialCharSequenceMgr.java|grep "LOGO_CHANGE"|grep "final"'
fi