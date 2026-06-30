#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

copy_if_missing() {
  local source="$1"
  local target="$2"

  if [[ ! -f "$source" ]]; then
    echo "Missing template: $source" >&2
    return 1
  fi

  if [[ -e "$target" ]]; then
    echo "Skip existing: $target"
  else
    cp "$source" "$target"
    echo "Created: $target"
  fi
}

echo "正在初始化 Agent Content Workspace..."

copy_if_missing "AGENTS.template.md" "AGENTS.md"
copy_if_missing "Learning.template.md" "Learning.md"

copy_if_missing "config/creator-profile.template.md" "config/creator-profile.md"
copy_if_missing "config/content-pillars.template.md" "config/content-pillars.md"
copy_if_missing "config/platform-a-rules.template.md" "config/platform-a-rules.md"
copy_if_missing "config/platform-b-rules.template.md" "config/platform-b-rules.md"
copy_if_missing "config/platform-c-rules.template.md" "config/platform-c-rules.md"
copy_if_missing "config/style-preferences.template.md" "config/style-preferences.md"
copy_if_missing "config/visual-rules.template.md" "config/visual-rules.md"
copy_if_missing "config/privacy-rules.template.md" "config/privacy-rules.md"
copy_if_missing "config/agent-prompt.template.md" "config/agent-prompt.md"

mkdir -p \
  platforms/platform-a/{drafts,final,assets,retros,samples,scripts,predictions} \
  platforms/platform-b/{drafts,final,assets,retros,samples,scripts,predictions} \
  platforms/platform-c/{drafts,final,assets,retros,samples,scripts,predictions}

echo
echo "欢迎使用 Agent Content Workspace。"
echo
echo "第一次使用时，不需要先研究所有文件。"
echo "请让 Agent 像聊天一样，一次只问你一个问题。"
echo "你回答后，Agent 会把答案整理进配置文件，然后再问下一个问题。"
echo
echo "你可以先这样对 Agent 说："
echo "  请先问我第一个问题，帮我一步一步完成工作区配置。"
echo
echo "Agent 应该先问："
echo "  你的创作者身份是什么？"
echo
echo "等你回答后，Agent 再继续问："
echo "  你的受众是谁？"
echo "  你有什么样的内容想法？"
echo "  你准备在哪些平台发布？"
echo "  每个平台希望怎么写？"
echo "  你喜欢什么文风？"
echo "  视觉素材怎么处理？"
echo "  哪些信息不能公开？"
echo "  是否要开启外部样本文风学习？"
echo
echo "配置完成后，可以检查这些文件："
echo "- config/creator-profile.md"
echo "- config/content-pillars.md"
echo "- config/platform-a-rules.md"
echo "- config/platform-b-rules.md"
echo "- config/platform-c-rules.md"
echo "- config/style-preferences.md"
echo "- config/visual-rules.md"
echo "- config/privacy-rules.md"
echo "- Learning.md"
echo
echo "如需采集微信公众号、X / Twitter、小红书或抖音链接，请运行："
echo "  bash scripts/setup-capture.sh"
