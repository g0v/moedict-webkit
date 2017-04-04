這是 <http://moedict.tw/> 線上及離線查詢 App 的源碼庫。

## Docker

可以從 Docker Hub 取回開發環境:

```sh
docker@boot2docker:~$ docker pull miaoski/moedict-webkit
docker@boot2docker:~$ docker run -p 8888:8888 -t -i miaoski/moedict-webkit /bin/bash
root@4a7bd751fd9e:/usr/local/src/moedict-webkit# make
```



## 需求

* Node.js 0.10.x
    * npm
* Perl 5.8.0+
* Python
    * lxml

## 前置作業 (Debian/Ubuntu)

```sh
sudo apt-get update
sudo apt-get install -y python g++ make nodejs python-lxml curl npm
```

## 安裝環境

```sh
npm i
pip install lxml
sudo npm i -g gulp
```

## 建置

## 建置離線檔案

建置離線瀏覽所需要的檔案:

```sh
make offline
```

## 手動逐步建置

來源 JSON 檔 `dict-revised.unicode.json` 及 `dict-revised.pua.json` 由
<https://github.com/g0v/moedict-data> 提供， 再經由
<https://github.com/g0v/moedict-epub> 造字轉換程式 `json2unicode.pl` 轉為
Unicode 編碼:

```sh
git clone --depth 1 https://github.com/g0v/moedict-data.git
git clone --depth 1 https://github.com/g0v/moedict-epub.git
cp -v moedict-data/dict-revised.json moedict-epub/
cd moedict-epub
perl json2unicode.pl > dict-revised.unicode.json
perl json2unicode.pl sym-pua.txt > dict-revised.pua.json
```

`pack`、`a` 及 `t` 資料目錄由 `json2prefix.ls`、
`autolink.ls` 及 `link2pack.pl` 程式產生：

```sh
lsc json2prefix.ls a
lsc autolink.ls a > a.txt
perl link2pack.pl a < a.txt

lsc json2prefix.ls t
lsc autolink.ls t > t.txt
perl link2pack.pl t < t.txt
```

## 本機運行

```sh
# quick static server, uses the pre-built js/deps.js ( watches: sass/ .jade )
npm start

# auto-reloads with react-hot-loader ( watches: sass/ .jade .ls )
npm run dev

# builds for deployment, using webpack and uglify
npm run build

```

## API 說明

首先請注意，萌典 API 必須去詢問 `https://www.moedict.tw/`，因為這個網址才有開 CORS。不要去訪問 `http://moedict.org/` ，會噴 No 'Access-Control-Allow-Origin' header 的錯誤。

