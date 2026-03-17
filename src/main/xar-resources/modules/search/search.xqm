xquery version "3.1";        
(:~  
 : Builds HTML search forms and HTMl search results Srophe Collections and sub-collections   
 :) 
module namespace search="http://srophe.org/srophe/search";

(:eXist templating module:)
import module namespace templates="http://exist-db.org/xquery/templates" ;

(: Import KWIC module:)
import module namespace kwic="http://exist-db.org/xquery/kwic";

(: Import Srophe application modules. :)
import module namespace config="http://srophe.org/srophe/config" at "../config.xqm";
import module namespace data="http://srophe.org/srophe/data" at "../lib/data.xqm";
import module namespace global="http://srophe.org/srophe/global" at "../lib/global.xqm";
import module namespace facet="http://expath.org/ns/facet" at "../lib/facet.xqm";
import module namespace sf="http://srophe.org/srophe/facets" at "../lib/facets.xql";
import module namespace page="http://srophe.org/srophe/page" at "../lib/paging.xqm";
import module namespace slider = "http://srophe.org/srophe/slider" at "../lib/date-slider.xqm";
import module namespace tei2html="http://srophe.org/srophe/tei2html" at "../content-negotiation/tei2html.xqm";

(: Syriaca.org search modules :)
import module namespace bibls="http://srophe.org/srophe/bibls" at "bibl-search.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";
(:declare namespace facet="http://expath.org/ns/facet";:)

(: Variables:)
declare variable $search:start {request:get-parameter('start', 1) cast as xs:integer};
declare variable $search:perpage {request:get-parameter('perpage', 20) cast as xs:integer};

(:~
 : Builds search result, saves to model("hits") for use in HTML display
:)

(:~
 : Search results stored in map for use by other HTML display functions. UPDATED for new search
:)
declare %templates:wrap function search:search-data(
  $node as node(),
  $model as map(*),
  $collection as xs:string?,
  $sort-element as xs:string?
){
  let $has-advanced :=
      normalize-space(request:get-parameter('generalKeyword', '')) != '' or
      normalize-space(request:get-parameter('searchTerm_1', '')) != '' or
      normalize-space(request:get-parameter('searchTerm_2', '')) != '' or
      normalize-space(request:get-parameter('searchTerm_3', '')) != '' or
      normalize-space(request:get-parameter('startYear', '')) != '' or
      normalize-space(request:get-parameter('endYear', '')) != ''

  let $queryExpr :=
      if($has-advanced)
      then data:create-advanced-query($collection)
      else if($collection = 'bibl')
      then bibls:query-string()
      else ()

  let $hits :=
      data:search($collection, $queryExpr, $sort-element)

  return map {
    "hits" :
      if(exists(request:get-parameter-names()))
      then $hits
      else if(ends-with(request:get-url(), 'search.html'))
      then ()
      else $hits
  }
};

