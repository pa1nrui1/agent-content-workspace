# 发布前扫描说明

公开发布前，应进行关键词扫描和人工复核。

## 示例命令

```bash
rg -n "<真实姓名>|<账号名>|<本地路径>|手机号|微信|邮箱|身份证|客户|当事人|案号|token|secret|cookie|auth|Authorization"
```

也可以使用仓库内置脚本：

```bash
bash scripts/privacy-scan.sh
```

如需扫描自己的姓名、账号、机构或私有项目名，可以使用：

```bash
PRIVACY_EXTRA_PATTERN="姓名A|账号A|机构A|项目A" bash scripts/privacy-scan.sh
```

## 检查范围

建议扫描：

- README
- AGENTS
- Learning
- config
- methods
- templates
- hooks
- examples
- third-party NOTICE

同时确认以下路径没有被提交：

- `samples/style-sources/`
- `samples/style-cards/`
- `captures/`
- `downloads/`
- `media/`
- `audio/`
- `transcripts/`
- `.auth/`
- `.capture-browser-profile/`
- `browser-profile/`

## 注意事项

扫描只能发现显性风险，不能替代人工判断。

截图、图片、PDF、视频仍需人工检查。

如果扫描结果涉及第三方许可证或致谢信息，应区分正常来源说明和敏感信息泄露。
