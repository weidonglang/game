# 第二批：十个完全不同的跨语言小游戏方案（Java / Python / Rust / R）

> 目标：这 10 个方案刻意避开上一批的题材：不再做卡牌、迷宫、打字、奶茶店经营、生存避障、怪物成长、节奏点击、数独、投篮、交通灯调度。  
> 语言不再强制固定，允许从 **Java / Python / Rust / R** 中自由组合。R 只在它自然有优势的地方使用，例如统计、概率、模拟、可视化、模型分析；不适合时可以不用。

---

## 总体约束

每个游戏必须有一个玩家能看到或操作的入口，不能只是后台算法：

- JavaFX / Swing 桌面窗口
- Python pygame / PySide 窗口
- Rust egui 桌面窗口
- R Shiny 数据面板
- Python FastAPI + HTML Canvas 本地网页

推荐给 Codex 的实现方式：先做 MVP，先让游戏能操作，再接入多语言模块。

---

# 1. 侦探证据板游戏《Evidence Board Detective》

## 游戏概念

玩家扮演侦探，在一个可拖拽的证据板上整理嫌疑人、时间线、物证和证词。玩家需要把证据连线，找出真正的嫌疑人。

这不是普通答题游戏，而是一个“证据组合推理游戏”：玩家可以拖动卡片、连线、标记矛盾点、提交推理结论。

## 推荐语言组合

```text
Java + Python + R
```

## 可视化前端 / 可操作入口

使用 **JavaFX** 制作证据板界面：

- 左侧：嫌疑人卡片。
- 中间：可拖拽证据板。
- 右侧：证词列表和时间线。
- 鼠标拖动：把证据和嫌疑人连接起来。
- 点击“提交推理”：判断玩家是否找到了关键链路。
- 点击“查看推理分析”：展示 R 生成的嫌疑概率图。

## 各语言分工

| 模块 | 语言 | 说明 |
|---|---|---|
| 证据板 UI、拖拽、连线 | Java | JavaFX 适合做桌面交互 |
| 案件文本、线索生成 | Python | 方便生成剧情、JSON 数据 |
| 嫌疑概率、证据权重分析 | R | 适合做概率统计和可视化 |

## R 的自然用途

R 不直接决定真相，而是作为“案件分析器”：

- 根据证据权重计算每个嫌疑人的嫌疑分。
- 根据玩家连接的证据链，判断推理是否偏向某个嫌疑人。
- 生成嫌疑人概率柱状图。
- 分析玩家是否遗漏关键证据。

## MVP 功能

- 1 个案件，3 名嫌疑人，10 张证据卡。
- 玩家能拖动证据卡到证据板。
- 玩家能用鼠标连接“嫌疑人 - 证据”。
- 玩家能提交最终嫌疑人。
- 游戏导出 `evidence_links.json`。
- R 读取 JSON，生成 `suspect_probability.png`。

## 数据文件示例

```json
{
  "case_id": "case_001",
  "links": [
    {"from": "suspect_a", "to": "knife", "weight": 0.7},
    {"from": "suspect_b", "to": "alibi_gap", "weight": 0.5}
  ],
  "final_guess": "suspect_a"
}
```

## Codex 开发任务建议

```text
1. 创建 JavaFX 主窗口，包含嫌疑人区、证据板区、证词区。
2. 实现 EvidenceCard 组件，支持拖拽和选中。
3. 实现证据连线数据结构 Link(from, to, weight)。
4. 用 Python 生成 case_001.json，包含嫌疑人、证据和正确答案。
5. Java 在提交后导出 evidence_links.json。
6. 编写 R 脚本 analyze_case.R，输出嫌疑概率图 suspect_probability.png。
```

---

# 2. 炼金配方实验室《Alchemy Recipe Lab》

## 游戏概念

玩家在炼金台上混合不同材料，尝试合成药水。每种材料有隐藏属性，例如温度、酸碱、魔力、稳定性。玩家通过多次实验推断最佳配方。

核心乐趣是“实验 - 观察 - 调参 - 再实验”。

## 推荐语言组合

```text
Python + Rust + R
```

## 可视化前端 / 可操作入口

使用 **pygame** 或 **PySide** 制作炼金台：

