#!/usr/bin/env node
import { chromium } from 'playwright';
import { createWriteStream } from 'node:fs';
import { mkdir, writeFile } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const ROOT_DIR = path.resolve(__dirname, '..');

const args = process.argv.slice(2);
const url = readPositionalArgs()[0];
const options = {
  platform: readOption('--platform'),
  outputRoot: path.resolve(ROOT_DIR, readOption('--output') || 'samples/style-sources'),
  cardRoot: path.resolve(ROOT_DIR, readOption('--cards') || 'samples/style-cards'),
  headless: args.includes('--headless'),
  waitMs: Number(readOption('--wait-ms') || 12000),
};

if (!url || args.includes('--help')) {
  printHelp();
  process.exit(url ? 0 : 1);
}

const platform = options.platform || detectPlatform(url);
if (!platform) {
  throw new Error(`Unsupported link: ${url}`);
}

const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
const runDir = path.join(options.outputRoot, platform, timestamp);
await mkdir(runDir, { recursive: true });
await mkdir(options.cardRoot, { recursive: true });

let result;
if (platform === 'wechat') {
  result = await captureWechat(url, runDir);
} else if (platform === 'twitter') {
  result = await captureBrowserText(url, runDir, 'twitter');
} else if (platform === 'xhs') {
  result = await captureBrowserText(url, runDir, 'xhs', { screenshot: true });
} else if (platform === 'douyin') {
  result = await captureDouyin(url, runDir);
} else {
  throw new Error(`Unsupported platform: ${platform}`);
}

const cardPath = path.join(options.cardRoot, `${timestamp}-${platform}.md`);
await writeFile(cardPath, buildStyleCard(result), 'utf8');

console.log('Capture complete.');
console.log(`Source folder: ${path.relative(ROOT_DIR, runDir)}`);
console.log(`Style card: ${path.relative(ROOT_DIR, cardPath)}`);

function readOption(name) {
  const index = args.indexOf(name);
  if (index === -1) return '';
  return args[index + 1] || '';
}

function readPositionalArgs() {
  const values = [];
  const optionsWithValue = new Set(['--platform', '--wait-ms', '--output', '--cards']);

  for (let index = 0; index < args.length; index += 1) {
    const arg = args[index];
    if (optionsWithValue.has(arg)) {
      index += 1;
    } else if (!arg.startsWith('--')) {
      values.push(arg);
    }
  }

  return values;
}

function detectPlatform(rawUrl) {
  const host = new URL(rawUrl).hostname.toLowerCase();
  if (host.includes('mp.weixin.qq.com')) return 'wechat';
  if (host === 'x.com' || host.endsWith('.x.com') || host.includes('twitter.com')) return 'twitter';
  if (host.includes('xiaohongshu.com') || host.includes('xhslink.com')) return 'xhs';
  if (host.includes('douyin.com')) return 'douyin';
  return '';
}

function printHelp() {
  console.log(`Usage:
  node scripts/capture-source.mjs "<link>"

Options:
  --platform wechat|twitter|xhs|douyin  Force platform detection.
  --headless                            Run browser without UI.
  --wait-ms <ms>                        Browser wait time after opening page.
  --output <dir>                        Source output root.
  --cards <dir>                         Style card output root.
`);
}

async function captureWechat(rawUrl, runDir) {
  const outputPath = path.join(runDir, 'article.md');
  const fetchScript = path.join(ROOT_DIR, 'skills/wechat-article-capture/scripts/fetch.js');

  if (!existsSync(fetchScript)) {
    throw new Error('Missing skills/wechat-article-capture/scripts/fetch.js');
  }

  await runCommand('node', [fetchScript, rawUrl, outputPath], ROOT_DIR);
  const metadata = {
    platform: '微信公众号',
    url: rawUrl,
    title: path.basename(outputPath, '.md'),
    sourcePath: outputPath,
    captureMethod: 'skills/wechat-article-capture',
    rawMaterial: 'article markdown',
  };
  await writeJson(path.join(runDir, 'metadata.json'), metadata);
  return metadata;
}

