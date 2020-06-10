bash的简单扩展
=====
1.配置说明
----------
    1.初始化
```sh
    $ sudo -k chmod -R a+x module/ config/ init
    $ ./init
```
    2. 查看使用说明
```sh
    $ xbash -h
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
          │    ├── test.module.example  ---------  测试工具的模版
          │    ├── multiBranch.module.example ---  添加gitPatch[多分支]的模版
          │    └── user_database.example  -------  xbash的用户数据库的模版
          ├── maintain
          │    ├── maintain.methods  ------------  系统维护工具
          │    └── maintain.database  -----------  xbash的系统维护模块配置
          └── git
               ├── git.methods  -----------------  git自定义的bash扩展
               ├── git_completion.methods  ------  git非自定义的bash扩展
               └── multiBranch.module.example ---  批量添加patch的工具的示例

3.其他说明
----------
    01 为了方便偷懒，部分实现在方法实现之外又加了一层命令简化封装，所以一种功能可能两种调用方式。
    02 命令简化封装和部分方法命名不符合规范,属于历史遗留和个人使用习惯问题
    03 用户模块[用户名.module]中添加配置会默认覆盖原始配置
    04 用户模块下定义会覆盖同名的默认定义

4.待实现
----------
    01 关于分支自动维护的若干实现
      1 分支信息同步:如何避免跨分支同步和自动记录并可追踪,分支树信息存放到单独分支便于信息同步
      2 同步时避免无效的操作生效
    02 ubuntu系统开发环境快速封装和释放 [重点]
    03 ubuntu快捷方式快速新建
    04 开机时间图封装
    05 开机时间流程python封装
    06 封装kernel config的说明查找，cd kernel-3.18 && grep -nr "DYNAMIC_DEBUG" --include=Kconfig -C 5 
    07 添加gitPatch[多分支],patch添加失败，不直接退出，尝试跳过当前分支
    08 撤销最新的commit的git命令封装

5.待修复
----------
    01 adb多设备连接处理,设备数量处理概率失败
    02 自动push概率无法重启
    03 多分支串行编译[环境独立]/在多个终端间串行执行命令,无法生成独立的环境
    04 adb的多设备连接处理，xl过滤log时,重启设备概率出现死循环，不停输出  - waiting for device - ,怀疑adb内部问题
    05 xconfig的sublime_text快捷方式模板，窗口打开状态在桌面显示异常