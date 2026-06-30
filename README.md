# Agent Content Workspace

中文 | English

一套面向创作者的 Agent 内容生产工作区模板，用配置文件、方法论、检查模板、工作流钩子、Learning 机制和第三方 Skill 协作，把自媒体内容生产整理成可执行、可复盘、可持续迭代的流程。

## 前置要求

- 能够使用本地文件夹管理内容工作区。
- 能够使用支持读取项目文件的 Agent，例如 Codex、Claude Code 或其他本地编码 Agent。
- 理解本项目采用抽象平台命名：`platform-a`、`platform-b`、`platform-c`。
- 开源前愿意执行隐私检查，不把未经明确确认公开的真实身份、账号、客户、后台数据和未脱敏素材提交到公开仓库。

## 快速开始

运行初始化脚本：

```bash
bash scripts/init-workspace.sh
```

也可以手动复制模板文件：

复制模板文件：

```bash
cp AGENTS.template.md AGENTS.md
cp Learning.template.md Learning.md
cp config/creator-profile.template.md config/creator-profile.md
cp config/content-pillars.template.md config/content-pillars.md
cp config/platform-a-rules.template.md config/platform-a-rules.md
cp config/platform-b-rules.template.md config/platform-b-rules.md
cp config/platform-c-rules.template.md config/platform-c-rules.md
cp config/style-preferences.template.md config/style-preferences.md
cp config/visual-rules.template.md config/visual-rules.md
cp config/privacy-rules.template.md config/privacy-rules.md
```

然后按顺序填写：

1. `config/creator-profile.md`
2. `config/content-pillars.md`
3. `config/platform-a-rules.md`
4. `config/platform-b-rules.md`
5. `config/platform-c-rules.md`
6. `config/style-preferences.md`
7. `config/visual-rules.md`
8. `config/privacy-rules.md`
9. `Learning.md`

## 工作流

```text
配置创作者定位
-> 配置平台规则
-> 建立内容主线
-> 进行选题前检查
-> 设计内容钩子
-> 生成草稿
-> 判断视觉策略
-> 调用第三方 Skill
-> 发布前确认
-> 发布后复盘
-> 更新 Learning
```

## 目录结构

```text
agent-content-workspace/
  AGENTS.template.md
  Learning.template.md
  config/
  methods/
  templates/
  hooks/
  platforms/
  privacy/
  third-party/
```

| 目录 | 用途 |
|---|---|
| `config/` | 创作者、平台、文风、视觉和隐私配置 |
| `methods/` | 内容生产方法论文档 |
| `templates/` | 选题、草稿、视觉、发布和复盘模板 |
| `hooks/` | Agent 在关键节点必须执行的检查规则 |
| `platforms/` | 抽象平台 A/B/C 的工作目录 |
| `privacy/` | 隐私脱敏和发布前扫描说明 |
| `third-party/` | 第三方 Skill 源码、致谢和同步规则 |
| `scripts/` | 初始化和隐私扫描脚本 |

## 可用模块

### 配置模块

用于让 Agent 在写作前理解创作者、平台和边界。

| 文件 | 作用 |
|---|---|
| `config/creator-profile.template.md` | 配置创作者定位、受众、表达方向和边界 |
| `config/content-pillars.template.md` | 配置长期内容主线 |
| `config/platform-a-rules.template.md` | 配置长文类平台规则 |
| `config/platform-b-rules.template.md` | 配置图文类平台规则 |
| `config/platform-c-rules.template.md` | 配置视频类平台规则 |
| `config/style-preferences.template.md` | 配置文风偏好和文风卡 |
| `config/visual-rules.template.md` | 配置视觉策略、参考案例和截图脱敏规则 |
| `config/privacy-rules.template.md` | 配置隐私红线和占位符规则 |

### 方法论模块

用于说明每个内容生产环节的原则和执行方式。

| 文件 | 主题 |
|---|---|
| `methods/01-config-first.md` | 先配置再生产 |
| `methods/02-creator-positioning.md` | 创作者定位 |
| `methods/03-platform-rules.md` | 平台规则 |
| `methods/04-topic-check.md` | 选题前检查 |
| `methods/05-content-hooks.md` | 内容钩子总论 |
| `methods/06-image-post-hooks.md` | 图文内容钩子 |
| `methods/07-video-first-three-seconds.md` | 视频前三秒钩子 |
| `methods/08-longform-opening.md` | 长文开篇 |
| `methods/09-draft-workflow.md` | 草稿工作流 |
| `methods/10-visual-strategy.md` | 视觉策略 |
| `methods/11-third-party-skill-collaboration.md` | 第三方 Skill 协作 |
| `methods/12-final-confirmation.md` | 发布前确认 |
| `methods/13-retro-and-prediction.md` | 预测与复盘 |
| `methods/14-learning-update.md` | Learning 更新 |
| `methods/15-privacy-redaction.md` | 隐私与脱敏 |

### 检查模板

用于把方法论变成可执行检查表。

