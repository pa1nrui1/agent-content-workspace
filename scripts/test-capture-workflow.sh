#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TEST_ROOT="captures/workflow-test"
SOURCE_ROOT="$TEST_ROOT/sources"
CARD_ROOT="$TEST_ROOT/cards"
TMP_DIR="$(mktemp -d)"
PORT="${CAPTURE_TEST_PORT:-18765}"
SERVER_PID=""

cleanup() {
  if [[ -n "$SERVER_PID" ]]; then
    kill "$SERVER_PID" >/dev/null 2>&1 || true
  fi
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

require_command() {
  local name="$1"
  if ! command -v "$name" >/dev/null 2>&1; then
    echo "Missing command: $name" >&2
    exit 1
  fi
}

require_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "Missing expected file: $file" >&2
    exit 1
  fi
}

require_nonempty_file() {
  local file="$1"
  require_file "$file"
  if [[ ! -s "$file" ]]; then
    echo "Expected non-empty file: $file" >&2
    exit 1
  fi
}

latest_run_dir() {
  local platform="$1"
  find "$SOURCE_ROOT/$platform" -mindepth 1 -maxdepth 1 -type d | sort | tail -1
}

run_capture() {
  local platform="$1"
  local title="$2"
  local path_name="$3"

  node scripts/capture-source.mjs \
    --platform "$platform" \
    --headless \
    --wait-ms 500 \
    --output "$SOURCE_ROOT" \
    --cards "$CARD_ROOT" \
    --fixture-title "$title" \
    "http://127.0.0.1:$PORT/$path_name"
}

require_command node
require_command python3
require_command ffmpeg

rm -rf "$TEST_ROOT"
mkdir -p "$SOURCE_ROOT" "$CARD_ROOT"

cat > "$TMP_DIR/wechat.html" <<'HTML'
<!doctype html>
<html>
<head><meta charset="utf-8"><title>测试公众号文章</title></head>
<body>
  <div id="js_content">
    <h1>测试公众号文章</h1>
    <p>这是用于验证微信公众号抓取流程的本地页面。</p>
    <p>标题、正文和结构用于生成文风卡。</p>
  </div>
</body>
</html>
HTML

cat > "$TMP_DIR/twitter.html" <<'HTML'
<!doctype html>
<html>
<head><meta charset="utf-8"><title>测试 X 内容</title><meta name="description" content="测试描述"></head>
<body>
  <h1>测试 X 内容</h1>
  <p>这是用于验证浏览器打开和文本保存的公开内容。</p>
</body>
</html>
HTML

cat > "$TMP_DIR/xhs.html" <<'HTML'
<!doctype html>
<html>
<head><meta charset="utf-8"><title>测试小红书内容</title></head>
<body>
  <h1>测试小红书内容</h1>
  <p>这是用于验证页面文本和截图保存的公开内容。</p>
</body>
</html>
HTML

ffmpeg -y \
  -f lavfi -i testsrc=size=320x180:rate=10 \
  -f lavfi -i sine=frequency=1000:duration=2 \
  -shortest \
  -c:v libx264 \
  -pix_fmt yuv420p \
  -c:a aac \
  "$TMP_DIR/source.mp4" >/dev/null 2>&1

cat > "$TMP_DIR/douyin.html" <<'HTML'
<!doctype html>
<html>
<head><meta charset="utf-8"><title>测试抖音视频标题</title></head>
<body>
  <h1 data-e2e="video-desc">测试抖音视频标题</h1>
  <video src="/source.mp4" controls autoplay muted></video>
</body>
</html>
HTML

python3 -m http.server "$PORT" --directory "$TMP_DIR" >/tmp/agent-content-workspace-capture-test.log 2>&1 &
SERVER_PID="$!"
sleep 1

run_capture wechat "测试公众号文章" wechat.html
run_capture twitter "测试 X 内容" twitter.html
run_capture xhs "测试小红书内容" xhs.html

if [[ -n "${WHISPER_MODEL:-}${WHISPER_CPP_MODEL:-}" ]]; then
  run_capture douyin "测试抖音视频标题" douyin.html
else
  if [[ -f "third-party/tools/whisper.cpp/models/for-tests-ggml-tiny.bin" ]]; then
    WHISPER_MODEL="third-party/tools/whisper.cpp/models/for-tests-ggml-tiny.bin" run_capture douyin "测试抖音视频标题" douyin.html
  else
    run_capture douyin "测试抖音视频标题" douyin.html
  fi
fi

WECHAT_DIR="$(latest_run_dir wechat)"
TWITTER_DIR="$(latest_run_dir twitter)"
XHS_DIR="$(latest_run_dir xhs)"
DOUYIN_DIR="$(latest_run_dir douyin)"

require_nonempty_file "$WECHAT_DIR/article.md"
require_nonempty_file "$WECHAT_DIR/metadata.json"
require_nonempty_file "$TWITTER_DIR/page-text.txt"
require_nonempty_file "$TWITTER_DIR/metadata.json"
require_nonempty_file "$XHS_DIR/page-text.txt"
require_file "$XHS_DIR/page.png"
require_nonempty_file "$DOUYIN_DIR/source.mp4"
require_nonempty_file "$DOUYIN_DIR/audio.wav"
require_file "$DOUYIN_DIR/transcript.txt"
require_nonempty_file "$DOUYIN_DIR/captured-media-urls.json"

CARD_COUNT="$(find "$CARD_ROOT" -type f -name '*.md' | wc -l | tr -d ' ')"
if [[ "$CARD_COUNT" -lt 4 ]]; then
  echo "Expected at least 4 style cards, got $CARD_COUNT" >&2
  exit 1
fi

echo
echo "Capture workflow test passed."
echo "Verified:"
echo "- WeChat article capture"
echo "- X / Twitter browser text capture"
echo "- Xiaohongshu browser text and screenshot capture"
echo "- Douyin MP4 download"
echo "- FFmpeg audio conversion"
echo "- Transcript file generation"
