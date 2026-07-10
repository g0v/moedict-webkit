# moedict-webkit

# ⚠️ Frozen

**This repository no longer builds dictionary packs.** Pack generation lives in
[`g0v/moedict-process`](https://github.com/g0v/moedict-process) (`bun run pack`;
see its `docs/pack-format-contract.md`). The files here are the frozen
static-frontend source for **www.moedict.org**, served from this repo's
`gh-pages` branch. Do NOT archive or rename this repo — gh-pages is the live
serving surface.

萌典 (moedict.org) 靜態前端的源碼庫（凍結維護）。

## 專案概述

- **語言**: LiveScript (.ls)、JavaScript、Sass/SCSS、Jade 模板
- **框架**: React 0.14、Webpack、Gulp
- **字典資料**: 由 `g0v/moedict-process` 產生後同步至 gh-pages 與 R2

## 常用指令

```sh
# 安裝相依套件
npm i

# 開發模式 (含 watch)
gulp dev

# 啟動靜態伺服器
gulp run

# 建置生產版本
gulp build
```

## 專案架構

- `main.ls` — 主程式入口
- `view.ls` — React 視圖元件
- `gulpfile.ls` — Gulp 建置設定
- `webpack.config.js` — Webpack 設定
- `sass/` — SCSS 樣式
- `js/` — 編譯後的 JS
- `css/` — 編譯後的 CSS
- `a/`, `t/`, `h/`, `c/` — 各字典的 pack 資料目錄（gh-pages 服務資料；由
  moedict-process 重新產生，不在此 repo 建置）

## 開發注意事項

- 主要邏輯使用 **LiveScript** 撰寫，編譯至 JavaScript
- 樣式使用 **Sass/SCSS**，透過 gulp-dart-sass 編譯
- 模板使用 **Jade**
- 檔案系統限制已解除：pack 產生流程移至 moedict-process 後，不再需要 HFS+
- 資料建置（pack、索引、翻譯）一律在 `g0v/moedict-process` 進行

## 歷史

2026-07-10 起，本 repo 的 pack 產生工具鏈（`json2prefix.ls`、`autolink.ls`、
`worker.ls`、`link2pack.pl`、`special2pack.pl`、`sort-json.pl`、
`cat2special.ls`、`twblg_index.py`、`build-pinyin-lookup.pl`、
`translation-data/*.py`）與 ZappaJS 伺服器（`server.ls`）已退役，由
`g0v/moedict-process`（pack 管線）與 `g0v/moedict.tw`（搜尋/拼音索引、R2
上傳）接手。
