# TechGuide — 技术学习私教

跨平台 Agent Skill（兼容 Trae、Codex、Claude Code）：输入一门技术主题（如"写爬虫""自动化脚本"），通过引导式对话完成从概念理解到动手实践的完整学习，并同步产出结构化 Markdown 笔记（可导入 Obsidian）。

姊妹项目：[RepoGuide](https://github.com/frewily/RepoGuide-Skill)（学已有代码库）。两份 Skill 产出的笔记在同一 Obsidian vault 里风格统一。

## 安装

| 平台 | 入口文件 | 安装方式 |
| --- | --- | --- |
| Trae | `skill.json` | 将本目录注册为 Trae 技能（指向 `skill.json`） |
| Codex | `SKILL.md` | 将本目录作为技能包添加（保留 `assets/`、`scripts/`、`instructions.md`） |
| Claude Code | `SKILL.md` | 将本目录放入 skills 目录 |
| 所有平台 | `instructions.md` | 共享同一份工作流，规则只维护一份 |

## 触发示例

- "我想掌握如何写爬虫"
- "学习自动化脚本，目标是能写定时任务"
- "帮我系统学一下 X 技术，我完全没基础"

## 笔记输出位置

调用 `scripts/init-notes.sh <topic-name>` 后，在**调用目录**下生成：

```text
notes/<topic-name>/
├── 技术全景.md
├── 核心概念词典.md
├── 主题笔记.md
├── 个人总结.md
└── 速查表.md
```

## 开发与测试

```bash
bash tests/check-content.sh
```

内容回归测试：断言 `instructions.md` 的教学规则约束（练习主线、用户先写、证据纪律）、模板章节要求、`init-notes.sh` 行为（创建 5 份笔记、无占位符残留、二次运行不覆盖、拒绝非法主题名）。
