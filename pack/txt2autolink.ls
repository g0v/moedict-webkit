require! <[ fs lazy ]>
idx <- [0 til 1024].forEach

buf <- new lazy(fs.createReadStream("#idx.txt")).lines.forEach
fn = ''
return if buf[0] is 125
i = 2
until buf[i] is 34 => fn += String.fromCharCode buf[i++]
i+=2
foo = unescape fn
foo -= /\(.*/
console.log "\"#foo\","
#fs.writeFileSync "autolink/#foo.json" buf.slice(i)
