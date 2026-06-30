# 第三方工具源码

本目录保存外部样本采集流程使用到的第三方工具源码。

这些工具保留原项目许可证，不适用本仓库根目录的 MIT License。

| 工具 | 来源 | 许可证 | 用途 |
|---|---|---|---|
| FFmpeg | https://ffmpeg.org/ | LGPL / GPL，见 `ffmpeg/COPYING*` | 将下载的 MP4 转为音频 |
| whisper.cpp | https://github.com/ggml-org/whisper.cpp | MIT，见 `whisper.cpp/LICENSE` | 本地语音转文字 |
| Playwright | https://github.com/microsoft/playwright | Apache-2.0，见 `playwright/LICENSE` | 浏览器自动化和媒体请求捕获 |

运行时仍使用用户本机安装的工具：

```bash
bash scripts/setup-capture.sh
```

同步源码用于透明披露、许可证合规和离线审查。
