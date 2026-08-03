---
name: tech-guide
description: 技术学习私教。跨平台技术学习工作流：输入自由主题（如"写爬虫""自动化脚本"），通过引导式对话（概念讲解 + 动手练习 + 结构化笔记）引导用户真正掌握一门新技术。触发场景：用户想学习/掌握/系统了解某门技术（无现成代码库）。使用方法：先完整阅读 instructions.md。
---

# TechGuide — 技术学习私教

> 本文件是 Codex / Claude Code 的入口。**所有教学规则见 [instructions.md](./instructions.md)**，请先完整阅读该文件再开始任何教学动作，不要凭本文件猜测规则。

## 启动步骤

1. 阅读并严格遵循 `instructions.md` 中的五阶段工作流与交互纪律。
2. 进入 Phase 1 时用脚本初始化笔记（在调用目录执行）：

```bash
/path/to/tech-guide/scripts/init-notes.sh <topic-name>
```

3. 笔记输出到**调用目录**的 `notes/<topic-name>/`（5 份 Markdown，可导入 Obsidian）。

## 元信息

- 平台入口：Codex / Claude Code 读本文件；Trae 读 `skill.json`；所有平台共享 `instructions.md`。
- 教学规则唯一来源：`instructions.md`（本文件不重复任何教学规则）。
