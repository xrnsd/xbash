# main.module 修复结果与回滚说明

实施日期：2026-10-31。范围为 main 及其实际加载的依赖；没有改动 `module/init.module` 或机器 `.bash_profile`。

## 阶段提交

| 步骤 | 提交 | 行为 |
| --- | --- | --- |
| 0 | `a6f8376` | 保存缺陷复现和隔离性能基线 |
| 1 | `e4e295e` | 启动保留所有 inputrc 状态，不删除用户文件 |
| 2 | `53579a4` | 符号链接解析、统一 HOME/仓库路径、进程内配置 guard |
| 3 | `caee077` | 公共函数先于配置，必需依赖失败传播，移除启动创建交互 |
| 4 | `f365c9f` | 定义模块按 Shell 加载一次，循环诊断和失败重试 |
| 5 | `9e89d51` | 精确 PATH 操作和独立环境应用 hook |
| 6 | `2d670a3` | 保留用户回调、当前分支查询、按实际能力加载补全 |
| 7 | `61c75d1` | 普通刷新、源码重载、显式会话/系统动作分离 |
| 8 | 本文所在提交 | 边界修正、旧逻辑清理、完整回归和使用说明 |

第 8 步验收中另外修正了：配置移除的提示符回调不再残留；回调可以读取上一条命令的退出码；重复会话同步只写变化的值；迁出的系统操作不再丢弃中途失败；原生补全和 Apple Terminal 配置避免普通刷新重复加载。

## 使用变化

运行环境要求 Bash 4.3+，本机用 Homebrew Bash 5.3.9 验证。系统 `/bin/bash` 3.2 会收到版本提示，不会继续执行新加载器。

```bash
ftResetXbash                     # 重新读取选项、应用环境，复用定义
ftResetXbash --reload            # 连同函数定义一起重新加载
ftResetXbash --android           # 本次应用启用 Android 的覆盖选项
ftResetXbash --conda             # 覆盖配置默认值后调用环境 hook
ftResetXbash --sync-session      # 显式同步 OPENAI_* 到当前 macOS 会话
ftResetXbash --system-config     # 显式调用配置定义的系统操作
```

仓库路径来自实际 main 文件位置，用户目录来自当前 HOME；SUDO_USER 不再隐式切换归属。用户名默认 USER；有明确需要时用 `XBASH_CONFIG_USER` 选择配置文件名，不改变 HOME。一个 Shell 的路径上下文固定，切换仓库/身份需新 Shell。

普通启动不再创建用户配置、用户模块、封装文件或替换 inputrc。缺失必需配置时给出诊断并返回非零；可选模块缺失可以跳过，已有模块加载失败则返回非零。当前 Shell 不会因 main 的错误主动 exit。

默认不写会话环境。需要自动同步可显式配置 `isAutoSyncOpenAIEnv=true`；同步前检查全部必要值，读取目标会话当前值，仅写变化项。失败返回非零；多个 setenv 不是原子事务，不承诺回滚已成功写入的项。日志不输出凭据值。

## 配置与模块约定

- 基础函数在用户配置之前可用。新配置将选项保留在顶层，把当前 Shell 的环境应用放进 `ftXbashApplyUserEnvironment`；系统修改放进仅显式调用的 `ftXbashApplySystemConfig`。
- 主动失败使用 `xbashConfigStatus=1; return 1`，或返回其他非零码。为兼容旧配置，未设置失败状态时，文件最终的普通条件判断返回 1 会被当作读取完成。因此裸 `return 1` 在旧约定下有歧义，需使用明确状态；不声称能够检测任意脚本中被后续成功语句掩盖的错误。
- hook 和模块必须显式检查关键操作的结果。模块只有成功才标记 loaded；进程内状态不 export。普通刷新不重解析已加载的定义，需要修改源码时使用 `--reload`。
- 用户模块声明框架依赖时使用 `_ftXbashLoadModule "$rFilePathXbashModuleCommon" || return $?` 等入口，避免直接重复 source。
- 用户命令封装因别名和补全可能取决于新选项，仍在刷新时执行；这是明确保留的配置应用阶段。旧个人脚本的任意顶层动作无法自动变成无副作用，需按上述 hook 约定迁移。
- `ftXbashPathAdd` 按完整目录去重，`ftXbashPathRemove` 只匹配指定项；刷新移除上一轮由 xbash 添加的项，再按新选项应用。保留外部路径顺序、空项和字面字符，不再按 sdk/java/go 子串删目录。
- 模板中的 Python 系统解释器切换要求显式 `pythonFilePath` 和 `python3FilePath`，不再扫描或猜测系统解释器；这些操作没有在真实系统上执行。

