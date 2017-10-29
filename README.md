bash的简单扩展与其他工具配置[部分]
=====
1.初始化环境
----------
    1 sudo chmod -R a+x module/ config/ init.sh
    2 ./init.sh #初始化

2.其他
----------
    1 xc/xc -h 查看简化命令说明，简化命令为脚本函数实现的封装
    2 xc -ft 查看全部脚本函数的简要说明，脚本函数 -h 查看对应函数的具体使用说明
    3 建议,不要以root权限运行xc clean_data_garbage, 不要开启xx[休眠]，这玩意脾气不好
    4 环境目录[参考]
        /home/xxx/
        ├── Xrnsd-extensions-to-bash  --  xbash目录
        ├── tools    -------------------  环境相关
        │        ├───── jdk  ---------------    java jdk
        │        └───── sdk  --------------    android sdk
        └── .bashrc   -------------------  Xrnsd-extensions-to-bash/module/bashrc/用户名.bashrc 的软连接
    5 工程结构
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
        │        ├── tools    -------------------   工具函数实现
        │        │      ├── base.sh                       demo测试,请忽略此文件的修改
        │        │      └── tools.sh                      脚本语法逻辑校验高亮工具
        │        │
        │        └── maintain.sh                    系统维护
        │
        ├── init.sh   ---------------------- xbash初始化
        │
        └── README.md
    6 已验证环境
        ubuntu12.04 x64
        ubuntu14.04 x64
        ubuntu16.04 x64
     7 未实现
        git已安装情况下，根据用户名初始化git配置