- 材料架：显示草药、矿石、晶体、液体。
- 炼金锅：拖放材料到锅中。
- 火候滑块：调整温度。
- 搅拌按钮：开始合成。
- 结果窗口：显示颜色、品质、失败原因。
- “实验报告”按钮：打开 R 生成的参数影响图。

## 各语言分工

| 模块 | 语言 | 说明 |
|---|---|---|
| 炼金台前端、拖放操作 | Python | pygame/PySide 开发快 |
| 配方规则引擎 | Rust | 负责稳定、可测试的合成计算 |
| 实验结果分析 | R | 适合做响应面分析、变量影响图 |

## R 的自然用途

R 适合分析“哪些参数最影响药水品质”：

- 温度对成功率的影响。
- 材料比例对品质的影响。
- 哪些材料组合经常爆炸。
- 给出下一次实验建议。

## MVP 功能

- 8 种材料。
- 3 个可调参数：温度、搅拌时间、材料比例。
- 至少 5 种药水结果。
- Rust 根据输入返回合成结果。
- 游戏记录每次实验到 `alchemy_trials.csv`。
- R 生成 `alchemy_effects_report.html`。

## 数据文件示例

```csv
trial_id,herb,ore,crystal,temp,stir_seconds,result,quality
1,moonleaf,iron,blue,70,8,healing_potion,82
2,firegrass,copper,red,95,5,explosion,0
```

## Codex 开发任务建议

```text
1. 用 Python 创建炼金台界面，支持点击或拖放材料。
2. 用 Rust 实现 evaluate_recipe(input_json) -> result_json。
3. Python 将玩家配方写入 JSON 并调用 Rust 可执行文件。
4. 每次实验追加 alchemy_trials.csv。
5. 用 R 分析参数与 quality 的关系，生成 HTML 报告。
```

---

# 3. 星图航线规划游戏《Star Route Navigator》

## 游戏概念

玩家是星际导航员，需要在星图中规划飞船航线。每个星球之间的航线有燃料消耗、风险、时间和奖励。玩家要在有限燃料内到达目标星系。

它不是迷宫游戏，因为地图是星际网络图，核心是路径规划、资源取舍和风险管理。

## 推荐语言组合

```text
Java + Rust
```

## 可视化前端 / 可操作入口

使用 **JavaFX Canvas** 制作星图：

- 节点：星球。
- 边：航线。
- 鼠标点击星球选择路线。
- 右侧面板显示剩余燃料、风险值、预计收益。
- 点击“自动建议航线”：调用 Rust 计算推荐路线。
- 点击“起航”：播放飞船沿路线移动的动画。

## 各语言分工

| 模块 | 语言 | 说明 |
|---|---|---|
| 星图 UI、动画、玩家操作 | Java | JavaFX Canvas 适合画节点图 |
| 路径搜索、风险计算 | Rust | 适合实现 Dijkstra、A*、动态规划 |

## R 是否需要

这个项目默认不需要 R。它的重点是图算法和可视化交互。若后期需要分析玩家偏好的路线选择，可以再加入 R，但 MVP 不强制。

## MVP 功能

- 生成 20 个星球节点。
- 节点之间有随机航线。
- 玩家点击选择一条路径。
- 系统显示燃料、时间、风险、收益。
- Rust 返回推荐路径。
- Java 播放起航动画。

## 数据文件示例

```json
{
  "nodes": ["Earth", "Vega", "Orion"],
  "edges": [
    {"from": "Earth", "to": "Vega", "fuel": 12, "risk": 0.2, "reward": 30},
    {"from": "Vega", "to": "Orion", "fuel": 8, "risk": 0.4, "reward": 50}
  ]
}
```

## Codex 开发任务建议

```text
1. 用 JavaFX Canvas 绘制星球节点和航线。
2. 实现点击节点后追加到 selected_route。
3. 用 Rust 实现 find_best_route(graph_json, fuel_limit)。
4. Java 调用 Rust CLI，读取推荐路径 JSON。
5. 在 JavaFX 中绘制推荐路径高亮和飞船动画。
```

---

# 4. 基因花园育种游戏《Genetic Garden》

## 游戏概念

玩家经营一个小花园，但重点不是卖货，而是育种。玩家把两株植物杂交，观察下一代花色、叶形、高度、香味等性状。目标是培育出指定品种。

游戏核心是遗传概率和多代选择。