## 验证结果

- 32 个隔离测试通过，包括 inputrc 六种状态、路径带空格、相对/绝对链接、父子 Shell、冷加载、普通刷新、强制重载、缺依赖、执行/语法失败、同 Shell 修复重试、只读 HOME、PATH、回调、退出码、Git 分支/新仓库/detached HEAD，以及会话与系统动作的成功/失败分支。
- 35 个 Bash 模块、配置及模板通过语法检查；按 shebang 排除了 Perl 文件。
- 真实 PTY 中使用当前用户配置测试首次加载、普通刷新、强制重载：三者返回码均为 0，xdf 别名存在，状态为 ready。sudo/launchctl 被 stub 拦截，未发生调用；未进行真实系统配置或真实会话写入。
- 可重复验证入口：`python3 tests/test_startup.py`。历史缺陷复现代码保留在第 0 步提交，当前目录不保留预期缺陷仍存在的旧断言。

性能使用同一源码目录、PATH、Shell 和 stub 用户配置/Git 场景，各运行 7 次；是隔离 main 与提示符数据，不包含登录文件、真实 Conda 或网络文件系统。最终脚本另有文件式调用计数，较基线有少量额外计量开销，因此仅作趋势比较。

| 阶段 | 基线中位数 / 最大值 ms | 修复后中位数 / 最大值 ms |
| --- | --- | --- |
| source main | 46.079 / 49.112 | 34.350 / 35.537 |
| 首次提示符函数 | 22.549 / 29.506 | 7.131 / 8.277 |
| 后续提示符函数 | 1.032 / 1.119 | 1.308 / 1.691 |

后续提示符在此微基准中略慢约 0.3ms，没有宣称所有阶段都提速。最终单次场景计数：common 定义加载 1 次、两次提示符共查询 Git 2 次、会话写入 0 次；原基线已确认 common 加载 2 次。原始数据分别为 `tests/startup-baseline.json` 和 `tests/startup-after.json`，脚本为 `tests/benchmark_main.py`。

当前 Git 查询仍同步。减少枚举和无效计算不等于给慢文件系统设置了硬超时；如需最长等待保证，应另做超时/后台刷新方案，并验证过期结果和子进程回收。

## 本机忽略文件与回滚

本机同时迁移了两个 Git 忽略文件，未强制加入仓库：

- `module/user/myname.module`：重复依赖走统一加载器，会话同步函数委托受检查的实现。
- `config/user/myname.config`：SDK/NDK/PATH 进入环境 hook，移除旧提示符绑定，明确默认不自动同步会话；原配置值未写入文档。

原始备份为 `local-backups/main-repair/` 下相同相对路径；阶段快照在其 `step4/`、`step5/`、`step6/`、`step7/` 子目录。备份文件权限 0600，该目录被 Git 忽略。

阶段提交便于逐批审查和回滚，但存在方案中列明的依赖，不能任意单独撤销基础加载协议而保留依赖它的后续实现。推荐在新分支按最新到最旧使用 `git revert <commit>`，冲突按目标阶段协议处理，每批运行对应版本测试。第 1 步的文件保留修复可独立保留。

Git 不会恢复上述忽略文件。回到某个阶段后，需匹配本机快照：

| 目标代码阶段 | 当前用户配置/模块应恢复到 |
| --- | --- |
| 7 或 8 | `local-backups/main-repair/step7/` |
| 6 | `local-backups/main-repair/step6/` |
| 5 | `local-backups/main-repair/step5/` |
| 4 | `local-backups/main-repair/step4/` |
| 3 或更早 | `local-backups/main-repair/` 的原始相对路径 |

恢复前先保存之后新增的个人修改。恢复相应快照中的 `config/user/myname.config` 和 `module/user/myname.module` 到仓库同名路径，然后新开 Bash 验证。旧 Shell 仍持有旧定义和 readonly 路径，不能仅靠 git revert 更新其内存状态。
