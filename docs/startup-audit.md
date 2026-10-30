# xbash 启动、加载与初始化代码审查

审查日期：2026-10-31（Asia/Hong_Kong）。基线提交：`c66f69c`。

本次仅分析，不修改运行代码。覆盖安装入口、交互式 Bash 加载、重载、首次提示符及 Conda 缓存；另外读取了当前机器的入口文件和被 Git 忽略的用户模块。下文明确区分仓库缺陷、当前用户配置缺陷及尚未进入默认启动路径的代码。

## 1. 实际执行链路

当前机器的登录链路（机器级文件不在仓库内）：

```text
~/.bash_profile
  ├─ ~/.bashrc → xbash/module/main.module
  │    ├─ config/common.config
  │    ├─ config/user/<user>.config
  │    ├─ module/common.methods
  │    ├─ module/auto/auto.methods
  │    ├─ module/git/git.methods
  │    ├─ module/user/<user>.module
  │    │    └─ 当前用户再次 source common / auto / git
  │    ├─ module/user/<user>.packaging.module
  │    ├─ 修改 ~/.inputrc 链接
  │    ├─ module/learn/learn.methods → learn/common.methods
  │    ├─ 可选的三类版本检查
  │    └─ ftAutoConfigOpenAIEnv → 3 次 launchctl setenv
  ├─ Conda 缓存加载或原生 hook 回退
  └─ ~/.cargo/env
提示符：PROMPT_COMMAND → ftSetBashPs1ByGitBranch → git branch
```

仓库提供的另一条链路是 `config/profile.config → main.module`，profile 与 main 都加载公共配置和用户配置。当前机器的 `.bash_profile` 并不通过这条 profile 路径，因此用户配置双重加载属于该入口的条件性问题，不能当作当前机器每次登录都发生的事实。

安装链路是 `./init → module/init.module → Git / 用户配置 / 模块链接 / inputrc`。它与现用启动链路存在明显偏差。

## 2. 高优先级问题

P1 表示会破坏已有配置、使安装或功能失效，或使失败状态被当作成功；P2 表示性能、依赖、幂等性和可维护性问题。优先级不代表发生概率。

### F01 · P1 · 安装路径与当前加载路径不一致

- 位置：`module/init.module:7,23,139`；`module/main.module:114-117`；`config/profile.config:9-17`。
- 安装器将用户目录固定为 `/home/<user>`；main 将其固定为 `/Users/<user>`；profile 的普通用户分支则使用 `$HOME`。同一套安装与启动逻辑有三种路径计算规则。
- `ftInitMoule` 寻找 `${dirPathLocal}/main.module`，实际入口在 `module/main.module`，根目录没有该文件。
- 当前 `.bashrc` 链接正确是机器已有状态，不能证明本版安装器能重新创建正确链接。macOS 上还会受到 `/home` 和 Linux 注销命令的影响；Linux 上 main 的 `/Users` 又会使加载中断。
- 修复方向：从脚本真实位置推导仓库根目录，统一用户目录来源，统一入口路径；按平台选择必要动作，先验证目标再写入。

### F02 · P1 · 初始化不幂等，会覆盖用户配置并使备份失去意义

- 位置：`module/init.module:49-57,148-153`。
- `ftInitUserConfig` 无条件把项目 profile 复制到用户 `.profile`，把模板复制到已有用户配置。
- 全量安装先调用该函数，再调用 `ftInitMoule` 备份 `.profile`。备份发生时原 `.profile` 已被覆盖，保存的是项目模板，无法恢复原配置。若 `.profile` 已是链接，`cp` 还可能沿链接写入目标。
- 隔离实测：原 `.profile=ORIGINAL_PROFILE`、用户配置 `CUSTOM_CONFIG`，调用后分别变成 `PROJECT_PROFILE`、`TEMPLATE_CONFIG`。
- 修复方向：只在缺失时创建；覆盖前备份真实原文件；把首次安装、迁移、重置拆成明确操作。