async function captureBrowserText(rawUrl, runDir, platformName, extra = {}) {
  const browser = await chromium.launch({ headless: options.headless });
  const context = await browser.newContext({
    userAgent: defaultUserAgent(),
    viewport: { width: 1366, height: 900 },
  });
  const page = await context.newPage();

  try {
    await page.goto(rawUrl, { waitUntil: 'domcontentloaded', timeout: 90000 });
    await page.waitForTimeout(options.waitMs);

    const data = await page.evaluate(() => {
      const title = document.title || '';
      const metaDescription = document.querySelector('meta[name="description"]')?.content || '';
      const h1 = document.querySelector('h1')?.innerText || '';
      const bodyText = document.body?.innerText || '';
      return {
        title: h1 || title,
        metaDescription,
        text: bodyText.replace(/\n{3,}/g, '\n\n').trim().slice(0, 20000),
      };
    });

    const textPath = path.join(runDir, 'page-text.txt');
    await writeFile(textPath, data.text, 'utf8');

    let screenshotPath = '';
    if (extra.screenshot) {
      screenshotPath = path.join(runDir, 'page.png');
      await page.screenshot({ path: screenshotPath, fullPage: true });
    }

    const metadata = {
      platform: platformName === 'twitter' ? 'X / Twitter' : '小红书',
      url: rawUrl,
      title: data.title,
      description: data.metaDescription,
      sourcePath: textPath,
      screenshotPath,
      captureMethod: 'playwright browser page text',
      rawMaterial: screenshotPath ? 'page text and screenshot' : 'page text',
    };
    await writeJson(path.join(runDir, 'metadata.json'), metadata);
    return metadata;
  } finally {
    await browser.close();
  }
}

async function captureDouyin(rawUrl, runDir) {
  const browser = await chromium.launch({ headless: options.headless });
  const context = await browser.newContext({
    userAgent: defaultUserAgent(),
    viewport: { width: 1366, height: 900 },
  });
  const page = await context.newPage();
  const mediaUrls = [];

  page.on('request', (request) => {
    const requestUrl = request.url();
    if (isMp4Candidate(requestUrl)) mediaUrls.push(requestUrl);
  });

  page.on('response', (response) => {
    const responseUrl = response.url();
    const contentType = response.headers()['content-type'] || '';
    if (isMp4Candidate(responseUrl) || contentType.includes('video/mp4')) {
      mediaUrls.push(responseUrl);
    }
  });

  try {
    await page.goto(rawUrl, { waitUntil: 'domcontentloaded', timeout: 90000 });
    await page.waitForTimeout(4000);
    await clickPlayIfVisible(page);
    await page.waitForTimeout(options.waitMs);

    const pageInfo = await page.evaluate(() => ({
      title: document.title || document.querySelector('[data-e2e="video-desc"]')?.textContent?.trim() || '',
      text: document.body?.innerText?.replace(/\n{3,}/g, '\n\n').trim().slice(0, 12000) || '',
    }));

    const uniqueUrls = [...new Set(mediaUrls)].filter(isMp4Candidate);
    const mp4Url = uniqueUrls[0];
    if (!mp4Url) {
      await writeJson(path.join(runDir, 'captured-media-urls.json'), uniqueUrls);
      throw new Error('No MP4 media request captured from Douyin page.');
    }

    const infoPath = path.join(runDir, 'page-text.txt');
    await writeFile(infoPath, pageInfo.text, 'utf8');
    await writeJson(path.join(runDir, 'captured-media-urls.json'), uniqueUrls);

    const mp4Path = path.join(runDir, 'source.mp4');
    await downloadFile(mp4Url, mp4Path, {
      referer: 'https://www.douyin.com/',
      userAgent: defaultUserAgent(),
    });

    const wavPath = path.join(runDir, 'audio.wav');
    await runCommand('ffmpeg', ['-y', '-i', mp4Path, '-ar', '16000', '-ac', '1', '-c:a', 'pcm_s16le', wavPath], ROOT_DIR);

    const transcriptPath = await transcribeAudio(wavPath, runDir);

    const metadata = {
      platform: '抖音',
      url: rawUrl,
      title: pageInfo.title,
      sourcePath: infoPath,
      mp4Path,
      audioPath: wavPath,
      transcriptPath,
      captureMethod: 'playwright media request interception -> mp4 download -> ffmpeg -> whisper',
      rawMaterial: 'mp4, wav, transcript',
    };
    await writeJson(path.join(runDir, 'metadata.json'), metadata);
    return metadata;
  } finally {
    await browser.close();
  }
}

function isMp4Candidate(candidateUrl) {
  return candidateUrl.includes('mime_type=video_mp4') ||
    candidateUrl.includes('video_mp4') ||
    candidateUrl.includes('douyinvod.com') ||
    candidateUrl.includes('.mp4');
}

async function clickPlayIfVisible(page) {
  const selectors = [
    'button[aria-label*="播放"]',
    '.xgplayer-play',
    'div[class*="play"]',
    'button[class*="play"]',
    'video',
  ];
  for (const selector of selectors) {
    try {
      const locator = page.locator(selector).first();
      if (await locator.isVisible({ timeout: 1500 })) {
        await locator.click({ timeout: 1500, force: true });
        return;
      }
    } catch {
      // Try the next selector.
    }
  }
}

