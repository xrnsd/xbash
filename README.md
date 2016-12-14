#android mmi开发环境的bash简单扩展
![Logo](data/logo.png)
##1.工程结构
####Xrnsd-extensions-to-bash在下面简写为xbash
	cmds
	├── config	-----------------------	工具相关配置
	│		├── config_base					全局参数
	│		├── bashrc_base					为普通用户相关bash配置文件
	│		├── bashrc_home					为作者使用的普通用户相关bash配置文件
	│		├── bashrc_root_work_lz			为root相关bash配置文件
	│		├── bashrc_work_lz				为普通用户相关bash配置文件
	│		└── config_system_init			android build环境初始化工具的配置文件
	│
	├── data	-----------------------	工具相关数据
	│		├── logo.png
	│		├── logo.psd
	│		└── user-dirs.dirs				home下默认文件夹配置
	│
	├── module	-----------------------	脚本实现文件[具体功能]
	│		├── compile.sh					xbash的项目编译初始化
	│		├── init_system.sh				android build环境初始化工具
	│		├── init_xbash.sh					xbash环境初始化工具
	│		├── test							xbash的脚本测试工具
	│		│		├── base.sh					demo测试,请忽略此文件的修改
	│		│		├── pytools.README
	│		│		└── pytools.py					脚本语法逻辑校验高亮工具
	│		├── maintain_system.sh			xbash的系统维护
	│		└── tools.sh					xbash的函数实现
	│
	├── main.sh	-----------------------	xbash主入口
	└── README.md

##2.初始化环境

	cd Xrnsd-extensions-to-bash
	./module/init_xbash.sh
	xc help

##3.其他
	1 已验证环境
		ubuntu12.04 x64
		ubuntu14.04 x64
		ubuntu16.04 x64

	2 环境目录
		/home/xxx/
		├── tools      -------------------      环境相关工具
		├── cmds      -------------------      xbash目录
		└── .bashrc     -------------------      xbash目录文件

	3 xc ,xb 为命令分类，搭配参数时和其余命令一样指向具体功能实现
	4 对记录和校验版本包软件和硬件信息相关实现修改，会影响历史备份的使用[导致检测失败]
	5 xx[休眠]建议不要开启，这玩意脾气不好
	6 提示找不到命令
		打开终端
		sudo chmod 777 -R /home/xxxx/cmds
	7 在终端直接使用tools.sh中方法，下列方法在参数错误情况下行为异常
		ftBootAnimation
		ftBoot
		ftSynchronous