### F03 · P1 · 错误返回值、异常字符串与成功提示相互脱节

- 位置：`module/init.module:49-57,170-186,260-281,285-293`；`module/main.module:127-159`。
- 多个 `cp/mkdir/ln/read` 的失败未统一记录；全量初始化不检查各步骤返回值，只依赖 `exceptionContent`。参数分支执行后裸 `return`，沿用函数最后一条命令的状态。
- 隔离实测：模块初始化记录了缺少 main 的错误，但最后 `cd` 成功，因此 `ftInitMoule` 返回 `0`。
- `ftInitInputrc` 依赖当前进程中的 `isUseXbashHistory`；初始化只修改配置文件，没有加载新配置。干净环境下该变量为空，函数直接返回 `1`，却不写入异常信息。main 又无条件处理 inputrc，开关语义不一致。
- main 仅验证文件存在，`source` 的执行结果并没有成为后续模块是否运行的前置条件；配置加载失败也可能继续运行，留下部分初始化状态。
- 修复方向：每步明确返回码和失败处理；区分“禁用/跳过/失败”；配置写入后的安装行为读取明确的安装选项，避免依赖父 Shell 的遗留环境。

### F04 · P1 · 普通启动会删除既有 inputrc

- 位置：`module/main.module:165`；另有 `module/init.module:170-186` 的第二套实现。
- 每次启动都检查链接；不匹配便执行 `rm -rf ~/.inputrc` 再创建链接，没有备份，也没有检查历史功能开关。
- 已有用户 inputrc 会被删除；如果该路径意外是目录，递归删除会扩大影响。安装与启动分别维护同一文件，行为和错误处理不一致。
- 修复方向：由安装/显式迁移负责链接；保留原文件；启动仅检查必要状态，避免用递归删除替换配置文件。

### F05 · P1 · Conda 缓存把加载失败改成成功，坏缓存可持续复用

- 位置：`module/base/conda_cache.module:46-49,53-69`。
- 缓存命中后执行 `source`，随后无条件 `return 0`，丢弃真实状态。当前机器 `.bash_profile` 据此决定是否调用原生 hook 回退。
- 首次生成未在发布前验证脚本可加载，直接 `mv` 成为缓存；hook 或 activation 失败时，临时文件也未统一清理。
- 假 Conda 输出 `if then` 的隔离实测：首次加载返回 `2`，第二次命中同一个坏缓存却返回 `0`。调用者会误判初始化成功，跳过回退。
- 修复方向：保留 source 返回码；验证后原子发布；命中失败时使缓存失效并回退；统一清理失败生成的临时文件。

### F06 · P1 · Conda 缓存键没有覆盖生成结果的全部输入

- 位置：`module/base/conda_cache.module:25-43`。
- 缓存键包含 PATH、PS1、部分 Conda 状态、可执行文件及 base history 的秒级修改时间，但不包含 `.condarc`、其他配置来源、目标环境 history、activation/deactivation 脚本以及这些脚本读取的外部状态。
- activation 代码可能内嵌当时生成的环境变量值。相同的现有键不等于可以安全复用。
- 隔离实测：假 Conda 根据 `.condarc` 生成变量；修改配置后直接生成器输出已变化，缓存加载仍返回旧值。该用例证明缓存算法的遗漏，不代表已经测得当前真实 Conda 配置失效。
- 修复方向：先界定哪些输出允许缓存；纳入支持范围内的配置和目标环境状态；对无法完整建模的 activation hook 使用原生执行，不把任意动态激活脚本视为静态输出。

## 3. 重复执行、阻塞与数据结构

### F07 · P2 · 主入口和用户模块重复加载相同实现

