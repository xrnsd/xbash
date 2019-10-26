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
          ├── common.methods  -------------------  框架和公用实现
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
               ├── git.methods  -----------------  git自定义的bash扩展
               ├── git_completion.methods  ------  git非自定义的bash扩展
               └── multiBranch.module.example ---  批量添加patch的工具的示例

3.待实现
----------
    01 实现 odex 转 jar
    02 自动给ini文件添加TAG时,允许添加注释
    03 基于android的out生成版本软件包 添加忽略列表配置
    04 关于分支自动维护的若干实现
      1 分支创建,修改,切换,查询,删除
      2 分支信息同步:如何避免跨分支同步和自动记录并可追踪
      3 同步时避免无效的操作生效
    05 实现自动升级[在用户分支下时]
    06 快速分析测试log

4.待修复
----------
    1 在nemo中打开新标签,概率无法打开指定目录
    2 init命令异常，无法正常初始化
