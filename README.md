bash的简单扩展与其他工具配置[部分]
=====
1.初始化环境
----------
    1 sudo chmod -R a+x module/ config/ init
    2 ./init #初始化

2.其他
----------
    1 xc -hb 查看封装命令说明
    2 xc -ft 查看全部工具函数的简要说明
    3 环境目录[参考]
        /home/xxx/
        ├── xbash
        ├── tools    -------------------  环境相关
        │       ├───── jdk  ---------------   java jdk
        │       └───── sdk  --------------    android sdk
        └── .bashrc   ------------------- ~/xbash/main.xbashrc 的软连接 

    4 工程结构
        │
        ├── config    -----------------------工具相关配置
        │        │
        │        └── user
        │             ├── expmale.config ------------ 用户xbash配置模版文件
        │             └── xxxxxxx.config ------------ 用户xxxxxxx相关xbash配置文件
        │
        ├── data    -----------------------xbash工具数据文件
        │        │
        │        ├── maintain.database  --------------  xbash 的系统维护模块配置
        │        └── base.database -------------------- xbash工具数据文件
        │
        ├── module    ---------------------  脚本实现文件[具体功能]
        │        │
        │        ├── main.module  --------------------  xbash主框架
        │        ├── test.module  --------------------  xbash的测试工具
        │        ├── init.module  --------------------  xbash安装初始化工具
        │        ├── common.methods  -----------------  xbash自定义实现方法
        │        ├── maintain.methods  ----------------  系统维护工具
        │        ├── bash_input.module  --------------  配置命令历史适配逻辑
        │        ├── packet_7731c.module  ------------  7731c的packet打包工具
        │        ├── git_completion.methods  ---------  git非自定义的bash扩张
        │        └── build    -----------------------   独立窗口串行多进程实现
        │                   ├── serialBuildByBranchName.module
        │                   └── serialBuildDemo.module
        │
        ├── test   ----------------------   脚本测试工具,demo测试,请忽略此文件的修改
        ├── init   ----------------------   xbash安装初始化工具
        ├── main   ----------------------   xbash主入口
        └── README.md

    5 槽点
        # 初始化中用户名的处理逻辑混乱
        # 初始化后用户名变化，会导致xbash无法正常使用