- 位置：`module/main.module:142-158`；当前被忽略的 `module/user/myname.module:3-5`，另见 `module/user/sts.module:4-7`。
- 一次启动 common、auto、git 各 source 两次，反复解析函数和注册补全；重载再执行一遍全链路。用户后定义的同名实现还可能被再次加载的框架版本覆盖。
- 隔离计数实测：第一次各 `2` 次，第二次 source main 后各累计 `4` 次。用户模块确实进入执行链；并非仅凭文本检索推断。
- `profile.config:28-37` 和 `main.module:127-136` 还维护了两套配置加载流程；走 profile 入口时用户配置会执行两遍，包含 PATH 重写和可选外部命令。
- 修复方向：模块由一个加载器管理；声明依赖和加载状态，显式区分加载定义、刷新配置和执行动作。

### F08 · P2 · 每次提示符刷新等待 Git，耗时没有上界

- 位置：`module/example/user.config.example:11`；当前用户配置 `:8`；`module/git/git.methods:18-36`。
- `PROMPT_COMMAND` 每次执行 `ftSetBashPs1ByGitBranch`；其 while 循环从进程替换读取 `git branch --no-color`，找到当前分支前必须等待 Git 输出。
- 进程替换启动了子进程，但主 Shell 的 read 仍然等待它。大量本地分支、慢文件系统或 Git 自身迟迟不输出，都会拖延提示符出现；并非每次都需要枚举全部本地分支。
- 隔离实测：将 Git 输出延迟 300ms，提示符函数约 309ms 后返回。这是等待语义验证，不是当前真实启动耗时基准。
- 首次进入 Git 仓库还会同步加载补全文件。`common.methods:4246-4252` 的版本查询/排序结果未使用，是这条首次提示符路径上的无效计算。
- 修复方向：用只查询当前分支的命令；优先压缩同步工作，再根据必要性引入有失效规则的缓存；需要后台刷新时避免旧目录结果覆盖新目录。

### F09 · P2 · PATH 当作空白分隔数组处理，破坏路径且循环反复启动进程

- 位置：`module/example/user.config.example:86-94,134-156,165-207`；当前用户配置 `:35-61`。
- `newList=($(echo "$PATH" | sed 's?:? ?g'))` 先把冒号转成空格，再进行词拆分和 glob 展开；带空格、通配符或空项的合法 PATH 无法保持原意。
- 每个路径项又通过命令替换执行 `echo | egrep`；多组 SDK/JDK/NDK 等配置重复全表扫描，开启的块越多、PATH 越长，外部进程越多。走 profile 入口会再做一遍。
- 隔离实测：`/usr/bin:/Applications/Android SDK/bin:/bin` 被拆成 4 项，其中 SDK 目录变成两个无效目录。
- 使用未锚定的 `sdk/java/go` 子串过滤也可能移除无关路径；例如包含 `go` 的普通目录可能被 Go 配置逻辑删除。
- main 的 `:200`、profile 的 `:63,67` 及机器 `.bash_profile:7` 另有直接拼接 PATH 的实现，反复重载会积累重复项。
- 修复方向：以冒号为分隔符保留路径语义；使用 Bash 内建匹配和统一的精确去重；各功能只管理自己拥有的目录。

### F10 · P2 · 启动读取配置时夹带安装交互与系统修改

- 位置：`module/main.module:131-135`；`config/profile.config:32-35`；`module/example/user.config.example:62-73,99-106,249-254,269-279`。
- 用户配置缺失时，打开终端会同步执行 `init --userconfig`，连续询问功能开关并复制配置；没有终端输入时也没有明确的取消/失败协议。
- 模板中的特定开关启用后，source 配置还会执行 sudo、update-alternatives、sysctl 等动作。Java 循环中每个工具都可能再次执行外部命令或等待授权，后续正常加载只能等它结束。
- 当前用户配置不是完整模板；这些 sudo 循环不能直接认定为当前机器启动变慢的实际原因。
- 修复方向：配置只表达选项和环境值；安装、授权、系统配置变更通过显式命令执行；缺少配置时启动给出可执行的修复提示。