API 的原始資料，請[參考連結](https://g0v.hackpad.com/3du.tw-ZNwaun62BP4)，本段落的說明是參考連結整理後並加上範例。

目前 API 已有 7 個端點，分別是 /a/, /t/, /h/, /c/, /raw/, /uni/, /pua/

### 1. /raw/

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

### 2. /uni/

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

### 3. /pua/

與 /uni/ 相同，已使用 Unicode 字元，但動態組字改用 @medicalwei 的造字替代。

以「[淘漉](http://moedict.org/#淘漉)」為例，內容有一字在 raw 是 {[9ad7]}，在 uni 是 ⿰扌層，在 pua 是 U+F9AD7。

若要顯示 PUA，必須引用萌典字型 [woff](https://www.moedict.tw/MOEDICT.woff) 或 [ttf](https://www.moedict.tw/MOEDICT.ttf)。

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

### 4. 國語 /a/

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

### 5. 閩南語 /t/

結構基本同 `/a/`。

範例： https://www.moedict.tw/t/%E7%99%BC%E7%A9%8E.json

```json
{
  "t": "`發~`穎~",
  "h": [
    {
      "_": "8778",
      "T": "huat-ínn",
      "s": "`發芽~",
      "d": [
        {
          "type": "`動~",
          "f": "`發芽~、萌`芽~。`植物~`的~`種子~`發出~`芽~。",
          "e": [
            "￹`樹仔~`發穎~`矣~！￺Tshiū-á huat-ínn--ah! ￻`樹~`發芽~`了~！"
          ]
        }
      ]
    }
  ]
}
```

### 6. 客語 /h/

結構基本同 `/a/`。

範例： https://www.moedict.tw/h/%E7%99%BC%E8%8A%BD.json

```json
{
  "t": "`發~`芽~",
  "h": [
    {
      "=": "02735",
      "p": "四?⃞fad²nga¹¹ 海?⃞fad⁵nga⁵⁵ 大?⃞fad²¹nga¹¹³ 平?⃞fad²nga⁵⁵ 安?⃞fad²⁴nga⁵³",
      "s": "`暴~`芽~,`暴筍~",
      "d": [
        {
          "e": [
            "￹`春天~`一~`到~，`草~`仔~`樹仔~`相賽~`開始~`發芽~。￻`春天~`一~`到~，`草~`木~`相~繼`開始~萌`芽~。"
          ],
          "f": "`植物~`的~`種~`子~，`因~`本身~`的~`生理~、`外~`部~`環~`境~`條件~`的~`合適~，`而~`開始~萌`發~`的~`一~`種~`現象~。",
          "type": "`動~"
        }
      ]
    }
  ]
}
```

### 7. 兩岸詞典 /c/

結構基本同 `/a/`。

範例： https://www.moedict.tw/c/%E9%BE%8D.json

```json
{
  "t": "龍",
  "h": [
    {
      "p": "lónɡ",
      "A": "龙",
      "d": [
        {
          "e": [
            "例?⃝「`飛~`龍~`在~`天~」、「`生龍活虎~」、「`葉公好龍~」、「`畫龍點睛~」。"
          ],
          "f": "`傳說~`中的~`神異~`動物~，`有~`角~、`鱗~、`爪~、`鬚~，`能~`上天~`入~`水~，`興~`雲~`降雨~。"
        },
        {
          "e": [
            "例?⃝「`龍顏~`大~`怒~」、「`龍~`體~`欠安~」、「`龍~`子~`龍~`孫~」。"
          ],
          "f": "`古代~`用作~`帝王~`的~`象徵~；`也~`指~`與~`帝王~`相關~`的~`物~`或~`人~。"
        },
        {
          "e": [
            "例?⃝「`人中~`之~`龍~」。"
          ],
          "f": "`借~`指~`首領~`或~`豪傑~`才~`俊~。"
        },
        {
          "e": [
            "例?⃝「`龍~`旗~」、「`龍舟~」、「`龍~`票~」。"
          ],
          "f": "`形狀~`像~`龍~`或~`裝飾~`著~`龍~`的~`圖案~`的~。"
        },
        {
          "e": [
            "例?⃝「`排~`成長~`龍~」、「`車水馬龍~」、「`大火~`蔓延~`一片~，`形成~`一~`條~`火龍~」。"
          ],
          "f": "`指~`某~`些~`連~`成~`一~`串~，`形狀~`像~`龍~`的~`東西~。"
        },
        {
          "e": [
            "例?⃝「`恐龍~」、「`翼~`手~`龍~」。"
          ],
          "f": "`指~`遠~`古~`某~`些~`巨大~`的~`爬行動物~。"
        },
        {
          "f": "`姓~。"
        },
        {
          "f": "`二~`一~`四部~`首~`之~`一~。"
        }
      ],
      "_": "1048060000",
      "b": "ㄌㄨㄥˊ"
    }
  ],
  "translation": {
    "francais": [
      "dragon",
      "impérial",
      "(nom de famille)",
      "212e radical"
    ],
    "Deutsch": [
      "Drache  (S)",
      "Long (Name)  (Eig, Fam)",
      "Schlange (auf der Speisekarte)  (Ess)",
      "Radikal Nr. 212 = Drache, Drachen "
    ],
    "English": [
      "surname Long",
      "dragon",
      "CL:`條~|条[tiao2]",
      "imperial"
    ]
  }
}
```

## API 使用範例

### Ajax

/uni/ 範例

```js
 $.ajax({
   url: "https://www.moedict.tw/uni/萌",
   dataType: "json",
   success: function(result) {
     console.log(result);
   }
 });
```

/a/ 範例

```js
 $.ajax({
   url: "https://www.moedict.tw/a/萌.json",
   dataType: "json",
   success: function(result) {
     console.log(result);
   }
 });
```

### jsonp

callback= 參數須固定為 moedict_jsonp_callback

範例： https://www.moedict.tw/uni/萌?callback=moedict_jsonp_callback

ajax 範例

```js
 $.ajax({
   url: "https://www.moedict.tw/uni/萌",
   dataType: "jsonp",
   jsonpCallback: "moedict_jsonp_callback",
   success: function(result) {
     console.log(result);
   }
 });
```

### Terminal

/uni/ 範例

    $ curl "https://www.moedict.tw/uni/萌"

/a/ 範例

    $ curl "https://www.moedict.tw/a/萌.json"

# 其他

`index.*.json` 為「重編國語辭典（修訂本）」的完整詞條清單。

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

# 教育部國語辭典公眾授權網

http://resources.publicense.moe.edu.tw/

# 教育部版權頁

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