## 推荐语言组合

```text
Python + R
```

## 可视化前端 / 可操作入口

使用 **Python PySide** 制作花园界面：

- 左侧：种子仓库。
- 中间：花圃格子。
- 右侧：植物性状面板。
- 玩家可以拖动两株植物到育种台。
- 点击“杂交”生成下一代种子。
- 点击“遗传分析”查看 R 生成的性状概率图。

## 各语言分工

| 模块 | 语言 | 说明 |
|---|---|---|
| 花园 UI、拖拽、种植 | Python | PySide 适合桌面工具式界面 |
| 遗传概率模拟、图表 | R | 适合概率分布和可视化 |

## R 的自然用途

R 非常适合做：

- 孟德尔遗传概率模拟。
- 多基因性状分布。
- 目标品种出现概率。
- 育种路线建议。

## MVP 功能

- 4 个性状：花色、叶形、高度、香味。
- 6 种基础植物。
- 支持两株植物杂交。
- R 计算下一代性状概率。
- 前端显示实际出生的种子。
- 生成 `trait_distribution.png`。

## 数据文件示例

```json
{
  "parent_a": {"color": "Rr", "height": "Tt", "scent": "Ss"},
  "parent_b": {"color": "rr", "height": "TT", "scent": "ss"},
  "target": {"color": "red", "height": "tall", "scent": "strong"}
}
```

## Codex 开发任务建议

```text
1. 用 PySide 创建花园格子、种子仓库和育种台。
2. 定义 Plant 类，包含 genotype 和 phenotype。
3. Python 将双亲基因型写入 breeding_request.json。
4. R 读取请求，计算 offspring 概率分布。
5. Python 读取 R 输出，随机生成一株后代并显示。
```

---

# 5. 拍卖心理战游戏《Auction Duel》

## 游戏概念

玩家参加一场密封报价拍卖。每轮有不同物品，玩家需要判断真实价值和对手心理，决定出价。出价太低会输，出价太高会亏。

这不是经营模拟，而是博弈和风险判断游戏。

## 推荐语言组合

```text
Java + R
```

## 可视化前端 / 可操作入口

使用 **JavaFX** 制作拍卖厅界面：

- 中间显示拍卖品图片占位、估价区间、稀有度。
- 玩家输入出价。
- AI 对手头像和历史风格显示在右侧。
- 每轮结束显示赢家、利润、亏损。
- 赛后点击“对手行为分析”，显示 R 图表。

## 各语言分工

| 模块 | 语言 | 说明 |
|---|---|---|
| 拍卖厅 UI、出价交互 | Java | 桌面端交互清楚 |
| 出价分布、对手策略分析 | R | 适合统计玩家和 AI 的报价行为 |

## R 的自然用途

R 用于分析拍卖策略：

- 玩家是否经常过度出价。
- 玩家对稀有物品是否偏激进。
- AI 对手报价分布。
- 不同策略的长期收益对比。

## MVP 功能

- 20 个拍卖品。
- 3 个 AI 对手：保守型、激进型、随机型。
- 玩家输入报价后结算收益。
- 记录 `auction_history.csv`。
- R 生成玩家报价偏差图和累计利润曲线。

## 数据文件示例

```csv
round,item,true_value,player_bid,ai_bid,winner,player_profit
1,Ancient Coin,120,150,130,player,-30
2,Crystal Vase,300,260,240,player,40
```

## Codex 开发任务建议

```text
1. 用 JavaFX 创建拍卖品展示、报价输入框、结果弹窗。
2. 实现 AuctionItem 和 AIBidder 类。
3. 每轮结束追加 auction_history.csv。
4. 用 R 读取历史数据，生成 bid_bias.png 和 profit_curve.png。
5. Java 加载 PNG 到赛后分析面板。
```

---

# 6. 密码逃脱房《Cipher Escape Room》

## 游戏概念

玩家被困在一个虚拟密室中，需要破解墙上的密码、书页上的暗号、机关上的符号。每个房间对应一种加密方式，例如凯撒密码、替换密码、维吉尼亚密码、栅栏密码。

这不是数独，也不是普通文字题，而是“可视化房间 + 密码机关”的解谜游戏。

## 推荐语言组合

```text
Python + Rust + R
```

## 可视化前端 / 可操作入口

