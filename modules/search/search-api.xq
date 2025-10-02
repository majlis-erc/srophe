xquery version "3.1";

(: module namespace api="http://srophe.org/modules/search-api"; :)
import module namespace util="http://exist-db.org/xquery/util";
module namespace api="http://majlis/search-api";
declare namespace rest="http://exquery.org/ns/restxq";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace fmap="http://srophe.org/modules/field-maps" at "field-maps.xqm";
import module namespace dtu="http://srophe.org/modules/date-utils" at "date-utils.xqm";

declare variable $api:DEFAULT-PAGE-SIZE := 20;

(:--- Helpers -------------------------------------------------------------:)

declare function api:get-param($name as xs:string, $default as xs:string := "") as xs:string {
  let $v := request:get-parameter($name, ())
  return if (exists($v) and string-length(normalize-space($v)) gt 0)
         then $v
         else $default
};

declare function api:get-param-multi($name as xs:string) as xs:string* {
  for $i in request:get-parameter-values($name)
  return $i
};

(: Build a WHERE predicate from one “criteria block” :)
declare function api:predicate-for-block(
  $block as map(*),
  $ctx   as element()
) as xs:boolean {
  let $term := map:get($block,'term')
  let $type := map:get($block,'type')            (: exact | similar :)
  let $entity := map:get($block,'entity')        (: manuscript | work | person :)
  let $fields := map:get($block,'fields')        (: zero or more display labels :)
  let $paths  := fmap:paths-for($entity, $fields)
  return
    if (empty($term) or empty($paths)) then true()
    else some $p in $paths satisfies
         (if ($type = 'exact')
            then ft:contains($ctx, ft:query(string-join($ctx/descendant-or-self::text(), ' '), '"'||$term||'"'))
            else ft:contains($ctx, $term))
};

(: Turn a list of blocks + ops into one combined predicate :)
declare function api:combined-predicate(
  $blocks as map(*)*
) as function(element()) as xs:boolean {
  function($ctx as element()) as xs:boolean {
    let $evals :=
      for $i at $pos in $blocks
      let $pred := api:predicate-for-block($i, $ctx)
      return map { 'pos': $pos, 'pred': $pred, 'op': map:get($i,'op') }
    return
      fold-left(
        subsequence($evals,1,1)?pred,
        subsequence($evals,2)!(
          function($acc, $cur) {
            let $op := $cur?op
            return
              if ($op = 'NOT') then $acc and not($cur?pred)
              else if ($op = 'OR') then $acc or $cur?pred
              else $acc and $cur?pred (: default AND :)
          }
        )
      )
  }
};

declare function api:collect-blocks() as map(*)* {
  let $idxs :=
    for $i in request:get-parameter-names()
    where matches($i, '^searchTerm_\d+$')
    return xs:integer(replace($i, '^searchTerm_(\d+)$', '$1'))
  for $n in sort(distinct-values($idxs))
  let $term := api:get-param(concat('searchTerm_', $n), '')
  let $type := api:get-param(concat('searchType_', $n), 'similar')
  let $entity := api:get-param(concat('entity_', $n), '')
  let $op := if ($n gt 1) then api:get-param(concat('logicalOperator_', $n), 'AND') else 'AND'
  let $fields := api:get-param-multi(concat('teiElements_', $n, '[]'))
  return map {
    'term': $term, 'type': $type, 'entity': $entity, 'op': $op, 'fields': $fields
  }
};

declare function api:entity-collections($blocks as map(*)*) as xs:anyURI* {
  let $ents := distinct-values(for $b in $blocks return $b?entity)
  return for $e in $ents return fmap:collection-for-entity($e)
};

declare function api:apply-year-filter($nodes as element()*, $start as xs:string?, $end as xs:string?) as element()* {
  if (not($start) and not($end)) then $nodes
  else for $n in $nodes
       where dtu:overlaps-year($n, $start, $end)
       return $n
};

(:--- Main ----------------------------------------------------------------:)

declare
  %rest:GET
  %rest:path("/apps/majlis/api/search_new")
  %output:method("json")
  %output:media-type("application/json") 
function api:search() as map(*) { 
  (: TEMP sanity: reply if ?ping=1 :)
  let $ping := request:get-parameter('ping', '')
  return
    if ($ping) then
      map { "ok": true(), "echo": request:get-query-string() }

    else (
    let $trace := request:get-parameter('trace','')
    let $_ := if ($trace) then util:log("info",
              "majlis api:search_new " || request:get-query-string())
          else ()

  (: let $general := api:get-param('generalKeyword','') :)
  let $general :=
  let $g := request:get-parameter('generalKeyword','')
  return if (normalize-space($g) != '')
         then $g
         else request:get-parameter('keyword','')

  let $startY  := api:get-param('startYear','')
  let $endY    := api:get-param('endYear','')
  let $page    := xs:integer(api:get-param('page','1'))
  let $size    := xs:integer(api:get-param('pageSize', xs:string($api:DEFAULT-PAGE-SIZE)))
  let $blocks0 := api:collect-blocks()
  let $blocks  := if ($general != '')
                    then ( map{'term':$general,'type':'similar','entity':'', 'op':'AND', 'fields':()} , $blocks0 )
                    else $blocks0
  let $cols    := for $c in api:entity-collections($blocks) return collection($c)
  let $items0  :=
        for $doc in ($cols//tei:TEI)
        let $pred := api:combined-predicate($blocks)
        where $pred($doc)
        return $doc
  let $items1  := api:apply-year-filter($items0, $startY, $endY)
  let $total   := count($items1)
  let $slice   := subsequence($items1, (($page - 1) * $size) + 1, $size)
  let $debug :=
  if ($trace) then map {
    "handler": "api:search",
    "route": "/apps/majlis/api/search_new",
    "module": "modules/search-api.xq",
    "query": request:get-query-string()
  } else map {}

(: …when you build the final map result, merge $debug in:) 

  return map {
    "total": $total,
    "page":  $page,
    "pageSize": $size,
    "debug": $debug
    "items": array {
      for $tei in $slice
      let $id := string(($tei/@xml:id, util:document-name($tei))[1])
      let $title := normalize-space(string(($tei//tei:titleStmt/tei:title)[1]))
      let $type := name($tei)
      let $date := string(($tei//tei:origDate/@when, $tei//tei:origDate/@notBefore)[1])
      return map {
        "id": $id,
        "title": $title,
        "type": $type,
        "date": $date,
        "path": xmldb:encode-uri(util:collection-name($tei)) || "/" || util:document-name($tei)
      }
    }
  }
  )
};

(: Optional: keep the old URL working too :)
declare
  %rest:GET
  %rest:path("/apps/majlis/api/search")
  %output:method("json")
  %output:media-type("application/json")
function api:search_compat() as map(*) {
  api:search()
};

