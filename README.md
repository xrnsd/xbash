bash的简单扩展
=====
1.配置说明
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

2.文件用途说明[部分]
----------
    │
    ├── config  ---------------  工具相关配置
    │     │
    │     ├── common.config  --------------------  xbash模块名称/路径配置
    │     └── expmale.config  -------------------  用户xbash配置模版
    │
    ├── module  ---------------  脚本实现文件[具体功能]
    │     │
    │     ├── auto
    │     │    ├── auto.methods  ----------------  Auto的相关实现
    │     │    ├── packet_7731c.module  ---------  7731c的packet打包工具
    │     │    ├── serialBuildByBranchName.module  独立窗口串行多进程实现
    │     │    └── serialBuildDemo.module
    │     ├── base
    │     │    ├── base.database  ---------------  工具数据
    │     │    ├── base.methods  ----------------  框架的基础实现
    │     │    ├── bash_input.module  -----------  配置命令历史适配逻辑
    │     │    ├── test.module.example  ---------  测试工具的模版
    │     │    └── main.module  -----------------  xbash主框架
    │     ├── maintain
    │     │    ├── maintain.methods  ------------  系统维护工具
    │     │    └── maintain.database  -----------  xbash的系统维护模块配置
    │     ├── git
    │     │    ├── git_completion.methods  ------  git非自定义的bash扩展
    │     │    └── multiBranch.module.example  --  批量添加patch的工具的示例
    │     │
    │     └── common.methods  -------------------  公用实现
    │
    ├── init  -----------------  xbash安装初始化工具
    ├── main  -----------------  xbash主入口
    └── README.md