使用 **pygame** 制作 2D 密室：

- 玩家用方向键移动。
- 点击墙上的纸条查看密文。
- 点击保险箱输入答案。
- 点击“频率分析仪”调用 R，显示字母频率图。
- Rust 负责校验密码和生成加密文本。

## 各语言分工

| 模块 | 语言 | 说明 |
|---|---|---|
| 密室地图、移动、点击交互 | Python | pygame 快速实现 2D 房间 |
| 加密/解密规则、答案校验 | Rust | 字符串规则清晰且安全 |
| 字母频率、提示图表 | R | 适合做频率统计和图表 |

## R 的自然用途

R 用来做“辅助破译工具”：

- 统计密文字母频率。
- 与英文常见频率对比。
- 显示可能的替换关系。
- 给出非直接答案的提示。

## MVP 功能

- 3 个房间。
- 3 类密码：凯撒、替换、栅栏。
- 玩家可移动、调查、输入答案。
- R 生成 `frequency_hint.png`。
- Rust 校验玩家答案是否正确。

## 数据文件示例

```json
{
  "room_id": 1,
  "cipher_type": "caesar",
  "cipher_text": "KHOOR ZRUOG",
  "player_answer": "HELLO WORLD"
}
```

## Codex 开发任务建议

```text
1. 用 pygame 创建密室地图和可交互物品。
2. 用 Rust 实现 cipher_core：encrypt、validate_answer、generate_puzzle。
3. Python 点击纸条后显示密文弹窗。
4. 点击频率分析仪时，将密文写入 cipher_request.json。
5. R 读取密文并生成 frequency_hint.png。
```

---

# 7. 机器人流水线编程游戏《Robot Assembly Line》

## 游戏概念

玩家不是直接控制角色，而是给机器人安排指令，让它在工厂流水线上搬运零件、组装产品、避开错误传送带。玩法类似可视化编程谜题。

核心是“编排指令 + 观察模拟结果 + 优化流程”。

## 推荐语言组合

```text
Java + Rust + Python
```

## 可视化前端 / 可操作入口

使用 **JavaFX** 制作工厂编辑器：

- 网格地图：传送带、机械臂、零件箱、出口。
- 指令块面板：Move、Pick、Drop、Rotate、Wait。
- 玩家拖动指令块组成机器人程序。
- 点击“运行”后播放机器人执行动画。
- 点击“调试”显示每一步状态。

## 各语言分工

| 模块 | 语言 | 说明 |
|---|---|---|
| 工厂编辑器、拖拽指令块 | Java | JavaFX 适合复杂桌面 UI |
| 模拟器、碰撞和规则校验 | Rust | 适合确定性模拟和性能计算 |
| 关卡生成脚本 | Python | 方便生成和检查关卡 JSON |

## R 是否需要

MVP 不需要 R。这个项目的核心是可视化编程和模拟器。如果后续要分析玩家哪一步经常卡住，可以再用 R 做关卡难度统计。

## MVP 功能

- 5 个教学关卡。
- 指令块拖拽排序。
- 点击运行后逐步播放机器人动作。
- Rust 返回每一帧状态。
- Python 生成 `levels/*.json`。

## 数据文件示例

```json
{
  "level_id": "line_01",
  "grid": [["empty", "belt", "box"], ["wall", "robot", "exit"]],
  "program": ["move_right", "pick", "move_down", "drop"]
}
```

## Codex 开发任务建议

```text
1. 用 JavaFX 创建网格地图和指令块面板。
2. 实现拖拽排序 program list。
3. 用 Rust 实现 simulate(level_json, program_json) -> frames_json。
4. Java 逐帧播放 Rust 返回的机器人状态。
5. 用 Python 生成 5 个 levels JSON 文件。
```

---

# 8. 池塘钓鱼生态游戏《Pond Fishing Season》

## 游戏概念

玩家在一个池塘中钓鱼。不同天气、时间、鱼饵、水深会影响鱼类出现。玩家需要观察规律，选择合适地点和鱼饵，完成图鉴。

它不是简单点击钓鱼，而是带生态概率和季节变化的收集游戏。

## 推荐语言组合

```text
Python + R
```

## 可视化前端 / 可操作入口

使用 **pygame** 制作池塘界面：

