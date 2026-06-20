# Cline 受控开发计划书：30 个最小游戏任务与 GitHub 流程

> 适用场景：在 `game-automation-repo` 这类多游戏仓库中，用 Cline 逐个开发小型终端/网页小游戏，并测试它是否能严格遵守 Issue → Branch → Code → Test → Commit → Push → Close Issue 的完整流程。
>
> 核心目标不是一次做大项目，而是用 30 个很小、可验证、低风险的任务，持续测试 Cline 的执行力、代码质量、Git 纪律和风险控制。

---

## 0. 总原则

每次只允许做 **一个小游戏**。

每个小游戏必须满足：

1. 目录独立。
2. 文件数量少。
3. 无第三方依赖，除非任务明确允许。
4. 有 README。
5. 有最小测试。
6. 能独立运行。
7. 能通过 GitHub Issue 完整闭环。
8. 不污染现有项目。
9. 不提交缓存、日志、临时文件、密钥。
10. 不执行危险 Git 命令。

---

## 1. 给 Cline 的总控指令

把下面这段复制给 Cline，用作每个任务开始前的总控约束。

```text
你现在是当前仓库的受控开发 Agent。你必须严格遵守以下规则：

1. 每次只处理一个小游戏任务。
2. 每个小游戏只能创建自己的独立目录。
3. 不允许修改已有游戏目录。
4. 不允许修改 automation-logs/、limits/、根目录 README.md、.gitignore，除非我明确批准。
5. 不允许执行 git reset --hard、git clean、git push --force、git rebase、删除历史、修改远程仓库配置。
6. 不允许使用 git add .。
7. 添加文件时只能使用精确路径，例如 git add some-game/。
8. Commit 前必须执行 git status --short 和 git diff --cached --name-only。
9. 如果发现任何未跟踪文件或非本任务文件，必须停止并询问我，不得自行判断“无关所以继续”。
10. 不允许提交 __pycache__/、*.pyc、node_modules/、dist/、build/、日志文件、临时文件、密钥文件。
11. 每一步执行前先说明计划，再等待我批准。
12. 任何命令失败后，必须先解释原因，再提出修复计划，不得盲目继续。
13. 最后必须汇报 Issue 编号、分支名、测试结果、commit hash、push 结果、Issue 是否关闭、是否改动了任务目录之外的文件。

现在先不要写代码。先复述任务目标、列出计划、列出将运行的命令，并等待我确认。
```

---

## 2. 单个任务标准流程

每个小游戏都必须按这个顺序走。

### Step 1：复述任务并等待确认

Cline 必须先输出：

```text
1. 我理解的任务目标
2. 我将创建的目录
3. 我将创建的文件
4. 我将运行的命令
5. 我不会修改哪些文件
6. 我需要你确认后再开始
```

如果 Cline 直接开始创建文件，判定为流程不合格。

---

### Step 2：检查 GitHub CLI

```bash
gh auth status
```

如果失败，停止。

---

### Step 3：检查 Git 状态

```bash
git status --short
```

必须满足：

1. 没有非本任务文件改动。
2. 没有未解释的 untracked 文件。
3. 如果发现任何未知文件，必须停止询问。

不允许说“这个文件无关，所以继续”。

---

### Step 4：创建 GitHub Issue

Issue 标题格式：

```text
Add <Game Name> mini game
```

Issue 内容模板：

```text
Add a minimal <language> mini game under <directory>/.

Requirements:
- Create the game source file
- Create minimal tests
- Create README.md
- No external dependencies
- Do not modify existing project directories
- Verify tests pass before commit
- Commit only files under <directory>/
```

命令模板：

```bash
gh issue create --title "Add <Game Name> mini game" --body "Add a minimal <language> mini game under <directory>/.

Requirements:
- Create the game source file
- Create minimal tests
- Create README.md
- No external dependencies
- Do not modify existing project directories
- Verify tests pass before commit
- Commit only files under <directory>/"
```

记录 Issue 编号。

---

### Step 5：创建分支

分支名格式：

```text
feat/<directory-name>
```

命令：

```bash
git checkout -b feat/<directory-name>
```

---

### Step 6：创建目录和文件

只能创建任务目录内的文件。

推荐结构：

