bash的简单扩展
=====
1.配置说明
----------
    1.初始化
```sh
    $ sudo -k chmod -R a+x module/ config/ init
    $ ./init
```
    2. 查看说明详情
```sh
    $ xc -h
```

2.文件用途说明[部分]
----------
    ├── README.md
    ├── main  -----------------  xbash主入口
    ├── init  -----------------  xbash安装初始化工具
    │
    ├── config  ---------------  工具相关配置
    │     │
    │     ├── common.config  --------------------  xbash模块名称/路径配置
    │     └── expmale.config  -------------------  用户xbash配置模版
    │
    └── module  ---------------  脚本实现文件[具体功能]
          │
          ├──common.methods  --------------------  框架和公用实现
          ├── auto
          │    ├── auto.methods  ----------------  Auto的相关实现
          │    ├── packet_7731c.module  ---------  7731c的packet打包工具
          │    ├── serialBuildByBranchName.module  独立窗口串行多进程实现
          │    └── serialBuildDemo.module
          ├── base
          │    ├── base.database  ---------------  工具数据
          │    ├── base.module  -----------------  xbash对bash命令历史的自定义处理
          │    ├── bash_input.module  -----------  配置命令历史适配逻辑
          │    ├── test.module.example  ---------  测试工具的模版
          │    └── packaging.module  ------------  xbash对扩展和内置命令的封装
          ├── maintain
          │    ├── maintain.methods  ------------  系统维护工具
          │    └── maintain.database  -----------  xbash的系统维护模块配置
          └── git
                ├── git_completion.methods  -----  git非自定义的bash扩展
                └── multiBranch.module.example --  批量添加patch的工具的示例

3.待实现
----------
    1 封装ninja命令加速mmm等模块编译命令[参照 https://note.qidong.name/2017/08/android-ninja/]
    2 实现 odex 转 jar
    3 修改软件包结构: 客户说明打包,软件说明不打包

4.待修复
----------
    1 在nemo中打开新标签,概率无法打开指定目录
