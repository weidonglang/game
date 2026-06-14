# Classic Mini Games Automation Repo

这是一个用于自动生成、维护和收集经典小游戏的仓库。仓库中的小游戏主要由 Codex 自动任务根据 `limits/` 目录中的需求说明逐步实现，每个游戏尽量保持小范围、低依赖、可独立运行。

当前仓库会优先从 `limits/` 中选择尚未完成的游戏说明进行实现；当所有游戏都完成后，再随机选择已有游戏做小幅完善，例如修复 bug、补充 README、改进输入校验或增加最小自检。

## 仓库结构

```text
.
├─ limits/                    # 游戏需求清单与开发状态记录
├─ moon-lander-game/           # 月面着陆器小游戏，C 终端版
├─ maze-runner-game/           # 迷宫奔跑小游戏，Python + R 分析
├─ morse-radio-operator/       # 摩斯电台操作员小游戏，HTML/CSS/JS 网页版
├─ auto-git-push.ps1           # Windows 自动提交与推送脚本
├─ .gitignore
└─ README.md
```

## 已有游戏

| 游戏                    | 目录                      | 技术栈                               | 运行方式                    |
| --------------------- | ----------------------- | --------------------------------- | ----------------------- |
| Moon Lander Mini Game | `moon-lander-game/`     | C，终端 UI                           | 编译后运行 `moon_lander.exe` |
| Maze Runner Mini Game | `maze-runner-game/`     | Python 3，Tkinter，R 分析脚本           | 运行 `main.py`            |
| Morse Radio Operator  | `morse-radio-operator/` | HTML，CSS，JavaScript，Web Audio API | 浏览器打开 `index.html`      |

## 运行游戏

### Moon Lander Mini Game

```powershell
cd E:\javacode\game-automation-repo\moon-lander-game
.\build.bat
.\moon_lander.exe
```

也可以手动编译：

```powershell
cd E:\javacode\game-automation-repo\moon-lander-game
gcc .\src\main.c -o .\moon_lander.exe -lm
.\moon_lander.exe
```

核心玩法：控制月面着陆器的推力和角度，在燃料有限的情况下安全降落。

### Maze Runner Mini Game

```powershell
cd E:\javacode\game-automation-repo
py -3 .\maze-runner-game\main.py
```

自检：

```powershell
cd E:\javacode\game-automation-repo
py -3 .\maze-runner-game\main.py --self-test
```

如果本机安装了 R，可以运行分析脚本：

```powershell
cd E:\javacode\game-automation-repo
Rscript .\maze-runner-game\analysis\analyze.R
```

核心玩法：在随机生成的迷宫中从入口移动到出口，并记录步数、路径和用时。

### Morse Radio Operator

```powershell
cd E:\javacode\game-automation-repo\morse-radio-operator
start index.html
```

也可以直接用浏览器打开：

```text
morse-radio-operator/index.html
```

核心玩法：调谐电台频率，收听带噪声的摩斯电码信号，输入点划组合并提交解码结果。

## 自动化开发流程

本仓库配合 Codex 自动任务使用。

### Codex 负责

* 从 `limits/` 中选择未完成的游戏需求；
* 创建新的小游戏项目目录；
* 实现最小可运行版本；
* 更新对应 `limits/*.md` 中的完成状态；
* 对已有游戏做小幅维护和完善。

### Windows 计划任务负责

* 运行 `auto-git-push.ps1`；
* 自动检测本地改动；
* 自动 `git add`；
* 自动创建提交；
* 自动 `git pull --rebase`；
* 自动 `git push` 到 GitHub。

当前自动提交脚本会把日志写到仓库外部目录：

```text
E:\javacode\game-automation-logs
```

这样可以避免日志文件污染仓库提交历史。

## 自动提交脚本

脚本位置：

```text
auto-git-push.ps1
```

脚本用途：

1. 进入 `E:\javacode\game-automation-repo`；
2. 检查是否有本地改动；
3. 如果有改动，自动提交；
4. 拉取远程最新提交并 rebase；
5. 推送到 GitHub；
6. 输出运行日志。

手动运行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "E:\javacode\game-automation-repo\auto-git-push.ps1"
```

## 开发约束

为了保持仓库简单、可维护，所有自动生成或手动维护的游戏应遵守以下约束：

* 每次只开发或完善一个游戏；
* 优先实现最小可运行版本；
* 不添加非必要依赖；
* 不引入复杂样式系统、排行榜、账号系统、存档系统或联网功能；
* 不在游戏子目录中单独执行 `git init`；
* 不修改 `.git/` 目录；
* 不提交自动化日志；
* 不使用 `git push --force`。

## 新游戏项目规范

每个游戏项目建议至少包含：

```text
<game-name>/
├─ README.md          # 游戏说明、运行方式、核心规则
├─ 源码文件
└─ 可选构建或自检脚本
```

项目 README 应说明：

* 游戏名称；
* 来源需求文件；
* 技术栈；
* 如何运行；
* 已实现的核心规则；
* 可选检查或构建命令。

## 状态记录

`limits/` 中的 Markdown 文件用于记录游戏需求和开发状态。

当某个游戏完成后，应只标记对应游戏条目，例如：

```text
Status: implemented
```

如果一个需求文件中包含多个游戏，不应因为完成其中一个就把整个文件标记为全部完成。

## 许可证

当前仓库主要用于个人自动化开发实验。如需公开复用，建议后续补充明确的开源许可证文件。