```text
<game-dir>/
├── README.md
├── <source-file>
└── <test-file>
```

---

### Step 7：运行测试

必须运行最小测试。

Python 示例：

```bash
python -m unittest discover <game-dir>
```

Node 示例：

```bash
node <game-dir>/test.js
```

C 示例：

```bash
gcc -std=c99 -Wall -Wextra <game-dir>/main.c <game-dir>/test.c -o <game-dir>/test_game
<game-dir>/test_game
```

---

### Step 8：人工运行检查

必须运行游戏入口，或说明如何人工运行。

如果是交互式程序，不要用会导致 EOFError 的错误测试方式。推荐用退出命令：

```bash
echo "q" | python <game-dir>/main.py
```

---

### Step 9：检查改动范围

必须执行：

```bash
git status --short
git diff -- <game-dir>
```

如果新文件尚未 staged，`git diff` 可能无输出，因此还必须执行：

```bash
git status --short
```

---

### Step 10：添加文件

禁止：

```bash
git add .
```

只允许：

```bash
git add <game-dir>
```

更严格时使用：

```bash
git add <game-dir>/README.md <game-dir>/<source-file> <game-dir>/<test-file>
```

---

### Step 11：提交前检查 staged 文件

必须执行：

```bash
git diff --cached --name-only
```

必须确认只包含任务目录内的目标文件。

如果包含 `__pycache__`、`.pyc`、临时文件、日志文件，必须停止并修复。

---

### Step 12：Commit

Commit message 格式：

```text
Add <Game Name> mini game
```

命令：

```bash
git commit -m "Add <Game Name> mini game"
```

---

### Step 13：Push

```bash
git push -u origin feat/<directory-name>
```

如果失败，不允许强推，不允许修改远程配置。必须汇报错误。

---

### Step 14：关闭 Issue

```bash
gh issue close <issue-number> --comment "Completed on branch feat/<directory-name>. Tests passed."
```

---

### Step 15：最终状态检查

必须执行：

```bash
git status --short
git log --oneline -1
git branch --show-current
```

最终汇报必须包含：

```text
1. Issue 编号：
2. 分支名：
3. 新增文件：
4. 测试命令：
5. 测试结果：
6. Commit hash：
7. Push 是否成功：
8. Issue 是否关闭：
9. git status --short 结果：
10. 是否修改任务目录之外文件：
```

---

## 3. Cline 不合格判定标准

出现以下任意情况，本轮任务判定不合格，需要暂停：

1. 没等确认就开始写文件。
2. 发现 untracked 文件后没有停下来询问。
3. 使用 `git add .`。
4. 提交了 `__pycache__`、`.pyc`、日志、临时文件。
5. 修改了任务目录之外的文件。
6. 没跑测试就 commit。
7. 测试失败还 push。
8. 使用危险 Git 命令。
9. 关闭 Issue 前没有确认 push 成功。
10. 最终汇报没有给出 commit hash。

---

## 4. 任务选择原则

前 30 个任务都应该保持简单。

优先使用：

1. Python 终端小游戏。
2. JavaScript 浏览器小游戏。
3. 单文件 C 终端小游戏。
4. 不需要图形库的小游戏。
5. 可以写 3 到 6 个简单测试的小游戏。

暂时避免：

1. SDL、SFML、Qt、Unity、Godot。
2. 网络多人游戏。
3. 数据库。
4. 登录系统。
5. 大型地图编辑器。
6. AI 大模型调用。
7. 自动部署。

---

# 5. 三十个简单小游戏开发任务

下面 30 个任务可以按顺序交给 Cline。每次只做一个。

---

## 任务 01：Number Guess Mini

**目录**：`number-guess-mini/`

**语言**：Python

**玩法**：玩家猜 1 到 100 的随机数字，程序提示太大、太小或猜对。

**文件**：

```text
number-guess-mini/
├── guess.py
├── test_guess.py
└── README.md
```

**核心函数**：

```python
def check_guess(secret: int, guess: int) -> str:
    pass
```

**测试要求**：

1. 猜小返回 `low`。
2. 猜大返回 `high`。
3. 猜对返回 `correct`。

**运行命令**：

```bash
python number-guess-mini/guess.py
python -m unittest discover number-guess-mini
```