async function downloadFile(rawUrl, targetPath, headers) {
  const response = await fetch(rawUrl, {
    headers: {
      Referer: headers.referer,
      'User-Agent': headers.userAgent,
    },
  });
  if (!response.ok) {
    throw new Error(`Download failed: ${response.status} ${response.statusText}`);
  }
  await mkdir(path.dirname(targetPath), { recursive: true });
  const stream = createWriteStream(targetPath);
  await new Promise((resolve, reject) => {
    response.body.pipeTo(new WritableStream({
      write(chunk) {
        stream.write(Buffer.from(chunk));
      },
      close() {
        stream.end(resolve);
      },
      abort(error) {
        stream.destroy(error);
        reject(error);
      },
    })).catch(reject);
  });
}

async function transcribeAudio(wavPath, runDir) {
  if (await commandExists('whisper-cli')) {
    const model = process.env.WHISPER_MODEL || process.env.WHISPER_CPP_MODEL || '';
    if (model) {
      const outputBase = path.join(runDir, 'transcript');
      await runCommand('whisper-cli', ['-m', model, '-l', 'zh', '-f', wavPath, '-otxt', '-of', outputBase], ROOT_DIR);
      return `${outputBase}.txt`;
    }
  }

  if (await hasPythonModule('faster_whisper')) {
    const script = [
      'from faster_whisper import WhisperModel',
      'import sys',
      'audio, out = sys.argv[1], sys.argv[2]',
      'model = WhisperModel("base", device="cpu", compute_type="int8")',
      'segments, info = model.transcribe(audio, language="zh")',
      'open(out, "w", encoding="utf-8").write("\\n".join(s.text.strip() for s in segments))',
    ].join('\n');
    const transcriptPath = path.join(runDir, 'transcript.txt');
    await runCommand('python3', ['-c', script, wavPath, transcriptPath], ROOT_DIR);
    return transcriptPath;
  }

  const notePath = path.join(runDir, 'transcript.txt');
  await writeFile(notePath, '未转写：未检测到 whisper-cli 或 faster-whisper。\n', 'utf8');
  return notePath;
}

async function hasPythonModule(moduleName) {
  try {
    await runCommand('python3', ['-c', `import ${moduleName}`], ROOT_DIR, { silent: true });
    return true;
  } catch {
    return false;
  }
}

async function commandExists(command) {
  try {
    await runCommand('bash', ['-lc', `command -v ${command}`], ROOT_DIR, { silent: true });
    return true;
  } catch {
    return false;
  }
}

function runCommand(command, commandArgs, cwd, extra = {}) {
  return new Promise((resolve, reject) => {
    const child = spawn(command, commandArgs, {
      cwd,
      stdio: extra.silent ? 'ignore' : 'inherit',
      env: process.env,
    });
    child.on('error', reject);
    child.on('close', (code) => {
      if (code === 0) resolve();
      else reject(new Error(`${command} exited with code ${code}`));
    });
  });
}

async function writeJson(filePath, data) {
  await writeFile(filePath, `${JSON.stringify(toRelativePaths(data), null, 2)}\n`, 'utf8');
}

function toRelativePaths(value) {
  if (Array.isArray(value)) return value.map(toRelativePaths);
  if (value && typeof value === 'object') {
    return Object.fromEntries(Object.entries(value).map(([key, item]) => [key, toRelativePaths(item)]));
  }
  if (typeof value === 'string' && value.startsWith(ROOT_DIR)) {
    return path.relative(ROOT_DIR, value);
  }
  return value;
}

function buildStyleCard(data) {
  return `# 文风卡

## 基本信息

- 样本名称：${data.title || '<待填写>'}
- 来源平台：${data.platform}
- 原始链接：${data.url}
- 采集时间：${new Date().toISOString()}
- 采集方式：${data.captureMethod}
- 原始素材：${data.rawMaterial}
- 原始素材位置：${data.sourcePath ? path.relative(ROOT_DIR, data.sourcePath) : ''}
- 视频位置：${data.mp4Path ? path.relative(ROOT_DIR, data.mp4Path) : ''}
- 音频位置：${data.audioPath ? path.relative(ROOT_DIR, data.audioPath) : ''}
- 转写位置：${data.transcriptPath ? path.relative(ROOT_DIR, data.transcriptPath) : ''}

## 一、适合学习

- 标题方式：
- 开头方式：
- 结构节奏：
- 句子长度：
- 情绪曲线：
- 视觉组织：
- 视频前三秒钩子：
- 结尾方式：

## 二、不适合学习

- 不应复制的表达：
- 不适合当前创作者的部分：
- 风险点：

## 三、可复用结构

1. <结构步骤A>
2. <结构步骤B>
3. <结构步骤C>

## 四、禁用点

- 不直接复制原句。
- 不保留他人独特表达。
- 不使用未授权图片、原文、截图、视频或音频。
`;
}

function defaultUserAgent() {
  return 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
}
