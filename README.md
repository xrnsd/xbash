# Xrnsd-extensions-to-bash   
android mmi开发环境的bash简单扩展
##说明：
###环境耦合较高，需要解耦，下面时作者环境说明
####1.环境目录
		home/xxx/tools     环境相关工具
		home/xxx/cmds      本项目文件
		home/xxx/.bashrc   为home/xxx/cmds/config/bashrc_xxxx的软连
						
####2.工程结构
		cmds/config     					环境相关工具
			config/bashrc_root_work_lz     	为root相关bash配置文件
			config/bashrc_work_lz     		为普通用户相关bash配置文件
		cmds/module     					脚本实现文件[具体功能]
			module/base     				Xrnsd-extensions-to-bash的流程控制
			module/compile.sh     			Xrnsd-extensions-to-bash的项目编译初始化
			module/system_backup_restore.sh Xrnsd-extensions-to-bash的系统维护
			module/test.sh     				Xrnsd-extensions-to-bash的demo测试
			module/tools     				Xrnsd-extensions-to-bash的小功能实现
		cmds/main.sh     					Xrnsd-extensions-to-bash主入口
		cmds/value     						全局参数
				
####3.准备操作
		1 下载项目
			clone xxx
		2 修改项目目录名称，这步跳过的话需要修改 Xrnsd-extensions-to-bash/config/bashrc_xxxx
			mv Xrnsd-extensions-to-bash cmds
		
		3 使用自定义普通用户bash配置
				cd /home/xxx
				mv .bashrc .bashrc_base.backup
				#bashrc_xxx默认为bashrc_work_lz
				ln -s cmds/config/bashrc_xxx
		4 使用自定义root用户bash配置
				cd /root
				mv .bashrc .bashrc_base.backup
				#bashrc_xxx默认为bashrc_root_work_lz
				ln -s /home/xxxx/cmds/config/bashrc_root_xxx
		5 输入xc 查看帮助
