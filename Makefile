# ⚠️ Frozen: pack generation retired 2026-07-10.
# Dictionary packs, indexes, xrefs, and translations are produced by
# `g0v/moedict-process` (bun run pack) and staged/uploaded via `g0v/moedict.tw`.
# Only the static-frontend build targets remain here; www.moedict.org is
# served from this repo's gh-pages branch.

run ::
	gulp run

dev ::
	gulp dev

build ::
	gulp build

deps ::
	npm i
	gulp build

js/deps.js ::
	gulp webpack:build

manifest :: js/deps.js
	perl -pi -e 's/# [A-Z].*\n/# @{[`date`]}/m' manifest.appcache

clean ::
	git clean -xdf
