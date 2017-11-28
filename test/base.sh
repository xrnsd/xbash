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

dirNameDebug=temp
dirPathHomeDebug=${rDirPathUserHome}/${dirNameDebug}
if [ -d $rDirPathUserHome ];then
    if [ ! -d $dirPathHomeDebug ];then
        mkdir  $dirPathHomeDebug
        ftEcho -s 测试用目录[$dirPathHomeDebug]不存在，已新建
    fi
    cd $dirPathHomeDebug
else
    echo -e "\033[1;31m    初始化demo环境失败\n\
    模块=$rModuleName\n\
    rDirPathUserHome=$rDirPathUserHome\n\
    \033[0m"
fi

# -eq =     -ne !=
# -gt  >      -ge >=
# -lt   <      le <=

# if [ $test1 = "1" -o $test2 = "1" ]&&[ $test3 = "3" -a $test4 = "4" ]
# -o 或    # -a 与

# echo 文件名: ${file%.*}”
# echo 后缀名: ${file##*.}”
# ${dirPathFileList%/*}父目录路径
# ${dirPathFileList##*/}父目录名
# `basename /home/wgx` wgx
# `dirname /home/wgx` /home
#sed -i 's/被替换的内容/要替换成的内容/' file #内容包含空格需要转义
#sed -i "s:被替换的内容:要替换成的内容:g" file #被替换的内容为路径，内容包含空格需要转义

#filenumbers= ls -l /media/data_self/backup/os |grep '.tgz'|grep "^-"|wc -l #文件数量获取
#b=${a//123/321} #将${a}里的所有123替换为321\

# versionName=$(echo $versionName |sed s/[[:space:]]//g) #删除所有空格

# LOWERCASE=$(echo $VARIABLE | tr '[A-Z]' '[a-z]') #转小写

# 分割字符串成数组bnList=$(echo $branchName|tr ")" "\n")

# 字符串包含if [[ helloworld == *low* ]];then

# 路径替换
# a=/aa2344aa/123bb
# echo b=$(echo $a | sed "s 123/  222/ ")

# note=${note:-'常规'}

# 遍历目录
#ls /home/test/ | while read line
#do
#    echo $line
#done

# 倒序遍历数组
# i=${#hashLIst[@]}
# while [ $i -gt "0" ]
# do
#   let i--
#   #${hashLIst[$i]}
# done

# 根据包名 过滤log
# adb logcat -v process | grep $(adb shell ps | grep com.android.systemui | awk '{print $2}')

# 把.git 以2048M为界压缩成 MTK6580L.tar. aa MTK6580L.tar. ab ......
# pigz 分包压缩 tar --use-compress-program=pigz -cvpf .git |split -b 2048m - MTK6580L.tar. 

# 遍历 ls 输出内容
# ls xxxxx | while read line;do echo $line ;done

# adb 模拟输入
# adb shell input text "526541651651"

# 对比文件不同
#diff 文件1 文件2

#算术运算
#$[ $dff+1 ]
mTimingStart=$(date +%s -d $(date +"%H:%M:%S"))
# ===================================================================================================================================
#####-------------------------------------------------------------------------#########
#####---------------   demo函数     $2为第一个参数 -------------#########
#####---------------------------------------------------------------------------#########
# ===================================================================================================================================
# cd /media/data/ptkfier/code/mtk6580L/alps
# git tag -a "$2" -m "Release version $2"
# git push origin --tags


# dirPathProcessEnableId=/tmp/ProcessEnableIds
# rm -rf $dirPathProcessEnableId
# mkdir $dirPathProcessEnableId

# for (( i = 0; i <2; i++ )); do
#     if [[ -z "$size" ]]; then
#         size=1000
#         stae=true
#     else
#         stae=false
#     fi
#     echo $stae>${dirPathProcessEnableId}/${size}
#     gnome-terminal -x bash -c "${rDirPathCmdModuleTools}/build.sh $size"
#     gnome-terminal -e 'bash -c "read dd"'  --window --tab -e 'bash -c "echo 11;read ff"'
#     size=`expr $size - 1`
# done

# package com.edl.memory;

# import android.R.bool;
# import android.app.Activity;
# import android.content.Context;
# import android.os.Bundle;
# import android.view.LayoutInflater;
# import android.view.MotionEvent;
# import android.view.View;
# import android.view.View.OnTouchListener;
# import android.view.WindowManager;

# public class MainActivity extends Activity implements OnTouchListener
# {
#     private static final String TAG = "123456";
#     public final static boolean DEBUG = true;
#     Bundle mBundle;
#     @Override
#     public void onCreate(Bundle savedInstanceState)
#     {
#         super.onCreate(savedInstanceState);
#         View mianView=LayoutInflater.from(MainActivity.this).inflate(R.layout.activity_main, null);
#         getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
#         setContentView(mianView);
#         findViewById(R.id.main).setOnTouchListener(this);
#     }

#     private void updateTitle(boolean is_enable) {
#         setTitle(is_enable?"OK":"NO");
#     }

#     @Override
#     public boolean onTouch(View arg0, MotionEvent arg1) {
#         determineTouchEvent(arg0.getContext() ,arg1);
#         return true;
#     }

#     public final static boolean IS_DEBUG_TOUCH_GESTUER=true;
#     public final static int THRESHOLDVALUE_TIME=200;
#     public static float THRESHOLDVALUE_DOWN = 15;
#     public static float THRESHOLDVALUE_MOVE = 20;
#     float mTriggerCoordinatesY =0,downX =0, downY = 0,moveY=0;
#     boolean isEnableDown =false;
#     boolean isTouchGesture=false;

#     public void determineTouchEvent(Context context,MotionEvent arg1) {
#         if(mTriggerCoordinatesY==0){
#             //dp 2 px
#             final float scale = context.getResources().getDisplayMetrics().density;
#             THRESHOLDVALUE_DOWN=(THRESHOLDVALUE_DOWN * scale + 0.5f);
#             THRESHOLDVALUE_MOVE=(THRESHOLDVALUE_MOVE * scale + 0.5f);

#             mTriggerCoordinatesY=context.getResources().getDisplayMetrics().heightPixels-THRESHOLDVALUE_DOWN;
#         }

#         switch (arg1.getAction()) {
#         case MotionEvent.ACTION_DOWN:

# //            downX = arg1.getRawX();
#             downY = arg1.getRawY();
#             isEnableDown = downY>=mTriggerCoordinatesY;
#             updateTitle(false);
#             break;

#         case MotionEvent.ACTION_MOVE:
#             if(isEnableDown){
#                 moveY = downY-arg1.getRawY();
#                 if(moveY>THRESHOLDVALUE_MOVE){
#                     float time=arg1.getEventTime()-arg1.getDownTime();
#                     if(IS_DEBUG_TOUCH_GESTUER) android.util.Log.d("123456", "MainActivity___onTouch time="+time);
#                     updateTitle(time<THRESHOLDVALUE_TIME);
#                     isEnableDown=false;
#                 }
#             }
#             break;
#         }
#     }
# }