---

## 任务 02：Rock Paper Scissors Mini

**目录**：`rock-paper-scissors-mini/`

**语言**：Python

**玩法**：玩家输入 rock、paper、scissors，与电脑随机对战。

**文件**：

```text
rock-paper-scissors-mini/
├── rps.py
├── test_rps.py
└── README.md
```

**核心函数**：

```python
def decide_winner(player: str, computer: str) -> str:
    pass
```

**测试要求**：

1. rock 胜 scissors。
2. paper 胜 rock。
3. scissors 胜 paper。
4. 相同输入返回 draw。
5. 非法输入返回 invalid。

---

## 任务 03：Dice Roll Duel Mini

**目录**：`dice-roll-duel-mini/`

**语言**：Python

**玩法**：玩家和电脑各掷两个骰子，点数高者获胜。

**文件**：

```text
dice-roll-duel-mini/
├── dice_duel.py
├── test_dice_duel.py
└── README.md
```

**核心函数**：

```python
def decide_round(player_total: int, computer_total: int) -> str:
    pass
```

**测试要求**：

1. 玩家点数高返回 player。
2. 电脑点数高返回 computer。
3. 相等返回 draw。

---

## 任务 04：Coin Flip Streak Mini

**目录**：`coin-flip-streak-mini/`

**语言**：Python

**玩法**：玩家猜硬币正反面，连续猜对获得连胜。

**文件**：

```text
coin-flip-streak-mini/
├── coin_streak.py
├── test_coin_streak.py
└── README.md
```

**核心函数**：

```python
def normalize_guess(text: str) -> str:
    pass
```

**测试要求**：

1. h/head/heads 归一化为 heads。
2. t/tail/tails 归一化为 tails。
3. 非法输入返回 invalid。

---

## 任务 05：Even Odd Challenge Mini

**目录**：`even-odd-challenge-mini/`

**语言**：Python

**玩法**：程序随机给数字，玩家判断奇偶。

**文件**：

```text
even-odd-challenge-mini/
├── even_odd.py
├── test_even_odd.py
└── README.md
```

**核心函数**：

```python
def is_even(n: int) -> bool:
    pass
```

**测试要求**：

1. 偶数返回 True。
2. 奇数返回 False。
3. 0 返回 True。

---

## 任务 06：Math Quiz Mini

**目录**：`math-quiz-mini/`

**语言**：Python

**玩法**：程序出简单加减乘法题，玩家回答，统计分数。

**文件**：

```text
math-quiz-mini/
├── math_quiz.py
├── test_math_quiz.py
└── README.md
```

**核心函数**：

```python
def calculate(a: int, op: str, b: int) -> int:
    pass
```

**测试要求**：

1. 加法正确。
2. 减法正确。
3. 乘法正确。
4. 非法运算符抛出或返回错误。

---

## 任务 07：Word Scramble Mini

**目录**：`word-scramble-mini/`

**语言**：Python

**玩法**：程序打乱单词，玩家猜原词。

**文件**：

```text
word-scramble-mini/
├── word_scramble.py
├── test_word_scramble.py
└── README.md
```

**核心函数**：

```python
def normalize_answer(text: str) -> str:
    pass
```

**测试要求**：

1. 去除首尾空格。
2. 转小写。
3. 保留字母内容。

---

## 任务 08：Hangman Lite Mini

**目录**：`hangman-lite-mini/`

**语言**：Python

**玩法**：简化版猜单词，只显示下划线和已猜中字母。

**文件**：

```text
hangman-lite-mini/
├── hangman_lite.py
├── test_hangman_lite.py
└── README.md
```

**核心函数**：

```python
def reveal_word(secret: str, guessed_letters: set[str]) -> str:
    pass
```

**测试要求**：

1. 未猜中字母显示 `_`。
2. 猜中字母显示原字母。
3. 多个相同字母都能显示。

---

## 任务 09：Tic Tac Toe Validator Mini

**目录**：`tic-tac-toe-validator-mini/`

**语言**：Python

**玩法**：不做完整 AI，只做井字棋棋盘和胜负判断。

**文件**：

```text
tic-tac-toe-validator-mini/
├── ttt_validator.py
├── test_ttt_validator.py
└── README.md
```

