# AGENTS.md

## 项目认知

- 这个仓库是 `xbash`，一个 Bash 扩展与初始化工具集合。
- 仓库根目录的 `init` 是初始化入口，实际链接到 `module/init.module`。
- `module/main.module` 是 Bash 启动入口，负责加载基础配置、用户配置和各类扩展模块。
- `config/common.config` 保存全局路径与文件名变量，`config/profile.config` 负责把 `xbash` 配置注入到 shell 环境。
- `module/common.methods` 提供通用函数与主命令能力，`module/test.module` 是调试/测试入口。
- `config/` 存放配置，`module/` 按功能划分扩展实现，`module/example/` 存放模板文件。

## 核心入口与结构

- 初始化入口：`./init`
- Bash 主入口：`module/main.module`
- 初始化实现：`module/init.module`
- 全局配置：`config/common.config`
- 用户相关配置：`config/uesr/****.config`
- Shell 启动配置：`config/profile.config`
- 通用扩展：`module/common.methods`
- 调试测试：`module/test.module`
- 用户相关数据或封装命令：`module/uesr/****`

## 工作流程要求

1. 收到需求后，如果有任何不明确的地方，先向用户确认，不要自行猜测后直接实施。
2. 只修改用户明确说明的部分，其他内容保持不动。
3. 每次修改后必须自动测试，并结合日志或实际操作结果做验证，确认没有问题后才能结束。
4. 任务结束前必须提交 `git commit`，不得跳过提交直接收尾。

## 修改原则

- 优先保持现有 Bash 脚本结构和命名习惯。
- 涉及路径、变量名、模块名时，先核对当前仓库中的实际定义，再动手改。
- 如果修改会影响初始化、加载链路或用户环境，先做最小范围变更，再验证行为。
