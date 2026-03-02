# moedict-webkit

萌典 (moedict.tw) 線上及離線查詢 App 的源碼庫。

## 專案概述

- **語言**: LiveScript (.ls)、JavaScript、Sass/SCSS、Jade 模板
- **框架**: React 0.14、Webpack、Gulp、ZappaJS
- **字典資料**: 教育部國語辭典、台語、客語等多語言辭典

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

# 建置離線檔案
make offline

# 取得字典資料 (git submodules)
make checkout
```

## 專案架構

- `main.ls` — 主程式入口
- `view.ls` — React 視圖元件
- `worker.ls` / `worker.js` — Web Worker
- `server.ls` / `server.js` — ZappaJS 伺服器
- `gulpfile.ls` — Gulp 建置設定
- `webpack.config.js` — Webpack 設定
- `sass/` — SCSS 樣式
- `js/` — 編譯後的 JS
- `css/` — 編譯後的 CSS
- `a/`, `t/`, `h/`, `c/` — 各字典的 pack 資料目錄
- `moedict-data/` — 國語辭典資料 (git clone)
- `moedict-epub/` — 字型轉換工具 (git clone)
- `dict-revised.unicode.json` — 國語辭典 Unicode 版
- `dict-revised.pua.json` — 國語辭典 PUA 版

## 開發注意事項

- 主要邏輯使用 **LiveScript** 撰寫，編譯至 JavaScript
- 樣式使用 **Sass/SCSS**，透過 gulp-dart-sass 編譯
- 模板使用 **Jade**
- macOS 開發環境需使用 HFS+ 檔案系統（High Sierra 以後需手動建立分割區）
- 字典資料檔案（`moedict-data/`、`moedict-epub/` 等）需透過 `make checkout` 另行取得

## 資料建置流程

1. `make checkout` — clone 各語言字典資料
2. `make moedict-data` — 建置字典資料（含 symlinks、pinyin）
3. `make offline` — 建置離線瀏覽所需檔案
