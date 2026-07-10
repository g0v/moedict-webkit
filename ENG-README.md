# ⚠️ Frozen

**This repository no longer builds dictionary packs.** Pack generation lives
in [`g0v/moedict-process`](https://github.com/g0v/moedict-process); search and
pinyin indexes plus R2 uploads live in
[`g0v/moedict.tw`](https://github.com/g0v/moedict.tw). The files here are the
frozen static-frontend source for <https://www.moedict.org/>, served from this
repo's gh-pages branch. The historical Perl/Python 2 pack toolchain and the
HFS+ requirement were retired on 2026-07-10; dictionary data is regenerated
by `moedict-process` and synced to gh-pages and R2.

This is the repository for the online and offline lookup app for <http://moedict.tw/>

## Requirements

* Node.js (frontend build: gulp / webpack / LiveScript)

## Installation Environment

```sh
npm i
sudo npm i -g gulp
```

## Running a local instance

```sh
# quick static server, uses the pre-built js/deps.js ( watches: sass/ .jade )
npm start

# auto-reloads with react-hot-loader ( watches: sass/ .jade .ls )
npm run dev

# builds for deployment, using webpack and uglify
npm run build

```

## API Documentation

Please note, the API for the MOE Dictionary must be queried at `https://www.moedict.tw/`, because only this address will satisfy the CORS policy. If you query `http://moedict.org/`, it will throw a No 'Access-Control-Allow-Origin' header error.

For the basic data on the API, please [consult this link](https://g0v.hackpad.com/3du.tw-ZNwaun62BP4); this section is based on that information with some reorganization and additional examples.

The current API has 7 endpoints: /a/, /t/, /h/, /c/, /raw/, /uni/, /pua/

### 1. /raw/

The original JSON file. Characters outside the Big5 character range are shown using composite characters {[abcd]}.

Example: https://www.moedict.tw/raw/%E8%90%8C

```JSON
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
            "管子．牧民：「惟有道者, 能備患於未形也，故禍不萌。」",
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

Takes the original JSON file and uses Unicode to display characters outside the Big5 range.

Example: https://www.moedict.tw/uni/%E8%90%8C

```JSON
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

Like the /uni/ endpoint, /pua/ uses Unicode code points, but for dynamic composite characters, it uses @medicalwei.

For example, in the entry for '[淘漉](http://moedict.org/#淘漉)', there is a character whose raw codepoint is {[9ad7]}, and in uni it is a composite of ⿰扌 and 層, but in pua it has the codepoint U+F9AD7.

If you would like to display PUA, you will need to use the fonts available from the MOEDict at the following links: [woff](https://www.moedict.tw/MOEDICT.woff) or [ttf](https://www.moedict.tw/MOEDICT.ttf).

Example： https://www.moedict.tw/pua/%E8%90%8C

```JSON
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

### 4. Mandarin /a/

Also uses PUA composite characters, and in the content it uses automatic breaking characters.

Example https://www.moedict.tw/a/%E8%90%8C.json

```JSON
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

### 5. Taiwanese /t/

The structure is identical to `/a/`.

Example: https://www.moedict.tw/t/%E7%99%BC%E7%A9%8E.json

```JSON
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

### 6. Hakka /h/

The structure is identical to `/a/`.

Example: https://www.moedict.tw/h/%E7%99%BC%E8%8A%BD.json

```JSON
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

### 7. Cross-Straits Dictionary /c/

The structure is basically the same as `/a/`.

Example: https://www.moedict.tw/c/%E9%BE%8D.json

```JSON
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

## API Examples

### Ajax

/uni/ Example

```JS
 $.ajax({
   url: "https://www.moedict.tw/uni/萌",
   dataType: "json",
   success: function(result) {
     console.log(result);
   }
 });
```

/a/ Example

```JS
 $.ajax({
   url: "https://www.moedict.tw/a/萌.json",
   dataType: "json",
   success: function(result) {
     console.log(result);
   }
 });
```

### jsonp

The callback parameter must always be `callback=moedict_jsonp_callback`.

Example: https://www.moedict.tw/uni/萌?callback=moedict_jsonp_callback

ajax example:

```JS
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

/uni/ example

    $ curl "https://www.moedict.tw/uni/萌"

/a/ example

    $ curl "https://www.moedict.tw/a/萌.json"

# Miscellaneous

`index.*.json` is the complete list of all headwords in the「重編國語辭典（修訂本）」(Revised Mandarin Dictionary (Corrected Edition)).

`dict-concised.audio.json` is the index of filenames of pronunciation files in the「國語辭典簡編本」(Concise Mandarin Dictionary).

Versions for other platforms, API, and underlying data can be had from http://3du.tw/ .

Many thanks to to the assistant developers at http://g0v.tw/ .

# CC0 1.0 Universal Public Domain Dedication

Apart from any files mentioned above, all other files in this directory have been dedicated by the author (Tang Feng) to the public domain by waiving all of his or her rights to the work worldwide under copyright law, including all related and neighboring rights, to the extent allowed by law.

* <https://creativecommons.org/publicdomain/zero/1.0/deed.zh_TW>
* <https://creativecommons.org/publicdomain/zero/1.0/deed.en>
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