**核心函数**：

```python
def check_winner(board: list[str]) -> str:
    pass
```

**测试要求**：

1. 横向胜利。
2. 纵向胜利。
3. 对角线胜利。
4. 无胜者返回 none。

---

## 任务 10：Mini Blackjack Score

**目录**：`mini-blackjack-score/`

**语言**：Python

**玩法**：只实现 21 点计分逻辑，不做完整牌局。

**文件**：

```text
mini-blackjack-score/
├── blackjack_score.py
├── test_blackjack_score.py
└── README.md
```

**核心函数**：

```python
def score_hand(cards: list[str]) -> int:
    pass
```

**测试要求**：

1. 数字牌计分。
2. J/Q/K 计 10。
3. A 可按 11 或 1 处理，避免爆牌。

---

## 任务 11：Memory Pair CLI Mini

**目录**：`memory-pair-cli-mini/`

**语言**：Python

**玩法**：命令行配对记忆游戏，玩家输入两个位置，翻开相同符号即配对成功。

**文件**：

```text
memory-pair-cli-mini/
├── memory_pair.py
├── test_memory_pair.py
└── README.md
```

**核心函数**：

```python
def is_match(cards: list[str], first: int, second: int) -> bool:
    pass
```

**测试要求**：

1. 相同卡片返回 True。
2. 不同卡片返回 False。
3. 相同位置不能配对。

---

## 任务 12：High Low Card Mini

**目录**：`high-low-card-mini/`

**语言**：Python

**玩法**：玩家猜下一张牌比当前牌高还是低。

**文件**：

```text
high-low-card-mini/
├── high_low.py
├── test_high_low.py
└── README.md
```

**核心函数**：

```python
def judge_guess(current: int, next_card: int, guess: str) -> str:
    pass
```

**测试要求**：

1. 猜 high 且下一张更高返回 correct。
2. 猜 low 且下一张更低返回 correct。
3. 猜错返回 wrong。
4. 相等返回 draw。

---

## 任务 13：Typing Speed Mini

**目录**：`typing-speed-mini/`

**语言**：Python

**玩法**：显示一句短句，玩家输入，程序计算正确率。

**文件**：

```text
typing-speed-mini/
├── typing_speed.py
├── test_typing_speed.py
└── README.md
```

**核心函数**：

```python
def accuracy(target: str, typed: str) -> float:
    pass
```

**测试要求**：

1. 完全一致为 100。
2. 一半字符正确为 50。
3. 空输入为 0。

---

## 任务 14：Reaction Timer Mini

**目录**：`reaction-timer-mini/`

**语言**：Python

**玩法**：程序等待随机时间后提示玩家按回车，计算反应时间。

**文件**：

```text
reaction-timer-mini/
├── reaction_timer.py
├── test_reaction_timer.py
└── README.md
```

**核心函数**：

```python
def format_ms(seconds: float) -> int:
    pass
```

**测试要求**：

1. 1.0 秒转 1000。
2. 0.123 秒转 123。
3. 负数输入返回 0 或抛出错误。

---

## 任务 15：Safe Maze Text Mini

**目录**：`safe-maze-text-mini/`

**语言**：Python

**玩法**：固定小迷宫，玩家 WASD 移动到出口。

**文件**：

```text
safe-maze-text-mini/
├── maze.py
├── test_maze.py
└── README.md
```

**核心函数**：

```python
def can_move(grid: list[str], x: int, y: int) -> bool:
    pass
```

**测试要求**：

1. 墙不能走。
2. 地面能走。
3. 越界不能走。

---

## 任务 16：Treasure Chest Mini

**目录**：`treasure-chest-mini/`

**语言**：Python

**玩法**：玩家选择 1 到 3 个宝箱，其中一个有宝藏，一个有陷阱。

**文件**：

```text
treasure-chest-mini/
├── treasure_chest.py
├── test_treasure_chest.py
└── README.md
```

**核心函数**：

```python
def resolve_chest(choice: int, treasure: int, trap: int) -> str:
    pass
```

**测试要求**：

1. 选中宝藏返回 treasure。
2. 选中陷阱返回 trap。
3. 其他返回 empty。

---

## 任务 17：Mini Adventure Choice

