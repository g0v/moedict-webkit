FORMAT: 1A
HOST: https://www.moedict.tw/

# MoeDict

## GET /SourceHanSansTW.ttf{?subset,weight}

Get a subset of Source Han Sans TW font （思源黑體） suitable for use as webfont.

+ Parameters
    + subset (required, string, `認得幾個字`) ... Characters to subset for.
    + weight (optional, string, `Regular`) ... Font weight, by number or by name.
        + Values
            + `100`
            + `ExtraLight`
            + `200`
            + `Light`
            + `300`
            + `Normal`
            + `400`
            + `Regular`
            + `500`
            + `Medium`
            + `700`
            + `Bold`
            + `900`
            + `Heavy`

+ Response 200 (application/x-font-ttf)
