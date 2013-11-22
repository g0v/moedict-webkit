這是 <http://moedict.tw/> 線上及離線查詢 App 的源碼庫。

## 需求

* Node.js
    * LiveScript
    * webworker-threads
    * jade
* Perl 5.8.0 以上
* Ruby
    * SASS
    * compass

## 安裝環境

```
sudo npm install -g LiveScript jade
npm install webworker-threads
gem install sass
gem install compass
```

## 建置

## 建置離線檔案

建置離線瀏覽所需要的檔案:

```
make offline
```

## 手動逐步建置

來源 JSON 檔 `dict-revised.unicode.json` 及 `dict-revised.pua.json` 由
<https://github.com/g0v/moedict-data> 提供， 再經由
<https://github.com/g0v/moedict-epub> 造字轉換程式 `json2unicode.pl` 轉為
Unicode 編碼:

```
git clone --depth 1 https://github.com/g0v/moedict-data.git
git clone --depth 1 https://github.com/g0v/moedict-epub.git
cp -v moedict-data/dict-revised.json moedict-epub/
cd moedict-epub
perl json2unicode.pl > dict-revised.unicode.json
perl json2unicode.pl sym-pua.txt > dict-revised.pua.json
```

`pack`、`a` 及 `t` 資料目錄由 `json2prefix.ls`、
`autolink.ls` 及 `link2pack.pl` 程式產生：

```
lsc json2prefix.ls a
lsc autolink.ls a > a.txt
perl link2pack.pl a < a.txt

lsc json2prefix.ls t
lsc autolink.ls t > t.txt
perl link2pack.pl t < t.txt
```

## 本機運行

```
make # runs in http://127.0.0.1:8888/
```

## API 說明

首先請注意，萌典 API 必須去詢問 `https://www.moedict.tw/`，因為這個網址才有開 CORS。不要去訪問 `http://moedict.org/` ，會噴 No 'Access-Control-Allow-Origin' header 的錯誤。