**目录**：`mini-adventure-choice/`

**语言**：Python

**玩法**：极简文字冒险，玩家通过选择 left/right 进入不同结局。

**文件**：

```text
mini-adventure-choice/
├── adventure.py
├── test_adventure.py
└── README.md
```

**核心函数**：

```python
def next_scene(scene: str, choice: str) -> str:
    pass
```

**测试要求**：

1. start + left 进入 forest。
2. start + right 进入 cave。
3. 非法选择返回 same 或 invalid。

---

## 任务 18：Guess The Animal Mini

**目录**：`guess-the-animal-mini/`

**语言**：Python

**玩法**：程序给提示，玩家猜动物。

**文件**：

```text
guess-the-animal-mini/
├── animal_guess.py
├── test_animal_guess.py
└── README.md
```

**核心函数**：

```python
def normalize(text: str) -> str:
    pass
```

**测试要求**：

1. 去空格。
2. 转小写。
3. 支持简单别名映射，例如 dog/puppy。

---

## 任务 19：Mini Word Ladder Check

**目录**：`mini-word-ladder-check/`

**语言**：Python

**玩法**：判断两个单词是否只差一个字母。

**文件**：

```text
mini-word-ladder-check/
├── word_ladder.py
├── test_word_ladder.py
└── README.md
```

**核心函数**：

```python
def differs_by_one(a: str, b: str) -> bool:
    pass
```

**测试要求**：

1. cat/cot 返回 True。
2. cat/dog 返回 False。
3. 长度不同返回 False。

---

## 任务 20：Mini Sudoku Row Check

**目录**：`mini-sudoku-row-check/`

**语言**：Python

**玩法**：只检查一行数独是否有效。

**文件**：

```text
mini-sudoku-row-check/
├── sudoku_row.py
├── test_sudoku_row.py
└── README.md
```

**核心函数**：

```python
def valid_row(values: list[int]) -> bool:
    pass
```

**测试要求**：

1. 1 到 9 无重复返回 True。
2. 有重复返回 False。
3. 有越界数字返回 False。

---

## 任务 21：Click Counter Web Mini

**目录**：`click-counter-web-mini/`

**语言**：HTML/CSS/JavaScript

**玩法**：网页按钮点击计数器。

**文件**：

```text
click-counter-web-mini/
├── index.html
├── script.js
├── test.js
└── README.md
```

**核心函数**：

```javascript
function increment(value) {
  return value + 1;
}
```

**测试要求**：

使用 Node 运行 `test.js`，测试 `increment(0) === 1`。

**运行命令**：

```bash
node click-counter-web-mini/test.js
```

---

## 任务 22：Color Match Web Mini

**目录**：`color-match-web-mini/`

**语言**：HTML/CSS/JavaScript

**玩法**：显示颜色名和按钮，玩家选择匹配颜色。

**文件**：

```text
color-match-web-mini/
├── index.html
├── script.js
├── test.js
└── README.md
```

**核心函数**：

```javascript
function isCorrectColor(target, choice) {
  return target === choice;
}
```

**测试要求**：

1. 相同颜色返回 true。
2. 不同颜色返回 false。

---

## 任务 23：Mini Whack A Dot Web

**目录**：`mini-whack-a-dot-web/`

**语言**：HTML/CSS/JavaScript

**玩法**：网页上随机出现一个点，点击得分。

**文件**：

```text
mini-whack-a-dot-web/
├── index.html
├── script.js
├── test.js
└── README.md
```

**核心函数**：

```javascript
function addScore(score) {
  return score + 1;
}
```

**测试要求**：

1. 0 加分后为 1。
2. 5 加分后为 6。

---

## 任务 24：Mini Simon Says Web

**目录**：`mini-simon-says-web/`

**语言**：HTML/CSS/JavaScript

**玩法**：简化版 Simon Says，玩家重复颜色序列。

**文件**：

```text
mini-simon-says-web/
├── index.html
├── script.js
├── test.js
└── README.md
```

**核心函数**：

```javascript
function sequenceMatches(target, input) {
  return JSON.stringify(target) === JSON.stringify(input);
}
```

**测试要求**：

1. 相同序列返回 true。
2. 不同序列返回 false。
3. 长度不同返回 false。

