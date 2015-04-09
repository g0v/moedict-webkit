import React from 'react'
const window = (typeof self === 'undefined') ? { $(){} } : self.window
const $body = window.$('body') || { hasClass(){} }
const localStorage = window.localStorage || { getItem(){}, setItem(){} }

export default class UserPref extends React.Component {
    static defaultProps = {
        simptrad: localStorage.getItem("simptrad"),
        phonetics: localStorage.getItem("phonetics"),
        pinyin_a: localStorage.getItem("pinyin_a") || "HanYu",
        pinyin_t: localStorage.getItem("pinyin_t") || "TL"
    }
    render() {
        const { phonetics, simptrad, pinyin_a, pinyin_t } = this.props
        return <div>
            <h4>偏好設定</h4>
            <button className="close btn-close" type="button" aria-hidden>×</button>
            <ul>{ $body.hasClass('lang-a') &&
                <PrefList pref={{pinyin_a}} label="羅馬拼音顯示方式" items={{
                    'HanYu-TongYong': "漢語華通共同顯示",
                    HanYu:            "漢語拼音",
                    TongYong:         "華通拼音",
                    WadeGiles:        "威妥瑪式",
                    GuoYin:           "注音二式"
                }} />
            }{ $body.hasClass('lang-t') &&
                <PrefList pref={{pinyin_t}} label="羅馬拼音顯示方式" items={{
                    'TL-DT':   "臺羅臺通共同顯示",
                    TL:        "臺羅拼音",
                    DT:        "臺通拼音",
                    POJ:       "白話字"
                }} />
            }<PrefList pref={{ phonetics }} label="條目音標顯示方式" items={{
                    rightangle:"注音拼音共同顯示",
                    bopomofo:  "注音符號",
                    pinyin:    "羅馬拼音",
                    '-':       '',
                    none:      "關閉"
                }} />
            </ul>
            <button className="btn btn-primary btn-block btn-close" type="button">關閉</button>
        </div>
    }
}

class PrefList extends React.Component {
    constructor(props) { super(props)
        const key = Object.keys(props.pref)[0]
        const selected = props.pref[key]
        this.state = { key, selected }
    }
    componentDidMount() { this.phoneticsChanged() }
    componentDidUpdate() { this.phoneticsChanged() }
    pinyin_aChanged() { location.reload() }
    pinyin_tChanged() { location.reload() }
    phoneticsChanged() { $body.attr('data-ruby-pref', {
        rightangle: "both", bopomofo: "zhuyin",
        pinyin: "pinyin", none: "none"
    }[this.state.selected]) }
    render() {
        const { label, items } = this.props
        const vals = Object.keys(items)
        var { key, selected } = this.state
        selected = selected || vals[0]
        return <li className="btn-group">
            <label>{ label }</label>
            <button className="btn btn-default btn-sm dropdown-toggle" type="button" data-toggle="dropdown">{
                vals.map((val)=>(val === selected) && items[val])
            }&nbsp;<span className="caret" /></button>
            <ul className="dropdown-menu">{ vals.map((val) => (val[0] === '-') 
                ? <li key={val} className="divider" role="presentation" />
                : <li key={val}><a style={{ cursor: "pointer" }}
                         className={ (val === selected) && 'active' }
                         onClick={()=>{
                             localStorage.setItem(key, val)
                             this.setState({ selected: val })
                             this[key + "Changed"]()
                             }}>{ items[val] }</a></li>
             ) }</ul>
        </li>
    }
}
