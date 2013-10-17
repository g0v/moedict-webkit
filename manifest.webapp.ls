#!/usr/bin/env lsc -cj
version: \0.1
name: \MoeDict
description: 'MoE Chinese dictionaries including Mandarin, Taiwanese Holok and Hakka.'
launch_path: \/index.html
icons:
  16: \/ffos/icon-16.png
  30: \/ffos/icon-30.png
  32: \/ffos/icon-32.png
  48: \/ffos/icon-48.png
  60: \/ffos/icon-60.png
  90: \/ffos/icon-90.png
  120: \/ffos/icon-120.png
  128: \/ffos/icon-128.png
  256: \/ffos/icon-256.png
installs_allowed_from: [\*]
developer:
  name: 'Audrey Tang'
  url: \https://www.moedict.tw/
locales:
  'zh-TW':
    name: \萌典
    developer: name: \唐鳳
    description: "教育部國語/臺語/客語有聲辭典。"
  'zh-CN':
    name: \萌典
    developer: name: \唐凤
    description: "教育部国语/台语/客语有声辞典。"
default_locale: \zh-TW
