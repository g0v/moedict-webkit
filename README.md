這是 <https://amis.moedict.tw/> 線上及離線查詢 App 的源碼庫。

## 需求

* Node.js v6+
* Perl 5.8.0+
* Python
* Ruby
* Gulp

## 安裝環境

```sh
npm i
make amis
make amis-poinsot
make amis-safolu
```

## 本機運行

```
make dev
```

相關設定檔案請看

* gulpfile.js
* webpack.config.js

## Deploy production 步驟

如果只有改到 js

```
$ make js/deps.js
更新 amis-deploy/manifest.appcache 這個檔案第二行的時間
$ git add .
$ git commit -m 'Update js/deps.js and amis-deploy/manifest.appcache in amis-deploy'
$ git push
```

如果有改到字典檔案，如更新蔡中涵字典

```
$ make amis-static
更新 amis-deploy/manifest.appcache 這個檔案第二行的時間
$ git add .
$ git commit -m 'Update js/deps.js and amis-deploy/manifest.appcache in amis-deploy'
$ git push
```

# CC0 1.0 公眾領域貢獻宣告

除前述資料檔之外，本目錄下的所有其他檔案，由作者 唐鳳 在法律
許可的範圍內，拋棄該著作依著作權法所享有之權利，包括所有相關
與鄰接的法律權利，並宣告將該著作貢獻至公眾領域。

* <https://creativecommons.org/publicdomain/zero/1.0/deed.zh_TW>
* <http://wiki.creativecommons.org.tw/cc-zero-1-0:pre-final>