(: Search summary for new search - start :)
declare %templates:wrap function search:search-summary(
  $node as node(),
  $model as map(*)
) {
  let $general := normalize-space(request:get-parameter('generalKeyword', ''))
  let $startYear := normalize-space(request:get-parameter('startYear', ''))
  let $endYear := normalize-space(request:get-parameter('endYear', ''))
  let $resultCount :=
    if($model?hits) then count($model?hits)
    else 0

  let $criteria :=
    for $n in 1 to 3
    let $term := normalize-space(request:get-parameter(concat('searchTerm_', $n), ''))
    let $entity := normalize-space(request:get-parameter(concat('entity_', $n), ''))
    let $type := normalize-space(request:get-parameter(concat('searchType_', $n), 'similar'))
    let $fieldsRaw := normalize-space(request:get-parameter(concat('teiElements_', $n), ''))
    let $fieldsLabel :=
      if($fieldsRaw = '') then 'all default fields'
      else replace($fieldsRaw, ',', ', ')
    let $operator :=
      if($n gt 1)
      then normalize-space(request:get-parameter(concat('logicalOperator_', $n), 'AND'))
      else ''
    where $term != '' or $entity != '' or $fieldsRaw != ''
    return
      <div xmlns="http://www.w3.org/1999/xhtml" class="search-summary-row">
        {
          if($n gt 1) then
            <span class="search-summary-operator">{$operator}</span>
          else ()
        }
        <span class="search-summary-chip">Criterion {$n}</span>
        {
          if($term != '') then
            <span class="search-summary-chip">Term: {$term}</span>
          else ()
        }
        <span class="search-summary-chip">Match: {$type}</span>
        {
          if($entity != '') then
            <span class="search-summary-chip">Entity: {$entity}</span>
          else ()
        }
        <span class="search-summary-chip">Fields: {$fieldsLabel}</span>
      </div>

  let $hasSearch :=
    $general != '' or
    $startYear != '' or
    $endYear != '' or
    exists($criteria)

  return
    if(not($hasSearch)) then ()
    else
      <div xmlns="http://www.w3.org/1999/xhtml" class="search-summary-box">
        <div class="search-summary-header">
          <h4 class="search-summary-title">Applied Search Criteria</h4>
          <span class="search-summary-count">{$resultCount} result{if($resultCount = 1) then '' else 's'}</span>
        </div>
        <div class="search-summary-content">
          {
            if($general != '') then
              <div class="search-summary-row">
                <span class="search-summary-chip">General Keyword: {$general}</span>
              </div>
            else ()
          }

          {$criteria}

          {
            if($startYear != '' or $endYear != '') then
              <div class="search-summary-row">
                {
                  if($startYear != '') then
                    <span class="search-summary-chip">Start Year: {$startYear}</span>
                  else ()
                }
                {
                  if($endYear != '') then
                    <span class="search-summary-chip">End Year: {$endYear}</span>
                  else ()
                }
              </div>
            else ()
          }
        </div>
      </div>
};

(: Search summary for new search - end :)