- 地图分成浅水、深水、芦苇、水草区。
- 玩家点击位置抛竿。
- 选择鱼饵：虫子、面团、小虾、亮片。
- 等待鱼漂动画，点击收杆。
- 图鉴界面显示已钓到的鱼。
- R 生成鱼群出现概率和生态趋势图。

## 各语言分工

| 模块 | 语言 | 说明 |
|---|---|---|
| 池塘画面、抛竿、收杆、图鉴 | Python | pygame 适合 2D 小游戏 |
| 鱼群概率、季节模型、统计图 | R | 适合生态概率和时间序列可视化 |

## R 的自然用途

R 可以做生态模拟和统计分析：

- 不同鱼饵对鱼种出现率的影响。
- 天气和时间对咬钩概率的影响。
- 玩家是否过度捕捞某一种鱼。
- 季节变化下鱼群数量趋势。

## MVP 功能

- 8 种鱼。
- 4 种鱼饵。
- 4 个钓点区域。
- 天气随机变化。
- 玩家每次钓鱼记录到 `fishing_log.csv`。
- R 生成 `fish_probability_chart.png`。

## 数据文件示例

```csv
cast_id,area,bait,weather,time_of_day,fish,caught
1,deep_water,shrimp,rainy,evening,catfish,true
2,reeds,worm,sunny,noon,none,false
```

## Codex 开发任务建议

```text
1. 用 pygame 创建池塘地图和钓鱼交互。
2. 定义 FishSpecies，包含 habitat、bait_preference、rarity。
3. Python 根据当前天气和区域计算基础概率。
4. 每次抛竿记录 fishing_log.csv。
5. R 分析不同变量对 caught 的影响，并输出概率图。
```

---

# 9. 魔法图书馆分类游戏《Arcane Library Sorter》

## 游戏概念

玩家是魔法图书管理员，需要把会移动、会伪装、会互相影响的魔法书放到正确书架。每本书有派系、元素、年代、危险等级等标签。

玩法是“观察属性 + 分类 + 处理异常书籍”。

## 推荐语言组合

```text
Java + Python
```

## 可视化前端 / 可操作入口

使用 **JavaFX** 制作图书馆界面：

- 中间是待分类书堆。
- 四周是不同书架。
- 玩家拖拽书本到书架。
- 错误分类会触发小事件，例如书本逃跑、书架震动。
- 右侧显示规则提示和剩余时间。

## 各语言分工

| 模块 | 语言 | 说明 |
|---|---|---|
| 图书馆 UI、拖拽分类、动画 | Java | JavaFX 适合拖拽式桌面游戏 |
| 关卡规则生成、书籍属性生成 | Python | 方便生成随机规则和文本 |

## R 是否需要

默认不需要 R。这个项目主要突出 UI 交互和规则生成。若后续要分析玩家错误分类模式，可以把日志交给 R，但不是 MVP 必需。

## MVP 功能

- 30 本书。
- 4 个书架。
- 每关随机生成分类规则。
- 玩家拖拽书本到书架。
- 错误时触发反馈动画。
- Python 生成 `library_level.json`。

## 数据文件示例

```json
{
  "book_id": "B012",
  "title": "Moonfire Index",
  "element": "fire",
  "era": "ancient",
  "danger": 3,
  "correct_shelf": "restricted_fire"
}
```

## Codex 开发任务建议

```text
1. 用 JavaFX 创建书本卡片和书架区域。
2. 实现拖拽放置和正确性判断。
3. 用 Python 生成每关的 books 和 shelves JSON。
4. Java 加载 JSON 后渲染关卡。
5. 增加计时器、分数和错误反馈动画。
```

---

# 10. 调色师配方挑战《Color Mixer Studio》

## 游戏概念

玩家需要用有限颜料调出目标颜色。每一关给出目标色块，玩家通过调整红、黄、蓝、白、黑等颜料比例，尽量接近目标颜色。

核心是色彩空间、误差反馈和视觉调参。

## 推荐语言组合

```text
Rust + Python + R
```

## 可视化前端 / 可操作入口

使用 **Python PySide** 或 **Rust egui** 制作调色界面：

- 左侧：目标颜色。
- 右侧：玩家当前混合颜色。
- 下方：多个滑块控制颜料比例。
- 实时显示色差分数。
- 点击“提交”后显示评级。
- 点击“误差分析”后显示 R 生成的颜色误差雷达图或散点图。

