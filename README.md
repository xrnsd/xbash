bash的简单扩展
=====
1.配置说明
----------
    1.初始化
```sh
    $ cd xbash
    $ sudo -k chmod -R a+x module/ config/ init
    $ ./init
```
    2. 查看使用说明
```sh
    $ xb -h
```

2.文件用途说明[部分]
----------
    ├── README.md
    ├── main  -----------------  xbash主入口
    ├── init  -----------------  xbash安装初始化工具
    │
    ├── config  ---------------  工具相关配置
    │     │
    │     └── common.config  --------------------  xbash模块名称/路径配置
    │
    └── module  ---------------  脚本实现文件[以文件夹划分功能]
          │
          ├── auto
          │    ├── auto.methods  ----------------  Auto的相关实现
          │    └── packet_7731c.module  ---------  7731c的packet打包工具
          ├── base
          │    ├── base.database  ---------------  工具数据
          │    ├── bash_input.module  -----------  配置命令历史适配逻辑
          │    ├── test.module.example  ---------  测试工具的模版
          │    └── packaging.module  ------------  xbash对扩展和内置命令的封装
          ├── common.methods  -------------------  框架和公用实现
          │
          ├── example     -----------------------  用于存放模版,该模块无需在main中初始化
          │    ├── user.config.expmale  ---------  用户xbash配置模版
          │    ├── test.module.example  ---------  测试工具的模版
          │    ├── multi_branch.module.example ---  添加gitPatch[多分支]的模版
          │    ├── user.packaging.module.example   xbash对扩展和内置命令的封装模版
          │    ├── proguard-rules.pro.example --   混淆配置文件模版
          │    └── user.database.example  -------  xbash的用户数据库的模版
          ├── maintain
          │    ├── maintain.methods  ------------  系统维护工具
          │    └── maintain.database  -----------  xbash的系统维护模块配置
          └── git
               ├── git.methods  -----------------  git自定义的bash扩展
               ├── git_completion.methods  ------  git非自定义的bash扩展
               └── multi_branch.module.example ---  批量添加patch的工具的示例

3.其他说明
----------
    01 为了方便偷懒，部分实现在方法实现之外又加了一层命令简化封装，所以一种功能可能存在两种调用方式。
    02 命令简化封装和部分方法命名不符合规范,属于历史遗留和个人使用习惯问题
    03 用户模块[用户名.module]中添加配置会默认覆盖原始配置
    04 用户模块下定义会覆盖同名的默认定义

4.待实现
----------
    01 jar库快速删除指定class文件

5.待修复
----------
    01 xconfig的sublime_text快捷方式模板，窗口打开状态在桌面显示异常
    02 不同函数错误连续提示修复
