android mmi开发环境的简单扩展[shell]
![Logo](config/base/logo.png)
=====
1.工程结构
----------
    Xrnsd-extensions-to-bash在下面简写为xbash
    │
    ├── config    -----------------------工具相关配置
    │        ├── base                             工具相关数据
    │        │     └── user-dirs.dirs                   home下默认文件夹配置
    │        │
    │        ├── bashrc                           bashrc通用配置
    │        │     ├── config_bashrc_base               bashrc配置
    │        │     └── config_bashrc_base.gone          bashrc部分可忽略配置
    │        │
    │        ├── config_base                      全局参数
    │        └── config_system_init               android build环境初始化工具的配置文件
    │
    ├── module    ---------------------  脚本实现文件[具体功能]
    │        │
    │        ├── bashrc   --------------------  bashrc独立配置
    │        │      ├── expmale.bashrc                  为普通用户相关bash配置文件
    │        │      ├── wgx-h.bashrc                    为作者使用的普通用户相关bash配置文件
    │        │      ├── wgx.bashrc                      为普通用户相关bash配置文件
    │        │      ├── root.bashrc                     为root相关bash配置文件
    │        │      └── .inputrc                        xbash命令历史补全
    │        │
    │        ├── packet   -------------------   packet工具
    │        │      └── 7731C_AndroidL.pl               sprd的7731c的packet生成工具
    │        │
    │        ├── test    --------------------   脚本测试工具
    │        │      ├── base.sh                         demo测试,请忽略此文件的修改
    │        │      ├── pytools.py                      脚本语法逻辑校验高亮工具
    │        │      └── pytools.README
    │        │
    │        ├── maintain.sh                    系统维护
    │        └── tools.sh   -----------------   工具函数实现
    │
    ├── init.sh   ---------------------- xbash初始化
    │
    └── README.md

2 已验证环境
----------
        ubuntu12.04 x64
        ubuntu14.04 x64
        ubuntu16.04 x64

4.初始化环境
----------
    1 cd Xrnsd-extensions-to-bash
    2 sudo chmod -R a+x module/ config/
    3 ./init.sh #初始化

5.其他
----------
    1 xc ,xb 为简化命令，搭配参数时和其余命令一样指向具体功能实现
    2 建议,不要以root权限运行xc clean_data_garbage
    3 建议,不要开启xx[休眠]，这玩意脾气不好
    4 对记录和校验版本包软件和硬件信息相关实现修改，会影响历史备份的使用[导致检测失败]
    5 环境目录[参考]
        /home/xxx/
        ├── tools     -------------------  环境相关
        │        ├───── jdk  ---------------    java jdk
        │        ├───── sdk  ---------------    android sdk
        │        └───── sp_flash_tool_v5.1548   全局参数
        └── .bashrc   -------------------  xbash中bashrc_work_lz的软连接