| 模板 | 使用场景 |
|---|---|
| `templates/topic-brief.md` | 记录选题卡片 |
| `templates/topic-check.md` | 推荐选题前查重和风险检查 |
| `templates/draft-template.md` | 生成草稿 |
| `templates/image-post-hook-check.md` | 图文发布前检查标题、首图和多图结构 |
| `templates/video-hook-check.md` | 视频发布前检查前三秒、前十秒和节奏 |
| `templates/visual-plan.md` | 制作视觉素材前确认视觉策略 |
| `templates/publish-checklist.md` | 发布前最终检查 |
| `templates/retro-template.md` | 发布后复盘 |
| `templates/style-card.md` | 把外部样本整理成文风卡 |
| `templates/skill-card.md` | 记录第三方 Skill 的用途和许可证 |

### 工作流钩子

用于规定 Agent 在关键节点必须做什么。

| 钩子 | 触发时机 |
|---|---|
| `hooks/before-topic.md` | 推荐选题前 |
| `hooks/before-draft.md` | 写草稿前 |
| `hooks/before-visual.md` | 做视觉素材前 |
| `hooks/before-image-post.md` | 图文发布前 |
| `hooks/before-video-post.md` | 视频发布前 |
| `hooks/before-final.md` | 归档最终稿前 |
| `hooks/after-retro.md` | 复盘后 |
| `hooks/sync-learning.md` | 写入 Learning 时 |
| `hooks/sync-third-party-skills.md` | 同步第三方 Skill 时 |

### 平台工作区

默认提供三个抽象平台。

| 平台 | 适用内容 |
|---|---|
| `platform-a` | 长文、深度分析、结构化论证、方法论内容 |
| `platform-b` | 图文、图片卡片、过程展示、收藏型内容 |
| `platform-c` | 短视频、口播、节奏推进、连续系列内容 |

每个平台目录包含：

```text
drafts/
final/
assets/
retros/
samples/
scripts/
predictions/
```

## 第三方 Skill

本项目同步以下第三方开源 Skill 源码，并保留原许可证和来源说明。

| Skill | 来源 | 用途 |
|---|---|---|
| `frontend-slides` | `zarazhangrui/frontend-slides` | HTML 幻灯片、视频辅助画面、流程演示、复杂概念可视化 |
| `cheat-on-content` | `XBuilderLAB/cheat-on-content` | 内容评分、发布前预测、发布后复盘、规则迭代 |
| `baoyu-skills` | `JimLiu/baoyu-skills` | 图文图片卡片、信息图、内容生成相关 Skill |

源码位置：

```text
third-party/skills/frontend-slides/
third-party/skills/cheat-on-content/
third-party/skills/baoyu-skills/
```

第三方 Skill 的版权归原作者所有。同步、修改和再分发时应遵守 `third-party/sync-policy.md`。

## 使用示例

推荐选题前：

```text
请先读取 AGENTS.md、Learning.md、创作者配置、内容主线和目标平台规则，然后使用 templates/topic-check.md 检查这个选题是否值得做。
```

写图文前：

```text
请基于 platform-b 规则写一版图文草稿，并在写完后使用 templates/image-post-hook-check.md 检查标题、首图、前两行正文和多图结构。
```

写视频口播前：

```text
请基于 platform-c 规则写一版口播稿，并单独检查前三秒是否有冲突、反差、后果或真实卡点。
```

复盘后：

```text
请使用 templates/retro-template.md 复盘这条内容，并判断是否有经验需要写入 Learning.md。
```

## 隐私与脱敏

公开发布前，应使用以下文件检查：

- `privacy/redaction-checklist.md`
- `privacy/forbidden-information.md`
- `privacy/pre-publish-scan.md`

也可以运行隐私扫描脚本：

```bash
bash scripts/privacy-scan.sh
```

如需同时扫描第三方源码：

```bash
bash scripts/privacy-scan.sh --include-third-party
```

如需扫描自己的姓名、账号、机构或私有项目名：

```bash
PRIVACY_EXTRA_PATTERN="姓名A|账号A|机构A|项目A" bash scripts/privacy-scan.sh
```

除项目作者明确选择公开的信息外，默认不得公开：

- 真实姓名、账号、电话、邮箱、地址。
- 客户、当事人、案号、合同、聊天记录。
- 平台后台数据、真实表现数据、未发布草稿。
- token、cookie、secret、auth、API key。
- 未授权文章、图片、视频和文风样本原文。

所有真实信息应使用占位符：

```text
<创作者名称>
<平台A>
<平台B>
<平台C>
<内容主线A>
<项目A>
<SkillA>
<隐私信息>
```

## 关于作者

潘睿律师 - 热衷于将 AI 技术应用于法律实务。

个人官网：[https://www.panrui.xyz/](https://www.panrui.xyz/)

欢迎添加微信交流（请注明来意）：

<img src="assets/wechat-qr.png" alt="潘睿律师微信二维码" width="260">

## License

本项目自有模板和方法论文档使用 MIT License。

第三方目录中的 Skill 保留原项目许可证和版权声明。
