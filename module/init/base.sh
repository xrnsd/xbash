#!/bin/bash
shellParameter1=${1:-'base'}

while true; do
	if [ -z $shellParameter1 ];then
		echo -en 请重新输入参数:
		read shellParameter1
	fi
	case $shellParameter1 in
		base | -base )		./init_xbash.sh; break;;
		system | -system )	./init_system.sh; break;;
		all | -all )		./init_system.sh;./init_xbash.sh; break;;
		n | N | q |Q)		exit;;
		* )			echo -e "错误参数：$shellParameter1\n\
无参	初始化xbash\n\
-system	初始化system\n\
-all	初始化xbash,初始化system"
					shellParameter1=
				;;
	esac
done