API 的原始資料，請[參考連結](https://g0v.hackpad.com/3du.tw-ZNwaun62BP4)，本段落的說明是參考連結整理後並加上範例。

目前 API 已有 8 個端點，分別是 /a/, /t/, /h/, /c/, /raw/, /uni/, /pua/

### /raw/

原始 json 檔，Big5 區之外的字以造字碼 {[abcd]} 表示。

範例： https://www.moedict.tw/raw/%E8%90%8C

```json
{
  "heteronyms": [
    {
      "bopomofo": "ㄇㄥˊ",
      "bopomofo2": "méng",
      "definitions": [
        {
          "def": "草木初生的芽。",
          "quote": [
            "說文解字：「萌，艸芽也。」",
            "唐．韓愈、劉師服、侯喜、軒轅彌明．石鼎聯句：「秋瓜未落蒂，凍芋強抽萌。」"
          ],
          "type": "名"
        },
        {
          "def": "事物發生的開端或徵兆。",
          "quote": [
            "韓非子．說林上：「聖人見微以知萌，見端以知末。」",
            "漢．蔡邕．對詔問{[9264]}異八事：「以杜漸防萌，則其救也。」"
          ],
          "type": "名"
        },
        {
          "def": "人民。",
          "example": [
            "如：「萌黎」、「萌隸」。"
          ],
          "link": [
            "通「氓」。"
          ],
          "type": "名"
        },
        {
          "def": "姓。如五代時蜀有萌慮。",
          "type": "名"
        },
        {
          "def": "發芽。",
          "example": [
            "如：「萌芽」。"
          ],
          "quote": [
            "楚辭．王逸．九思．傷時：「明風習習兮龢暖，百草萌兮華榮。」"
          ],
          "type": "動"
        },
        {
          "def": "發生。",
          "example": [
            "如：「故態復萌」。"
          ],
          "quote": [
            "管子．牧民：「惟有道者，能備患於未形也，故禍不萌。」",
            "三國演義．第一回：「若萌異心，必獲惡報。」"
          ],
          "type": "動"
        }
      ],
      "pinyin": "méng"
    }
  ],
  "non_radical_stroke_count": 8,
  "radical": "艸",
  "stroke_count": 12,
  "title": "萌"
}
```

### /uni/

將原始 json 檔，Big5 區之外的字轉成相應的 Unicode 字元表示。

範例： https://www.moedict.tw/uni/%E8%90%8C

```json
{
  "heteronyms": [
    {
      "bopomofo": "ㄇㄥˊ",
      "bopomofo2": "méng",
      "definitions": [
        {
          "def": "草木初生的芽。",
          "quote": [
            "說文解字：「萌，艸芽也。」",
            "唐．韓愈、劉師服、侯喜、軒轅彌明．石鼎聯句：「秋瓜未落蒂，凍芋強抽萌。」"
          ],
          "type": "名"
        },
        {
          "def": "事物發生的開端或徵兆。",
          "quote": [
            "韓非子．說林上：「聖人見微以知萌，見端以知末。」",
            "漢．蔡邕．對詔問灾異八事：「以杜漸防萌，則其救也。」"
          ],
          "type": "名"
        },
        {
          "def": "人民。",
          "example": [
            "如：「萌黎」、「萌隸」。"
          ],
          "link": [
            "通「氓」。"
          ],
          "type": "名"
        },
        {
          "def": "姓。如五代時蜀有萌慮。",
          "type": "名"
        },
        {
          "def": "發芽。",
          "example": [
            "如：「萌芽」。"
          ],
          "quote": [
            "楚辭．王逸．九思．傷時：「明風習習兮龢暖，百草萌兮華榮。」"
          ],
          "type": "動"
        },
        {
          "def": "發生。",
          "example": [
            "如：「故態復萌」。"
          ],
          "quote": [
            "管子．牧民：「惟有道者，能備患於未形也，故禍不萌。」",
            "三國演義．第一回：「若萌異心，必獲惡報。」"
          ],
          "type": "動"
        }
      ],
      "pinyin": "méng"
    }
  ],
  "non_radical_stroke_count": 8,
  "radical": "艸",
  "stroke_count": 12,
  "title": "萌"
}
```

### /pua/

與 /uni/ 相同，已使用 Unicode 字元，但動態組字改用 @medicalwei 的造字替代。

範例： https://www.moedict.tw/pua/%E8%90%8C

```json
{
  "heteronyms": [
    {
      "bopomofo": "ㄇㄥˊ",
      "bopomofo2": "méng",
      "definitions": [
        {
          "def": "草木初生的芽。",
          "quote": [
            "說文解字：「萌，艸芽也。」",
            "唐．韓愈、劉師服、侯喜、軒轅彌明．石鼎聯句：「秋瓜未落蒂，凍芋強抽萌。」"
          ],
          "type": "名"
        },
        {
          "def": "事物發生的開端或徵兆。",
          "quote": [
            "韓非子．說林上：「聖人見微以知萌，見端以知末。」",
            "漢．蔡邕．對詔問灾異八事：「以杜漸防萌，則其救也。」"
          ],
          "type": "名"
        },
        {
          "def": "人民。",
          "example": [
            "如：「萌黎」、「萌隸」。"
          ],
          "link": [
            "通「氓」。"
          ],
          "type": "名"
        },
        {
          "def": "姓。如五代時蜀有萌慮。",
          "type": "名"
        },
        {
          "def": "發芽。",
          "example": [
            "如：「萌芽」。"
          ],
          "quote": [
            "楚辭．王逸．九思．傷時：「明風習習兮龢暖，百草萌兮華榮。」"
          ],
          "type": "動"
        },
        {
          "def": "發生。",
          "example": [
            "如：「故態復萌」。"
          ],
          "quote": [
            "管子．牧民：「惟有道者，能備患於未形也，故禍不萌。」",
            "三國演義．第一回：「若萌異心，必獲惡報。」"
          ],
          "type": "動"
        }
      ],
      "pinyin": "méng"
    }
  ],
  "non_radical_stroke_count": 8,
  "radical": "艸",
  "stroke_count": 12,
  "title": "萌"
}
```

### 國語 /a/

已使用 PUA 造字，再加上內文自動斷詞。

範例： https://www.moedict.tw/a/%E8%90%8C.json

```json
{
  "n": 8,
  "t": "萌",
  "r": "`艸~",
  "c": 12,
  "h": [
    {
      "d": [
        {
          "q": [
            "`說文解字~：「`萌~，`艸~`芽~`也~。」",
            "`唐~．`韓愈~、`劉~`師~`服~、`侯~`喜~、`軒轅~`彌~`明~．`石~`鼎~`聯句~：「`秋~`瓜~`未~`落~`蒂~，`凍~`芋~`強~`抽~`萌~。」"
          ],
          "type": "`名~",
          "f": "`草木~`初~`生~`的~`芽~。"
        },
        {
          "q": [
            "`韓非子~．`說~`林~`上~：「`聖人~`見~`微~`以~`知~`萌~，`見~`端~`以~`知~`末~。」",
            "`漢~．`蔡邕~．`對~`詔~`問~`灾~`異~`八~`事~：「`以~`杜漸防萌~，`則~`其~`救~`也~。」"
          ],
          "type": "`名~",
          "f": "`事物~`發生~`的~`開端~`或~`徵兆~。"
        },
        {
          "type": "`名~",
          "l": [
            "`通~「`氓~」。"
          ],
          "e": [
            "`如~：「`萌黎~」、「`萌隸~」。"
          ],
          "f": "`人民~。"
        },
        {
          "type": "`名~",
          "f": "`姓~。`如~`五代~`時~`蜀~`有~`萌~`慮~。"
        },
        {
          "q": [
            "`楚辭~．`王~`逸~．`九思~．`傷~`時~：「`明~`風~`習習~`兮~`龢~`暖~，`百草~`萌~`兮~`華~`榮~。」"
          ],
          "type": "`動~",
          "e": [
            "`如~：「`萌芽~」。"
          ],
          "f": "`發芽~。"
        },
        {
          "q": [
            "`管子~．`牧民~：「`惟~`有道~`者~，`能~`備~`患~`於~`未~`形~`也~，`故~`禍~`不~`萌~。」",
            "`三國演義~．`第一~`回~：「`若~`萌~`異心~，`必~`獲~`惡報~。」"
          ],
          "type": "`動~",
          "e": [
            "`如~：「`故態復萌~」。"
          ],
          "f": "`發生~。"
        }
      ],
      "p": "méng",
      "b": "ㄇㄥˊ",
      "=": "0676"
    }
  ],
  "translation": {
    "francais": [
      "germer"
    ],
    "Deutsch": [
      "Leute, Menschen  (S)",
      "Meng  (Eig, Fam)",
      "keimen, sprießen, knospen, ausschlagen "
    ],
    "English": [
      "to sprout",
      "to bud",
      "to have a strong affection for (slang)",
      "adorable (loanword from Japanese `萌~え moe, slang describing affection for a cute character)"
    ]
  }
}
```

### 閩南語 /t/

結構基本同 `/a/` （待補）

### 客語 /h/

結構基本同 `/a/` （待補）

### 兩岸詞典 /c/

結構基本同 `/a/` （待補）

## API 使用範例

### Ajax

/uni/ 範例

    $.ajax({
      url: "https://www.moedict.tw/uni/萌",
      dataType: "json",
      success: function(result) {
        console.log(result);
      }
    });

/a/ 範例

    $.ajax({
      url: "https://www.moedict.tw/a/萌.json",
      dataType: "json",
      success: function(result) {
        console.log(result);
      }
    });

### jsonp

callback= 參數須固定為 moedict_jsonp_callback

範例： https://www.moedict.tw/uni/萌?callback=moedict_jsonp_callback

ajax 範例

    $.ajax({
      url: "https://www.moedict.tw/uni/萌",
      dataType: "jsonp",
      jsonpCallback: "moedict_jsonp_callback",
      success: function(result) {
        console.log(result);
      }
    });

### Terminal

/uni/ 範例

    $ curl "https://www.moedict.tw/uni/萌"

/a/ 範例

    $ curl "https://www.moedict.tw/a/萌.json"

# 其他

`index.*.json` 為「重編國語辭典（修訂本）」的完整詞條清單，
於 2013-05-22 取得，為非營利之教育目的，依著作權法第 50 條，
「以中央或地方機關或公法人之名義公開發表之著作，在合理範圍內，
得重製、公開播送或公開傳輸。」

`dict-concised.audio.json` 為「國語辭典簡編本」的詞條發音
檔名清單。

其他平台版本、API 及原始資料等，均可在 http://3du.tw/ 取得。

感謝 http://g0v.tw/ 頻道內所有協助開發的朋友們。

# CC0 1.0 公眾領域貢獻宣告

除前述資料檔之外，本目錄下的所有其他檔案，由作者 唐鳳 在法律
許可的範圍內，拋棄該著作依著作權法所享有之權利，包括所有相關
與鄰接的法律權利，並宣告將該著作貢獻至公眾領域。

* <https://creativecommons.org/publicdomain/zero/1.0/deed.zh_TW>
* <http://wiki.creativecommons.org.tw/cc-zero-1-0:pre-final>

# 教育部版權頁

http://dict.revised.moe.edu.tw/htm/sk/ban.htm

        =====================================================
        編　　輯　　者：        教育部國語推行委員會
        國語推行委員會主任委員：童春發
        編輯委員會主任委員：    李　鍌
        總　　編　　輯：        李殿魁
        副　總　編　輯：        曾榮汾

        發　　行　　人：        杜正勝
        發　　行　　所：        教育部
        地　　　　　址：        臺北市中山南路5號
        電　　　　　話：        (02)7736-6801
        =====================================================
