#android mmi开发环境的bash简单扩展
![Logo](data/logo.png)
##1.工程结构
####Xrnsd-extensions-to-bash在下面简写为xbash
	cmds/config	---------------------	环境相关工具
		config/bashrc_root_work_lz		为root相关bash配置文件
		config/bashrc_base				为普通用户相关bash配置文件
		config/bashrc_work_lz			为作者使用的普通用户相关bash配置文件
		config/bashrc_home				为作者在家使用的普通用户相关bash配置文件
		config/system_init.config		android build环境初始化工具的配置文件

	cmds/data	---------------------	脚本数据存储
		data/excludeDirsAll.list		备份排除[忽略]全部列表
		data/excludeDirsBase.list		备份排除[忽略]基础列表
		data/user-dirs.dirs				home下默认文件夹配置
		data/value						全局参数

	cmds/module	---------------------	脚本实现文件[具体功能]
		module/system_backup_restore.sh	xbash的系统维护
		module/test.sh					xbash的demo测试,请忽略此文件的修改
		module/tools.sh					xbash的函数实现
		module/pytools					xbash的脚本测试工具
		module/compile.sh				xbash的项目编译初始化
		module/system_init.sh			android build环境初始化工具

	cmds/main.sh	-------------------	xbash主入口

##2.准备操作
	环境目录
		/home/xxx/tools	-------------------	环境相关工具
			tools/sdk
			tools/ndk
			tools/jdk
			tools/eclipse
			tools/sp_flash_tool
			tools/xls2values
		/home/xxx/cmds	-------------------	本项目目录
		/home/xxx/.bashrc	---------------	普通用户bash配置
		/root/.bashrc	------------------	root用户bash配置

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

	5 输入xc help查看帮助
		1. 提示找不到命令
		打开新窗口
		sudo chmod 777 -R /home/xxxx/cmds/module
		sudo chmod 777  /home/xxxx/cmds/main.sh
		sudo chmod 777  /home/xxxx/cmds/value
		xc

##3.其他
	1 已验证环境
		ubuntu12.04 x64
		ubuntu14.04 x64
		ubuntu16.04 x64

	3 自定义命令名称
		修改 /home/xxxx/cmds/config/xxxx
		修改 /home/xxxx/cmds/data/value
		修改 /home/xxxx/cmds/module/tools.sh

	4 xc ,xb 为命令分类，搭配参数时和其余命令一样指向具体功能实现
	5 对记录和校验版本包软件和硬件信息相关实现修改，会影响历史备份的使用[导致检测失败]
	6 xx[休眠]建议不要开启，这玩意脾气不好