## 4. 依赖、状态与冗余实现

### F11 · P1 · Conda 重载命令提前返回，标志与实际状态不一致

- 位置：`module/common.methods:94,125,161-163`。
- `ftResetXbash --conda` 设置 `isEnableConda=true` 后立即返回，根本不到 source `.bashrc` 的语句；同时留下 `isResetXbash=true`。
- 隔离实测：拦截 source，未出现重载调用，两个标志却均为 true。
- 当前机器的 `.bash_profile` 无条件尝试 Conda 缓存，用户配置又有受开关控制的原生 hook；登录与非登录 Shell 的激活策略不同。启用用户 hook 后，登录链路可同时运行两条初始化路径。
- 修复方向：定义启用配置、加载定义、环境已激活三个不同状态；命令执行实际动作后再更新结果状态，统一入口并保证失败时恢复。

### F12 · P2 · 进程内加载标志被 export，子 Shell 继承了并不存在的能力

- 位置：`module/common.methods:4253-4256`；`module/git/git.methods:36`。
- `isLoadGitCompletion` 被导出，但补全函数和 `complete` 注册不会随普通环境变量继承。子 Bash 会重新加载 xbash 函数，却因标志非空跳过补全加载。
- 隔离实测：子 Shell 中 `marker=1`，调用提示符函数后 `_git` 仍不存在。
- `config/common.config:3-21` 同样把配置 guard 导出并提前置为 readonly；它表示父进程曾经初始化过，不是当前进程重新校验过。导出变量在子进程中也不会自动保留 readonly 属性。
- 修复方向：进程内加载标志不 export，直接检查所需函数/补全是否存在；路径配置完成验证后再发布 ready 状态。

### F13 · P2 · 配置在公共函数之前执行，首次加载和重载的依赖不一致

- 位置：`module/main.module:136,142`；`module/example/user.config.example:62,99,266`。
- 用户配置先执行，`ftEcho` 后定义。模板在部分启用的工具重置分支中调用 `ftEcho`，新 Shell 可能报未定义，已有函数的重载却能通过。
- 配置文件同时负责选项、依赖探测、环境计算和系统操作，且使用 `filePath/newList/item/config` 等全局临时变量；source 进入调用者作用域，容易覆盖其他模块状态。模板中的布尔值有的判断非空，有的比较 true；当前用户配置甚至存在 `ture` 仍因非空而启用的情况。
- 修复方向：先加载无副作用的基础函数，再读声明式选项，再按依赖初始化；变量局部化，开关统一解释。

### F14 · P2 · 每次打开终端重复写入会话级状态

- 位置：`module/main.module:183-185`；当前被忽略的用户模块 `ftAutoConfigOpenAIEnv`。
- 每次启动/重载都会执行三次 `launchctl setenv`，没有比较值、检查平台或检查结果。不同终端可能把各自环境写入同一个用户会话，最终值取决于执行顺序。
- 隔离实测：第一次启动调用 3 次，重载后累计 6 次。测试使用 stub，没有真实修改 launchctl 环境。
- 修复方向：将会话级同步放到明确的配置更新动作中；如需自动同步，比较目标状态并报告失败，避免把它混入所有 Shell 的常规读取。

### F15 · P2 · 旧功能仍暴露开关，但启动执行链已断开

- 位置：`module/init.module:65-95`；`module/example/user.config.example:8,13`；`module/common.methods:293-315`；`module/main.module:173-174`。
- 安装仍询问自动更新与历史处理开关，但当前审查范围未找到 `ftGitUpdateVersion` 的有效启动调用；`ftBashHistory` 的 main 调用已注释。
- 这些函数仍可手动调用，不能称为所有场景下的死代码；准确结论是启动功能入口与配置承诺不一致。
- `ftLoadGitCompletion` 的版本比较结果没有消费者；`ftVersionComparison:780-781` 中相等时 `<=` 已返回，末尾 `>=` 输出分支不可达。
- 修复方向：明确保留功能及其触发点；删除无消费者计算和不可达分支；停用功能时同步更新安装提示。

