bash的简单扩展与其他工具配置[部分]
=====
1.初始化环境
----------
    1 sudo chmod -R a+x module/ config/ init.sh
    2 ./init.sh #初始化
    3 重开终端,xc -h 常看实现说明

2.其他
----------
    1 xc/xc -h 查看简化命令说明，简化命令为脚本函数实现的封装
    2 xc -ft 查看全部脚本函数的简要说明，脚本函数 -h 查看对应函数的具体使用说明
    3 建议,不要以root权限运行xc clean_data_garbage, 不要开启xx[休眠]，这玩意脾气不好
    4 环境目录[参考]
        /home/xxx/
        ├── Xrnsd-extensions-to-bash  --  xbash目录
        ├── tools    -------------------  环境相关
        │        ├───── jdk  ---------------   java jdk
        │        └───── sdk  --------------    android sdk
        └── .bashrc   ------------------- Xrnsd-extensions-to-bash/module/bashrc/用户名.bashrc 的软连接
    5 工程结构
        Xrnsd-extensions-to-bash在下面简写为xbash
        │
        ├── config    -----------------------工具相关配置
        │        │
        │        ├── bashrc                         bashrc通用配置
        │        │      │
        │        │      ├── expmale.config               为普通用户相关bash配置模版文件
        │        │      └── wgx.config                   为作者使用的普通用户相关bash配置文件
        │        │
        │        ├── data                           xbash工具数据文件
        │        └── other                          其他工具的配置
        │
        ├── module    ---------------------  脚本实现文件[具体功能]
        │        │
        │        ├── bashrc   --------------------  bashrc独立配置
        │        │      │
        │        │      ├── expmale.bashrc             为普通用户相关xbash配置模版文件
        │        │      ├── common.bashrc              为普通用户相关xbash公共配置文件
        │        │      └── username.bashrc            为用户username使用的xbash配置文件
        │        │
        │        └── tools    -------------------   工具函数实现
        │             ├── maintain.sh                  系统备份和还原
        │             ├── base.sh                      xbash基础框架实现
        │             ├── tools.sh                     xbash的高耦合实现[写的很烂]
        │             └── build                        串行执行
        │                  ├── serialBuildByBranchName.sh      多分支串行编译[环境独立]/在多个终端间串行执行命令的执行主体
        │                  └── serialBuildDemo.sh              串行执行命令的执行主体demo
        │
        ├── init.sh   ----------------------xbash初始化
        ├── test.sh   --------------------- 脚本测试工具,demo测试,请忽略此文件的修改
        └── README.md
    6 已验证环境
        ubuntu12.04 x64
        ubuntu14.04 x64
        ubuntu16.04 x64
     7 未实现
        系统维护工具的信息记录和校验实现重构