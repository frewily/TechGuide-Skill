#!/usr/bin/env bash
# TechGuide init-notes.sh
# 用法: ./init-notes.sh [--out <dir>] <topic-name>
# 默认在调用目录（当前工作目录）创建 notes/<topic-name>/ 下的 5 份笔记，
# 也可用 --out <dir> 指定输出目录；从本包 assets/templates 复制并替换占位符。
# 安全保证: 主题名校验、不覆盖已有笔记、原子写入、兼容 macOS / Linux。
set -euo pipefail

usage() {
  echo "用法: $0 [--out <dir>] <topic-name>" >&2
  echo "  默认输出到当前工作目录；--out <dir> 指定输出目录" >&2
  echo "  topic-name 仅允许 [A-Za-z0-9._-]，且不能是 . 或 .." >&2
  exit 1
}

# --- 1. 解析参数 ---
out_dir="$(pwd)"
if [ "$#" -ge 1 ] && [ "$1" = "--out" ]; then
  if [ "$#" -lt 3 ]; then
    usage
  fi
  out_dir="$2"
  shift 2
fi

if [ "$#" -ne 1 ]; then
  usage
fi
topic="$1"

case "$topic" in
  "" | "." | ".." | */*)
    echo "错误: 非法主题名 '$topic'" >&2
    usage
    ;;
esac

if ! printf '%s' "$topic" | grep -Eq '^[A-Za-z0-9._-]+$'; then
  echo "错误: 主题名包含非法字符 '$topic'" >&2
  usage
fi

# --- 2. 定位模板目录（从脚本自身位置，不依赖调用目录） ---
script_dir="$(cd "$(dirname "$0")" && pwd)"
templates_dir="$script_dir/../assets/templates"

if [ ! -d "$templates_dir" ]; then
  echo "错误: 找不到模板目录 $templates_dir" >&2
  exit 1
fi

# --- 3. 创建输出目录 ---
notes_dir="$out_dir/notes/$topic"
mkdir -p "$notes_dir"

date_str="$(date +%F)"
n_created=0
n_skipped=0

for template in "$templates_dir"/*.md; do
  [ -e "$template" ] || continue
  name="$(basename "$template")"
  dest="$notes_dir/$name"

  if [ -e "$dest" ]; then
    echo "跳过（已存在）: $dest"
    n_skipped=$((n_skipped + 1))
    continue
  fi

  # 原子写入: 临时文件与目标同目录（保证同文件系统）-> sed 替换 -> mv
  tmp="$(mktemp "$notes_dir/.techguide.XXXXXX")"
  sed -e "s/{{topic-name}}/$topic/g" -e "s/{{date}}/$date_str/g" "$template" > "$tmp"
  mv "$tmp" "$dest"
  n_created=$((n_created + 1))
  echo "创建: $dest"
done

echo "完成: 创建 $n_created 份，跳过 $n_skipped 份。笔记目录: $notes_dir"
