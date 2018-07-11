bash的简单扩展与其他工具配置[部分]
=====
1.初始化环境
----------
    1 sudo chmod -R a+x module/ config/ init
    2 ./init #初始化
    3 重开终端,xc -h 常看实现说明

2.其他
----------
    1 xc/xc -h 查看简化命令说明，简化命令为脚本函数实现的封装
    2 xc -ft 查看全部脚本函数的简要说明，脚本函数 -h 查看对应函数的具体使用说明
    3 建议,不要以root权限运行xc clean_data_garbage
    4 环境目录[参考]
        /home/xxx/
        ├── xbash
        ├── tools    -------------------  环境相关
        │       ├───── jdk  ---------------   java jdk
        │       └───── sdk  --------------    android sdk
        └── .bashrc   ------------------- ~/xbash/main.xbashrc 的软连接 
    5 工程结构
        │
        ├── config    -----------------------工具相关配置
        │        │
        │        ├── user
        │        │      │
        │        │      ├── expmale.config ------------ 用户xbash配置模版文件
        │        │      └── xxxxxxx.config ------------ 用户xxxxxxx相关xbash配置文件
        │        └── base.database -------------------- xbash工具数据文件
        │
        ├── module    ---------------------  脚本实现文件[具体功能]
        │        │
        │        ├── main.module  --------------------  xbash主框架
        │        ├── test.module  --------------------  xbash的测试工具
        │        ├── init.module  --------------------  xbash安装初始化工具
        │        ├── common.methods  -----------------  xbash自定义实现方法
        │        ├── maintain.module  ----------------  系统维护工具
        │        ├── bash_input.module  --------------  配置命令历史适配逻辑
        │        ├── packet_7731c.module  ------------  7731c的packet打包工具
        │        ├── git-completion.methods  ---------  git非自定义的bash扩张
        │        └── build    -----------------    --   独立窗口串行多进程实现
        │             ├── serialBuildByBranchName.module
        │             └── serialBuildDemo.module
        │
        ├── test   ----------------------   脚本测试工具,demo测试,请忽略此文件的修改
        ├── init   ----------------------   xbash安装初始化工具
        ├── main   ----------------------   xbash主入口
        └── README.md
    6 已验证环境
        ubuntu12.04 x64
        ubuntu14.04 x64
        ubuntu16.04 x64
    7 未实现
        # 模块自动加载框架,脱离模块名修改局限
    8 bug
        