## 各语言分工

| 模块 | 语言 | 说明 |
|---|---|---|
| 调色 UI、滑块、色块显示 | Python 或 Rust | PySide/egui 都可做本地可视界面 |
| 颜色混合和色差计算 | Rust | 适合做稳定、可复用的计算核心 |
| 误差统计、玩家调色习惯分析 | R | 适合统计误差分布和可视化 |

## R 的自然用途

R 用来分析玩家的调色偏差：

- 是否总是偏红、偏暗、饱和度过高。
- 哪些目标色最难。
- 玩家经过多轮是否更接近目标。
- 生成色差趋势图。

## MVP 功能

- 20 个目标颜色关卡。
- 5 个颜料滑块。
- 实时显示当前混合色。
- Rust 返回 RGB 和 Delta E 近似误差。
- 记录 `color_attempts.csv`。
- R 生成 `color_error_report.png`。

## 数据文件示例

```csv
level,target_r,target_g,target_b,mix_r,mix_g,mix_b,error,attempt
1,180,90,60,170,100,70,18.4,1
1,180,90,60,178,92,61,3.2,2
```

## Codex 开发任务建议

```text
1. 用 PySide 创建目标色块、混合色块和颜料比例滑块。
2. 用 Rust 实现 mix_colors(pigments) 和 color_error(target, mixed)。
3. Python 每次滑块变化后调用 Rust 计算当前颜色。
4. 玩家提交后追加 color_attempts.csv。
5. R 读取记录并生成误差趋势图和偏色分析图。
```

---

# 第二批方案对照表

| 编号 | 游戏 | 推荐语言 | 是否默认使用 R | 可操作入口 |
|---:|---|---|---|---|
| 1 | Evidence Board Detective | Java + Python + R | 是 | JavaFX 证据板 |
| 2 | Alchemy Recipe Lab | Python + Rust + R | 是 | pygame/PySide 炼金台 |
| 3 | Star Route Navigator | Java + Rust | 否 | JavaFX 星图 |
| 4 | Genetic Garden | Python + R | 是 | PySide 花园 |
| 5 | Auction Duel | Java + R | 是 | JavaFX 拍卖厅 |
| 6 | Cipher Escape Room | Python + Rust + R | 是 | pygame 密室 |
| 7 | Robot Assembly Line | Java + Rust + Python | 否 | JavaFX 工厂编辑器 |
| 8 | Pond Fishing Season | Python + R | 是 | pygame 池塘 |
| 9 | Arcane Library Sorter | Java + Python | 否 | JavaFX 图书馆 |
| 10 | Color Mixer Studio | Rust + Python + R | 是 | PySide/egui 调色器 |

---

# 建议优先做的 3 个

## 最适合做成完整作品：Cipher Escape Room

优点：

- 有地图、有互动、有谜题、有 UI。
- Rust 的密码规则很自然。
- R 的频率分析不是硬塞，而是合理的“游戏内工具”。
- Codex 容易逐步生成：地图、交互、谜题、校验、提示图。

## 最适合突出 R：Genetic Garden

优点：

- R 的概率分布、遗传模拟、图表能力非常合适。
- 前端不难。
- 视觉表现可以很可爱。
- 数据结构清楚，容易扩展。

## 最适合展示多语言协作：Alchemy Recipe Lab

优点：

- Python 做可视炼金台。
- Rust 做规则引擎。
- R 做实验分析。
- 玩法和数据分析之间关系非常紧密。

---

# 给 Codex 的总提示词

可以直接把下面这段给 Codex，让它从某一个游戏开始实现：

```text
请基于本 Markdown 中的游戏设计，先实现一个可运行 MVP。要求：
1. 优先保证有可视化前端或可操作入口。
2. 多语言交互先用 JSON/CSV 文件完成，不要一开始就上复杂 FFI。
3. 先实现核心玩法闭环：启动 -> 玩家操作 -> 结算 -> 记录日志。
4. 如果方案包含 R，则先提供 R 脚本，读取 CSV/JSON 并输出 PNG 或 HTML 报告。
5. 每个模块保持独立目录，例如 frontend/、core_rust/、analysis_r/、data/。
6. 提供 README，写清楚如何运行每个模块。
```