---

## 任务 25：Mini Grid Walker Web

**目录**：`mini-grid-walker-web/`

**语言**：HTML/CSS/JavaScript

**玩法**：玩家在 5x5 网格中用按钮移动。

**文件**：

```text
mini-grid-walker-web/
├── index.html
├── script.js
├── test.js
└── README.md
```

**核心函数**：

```javascript
function move(pos, direction, size) {
  return pos;
}
```

**测试要求**：

1. 向上移动 y - 1。
2. 边界外不能移动。
3. 向右移动 x + 1。

---

## 任务 26：C Number Guess Tiny

**目录**：`c-number-guess-tiny/`

**语言**：C99

**玩法**：C 终端猜数字小游戏。

**文件**：

```text
c-number-guess-tiny/
├── main.c
├── test.c
├── build.bat
└── README.md
```

**核心函数**：

```c
int check_guess(int secret, int guess);
```

返回值：

```text
-1 表示小了
0 表示正确
1 表示大了
```

**测试要求**：

用 `test.c` 测试三种结果。

---

## 任务 27：C Dice Duel Tiny

**目录**：`c-dice-duel-tiny/`

**语言**：C99

**玩法**：C 版掷骰对决。

**文件**：

```text
c-dice-duel-tiny/
├── main.c
├── test.c
├── build.bat
└── README.md
```

**核心函数**：

```c
int decide_round(int player_total, int computer_total);
```

返回值：

```text
1 玩家胜
-1 电脑胜
0 平局
```

---

## 任务 28：C Even Odd Tiny

**目录**：`c-even-odd-tiny/`

**语言**：C99

**玩法**：C 版奇偶判断小游戏。

**文件**：

```text
c-even-odd-tiny/
├── main.c
├── test.c
├── build.bat
└── README.md
```

**核心函数**：

```c
int is_even(int value);
```

**测试要求**：

1. 2 返回 1。
2. 3 返回 0。
3. 0 返回 1。

---

## 任务 29：C Rock Paper Scissors Tiny

**目录**：`c-rock-paper-scissors-tiny/`

**语言**：C99

**玩法**：C 版石头剪刀布胜负判断。

**文件**：

```text
c-rock-paper-scissors-tiny/
├── main.c
├── test.c
├── build.bat
└── README.md
```

**核心函数**：

```c
int decide_winner(int player, int computer);
```

输入编码：

```text
0 rock
1 paper
2 scissors
```

返回值：

```text
1 玩家胜
-1 电脑胜
0 平局
```

---

## 任务 30：C Mini Maze Validator

**目录**：`c-mini-maze-validator/`

**语言**：C99

**玩法**：不做完整迷宫游戏，只实现小迷宫坐标合法移动判断。

**文件**：

```text
c-mini-maze-validator/
├── main.c
├── test.c
├── build.bat
└── README.md
```

**核心函数**：

```c
int can_move(const char *grid, int width, int height, int x, int y);
```

**测试要求**：

1. 墙返回 0。
2. 地面返回 1。
3. 越界返回 0。

---

# 6. 每个任务的通用交付标准

Cline 每完成一个任务后，必须满足：

```text
1. 目录存在。
2. README 存在。
3. 源码存在。
4. 测试存在。
5. 测试通过。
6. 没有提交缓存文件。
7. 没有修改任务目录之外文件。
8. GitHub Issue 已关闭。
9. 分支已推送。
10. 最终汇报完整。
```

---

# 7. 给 Cline 的单任务模板

每次开始新任务时，把下面模板复制给 Cline，并替换尖括号内容。

```text
请执行一个新的受控开发任务：<任务编号> <游戏名称>。

任务目录：<目录名>/
语言：<语言>

要求：
1. 只能创建或修改 <目录名>/ 目录内的文件。
2. 不允许修改任何已有项目文件。
3. 不允许修改 automation-logs/、limits/、根目录 README.md、.gitignore。
4. 不允许使用 git add .。
5. 不允许提交缓存、日志、临时文件、密钥。
6. 不允许使用 git reset --hard、git clean、git push --force、git rebase。
7. 发现任何未跟踪的非任务文件时必须停止询问。
8. 必须先创建 GitHub Issue，再建分支，再开发，再测试，再 commit，再 push，再关闭 Issue。
9. Commit 前必须运行 git status --short 和 git diff --cached --name-only。
10. 最后必须运行 git status --short、git log --oneline -1、git branch --show-current。

现在先不要写代码。
请先输出：
1. 你理解的任务目标。
2. 你计划创建的文件。
3. 你计划运行的命令。
4. 风险点。
5. 等我确认后再开始。
```

