# Xrnsd-extensions-to-bash ，android mmi开发环境的bash简单扩展

##说明：环境耦合较高，需要解耦，下面介绍作者环境和工具初始化
##已验证环境
		ubuntu12.04 x64
			12.04 下xx[休眠]建议不要开启，太不稳定了
		ubuntu14.04 x64
		ubuntu16.04 x64

##环境目录
		home/xxx/tools     环境相关工具
				tools/sdk
				tools/ndk
				tools/jdk
				tools/eclipse
				tools/sp_flash_tool
				tools/xls2values
		home/xxx/cmds      本项目文件[对Xrnsd-extensions-to-bash重命名]
		home/xxx/.bashrc   为home/xxx/cmds/config/bashrc_xxxx的软连接
		/root/.bashrc      为home/xxx/cmds/config/bashrc_root_xxxx的软连接

##工具
###1.工程结构，Xrnsd-extensions-to-bash在下面简写为xbash
		cmds/config     					环境相关工具
			config/bashrc_root_work_lz     	为root相关bash配置文件
			config/bashrc_base 				为普通用户相关bash配置文件
			config/bashrc_work_lz     		为作者使用的普通用户相关bash配置文件
		cmds/module     					脚本实现文件[具体功能]
			module/base     				xbash的流程控制
			module/system_backup_restore.sh xbash的系统维护
			module/test.sh     				xbash的demo测试,请忽略此文件的修改
			module/tools     				xbash的小功能实现
			module/pytools     				xbash的脚本测试工具
			module/compile.sh     			xbash的项目编译初始化
		cmds/data     						脚本数据存储
			data/excludeDirsAll.list		备份排除[忽略]全部列表
			data/excludeDirsBase.list		备份排除[忽略]基础列表
			data/version/read.me			系统当前有效修改说明信息
			data/value     				全局参数
		cmds/main.sh     					xbash主入口

###2.准备操作
		1 下载项目
			git clone https://github.com/xrnsd/Xrnsd-extensions-to-bash.git

		2 修改项目目录名称，这步跳过的话需要修改 Xrnsd-extensions-to-bash/config/bashrc_xxxx,
		将下面所有步骤的cmds替换为Xrnsd-extensions-to-bash
			mv Xrnsd-extensions-to-bash cmds

		3 使用自定义普通用户bash配置
			cd /home/xxx
			mv .bashrc .bashrc_base.backup
			#作者使用bashrc_work_lz
			ln -s cmds/config/bashrc_base .bashrc
			gedit .bashrc
			修改pwd=123，替换成自己的密码
			修改tools相关工具[有的话]，对应到你当前环境下的路径，如jdk的路径

		4 使用自定义root用户bash配置
			cd /root
			mv .bashrc .bashrc_base.backup
			#bashrc_xxx默认为bashrc_root_work_lz
			sudo ln -s /home/xxxx/cmds/config/bashrc_root_xxx .bashrc
			sudo gedit .bashrc
			修改pwd=123，替换成自己的密码
			修改tools相关工具[有的话]，对应到你当前环境下的路径，如jdk的路径

		5 输入xc 查看帮助
			1. 提示找不到命令
				打开新窗口
				sudo chmod 777 -R /home/xxxx/cmds/module
				sudo chmod 777  /home/xxxx/cmds/main.sh
				sudo chmod 777  /home/xxxx/cmds/value
				xc

		6 自定义命令名称
			修改 /home/xxxx/cmds/config/xxxx
			修改 /home/xxxx/cmds/value
			修改 /home/xxxx/cmds/module/base
