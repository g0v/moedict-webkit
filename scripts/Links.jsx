import React from 'react'

const shareButtons = [
  { id: "f", icon: "facebook", label: "Facebook", background: "#3B579D", href: "https://www.facebook.com/sharer/sharer.php?u=https%3A%2F%2Fwww.moedict.tw%2F" },
  { id: "t", icon: "twitter", label: "Twitter", background: "#00ACED", href: "https://twitter.com/share?text=__TEXT__&url=https%3A%2F%2Fwww.moedict.tw%2F" },
  { id: "g", icon: "google-plus", label: "Google+", background: "#D95C5C", href: "https://plus.google.com/share?url=https%3A%2F%2Fwww.moedict.tw%2F" }
]

export default class Links extends React.Component { render() {
    return <div>
        <a title="關於本站" href="#"
           className="visible-xs pull-left ebas btn btn-default"
           style={{ float: "left", marginTop: "-10px"
                  , marginLeft: "5px", marginBottom: "5px" }}
           onClick={ ()=>window.pressAbout() } >
           <span className="iconic-circle"><i className="icon-info" /></span>
           <span>&nbsp;萌典</span>
       </a>
       <div className="share" style={{
           float: "right", marginTop: "-10px",
           marginRight: "5px", marginBottom: "15px"
       }}>{ shareButtons.map(({ id, icon, label, background, href }) =>
           <a key={id} id={"share-"+id} className="btn btn-default small not-ios"
              title={`${label} 分享`} style={{ background, color: "white" }}
              data-href={href} target="_blank">
              <i className="icon-share">&nbsp;</i>
              <i className={"icon-"+icon} />
           </a>
       ) }</div>
    </div>
} }
