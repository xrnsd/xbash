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
          │    ├── packet_7731c.module  ---------  7731c的packet打包工具
          │    ├── serialBuildByBranchName.module  独立窗口串行多进程实现
          │    └── serialBuildDemo.module
          ├── base
          │    ├── base.database  ---------------  工具数据
          │    ├── bash_input.module  -----------  配置命令历史适配逻辑
          │    ├── test.module.example  ---------  测试工具的模版
          │    └── packaging.module  ------------  xbash对扩展和内置命令的封装
          ├── common.methods  -------------------  框架和公用实现
          │
          ├── example     -----------------------  用于存放模版,该模块无需在main中初始化
          │    ├── user.config.expmale  --------------  用户xbash配置模版
          │    ├── test.module.example  ---------  测试工具的模版
          │    ├── multiBranch.module.example ---  添加gitPatch[多分支]的模版
          │    └── user.database.example  -------  xbash的用户数据库的模版
          ├── maintain
          │    ├── maintain.methods  ------------  系统维护工具
          │    └── maintain.database  -----------  xbash的系统维护模块配置
          └── git
               ├── git.methods  -----------------  git自定义的bash扩展
               ├── git_completion.methods  ------  git非自定义的bash扩展
               └── multiBranch.module.example ---  批量添加patch的工具的示例

3.其他说明
----------
    01 为了方便偷懒，部分实现在方法实现之外又加了一层命令简化封装，所以一种功能可能存在两种调用方式。
    02 命令简化封装和部分方法命名不符合规范,属于历史遗留和个人使用习惯问题
    03 用户模块[用户名.module]中添加配置会默认覆盖原始配置
    04 用户模块下定义会覆盖同名的默认定义

4.待实现
----------
    01 关于分支自动维护的若干实现
      1 分支信息同步:如何避免跨分支同步和自动记录并可追踪,分支树信息存放到单独分支便于信息同步
      2 同步时避免无效的操作生效
    02 ubuntu系统开发环境快速封装和释放 [重点]
    03 开机时间图封装
    04 开机时间流程python封装
    05 百度网盘自动上传封装，属于auto
    06 jar库快速删除指定class文件
    07 同项目不同存放设备之间的同步
    08 ftAutoAsConfigFileAutoCreate生成的配置文件android.iml改为项目名.iml
    09 基于标签找到分支信息
    10 快速挂载远程nfs目录
    11 APP模板参照系统软件说明版本添加部分信息
    12 xconfig配置快速生效实现
    13 目录间同步封装

5.待修复
----------
    01 xconfig的sublime_text快捷方式模板，窗口打开状态在桌面显示异常
    02 不同函数错误连续提示修复
    03 flashcache在配置后插入其他硬盘开机导致sdx变化,就会开机配置失败