declare %templates:wrap function search:debug-collection(
  $node as node(),
  $model as map(*)
) {
  let $docs := collection('/db/apps/majlis-data/data')//tei:TEI
  return
    <div xmlns="http://www.w3.org/1999/xhtml" style="background:#e2f0ff; border:1px solid #8cb3d9; padding:1em; margin:1em 0;">
      <h3>DEBUG COLLECTION</h3>
      <p><strong>tei-count:</strong> {count($docs)}</p>
      <p><strong>first-id:</strong> {string(($docs[1]//tei:idno)[1])}</p>
      <p><strong>first-title:</strong> {normalize-space(string(($docs[1]//tei:title)[1]))}</p>
    </div>
};

(: Debug for new search - start :)
declare %templates:wrap function search:debug-search(
  $node as node(),
  $model as map(*),
  $collection as xs:string?,
  $sort-element as xs:string?
) {
  let $has-advanced :=
      normalize-space(request:get-parameter('generalKeyword', '')) != '' or
      normalize-space(request:get-parameter('searchTerm_1', '')) != '' or
      normalize-space(request:get-parameter('searchTerm_2', '')) != '' or
      normalize-space(request:get-parameter('searchTerm_3', '')) != '' or
      normalize-space(request:get-parameter('startYear', '')) != '' or
      normalize-space(request:get-parameter('endYear', '')) != ''

  let $queryExpr :=
      if($has-advanced)
      then data:create-advanced-query($collection)
      else if($collection = 'bibl')
      then bibls:query-string()
      else concat(
        data:build-collection-path($collection),
        data:create-query($collection),
        slider:date-filter(())
      )

  let $hits := data:search($collection, $queryExpr, $sort-element)

  return
    <div xmlns="http://www.w3.org/1999/xhtml" style="background:#fff3cd; border:1px solid #e0b800; padding:1em; margin:1em 0;">
      <h3>DEBUG SEARCH</h3>
      <p><strong>collection:</strong> {string($collection)}</p>
      <p><strong>sort-element:</strong> {string($sort-element)}</p>
      <p><strong>has-advanced:</strong> {string($has-advanced)}</p>
      <p><strong>request params:</strong> {string-join(request:get-parameter-names(), ', ')}</p>
      <p><strong>queryExpr:</strong></p>
      <pre>{string($queryExpr)}</pre>
      <p><strong>hit-count:</strong> {count($hits)}</p>
      <ul>{
        for $hit in subsequence($hits, 1, 5)
        let $id := string(($hit/descendant::tei:idno)[1])
        return <li>{$id}</li>
      }</ul>
    </div>
};
(: debug for new serch - end :)

(:~ 
 : Builds results output
:)
declare 
    %templates:default("start", 1)
function search:show-hits($node as node()*, $model as map(*), $collection as xs:string?, $kwic as xs:string?) {
    let $hits := $model("hits")
    let $facet-config := global:facet-definition-file($collection)
    return 
        if(not(empty($facet-config))) then 
            <div class="row" id="search-results" xmlns="http://www.w3.org/1999/xhtml">
                <div class="col-md-8 col-md-push-4">
                    <div class="indent" id="search-results" xmlns="http://www.w3.org/1999/xhtml">{
                            let $hits := $model("hits")
                            for $hit at $p in subsequence($hits, $search:start, $search:perpage)
                            let $id := replace($hit/descendant::tei:idno[1],'/tei','')
                            let $kwic := if($kwic = ('true','yes','true()','kwic')) then kwic:expand($hit) else () 
                            return 
                             <div class="row record" xmlns="http://www.w3.org/1999/xhtml" style="border-bottom:1px dotted #eee; padding-top:.5em">
                                 <div class="col-md-1" style="margin-right:-1em; padding-top:.25em;">        
                                     <span class="badge" style="margin-right:1em;">{$search:start + $p - 1}</span>
                                 </div>
                                 <div class="col-md-11" style="margin-right:-1em; padding-top:.25em;">
                                     {tei2html:summary-view($hit, '', $id)}
                                     {
                                        if($kwic//exist:match) then 
                                           tei2html:output-kwic($kwic, $id)
                                        else ()
                                     }
                                 </div>
                             </div>   
                    }</div>
                </div>
                <div class="col-md-4 col-md-pull-8">{
                 let $hits := $model("hits")
                 let $facet-config := global:facet-definition-file($collection)
                 return 
                     if(not(empty($facet-config))) then 
                         sf:display($model("hits"),$facet-config)
                     else ()  
                }</div>
        </div>
        else 
         <div class="indent" id="search-results" xmlns="http://www.w3.org/1999/xhtml">
         {
                 let $hits := $model("hits")
                 for $hit at $p in subsequence($hits, $search:start, $search:perpage)
                 let $id := replace($hit/descendant::tei:idno[1],'/tei','')
                 let $kwic := if($kwic = ('true','yes','true()','kwic')) then kwic:expand($hit) else () 
                 return 
                  <div class="row record" xmlns="http://www.w3.org/1999/xhtml" style="border-bottom:1px dotted #eee; padding-top:.5em">
                      <div class="col-md-1" style="margin-right:-1em; padding-top:.25em;">        
                          <span class="badge" style="margin-right:1em;">{$search:start + $p - 1}</span>
                      </div>
                      <div class="col-md-11" style="margin-right:-1em; padding-top:.25em;">
                          {tei2html:summary-view($hit, '', $id)}
                          {
                             if($kwic//exist:match) then 
                                tei2html:output-kwic($kwic, $id)
                             else ()
                          }
                      </div>
                  </div>   
         }</div>
};

(:~
 : Build advanced search form using either search-config.xml or the default form search:default-search-form()
 : @param $collection. Optional parameter to limit search by collection. 
 : @note Collections are defined in repo-config.xml
 : @note Additional Search forms can be developed to replace the default search form.
 : @depreciated: do a manual HTML build, add xquery keyboard options 
:)
declare function search:search-form($node as node(), $model as map(*), $collection as xs:string?){
if(exists(request:get-parameter-names())) then ()
else 
    let $search-config := 
        if($collection != '') then concat($config:app-root, '/', string(config:collection-vars($collection)/@app-root),'/','search-config.xml')
        else concat($config:app-root, '/','search-config.xml')
    return 
        if($collection ='bibl') then <div>{bibls:search-form()}</div>
        else if(doc-available($search-config)) then 
            search:build-form($search-config)             
        else search:default-search-form()
};

(:~
 : Builds a simple advanced search from the search-config.xml. 
 : search-config.xml provides a simple mechinisim for creating custom inputs and XPaths, 
 : For more complicated advanced search options, especially those that require multiple XPath combinations
 : we recommend you add your own customizations to search.xqm
 : @param $search-config a values to use for the default search form and for the XPath search filters.
 : @depreciated: do a manual HTML build, add xquery keyboard options 
:)
declare function search:build-form($search-config) {
    let $config := doc($search-config)
    return 
        <form method="get" class="form-horizontal indent" role="form">
            <h1 class="search-header">{if($config//label != '') then $config//label else 'Search'}</h1>
            {if($config//desc != '') then 
                <p class="indent info">{$config//desc}</p>
            else() 
            }
            <div class="well well-small search-box">
                <div class="row">
                    <div class="col-md-10">{
                        for $input in $config//input
                        let $name := string($input/@name)
                        let $id := concat('s',$name)
                        return 
                            <div class="form-group">
                                <label for="{$name}" class="col-sm-2 col-md-3  control-label">{string($input/@label)}: 
                                {if($input/@title != '') then 
                                    <span class="glyphicon glyphicon-question-sign text-info moreInfo" aria-hidden="true" data-toggle="tooltip" title="{string($input/@title)}"></span>
                                else ()}
                                </label>
                                <div class="col-sm-10 col-md-9 ">
                                    <div class="input-group">
                                        <input type="text" 
                                        id="{$id}" 
                                        name="{$name}" 
                                        data-toggle="tooltip" 
                                        data-placement="left" class="form-control keyboard"/>
                                        {($input/@title,$input/@placeholder)}
                                        {
                                            if($input/@keyboard='yes') then 
                                                <span class="input-group-btn">{global:keyboard-select-menu($id)}</span>
                                             else ()
                                         }
                                    </div> 
                                </div>
                            </div>}
                    </div>
                </div> 
            </div>
            <div class="pull-right">
                <button type="submit" class="btn btn-info">Search</button>&#160;
                <button type="reset" class="btn btn-warning">Clear</button>
            </div>
            <br class="clearfix"/><br/>
        </form> 
};

(:~
 : Simple default search form to us if not search-config.xml file is present. Can be customized. 
:)
declare function search:default-search-form() {
    <form method="get" class="form-horizontal indent" role="form">
        <h1 class="search-header">Search</h1>
        <div class="well well-small search-box">
            <div class="row">
                <div class="col-md-10">
                    <!-- Keyword -->
                    <div class="form-group">
                        <label for="q" class="col-sm-2 col-md-3  control-label">Keyword: </label>
                        <div class="col-sm-10 col-md-9 ">
                            <div class="input-group">
                                <input type="text" id="keyword" name="keyword" class="form-control keyboard"/>
                                <div class="input-group-btn">
                                {global:keyboard-select-menu('keyword')}
                                </div>
                            </div> 
                        </div>
                    </div>
                    <!-- Title-->
                    <div class="form-group">
                        <label for="title" class="col-sm-2 col-md-3  control-label">Title: </label>
                        <div class="col-sm-10 col-md-9 ">
                            <div class="input-group">
                                <input type="text" id="title" name="title" class="form-control keyboard"/>
                                <div class="input-group-btn">
                                {global:keyboard-select-menu('title')}
                                </div>
                            </div>   
                        </div>
                    </div>
                   <!-- Place Name-->
                    <div class="form-group">
                        <label for="placeName" class="col-sm-2 col-md-3  control-label">Place Name: </label>
                        <div class="col-sm-10 col-md-9 ">
                            <div class="input-group">
                                <input type="text" id="placeName" name="placeName" class="form-control keyboard"/>
                                <div class="input-group-btn">
                                {global:keyboard-select-menu('placeName')}
                                </div>
                            </div>   
                        </div>
                    </div>
                <!-- end col  -->
                </div>
                <!-- end row  -->
            </div>    
            <div class="pull-right">
                <button type="submit" class="btn btn-info">Search</button>&#160;
                <button type="reset" class="btn">Clear</button>
            </div>
            <br class="clearfix"/><br/>
        </div>
    </form>
};

(: Helper functions for new search page :)

(:~
:declare function search:advanced-search(
: :  $collection as xs:string?,
:   $sort-element as xs:string?
: ) {
:   let $block1 := search:run-block(1, $collection)
:   let $block2 := search:run-block(2, $collection)
:   let $block3 := search:run-block(3, $collection)
: 
:   let $hasBlocks := exists($block1) or exists($block2) or exists($block3)
: 
:   let $base :=
:     if($collection != '')
:     then collection(concat($config:data-root, '/', $collection))//tei:TEI
:     else collection($config:data-root)//tei:TEI
: 
:   let $combined12 :=
:     if(empty($block1) and empty($block2)) then ()
:     else if(empty($block1)) then $block2
:     else if(empty($block2)) then $block1
:     else search:combine-hits(
:       $block1,
:       $block2,
:       request:get-parameter('logicalOperator_2', 'AND')
:     )
: 
:   let $combined123 :=
:     if(empty($combined12) and empty($block3)) then ()
:     else if(empty($combined12)) then $block3
:     else if(empty($block3)) then $combined12
:     else search:combine-hits(
:       $combined12,
:       $block3,
:       request:get-parameter('logicalOperator_3', 'AND')
:     )
: 
:   let $generalKeyword := normalize-space(request:get-parameter('generalKeyword', ''))
: 
:   let $starting-set :=
:     if($hasBlocks) then $combined123 else $base
: 
:   let $afterGeneral :=
:     if($generalKeyword != '')
:     then
:       $starting-set[
:         ft:query(., data:clean-string($generalKeyword), data:search-options())
:       ]
:     else $starting-set
: 
:   let $afterYears := search:filter-by-year($afterGeneral)
:   return $afterYears
: };
: 
: declare function search:run-block(
:   $n as xs:integer,
:   $collection as xs:string?
: ) {
:   let $term := normalize-space(request:get-parameter(concat('searchTerm_', $n), ''))
:   let $entity := request:get-parameter(concat('entity_', $n), '')
:   let $type := request:get-parameter(concat('searchType_', $n), 'similar')
:   let $fields := tokenize(request:get-parameter(concat('teiElements_', $n), ''), ',\s*')
:   return
:     if($term = '') then ()
:     else data:advanced-block-search($collection, $entity, $fields, $term, $type)
: };
: 
: declare function search:combine-hits(
:   $left as node()*,
:   $right as node()*,
:   $op as xs:string
: ) as node()* {
:   if($op = 'OR') then ($left | $right)
:   else if($op = 'NOT') then $left except $right
:   else $left intersect $right
: };
: 
:)
declare function search:filter-by-year($hits as node()*) as node()* {
  let $start := normalize-space(request:get-parameter('startYear', ''))
  let $end := normalize-space(request:get-parameter('endYear', ''))
  return
    if($start = '' and $end = '') then $hits
    else
      for $hit in $hits
      let $year := search:get-record-year($hit)
      where
        ($start = '' or $year >= xs:integer($start))
        and
        ($end = '' or $year <= xs:integer($end))
      return $hit
};

declare function search:get-record-year($hit as node()) as xs:integer? {
  let $date :=
    (
      $hit//@when,
      $hit//@from,
      $hit//@to,
      $hit//tei:date/@when,
      $hit//tei:date/@syriaca-computed-start
    )[1]
  let $year :=
    if(matches(string($date), '^-?\d{1,4}'))
    then replace(string($date), '^(-?\d{1,4}).*$', '$1')
    else ()
  return
    if($year castable as xs:integer) then xs:integer($year) else ()
};
