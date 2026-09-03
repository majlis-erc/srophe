# Browse-page facet index fix

## Problem

Every browse page (manuscripts, places, persons, etc.) returned zero results on
staging, even though the underlying Lucene full-text index was healthy.

## Root cause

Commit `204d830` changed `data:get-records()` (`modules/lib/data.xqm`) to run
`ft:query()` directly against the `tei:TEI` element, so `ft:facets()` computes
facet counts correctly — a match's facet dimensions only compute when the
matched node itself carries a `<text>` index config.

That commit's own comment says `tei:TEI` "already has its own
`<text qname="tei:TEI">` full-text index block in collection.xconf" — but no
such block has ever existed in `facets.xql`'s history. The live server's
`collection.xconf` must have carried a manually-patched version with it that
was never committed back to this repo, which is why browsing still worked
(aside from a cosmetic facet-duplication bug) until `sf:update-index()`
regenerated `collection.xconf` from source and silently dropped it, breaking
browse-page results across every collection.

## Fix

Add a `tei:TEI`-scoped `<text>` block to `sf:build-index()`
(`modules/lib/facets.xql`) carrying the same facet/field definitions as the
existing `tei:body` block (left unchanged — other search code paths in
`rest.xqm`, `bibl-search.xqm`, `search.xqm`, and elsewhere in `data.xqm` still
query `descendant::tei:body` directly). The facet expressions already use
`descendant-or-self::tei:body` internally, which resolves correctly under
either qname since `msIdentifier` and the rest of each record's `msDesc`
metadata live inside `tei:body` in this app's data model, not `teiHeader`.

## Deploy follow-up (after merge)

Merging this alone does not fix the live site — deploying new app code does
not retroactively rebuild the data collection's index. After this deploys via
CI, `collection.xconf` needs to be regenerated (`sf:update-index()`) and the
data collections reindexed.
