#!/bin/bash
#####-----------------------变量------------------------------#########
readonly rModuleName=test/base.sh
#####----------------------初始化demo环境--------------------------#######
# 函数
if [ -f $rFilePathCmdModuleToolsSpecific ];then
    source  $rFilePathCmdModuleToolsSpecific
else
    echo -e "\033[1;31m    函数加载失败\n\
    模块=$rModuleName\n\
    toolsPath=$rFilePathCmdModuleToolsSpecific\n\
    \033[0m"
fi

# -eq =     -ne !=
# -gt  >      -ge >=
# -lt   <      le <=

# 根据包名 过滤log
# adb logcat -v process | grep $(adb shell ps | grep com.android.systemui | awk '{print $2}')

# 把.git 以2048M为界压缩成 MTK6580L.tar. aa MTK6580L.tar. ab ......
# pigz 分包压缩 tar --use-compress-program=pigz -cvpf - .git |split -b 2048m - MTK6580L.tar. 

#算术运算
#$[ $dff+1 ]
# ===================================================================================================================================
#####-------------------------------------------------------------------------#########
#####---------------   demo函数     $2为第一个参数 -------------#########
#####---------------------------------------------------------------------------#########
# ====================================================================================================================
cd /home/wgx-h/.config/sublime-text-3/Packages/User 

ln -s /home/wgx-h/xbash/config/other/sublime_text/sublime-snippet/java_tamplate_zsd.sublime-snippet
ln -s /home/wgx-h/xbash/config/other/sublime_text/sublime-snippet/shell_adb.sublime-snippet
ln -s /home/wgx-h/xbash/config/other/sublime_text/sublime-snippet/xbash_ini.sublime-snippet
ln -s /home/wgx-h/xbash/config/other/sublime_text/sublime-snippet/java_tamplate_zsl.sublime-snippet
ln -s /home/wgx-h/xbash/config/other/sublime_text/sublime-snippet/shell_array.sublime-snippet         
ln -s /home/wgx-h/xbash/config/other/sublime_text/sublime-snippet/xml_tamplate_zsd.sublime-snippet
ln -s /home/wgx-h/xbash/config/other/sublime_text/sublime-snippet/java_tamplate_zsm.sublime-snippet
ln -s /home/wgx-h/xbash/config/other/sublime_text/sublime-snippet/shell_directory_file.sublime-snippet
ln -s /home/wgx-h/xbash/config/other/sublime_text/sublime-snippet/xml_tamplate_zsm.sublime-snippet
ln -s /home/wgx-h/xbash/config/other/sublime_text/sublime-snippet/java_tamplate_zs.sublime-snippet 
ln -s /home/wgx-h/xbash/config/other/sublime_text/sublime-snippet/shell_git.sublime-snippet
ln -s /home/wgx-h/xbash/config/other/sublime_text/sublime-snippet/xml_tamplate_zs.sublime-snippet
ln -s /home/wgx-h/xbash/config/other/sublime_text/sublime-snippet/java_tamplate_zst.sublime-snippet
ln -s /home/wgx-h/xbash/config/other/sublime_text/sublime-snippet/shell_tar.sublime-snippet
ln -s /home/wgx-h/xbash/config/other/sublime_text/sublime-snippet/xml_tamplate_zsv.sublime-snippet
ln -s /home/wgx-h/xbash/config/other/sublime_text/sublime-snippet/java_tamplate_zsv.sublime-snippet
ln -s /home/wgx-h/xbash/config/other/sublime_text/sublime-snippet/shell_value.sublime-snippet

