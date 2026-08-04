#!/usr/bin/env bash
# TechGuide 内容回归测试
# 断言: instructions.md 的教学规则约束、模板章节要求、init-notes.sh 行为。
# 用法: bash tests/check-content.sh
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

fail=0
pass() { echo "PASS: $1"; }
fails() { echo "FAIL: $1"; fail=1; }
assert() { # assert <描述> <命令...>
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then pass "$desc"; else fails "$desc"; fi
}
assert_not() { # assert_not <描述> <命令...>  （命令应失败）
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then fails "$desc"; else pass "$desc"; fi
}

echo "== 1. instructions.md 教学规则约束 =="
assert "instructions.md 含练习主线（不可跳过）" \
  grep -q "练习" "$root/instructions.md"
assert "instructions.md 声明练习不可跳过/不可降级" \
  grep -q "不可跳过" "$root/instructions.md"
assert "instructions.md 要求用户先自己写" \
  grep -q "用户先自己写" "$root/instructions.md"
assert "instructions.md 禁止编造（证据纪律）" \
  grep -q "编造" "$root/instructions.md"
assert "instructions.md 要求标注证据/出处" \
  grep -q "证据" "$root/instructions.md"
assert "instructions.md 按领域逐个讲解" \
  grep -q "按领域逐个讲解" "$root/instructions.md"
assert "instructions.md 练习记录分散到各领域章节末尾" \
  grep -q "分散到各领域章节末尾" "$root/instructions.md"
assert "instructions.md 规定中断恢复流程" \
  grep -q "学习恢复" "$root/instructions.md"

echo "== 2. 模板章节要求 =="
for t in 技术全景 核心概念词典 主题笔记 个人总结 速查表; do
  f="$root/assets/templates/$t.md"
  assert "模板 $t.md 存在且含 tech-guide front matter" \
    grep -q "tags: \[tech-guide, learning\]" "$f"
  assert "模板 $t.md 含 progress 字段" \
    grep -q "^progress: Phase 1" "$f"
done
assert "主题笔记模板含练习记录小节" \
  grep -q "练习记录" "$root/assets/templates/主题笔记.md"
assert "主题笔记模板按领域分章（## 领域）" \
  grep -q "^## 领域" "$root/assets/templates/主题笔记.md"
assert "主题笔记模板练习记录在领域章内（### 练习记录）" \
  grep -q "^### 练习记录" "$root/assets/templates/主题笔记.md"
assert "主题笔记练习记录嵌套在各领域章节内" \
  awk '/^## /{s=$0} /^### 练习记录/{if (s ~ /^## 领域/) ok=1} END{exit !ok}' \
  "$root/assets/templates/主题笔记.md"
assert "核心概念词典模板含所属领域列" \
  grep -q "所属领域" "$root/assets/templates/核心概念词典.md"
assert "技术全景模板含领域清单" \
  grep -q "领域清单" "$root/assets/templates/技术全景.md"
assert "速查表模板按领域分节" \
  grep -q "^## 领域" "$root/assets/templates/速查表.md"

echo "== 3. init-notes.sh 行为 =="
cd "$tmp"

assert "合法主题名创建成功" "$root/scripts/init-notes.sh" "test-topic"
for t in 技术全景 核心概念词典 主题笔记 个人总结 速查表; do
  assert "创建 $t.md" test -f "$tmp/notes/test-topic/$t.md"
done
assert_not "无占位符残留（{{topic-name}}/{{date}}）" \
  grep -rq "{{" "$tmp/notes/test-topic"
assert "front matter 占位符已替换为实际值" \
  grep -q "topic: \"test-topic\"" "$tmp/notes/test-topic/技术全景.md"

count_before="$(find "$tmp/notes/test-topic" -type f | wc -l | tr -d ' ')"
"$root/scripts/init-notes.sh" "test-topic" >/dev/null 2>&1
count_after="$(find "$tmp/notes/test-topic" -type f | wc -l | tr -d ' ')"
if [ "$count_before" = "$count_after" ] && [ "$count_after" = 5 ]; then
  pass "二次运行不覆盖（仍为 5 份）"
else
  fails "二次运行不覆盖（before=$count_before after=$count_after）"
fi

assert_not "拒绝非法主题名: ../x" "$root/scripts/init-notes.sh" "../x"
assert_not "拒绝非法主题名: ." "$root/scripts/init-notes.sh" "."
assert_not "拒绝非法主题名: .." "$root/scripts/init-notes.sh" ".."
assert_not "拒绝非法主题名: a/b（路径穿越）" "$root/scripts/init-notes.sh" "a/b"
assert "非法主题名不写出 notes/ 之外" \
  test ! -e "$(cd "$tmp/.." && pwd)/x"

echo "== 4. skill.json 合法性 =="
assert "skill.json 是合法 JSON" \
  python3 -c "import json; json.load(open('$root/skill.json'))"

echo ""
if [ "$fail" -eq 0 ]; then
  echo "全部通过。"
  exit 0
else
  echo "存在失败项。"
  exit 1
fi
