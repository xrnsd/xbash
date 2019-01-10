bash的简单扩展
=====
1.说明
----------
    1.初始化
```sh
    $ sudo chmod -R a+x module/ config/ init
    $ ./init
```
    2. 查看说明详情
```sh
    $ xc -h
```

2.工程结构
----------
    │
    ├── config    -----------------------工具相关配置
    │     │
    │     ├── common.config  ------------------  通用配置
    │     ├── expmale.config  -----------------  用户xbash配置模版
    │     └── user
    │          └── xx.config  -----------------  用户xx相关xbash配置[仓库中不存在]
    │
    ├── data    -----------------------  xbash工具数据文件
    │     │
    │     ├── maintain.database  --------------  xbash的系统维护模块配置
    │     ├── versionInfo.database  -----------  xbash的系统维护模块历史记录[仓库中不存在]
    │     └── base.database -------------------- xbash工具数据
    │
    ├── module    ---------------------  脚本实现文件[具体功能]
    │     │
    │     ├── main.module  --------------------  xbash主框架
    │     ├── test.module  --------------------  xbash的测试工具
    │     ├── common.methods  -----------------  xbash自定义实现方法
    │     ├── maintain.methods  ---------------  系统维护工具
    │     ├── bash_input.module  --------------  配置命令历史适配逻辑
    │     ├── build
    │     │    ├── packet_7731c.module  ------   7731c的packet打包工具
    │     │    ├── serialBuildByBranchName.module 独立窗口串行多进程实现
    │     │    └── serialBuildDemo.module
    │     ├── git
    │     │    ├── git_completion.methods  ----  git非自定义的bash扩展
    │     │    ├── multiBranch.module  --------  批量添加patch的工具[仓库中不存在]
    │     │    └── multiBranch.module.example    批量添加patch的工具的示例
    │     └── user
    │          └── xx.module  ----------------   用户xx自定义模块[仓库中不存在]
    │
    ├── init   ----------------------   xbash安装初始化工具
    ├── main   ----------------------   xbash主入口
    └── README.md

3.环境目录[仅供参考]
----------
    /home/xxx/
    ├── xbash
    ├── tools    -------------------  环境相关
    │     ├───── jdk  ---------------   java jdk
    │     └───── sdk  --------------    android sdk
    └── .bashrc   ------------------- ~/xbash/main.xbashrc 的软连接

4.槽点
----------
    # 初始化中用户名的处理逻辑混乱
    # 初始化后用户名变化，会导致xbash无法正常使用
