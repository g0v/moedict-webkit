require! fs
for {name, entries} in require './moedict-data/dict-cat.json'
  fs.writeFileSync "=#name", JSON.stringify(entries)
