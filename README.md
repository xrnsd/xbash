bash的简单扩展与其他工具配置[部分]
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
    │        │     ├── config_bashrc_base.gone          bashrc的用户独有配置[git忽略其修改]
    │        │     └── config_bashrc_base.gone_simple   bashrc的用户独有配置的模版
    │        │
    │        ├── base.config                      全局参数
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
    1 sudo chmod -R a+x module/ config/ init.sh
    2 ./init.sh #初始化

5.其他
----------
    1 xc/xc -h 等为简化命令，搭配参数时和其余命令一样指向原生命令
    2 xc -ft 查看原生命令说明
    3 建议,不要以root权限运行xc clean_data_garbage
    4 建议,不要开启xx[休眠]，这玩意脾气不好
    5 环境目录[参考]
        /home/xxx/
        ├── Xrnsd-extensions-to-bash   --  xbash目录
        ├── tools     -------------------  环境相关
        │        ├───── jdk  ---------------    java jdk
        │        └───── sdk  ---------------    android sdk
        └── .bashrc   -------------------  xbash中module/bashrc/用户.bashrc文件的软连接
