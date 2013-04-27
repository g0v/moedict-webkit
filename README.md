這是 http://moedict.tw/ 線上及離線查詢 App 的源碼庫。

來源 JSON 檔由 https://github.com/g0v/moedict-data 提供，
再經由 https://github.com/g0v/moedict-epub/ 造字轉換程式
`json2unicode.pl` 轉為 Unicode 編碼。

`pack`、`a` 及 `t` 資料目錄由 `json2prefix.ls`、
`autolink.ls` 及 `link2pack.pl` 程式產生：

```
lsc autolink.ls > autolinked.txt
perl link2pack.pl
```

`styles.css` 用到的四個字形檔（不得為商業利用）可於此取得：
https://github.com/g0v/moedict-epub/tree/master/fontforge

`precomputed.json` 為「重編國語辭典（修訂本）」的部份詞條清單，
於 2013-02-03 取得，為非營利之教育目的，依著作權法第 50 條，
「以中央或地方機關或公法人之名義公開發表之著作，在合理範圍內，
得重製、公開播送或公開傳輸。」

教育部版權頁：http://dict.revised.moe.edu.tw/htm/sk/ban.htm

其他平台版本、API 及原始資料等，均可在 http://3du.tw/ 取得。

感謝 http://g0v.tw/ 頻道內所有協助開發的朋友們。

# CC0 1.0 公眾領域貢獻宣告

除前述資料檔之外，本目錄下的所有其他檔案，由作者 唐鳳 在法律
許可的範圍內，拋棄該著作依著作權法所享有之權利，包括所有相關
與鄰接的法律權利，並宣告將該著作貢獻至公眾領域。

* <https://creativecommons.org/publicdomain/zero/1.0/deed.zh_TW>
* <http://wiki.creativecommons.org.tw/cc-zero-1-0:pre-final>