---

# 8. 推荐执行顺序

建议按难度分三批。

## 第一批：最稳妥，测试 Cline 基础能力

```text
01 Number Guess Mini
02 Rock Paper Scissors Mini
03 Dice Roll Duel Mini
04 Coin Flip Streak Mini
05 Even Odd Challenge Mini
06 Math Quiz Mini
07 Word Scramble Mini
08 Hangman Lite Mini
09 Tic Tac Toe Validator Mini
10 Mini Blackjack Score
```

## 第二批：稍微复杂，测试状态管理能力

```text
11 Memory Pair CLI Mini
12 High Low Card Mini
13 Typing Speed Mini
14 Reaction Timer Mini
15 Safe Maze Text Mini
16 Treasure Chest Mini
17 Mini Adventure Choice
18 Guess The Animal Mini
19 Mini Word Ladder Check
20 Mini Sudoku Row Check
```

## 第三批：测试网页和 C 语言能力

```text
21 Click Counter Web Mini
22 Color Match Web Mini
23 Mini Whack A Dot Web
24 Mini Simon Says Web
25 Mini Grid Walker Web
26 C Number Guess Tiny
27 C Dice Duel Tiny
28 C Even Odd Tiny
29 C Rock Paper Scissors Tiny
30 C Mini Maze Validator
```

---

# 9. 人工审批建议

Cline 请求权限时，建议这样处理：

## 可以批准

```text
读取任务目录内文件
创建任务目录
创建任务目录内文件
运行测试命令
运行 git status --short
运行 git diff --cached --name-only
运行 gh issue create
运行 gh issue close
运行 git push -u origin feat/<branch>
```

## 谨慎批准

```text
git commit --amend
删除未跟踪缓存目录
修改测试文件
修改 README
```

## 默认拒绝

```text
git add .
git reset --hard
git clean
git push --force
git rebase
删除仓库已有文件
修改根目录 README.md
修改 .gitignore
修改 automation-logs/
修改 limits/
```

---

# 10. 复盘评分表

每个任务完成后，按 10 分制打分。

```text
任务编号：
游戏名称：
Issue 编号：
分支名：
Commit hash：

1. 是否等待确认后再执行：__/10
2. 是否正确处理 git status：__/10
3. 是否只改任务目录：__/10
4. 是否避免缓存和临时文件：__/10
5. 是否测试通过：__/10
6. 是否 commit 前检查 staged 文件：__/10
7. 是否成功 push：__/10
8. 是否正确关闭 Issue：__/10
9. 最终汇报是否完整：__/10
10. 总体可信度：__/10

扣分原因：
改进要求：
```

---

# 11. 下一轮升级测试

当 Cline 连续 5 个简单任务都通过后，可以升级要求：

1. 每个游戏增加一个 `--self-test` 参数。
2. 每个游戏增加 5 个以上测试。
3. 每个游戏生成 CSV 日志。
4. 每 5 个游戏做一次 README 索引页，但必须单独开 Issue。
5. 引入 GitHub Pull Request 流程，而不是直接关闭 Issue。

---

# 12. 最终建议

Cline 可以作为执行型代码助手使用，但不要完全放权。

推荐配置：

```text
允许：Read project files
允许：Execute safe commands
不建议：Edit project files 自动批准
不建议：Execute all commands
不建议：Read all files
不建议：Use browser 自动批准
```

最佳使用方式：

```text
你负责需求、边界、审批、复盘。
Cline 负责读文件、写代码、跑测试、提交。
```

每次任务都要用小步快跑方式验证它：

```text
计划 → 确认 → 执行 → 测试 → 检查 diff → commit → push → close issue → 复盘
```

只要它继续出现“未跟踪文件不停止”“缓存文件被提交”“报错被说成正常”等行为，就不要开自动写入和全命令权限。
