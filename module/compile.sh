#! /bin/bash
    fuChooseProject()
    {
        echo -e "projects:"
        echo -e "1.\t 6580"
        echo -e "2.\t 6580Version"
        echo -e "3.\t 6735"
        echo -e "4.\t 7731"
    }

    ftInitCompile()
    {
    while true; do
        echo -en "choose project:"
        read -n1 option1
        case $option1 in
        [1]*)ft6580;break;;
        [2]*)ft6580Version;break;;
        [3]*)ft6735;break;;
        [4]*)ft7731;break;;
        *)ft6580;break;;
        # *)  echo "请输入1,2...";;
        esac
    done
    }
    #init project
    ft7731()
    {
    cd /media/data_self/code/7731/idh&&
    source edl.sh&&
    edl
    }

    ft6735()
    {
    cd /media/data_self/code/1104/mtk6735/alps&&
    source edl.sh&&
    edl
    }
    ft6580()
    {
    cd /media/data_self/code/mtk6580/alps&&
    source edl.sh&&
    edl
    }
    ft6580Version()
    {
    cd /media/data_self/code/mtk6580/version/mtk6580/alps&&
    source edl.sh&&
    edl
    }
    #main
    fuChooseProject
    ftInitCompile

    #显示CPU的核心数： sed -n "/processor/p" /proc/cpuinfo | wc -l
    #make -j`sed -n "/processor/p" /proc/cpuinfo | wc -l`
