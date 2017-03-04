import React from 'react'

export default class Nav extends React.Component { render() {
    return <nav className="navbar navbar-inverse navbar-fixed-top" role="navigation">
        <div className="navbar-header">
            <a className="navbar-brand brand ebas" href="./">阿美語萌典</a>
        </div>
        <ul className="nav navbar-nav">
            <li className="dropdown">
                <a className="dropdown-toggle" href="#" data-toggle="dropdown">
                    <i className="icon-book">&nbsp;</i>
                    <span className="lang-active" style={{
                        margin: 0, padding: 0
                    }} itemProp="articleSection">方敏英字典</span>
                    <b className="caret"></b>
                </a>
                <DropDown STANDALONE={this.props.STANDALONE} />
            </li>
            <li id="btn-starred" title="字詞紀錄簿">
                <a href="#=*" style={{ paddingLeft: "5px", paddingRight: "5px" }}>
                    <i className="icon-bookmark-empty" />
                </a>
            </li>
            <li id="btn-pref" title="偏好設定">
                <a href="#=*" style={{ paddingLeft: "5px", paddingRight: "5px" }}>
                    <i className="icon-cogs" />
                </a>
            </li>
            { window.isMoedictDesktop && <li id="btn-moedict-desktop-addons">
                <a href="https://racklin.github.io/moedict-desktop/addon.html" style={{
                    paddingLeft: "5px", paddingRight: "5px"
                }} alt="下載擴充套件"><i className="icon-download-alt" /></a>
            </li> }
            <li>
                <form id="lookback" className="back"
                    target="_blank" acceptCharset="big5"
                    action="http://dict.revised.moe.edu.tw/cgi-bin/newDict/dict.sh" style={{ display: "none", margin: 0, padding: 0 }}>
                    <input type="hidden" name="idx" value="dict.idx" />
                    <input type="hidden" name="fld" value="1" />
                    <input type="hidden" name="imgFont" value="1" />
                    <input type="hidden" name="cat" value="" />
                    <input id="cond" type="hidden" name="cond" value="^萌$" />
                    <input className="iconic-circle" type="submit" value="反" title="反查來源（教育部國語辭典）" style={{ fontFamily: "EBAS", marginTop: "12px", borderRadius: "20px", border: "0px" }} />
                </form>
            </li>
            <li className="resize-btn app-only" style={{
                position: "absolute", top: "2px", left: "8em", padding: "3px"
            }}>
                <a style={{ paddingLeft: "5px", paddingRight: "5px", marginRight: "30px" }} href="#" onClick={()=> window.adjustFontSize(-1)}>
                    <i className="icon-resize-small" />
                </a>
            </li>
            <li className="resize-btn app-only" style={{
                position: "absolute", top: "2px", left: "8em", padding: "3px"
              , marginLeft: "30px"
            }}>
                <a style={{ paddingLeft: "5px", paddingRight: "5px" }} href="#" onClick={()=> window.adjustFontSize(+1)}>
                    <i className="icon-resize-full" />
                </a>
            </li>
        </ul>
        <ul className="nav pull-right hidden-xs">
            <li>
                <a href="about.html" title="關於本站" onClick={()=> window.pressAbout()}>
                    <span className="iconic-circle">
                        <i className="icon-info" />
                    </span>
                </a>
            </li>
        </ul>
        <ul className="nav pull-right hidden-xs hidden-sm web-only">
            <li><a href="http://ckhis.ck.tp.edu.tw/~ljm/amis-mp/" target="_blank" title="「阿美語萌典」校對活動"><img src="https://www.moedict.tw/dodo/icon.png" width="32" height="32" /> 幫校對</a></li>
        </ul>
        <ul className="nav pull-right hidden-xs">
            <li className="web-inline-only" style={{ display: "inline-block" }}>
                <a href="https://racklin.github.io/moedict-desktop/download.html" target="_blank" title="桌面版下載（可離線使用）" style={{ color: "#ccc" }}>
                    <i className="icon-download-alt" />
                </a>
            </li>
            <li className="web-inline-only" style={{ display: "inline-block" }}>
                <a href="https://play.google.com/store/apps/details?id=org.audreyt.dict.moe" target="_blank" title="Google Play 下載" style={{ color: "#ccc" }}>
                    <i className="icon-android" />
                </a>
            </li>
            <li className="web-inline-only" style={{ display: "inline-block" }}>
                <a href="https://itunes.apple.com/tw/app/meng-dian/id599429224" target="_blank" title="App Store 下載" style={{ color: "#ccc" }}>
                    <i className="icon-apple" />
                </a>
            </li>
        </ul>
    </nav>
} }

class DropDown extends React.Component { render() {
    return <ul className="dropdown-menu" role="navigation">{[
        <MenuItem key="##" lang="p" href="##">方敏英字典</MenuItem>,
        <MenuItem key="#!" lang="m" href="#!">潘世光阿法</MenuItem>,
        <MenuItem key="#:" lang="s" href="#:">蔡中涵大辭典</MenuItem>]}
    </ul>
} }

class Taxonomy extends React.Component { render() {
    const {lang} = this.props
    return <li className="dropdown-submenu">
        <a className={lang + " taxonomy"}>…分類索引</a>
    </li>
} }

class MenuItem extends React.Component { render() {
    const {lang, href, children} = this.props
    const role = ((children[0] === "…") && "menuitem")
    return <li role="presentation">
        <a className={lang + " lang-option " + (role && `${lang}-idiom`)}
            role={role} href={href}>{ children }</a>
    </li>
} }