## 5. 没有归为“当前启动阻塞”的代码

- `module/auto/auto.methods` 中 AOSP 扫描、设备等待、打包循环，以及用户模块中的开机/SSH 等待，主要是函数定义。source 不会执行函数体；当前启动链未看到这些函数的调用。
- `module/auto/autoBoot.module.example:38-43` 顶层包含同步启动动作和 sleep，但当前加载链没有 source 它。只能列为将来接入自启动时的阻塞风险。
- `module/base/key.module:19-28,44-52` 的 Escape 后续读取没有超时，孤立 Escape 可能等不到剩余字符；它由交互命令调用，不是默认启动路径。
- `module/test.module:18-40` 是实际打包任务，不是自动断言测试，不能把运行 `ftTest` 当成无副作用的验证。失败的 cd 后仍继续 tar 也是该手动调试入口的风险；本次没有执行它。
- `ftGitUpdateVersion` 存在不报告拉取完成状态的问题，但当前未接入启动，不把它算进实测启动延迟。
- Git 模块的 V1/V2 分支工具属于另一个手动命令范围；本次发现的初始化重复实现主要是 profile/main、init/main 的 inputrc 管理以及原生/缓存 Conda 路径。

## 6. 验证记录与限制

- 对 33 个 Bash 模块、配置及相应模板执行 `bash -n`，全部通过。`packet_7731c.module` 按 shebang 确认是 Perl，未按 Bash 判错。语法通过不代表运行语义正确。
- 11 组隔离运行覆盖加载计数、重载提前返回、PATH 拆分、补全继承、配置覆盖、inputrc 跳过、安装路径、失败返回码、缓存失效、坏缓存与提示符等待。
- 所有安装写入都限定在临时目录；Conda 使用假可执行文件；加载计数时替换用户配置和命令封装，拦截 launchctl 与 inputrc 检查。加载的是实际 main/common/auto/git/用户模块/learn 定义，但该用例不是完整真实登录环境测试。
- 交互计数用例没有 PTY，Bash 输出了无 job control 提示；未影响计数结果。
- 当前用户配置和机器入口属于本机事实，不随 Git 分发；报告不复制其凭据或完整内容。
- 临时验证脚本：`/private/tmp/xbash-startup-audit/check.py`；结构化输出：同目录 `results.json`。复现命令：`python3 /private/tmp/xbash-startup-audit/check.py`。这两个临时文件不随报告提交。
- 未运行真实 init、sudo、设备命令、网络操作、真实 Conda 激活或真实会话环境写入；未将源文件注释中的毫秒值当作可靠性能数据。

## 7. 建议修复顺序

1. 修复安装目标、配置备份和返回码，移除常规启动中的递归删除；先确保现有配置可保留、失败可见。
2. 修复 Conda 提前返回、坏缓存成功状态和缓存输入范围，统一登录/非登录 Shell 的激活策略。
3. 统一加载器，移除用户模块的反向重复依赖；分开函数定义、选项读取、环境初始化和系统动作。
4. 修复 PATH 数据处理与提示符同步工作，再以真实但无副作用的场景测量冷/热启动、重载及首次提示符耗时。
5. 清理导出标志、旧开关与无消费者代码；补上首次安装、重复安装、子 Shell、缺依赖和失败恢复的行为验证。

建议加载阶段采用明确顺序：`基础函数 → 路径验证 → 用户选项 → 功能依赖 → 环境应用 → ready/failed`。模块状态至少区分未加载、加载中、已加载、失败；幂等控制不能用继承自父进程的单个 true 值替代。并非所有工作都应后台化：环境变量必须在当前 Shell 应用，后台子进程的赋值不会自动回写父 Shell。
