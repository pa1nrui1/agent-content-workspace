# 第三方 Skill

本目录用于记录和同步内容生产工作流中使用的第三方开源 Skill 和第三方工具源码。

第三方 Skill 是本工作区的专业能力模块，用于支持图文图片生成、HTML 视觉演示、内容预测和发布复盘等工作。

第三方工具用于支持外部样本采集、浏览器打开、MP4 下载、音频转换和本地转写。

## 使用原则

1. 第三方 Skill 的版权归原作者所有。
2. 同步第三方 Skill 时必须保留原 LICENSE。
3. 同步第三方 Skill 时必须保留原作者信息和来源链接。
4. 如有本地修改，必须单独说明。
5. 不得同步许可证不允许再分发的内容。
6. `third-party/tools/` 下的工具源码保留原项目许可证，不适用根目录 MIT。

## 当前已同步

- `frontend-slides`：HTML 幻灯片、视频辅助画面、流程演示和复杂概念可视化。
- `cheat-on-content`：内容评分、发布前预测、发布后复盘和规则迭代。
- `baoyu-skills / baoyu-xhs-images`：图文平台图片卡片、封面图、知识卡、流程图和多图内容生成。
- `FFmpeg`：MP4 转音频。
- `whisper.cpp`：本地语音转文字。
- `Playwright`：浏览器自动化和媒体请求捕获。

源码位置：

- `third-party/skills/frontend-slides`
- `third-party/skills/cheat-on-content`
- `third-party/skills/baoyu-skills`
- `third-party/tools/ffmpeg`
- `third-party/tools/whisper.cpp`
- `third-party/tools/playwright`
