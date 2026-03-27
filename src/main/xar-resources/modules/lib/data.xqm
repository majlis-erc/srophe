xquery version "3.0";
(:~  
 : Basic data interactions, returns raw data for use in other modules  
 : Used by ../app.xql and content-negotiation/content-negotiation.xql  
:)
module namespace data="http://srophe.org/srophe/data";

import module namespace config="http://srophe.org/srophe/config" at "../config.xqm";
import module namespace global="http://srophe.org/srophe/global" at "global.xqm";
import module namespace facet="http://expath.org/ns/facet" at "facet.xqm";
import module namespace sf="http://srophe.org/srophe/facets" at "facets.xql";
import module namespace slider = "http://srophe.org/srophe/slider" at "date-slider.xqm";
import module namespace functx="http://www.functx.com";

declare namespace srophe="https://srophe.app";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $data:QUERY_OPTIONS := map {
    "leading-wildcard": "yes",
    "filter-rewrite": "yes"
};

declare variable $data:SORT_FIELDS := $config:get-config//*:sortFields/*:fields;

(:~
 : Return document by id/tei:idno or document path
 : Return by id if get-parameter $id
 : Return by document path if @param $doc
:)
declare function data:get-document() {
    (: Get document by id or tei:idno:)
    let $id := (:if(ends-with(request:get-parameter('id', ''),'/tei')) then request:get-parameter('id', '') else concat(request:get-parameter('id', ''),'/tei'):)request:get-parameter('id', '')
    return 
        (collection($config:data-root)//tei:idno[@type='URI'][. = $id]/ancestor::tei:TEI | 
        collection($config:data-root)//tei:idno[@type='URI'][. = concat($id,'/')]/ancestor::tei:TEI |
        collection($config:data-root)//tei:idno[@type='URI'][. = concat($id,'/tei')]/ancestor::tei:TEI)[1]
    
};

(:~
 : Return document by id/tei:idno or document path
 : @param $id return document by id or tei:idno
 : @param $doc return document path relative to data-root
:)
declare function data:get-document($id as xs:string?) {
    let $id := if(ends-with(request:get-parameter('id', ''),'/tei')) then request:get-parameter('id', '') else concat(request:get-parameter('id', ''),'/tei')
    return 
    if(starts-with($id,'http')) then
        if($config:document-id) then 
            collection($config:data-root)//tei:idno[. = $id][@type='URI']/ancestor::tei:TEI
        else collection($config:data-root)/id($id)/ancestor::tei:TEI
    else if(starts-with($id,$config:data-root)) then 
            doc(xmldb:encode-uri($id || '.xml'))
    else doc(xmldb:encode-uri($config:data-root || "/" || $id || '.xml'))
};

(:~
  : @depreciated
  : Select correct tei element to base browse list on. 
  : Places use tei:place/tei:placeName
  : Persons use tei:person/tei:persName
  : Defaults to tei:title
:)
declare function data:element($element as xs:string?) as xs:string?{
    if(request:get-parameter('element', '') != '') then 
        request:get-parameter('element', '') 
    else if($element) then $element        
    else "tei:titleStmt/tei:title[@level='a']"  
};

(:~
 : @depreciated
 : Make XPath language filter. 
 : @param $element used to select browse element: persName/placeName/title
:)
declare function data:element-filter($element as xs:string?) as xs:string? {    
    if(request:get-parameter('lang', '') != '') then 
        if(request:get-parameter('alpha-filter', '') = 'ALL') then 
            concat("/descendant::",$element,"[@xml:lang = '", request:get-parameter('lang', ''),"']")
        else concat("/descendant::",$element,"[@xml:lang = '", request:get-parameter('lang', ''),"']")
    else
        if(request:get-parameter('alpha-filter', '') = 'ALL') then 
            concat("/descendant::",$element)
        else concat("/descendant::",$element)
};

(:~
 : Build browse/search path.
 : @param $collection name from repo-config.xml
 : @note parameters can be passed to function via the HTML templates or from the requesting url
 : @note there are two ways to define collections, physical collection and tei collection. TEI collection is defined in the seriesStmt
 : Enhancement: It would be nice to be able to pass in multiple collections to browse function
:)
declare function data:build-collection-path($collection as xs:string?) as xs:string?{  
    let $collection-path := 
            if(config:collection-vars($collection)/@data-root != '') then concat('/',config:collection-vars($collection)/@data-root)
            else if($collection != '') then concat('/',$collection)
            else ()
    let $get-series :=  
            if(config:collection-vars($collection)/@collection-URI != '') then string(config:collection-vars($collection)/@collection-URI)
            else ()                             
    let $series-path := 
            if($get-series != '') then concat("//tei:idno[. = '",$get-series,"'][ancestor::tei:seriesStmt]/ancestor::tei:TEI")
            else "//tei:TEI"
    return concat("collection('",$config:data-root,$collection-path,"')",$series-path)
};

(:~
 : Get all data for browse pages 
 : @param $collection collection to limit results set by
 : @param $element TEI element to base sort order on. 
:)
declare function data:get-records($collection as xs:string*, $element as xs:string?){
    let $sort := 
        if(request:get-parameter('sort', '') != '') then request:get-parameter('sort', '') 
        else if(request:get-parameter('sort-element', '') != '') then request:get-parameter('sort-element', '')
        else ()  
    let $hits := util:eval(data:build-collection-path($collection))[descendant::tei:body[ft:query(., (),sf:facet-query())]]                        
    return 
        if(request:get-parameter('view', '') = 'map') then $hits  
        else if(request:get-parameter('view', '') = 'timeline') then $hits
        else if($collection = 'manuscripts') then
            for $hit in $hits
            let $root := $hit/ancestor-or-self::tei:TEI
            let $s := ft:field($hit, "mssSort")[1] 
            order by number($s[1]) ascending  
            (:where matches($s[1],global:get-alpha-filter()):)
            return $root
        else if(request:get-parameter('alpha-filter', '') != '' 
            and request:get-parameter('alpha-filter', '') != 'All'
            and request:get-parameter('alpha-filter', '') != 'ALL'
            and request:get-parameter('alpha-filter', '') != 'all') then
                for $hit in $hits
                let $root := $hit/ancestor-or-self::tei:TEI
                let $s := 
                    if(contains($sort, 'author')) then ft:field($hit, "author")[1]
                    else if(request:get-parameter('sort', '') = 'title') then 
                        if(request:get-parameter('lang', '') = 'syr') then ft:field($hit, "titleSyriac")[1]
                        else if(request:get-parameter('lang', '') = 'ar') then ft:field($hit, "titleArabic")[1]
                        else ft:field($hit, "title")
                    else if(request:get-parameter('lang', '') = 'syr') then ft:field($hit, "titleSyriac")[1]
                    else if(request:get-parameter('lang', '') = 'ar') then ft:field($hit, "titleArabic")[1]
                    else if(request:get-parameter('sort', '') = $data:SORT_FIELDS) then
                        ft:field($hit, request:get-parameter('sort', ''))[1]
                    else if(request:get-parameter('sort', '') != '' and request:get-parameter('sort', '') != 'title' and not(contains($sort, 'author'))) then
                        if($collection = 'bibl') then
                            data:add-sort-options-bibl($hit, $sort)
                        else data:add-sort-options($hit, $sort) 
                    else ft:field($hit, "title")  
                    
                order by $s[1] collation 'http://www.w3.org/2013/collation/UCA'
                where matches($s[1],global:get-alpha-filter())
                return $root
        else 
                for $hit in $hits
                let $root := $hit/ancestor-or-self::tei:TEI
                let $s := 
                        if(contains($sort, 'author')) then ft:field($hit, "author")[1]
                        else if(request:get-parameter('sort', '') = 'title') then 
                            if(request:get-parameter('lang', '') = 'syr') then ft:field($hit, "titleSyriac")[1]
                            else if(request:get-parameter('lang', '') = 'ar') then ft:field($hit, "titleArabic")[1]
                            else ft:field($hit, "title")
                        else if(request:get-parameter('sort', '') = $data:SORT_FIELDS) then
                            ft:field($hit, request:get-parameter('sort', ''))[1]
                        else if(request:get-parameter('sort', '') != '' and request:get-parameter('sort', '') != 'title' and not(contains($sort, 'author'))) then
                            if($collection = 'bibl') then
                                data:add-sort-options-bibl($hit, $sort)
                            else data:add-sort-options($hit, $sort)  
                        else ft:field($hit, "title")                
                order by $s[1] collation 'http://www.w3.org/2013/collation/UCA', ft:field($hit, "author")[1]  collation 'http://www.w3.org/2013/collation/UCA'
                return $root 
};

(:~
 : Main search functions.
 : Build a search XPath based on search parameters. 
 : Add sort options. 
:)
declare function data:search($collection as xs:string*, $queryString as xs:string?, $sort-element as xs:string?) {                      
    let $eval-string := if($queryString != '') then $queryString 
                        else concat(data:build-collection-path($collection), data:create-query($collection), slider:date-filter(()))
    let $hits :=
            if(request:get-parameter-names() = '' or empty(request:get-parameter-names())) then 
                if($collection = 'bibl') then
                    collection($config:data-root || '/' || $collection)//tei:body[ft:query(., (), sf:facet-query())]
                else
                    collection($config:data-root || '/' || $collection)[not(contains(document-uri(root(.)), '/bibl/tei/'))]//tei:body[ft:query(., (), sf:facet-query())]
            else
                if($collection = 'bibl') then
                    util:eval($eval-string)//tei:body[ft:query(., (), sf:facet-query())]
                else
                    util:eval($eval-string)[not(contains(document-uri(root(.)), '/bibl/tei/'))]//tei:body[ft:query(., (), sf:facet-query())]      
    let $sort := if($sort-element != '') then 
                    $sort-element
                 else if(request:get-parameter('sort-element', '') != '') then
                    request:get-parameter('sort-element', '')
                 else ()
    return
        if((request:get-parameter('sort-element', '') != '' and request:get-parameter('sort-element', '') != 'relevance') or ($sort-element != '' and $sort-element != 'relevance')) then 
            for $hit in $hits/ancestor-or-self::tei:TEI
            let $s := 
                    if(contains($sort, 'author')) then ft:field($hit, "author")[1]
                    else if(request:get-parameter('sort', '') = 'title') then 
                        if(request:get-parameter('lang', '') = 'syr') then ft:field($hit, "titleSyriac")[1]
                        else if(request:get-parameter('lang', '') = 'ar') then ft:field($hit, "titleArabic")[1]
                        else ft:field($hit, "title")
                    else if(request:get-parameter('sort', '') = $data:SORT_FIELDS) then
                        ft:field($hit, request:get-parameter('sort', ''))[1]
                    else if(request:get-parameter('sort', '') != '' and request:get-parameter('sort', '') != 'title' and not(contains($sort, 'author'))) then
                        if($collection = 'bibl') then
                            data:add-sort-options-bibl($hit, $sort)
                        else data:add-sort-options($hit, $sort)                    
                    else ft:field($hit, "title")                
            order by $s collation 'http://www.w3.org/2013/collation/UCA'
            return $hit
        else 
            for $hit in $hits
            order by ft:score($hit) descending
            return $hit/ancestor-or-self::tei:TEI        
};

(:~
 : API search functions. Called from content-negotiation.xql
 : Build a search XPath based on search parameters. 
 : Add sort options. 
:)
declare function data:apiSearch($collection as xs:string*, $element as xs:string?, $queryString as xs:string?, $sort-element as xs:string?) {                      
    let $elementSearch :=  
                if(exists($element) and $element != '') then  
                    for $e in $element
                    return concat("/descendant::tei:",$element,"[ft:query(.,'",data:clean-string($queryString),"',data:search-options())]")            
                else concat('[descendant::tei:body[ft:query(.,"',$queryString,'",sf:facet-query())]]')
    let $eval-string := concat(data:build-collection-path($collection), $elementSearch)
    let $hits := util:eval($eval-string)     
    let $sort := if($sort-element != '') then 
                    $sort-element
                 else if(request:get-parameter('sort', '') != '') then
                    request:get-parameter('sort', '')
                 else if(request:get-parameter('sort-element', '') != '') then
                    request:get-parameter('sort-element', '')
                 else ()
    return 
        if((request:get-parameter('sort-element', '') != '' and request:get-parameter('sort-element', '') != 'relevance') or ($sort-element != '' and $sort-element != 'relevance')) then 
            for $hit in $hits
            let $s := 
                    if(contains($sort, 'author')) then ft:field($hit, "author")[1]
                    else if(request:get-parameter('sort', '') = 'title') then 
                        if(request:get-parameter('lang', '') = 'syr') then ft:field($hit, "titleSyriac")[1]
                        else if(request:get-parameter('lang', '') = 'ar') then ft:field($hit, "titleArabic")[1]
                        else ft:field($hit, "title")
                    else if(request:get-parameter('sort', '') = $data:SORT_FIELDS) then
                        ft:field($hit, request:get-parameter('sort', ''))[1]                  
                    else $hit              
            order by $s collation 'http://www.w3.org/2013/collation/UCA'
            return $hit
        else 
            for $hit in $hits
            order by ft:score($hit) descending
            return $hit
};
(:~   
 : Builds general search string.
:)
declare function data:create-query($collection as xs:string?) as xs:string?{
    let $search-config := 
        if($collection != '') then concat($config:app-root, '/', string(config:collection-vars($collection)/@app-root),'/','search-config.xml')
        else concat($config:app-root, '/','search-config.xml')
    return 
         if(doc-available($search-config)) then 
            concat(string-join(data:dynamic-paths($search-config),''),data:relation-search())
        else
            concat(
            data:keyword-search(),
            data:element-search('title',request:get-parameter('title', '')),
            data:element-search('author',request:get-parameter('author', '')),
            data:element-search('placeName',request:get-parameter('placeName', '')),
            data:relation-search()
            )               
};

(:~ 
 : Adds sort filter based on sort prameter
 : Currently supports sort on title, author, publication date and person dates
 : @param $sort-option
:)
declare function data:add-sort-options($hit, $sort-option as xs:string*){
    if($sort-option != '') then
        if($sort-option = 'title') then 
            global:build-sort-string($hit/descendant::tei:titleStmt/tei:title[1],request:get-parameter('lang', ''))
        else if($sort-option = 'author') then 
            if($hit/descendant::tei:titleStmt/tei:author[1]) then 
                if($hit/descendant::tei:titleStmt/tei:author[1]/descendant-or-self::tei:surname) then 
                    $hit/descendant::tei:titleStmt/tei:author[1]/descendant-or-self::tei:surname[1]
                else $hit//descendant::tei:author[1]
            else 
                if($hit/descendant::tei:titleStmt/tei:editor[1]/descendant-or-self::tei:surname) then 
                    $hit/descendant::tei:titleStmt/tei:editor[1]/descendant-or-self::tei:surname[1]
                else $hit/descendant::tei:titleStmt/tei:editor[1]
        else if($sort-option = 'pubDate') then 
            $hit/descendant::tei:teiHeader/descendant::tei:imprint[1]/descendant-or-self::tei:date[1]
        else if($sort-option = 'pubPlace') then 
            $hit/descendant::tei:teiHeader/descendant::tei:imprint[1]/descendant-or-self::tei:pubPlace[1]
        else if($sort-option = 'persDate') then
            if($hit/descendant::tei:birth) then $hit/descendant::tei:birth/@syriaca-computed-start
            else if($hit/descendant::tei:death) then $hit/descendant::tei:death/@syriaca-computed-start
            else ()
        else $hit
    else $hit
};

(:~ 
 : Adds sort filter based on sort prameter
 : Currently supports sort on title, author, publication date and person dates
 : @param $sort-option
:)
declare function data:add-sort-options-bibl($hit, $sort-option as xs:string*){
    if($sort-option != '') then
        if($sort-option = 'title') then 
            if($hit/descendant::tei:body/tei:biblStruct) then 
                global:build-sort-string($hit/descendant::tei:body/tei:biblStruct/descendant::tei:title[1],request:get-parameter('lang', ''))
            else global:build-sort-string($hit/descendant::tei:titleStmt/tei:title[1],request:get-parameter('lang', ''))
        else if($sort-option = 'author') then 
            if($hit/descendant::tei:body/tei:biblStruct) then 
                if($hit/descendant::tei:body/tei:biblStruct/descendant::tei:author) then 
                    if($hit/descendant::tei:body/tei:biblStruct/descendant::tei:author[1]/descendant-or-self::tei:surname) then 
                        $hit/descendant::tei:body/tei:biblStruct/descendant::tei:author[1]/descendant-or-self::tei:surname[1]
                    else $hit/descendant::tei:body/tei:biblStruct/descendant::tei:author[1]
                else 
                    if($hit/descendant::tei:body/tei:biblStruct/descendant::tei:editor[1]/descendant-or-self::tei:surname) then 
                        $hit/descendant::tei:body/tei:biblStruct/descendant::tei:editor[1]/descendant-or-self::tei:surname[1]
                    else $hit/descendant::tei:body/tei:biblStruct/descendant::tei:editor[1]
            else if($hit/descendant::tei:titleStmt/tei:author[1]) then 
                if($hit/descendant::tei:titleStmt/tei:author[1]/descendant-or-self::tei:surname) then 
                    $hit/descendant::tei:titleStmt/tei:author[1]/descendant-or-self::tei:surname[1]
                else $hit//descendant::tei:author[1]
            else 
                if($hit/descendant::tei:titleStmt/tei:editor[1]/descendant-or-self::tei:surname) then 
                    $hit/descendant::tei:titleStmt/tei:editor[1]/descendant-or-self::tei:surname[1]
                else $hit/descendant::tei:titleStmt/tei:editor[1]
        else if($sort-option = 'pubDate') then 
            if($hit/descendant::tei:body/tei:biblStruct/descendant::tei:imprint) then
                $hit/descendant::tei:body/tei:biblStruct/descendant::tei:imprint[1]/tei:date[1]
            else $hit/descendant::tei:teiHeader/descendant::tei:imprint[1]/descendant-or-self::tei:date[1]
        else if($sort-option = 'pubPlace') then 
            if($hit/descendant::tei:body/tei:biblStruct/descendant::tei:imprint/descendant-or-self::tei:pubPlace) then
                $hit/descendant::tei:body/tei:biblStruct/descendant::tei:imprint[1]/descendant-or-self::tei:pubPlace[1]
            else $hit/descendant::tei:teiHeader/descendant::tei:imprint[1]/descendant-or-self::tei:pubPlace[1]
        else if($sort-option = 'persDate') then
            if($hit/descendant::tei:birth) then $hit/descendant::tei:birth/@syriaca-computed-start
            else if($hit/descendant::tei:death) then $hit/descendant::tei:death/@syriaca-computed-start
            else ()
        else $hit
    else $hit
};


(:~ 
 : Adds sort filter based on sort prameter
 : Currently supports sort on title, author, publication date and person dates
 : @param $sort-option
:)
declare function data:sort-element($hit, $sort-element as xs:string*, $lang as xs:string?){
    if($sort-element != '') then
        if($sort-element = "tei:place/tei:placeName[@srophe:tags='#headword']") then 
            if($lang != '') then
                $hit/descendant::tei:place/tei:placeName[@srophe:tags='#headword'][@xml:lang=$lang][1]
            else $hit/descendant::tei:place/tei:placeName[@srophe:tags='#headword'][1]
        else if($sort-element = "tei:place/tei:placeName") then 
            if($lang != '') then
                $hit/descendant::tei:place/tei:placeName[@xml:lang=$lang][1]
            else $hit/descendant::tei:place/tei:placeName[1]            
        else if($sort-element = "tei:person/tei:persName[@srophe:tags='#headword']") then 
            if($lang != '') then
                $hit/descendant::tei:person/tei:pers[@srophe:tags='#headword'][@xml:lang=$lang][1]
            else $hit/descendant::tei:person/tei:pers[@srophe:tags='#headword'][1]
        else if($sort-element = "tei:person/tei:persName") then 
            if($lang != '') then
                $hit/descendant::tei:person/tei:persName[@xml:lang=$lang][1]
            else $hit/descendant::tei:person/tei:persName[1]
        else if($sort-element = "tei:titleStmt/tei:title[@level='a']") then 
            if($lang != '') then
                $hit/descendant::tei:titleStmt/tei:title[@level='a'][@xml:lang=$lang][1]
            else $hit/descendant::tei:titleStmt/tei:title[@level='a'][1]
        else if($sort-element = "tei:titleStmt/tei:title") then 
            if($lang != '') then
                $hit/descendant::tei:titleStmt/tei:title[@xml:lang=$lang][1]
            else $hit/descendant::tei:titleStmt/tei:title[1]
        else if($sort-element = "tei:title") then 
            if($lang != '') then
                $hit/descendant::tei:title[@xml:lang=$lang][1]
            else $hit/descendant::tei:title[1]
        else 
            if($lang != '') then
                util:eval(concat('$hit/descendant::',$sort-element,'[@xml:lang="',$lang,'"][1]'))
            else util:eval(concat('$hit/descendant::',$sort-element,'[1]'))            
    else $hit/descendant::tei:titleStmt/tei:title[1]
};

(:~
 : Search options passed to ft:query functions
 : Defaults to AND
:)
declare function data:search-options(){
    <options>
        <default-operator>and</default-operator>
        <phrase-slop>1</phrase-slop>
        <leading-wildcard>yes</leading-wildcard>
        <filter-rewrite>yes</filter-rewrite>
    </options>
};

(:~
 : Cleans search parameters to replace bad/undesirable data in strings
 : @param-string parameter string to be cleaned
:)
declare function data:clean-string($string){
let $query-string := $string
let $query-string := 
	   if (functx:number-of-matches($query-string, '"') mod 2) then 
	       replace($query-string, '"', ' ')
	   else $query-string   (:if there is an uneven number of quotation marks, delete all quotation marks.:)
let $query-string := 
	   if ((functx:number-of-matches($query-string, '\(') + functx:number-of-matches($query-string, '\)')) mod 2 eq 0) 
	   then $query-string
	   else translate($query-string, '()', ' ') (:if there is an uneven number of parentheses, delete all parentheses.:)
let $query-string := 
	   if ((functx:number-of-matches($query-string, '\[') + functx:number-of-matches($query-string, '\]')) mod 2 eq 0) 
	   then $query-string
	   else translate($query-string, '[]', ' ') (:if there is an uneven number of brackets, delete all brackets.:)
let $query-string := replace($string,"'","''")	   
return 
    if(matches($query-string,"(^\*$)|(^\?$)")) then 'Invalid Search String, please try again.' (: Must enter some text with wildcard searches:)
    else replace(replace($query-string,'<|>|@|&amp;',''), '(\.|\[|\]|\\|\||\-|\^|\$|\+|\{|\}|\(|\)|(/))','\\$1')

};

(:~
 : Build XPath filters from values in search-config.xml
 : Matches request paramters with @name in search-config to find the matching XPath. 
:)
declare function data:dynamic-paths($search-config as xs:string?){
    let $config := doc($search-config)
    let $params := request:get-parameter-names()
    return string-join(
        for $p in $params
        return 
            if(request:get-parameter($p, '') != '') then
                if($p = 'keyword') then
                    data:keyword-search()
                else if(string($config//input[@name = $p]/@element) = '.') then
                    concat("[ft:query(.//tei:body,'",data:clean-string(request:get-parameter($p, '')),"',data:search-options())]")
                else if(string($config//input[@name = $p]/@element) != '') then
                    concat("[ft:query(.//",string($config//input[@name = $p]/@element),",'",data:clean-string(request:get-parameter($p, '')),"',data:search-options())]")
                else ()    
            else (),'')
};

(:
 : General keyword anywhere search function 
:)
declare function data:keyword-search(){
    if(request:get-parameter('keyword', '') != '') then 
        for $query in request:get-parameter('keyword', '') 
        return concat("[ft:query(.//tei:body,'",data:clean-string($query),"',data:search-options()) or ft:query(.//tei:teiHeader,'",data:clean-string($query),"',data:search-options())]")
    else if(request:get-parameter('q', '') != '') then 
        for $query in request:get-parameter('q', '') 
        return concat("[ft:query(.//tei:body,'",data:clean-string($query),"',data:search-options()) or ft:query(.//tei:teiHeader,'",data:clean-string($query),"',data:search-options())]")
    else ()
};

(:~
 : Add a generic relationship search to any search module. 
:)
declare function data:relation-search(){
    if(request:get-parameter('relation-id', '') != '') then
        if(request:get-parameter('relation-type', '') != '') then
            concat("[descendant::tei:relation[@passive[matches(.,'",request:get-parameter('relation-id', ''),"(\W.*)?$')] or @mutual[matches(.,'",request:get-parameter('relation-id', ''),"(\W.*)?$')]][@ref = '",request:get-parameter('relation-type', ''),"' or @name = '",request:get-parameter('relation-type', ''),"']]")
        else concat("[descendant::tei:relation[@passive[matches(.,'",request:get-parameter('relation-id', ''),"(\W.*)?$')] or @mutual[matches(.,'",request:get-parameter('relation-id', ''),"(\W.*)?$')]]]")
    else ()
};

(:~
 : Generic URI search
 : Searches record URIs and also references to record ids.
:)
declare function data:uri() as xs:string? {
    if(request:get-parameter('uri', '') != '') then 
        let $q := request:get-parameter('uri', '')
        return 
        concat("
        [ft:query(descendant::*,'&quot;",$q,"&quot;',data:search-options()) or 
            .//@passive[matches(.,'",$q,"(\W.*)?$')]
            or 
            .//@mutual[matches(.,'",$q,"(\W.*)?$')]
            or 
            .//@active[matches(.,'",$q,"(\W.*)?$')]
            or 
            .//@ref[matches(.,'",$q,"(\W.*)?$')]
            or 
            .//@target[matches(.,'",$q,"(\W.*)?$')]
        ]")
    else ''    
};

(:
 : General search function to pass in any TEI element. 
 : @param $element element name must have a lucene index defined on the element
 : @param $query query text to be searched. 
:)
declare function data:element-search($element, $query){
    if(exists($element) and $element != '') then 
        if(request:get-parameter($element, '') != '') then 
            for $e in $element
            return concat("[ft:query(descendant::tei:",$element,",'",data:clean-string($query),"',data:search-options())]")            
        else ()
    else ()
};

(:
 : Add your custom search paths here: 
 : Example of a complex search used by Syriaca.org
 : Search for bibl records with matching URI
 declare function search:bibl(){
    if($search:bibl != '') then  
        let $terms := data:clean-string($search:bibl)
        let $ids := 
            if(matches($search:bibl,'^http://syriaca.org/')) then
                normalize-space($search:bibl)
            else 
                string-join(distinct-values(
                for $r in collection($global:data-root || '/bibl')//tei:body[ft:query(.,$terms, data:search-options())]/ancestor::tei:TEI/descendant::tei:publicationStmt/tei:idno[starts-with(.,'http://syriaca.org')][1]
                return concat(substring-before($r,'/tei'),'(\s|$)')),'|')
        return concat("[descendant::tei:bibl/tei:ptr[@target[matches(.,'",$ids,"')]]]")
    else ()  
};
:)

(: Functions for new serch :)

declare function data:advanced-block-search(
  $collection as xs:string?,
  $entity as xs:string?,
  $fields as xs:string*,
  $term as xs:string,
  $type as xs:string
) as node()* {
  let $docs := data:advanced-entity-base($collection, $entity)
  let $query := data:clean-string($term)
  return
    if(empty($fields))
    then data:search-all-default-fields($docs, $entity, $query, $type)
    else data:search-selected-fields($docs, $entity, $fields, $query, $type)
};

declare function data:advanced-entity-base(
  $collection as xs:string?,
  $entity as xs:string?
) as node()* {
  let $base :=
    if($collection != '')
    then collection(concat($config:data-root, '/', $collection))//tei:TEI
    else collection($config:data-root)//tei:TEI

  return
    if($entity = 'person') then $base[.//tei:person]
    else if($entity = 'place') then $base[.//tei:place]
    else if($entity = 'work') then $base[.//tei:body/tei:bibl]
    else if($entity = 'manuscript') then $base[.//tei:msDesc]
    else $base
};

declare function data:search-all-default-fields(
  $docs as node()*,
  $entity as xs:string?,
  $query as xs:string,
  $type as xs:string
) as node()* {
  if($entity = 'person') then
    $docs[
      data:match-node(.//tei:persName, $query, $type) or
      data:match-node(.//tei:note, $query, $type)
    ]
  else if($entity = 'place') then
    $docs[
      data:match-node(.//tei:placeName, $query, $type) or
      data:match-node(.//tei:note, $query, $type)
    ]
  else if($entity = 'work') then
    $docs[
      data:match-node(.//tei:title, $query, $type) or
      data:match-node(.//tei:author, $query, $type) or
      data:match-node(.//tei:textLang, $query, $type) or
      data:match-node(.//tei:term, $query, $type)
    ]
  else if($entity = 'manuscript') then
    $docs[
      data:match-node(.//tei:msContents, $query, $type) or
      data:match-node(.//tei:physDesc, $query, $type) or
      data:match-node(.//tei:history, $query, $type)
    ]
  else
    $docs[
      data:match-node(.//tei:body, $query, $type) or
      data:match-node(.//tei:teiHeader, $query, $type)
    ]
};

declare function data:search-selected-fields(
  $docs as node()*,
  $entity as xs:string?,
  $fields as xs:string*,
  $query as xs:string,
  $type as xs:string
) as node()* {
  $docs[
    some $field in $fields satisfies data:match-field(., $entity, $field, $query, $type)
  ]
};

declare function data:match-field(
  $doc as node(),
  $entity as xs:string?,
  $field as xs:string,
  $query as xs:string,
  $type as xs:string
) as xs:boolean {
  if($entity = 'person' and $field = 'name') then data:match-node($doc//tei:persName, $query, $type)
  else if($entity = 'person' and $field = 'biography') then data:match-node($doc//tei:note, $query, $type)

  else if($entity = 'place' and $field = 'name') then data:match-node($doc//tei:placeName, $query, $type)

  else if($entity = 'work' and $field = 'title') then data:match-node($doc//tei:title, $query, $type)
  else if($entity = 'work' and $field = 'author') then data:match-node($doc//tei:author, $query, $type)
  else if($entity = 'work' and $field = 'language') then data:match-node($doc//tei:textLang, $query, $type)
  else if($entity = 'work' and $field = 'subject') then data:match-node($doc//tei:term, $query, $type)

  else if($entity = 'manuscript' and $field = 'content') then data:match-node($doc//tei:msContents, $query, $type)
  else if($entity = 'manuscript' and $field = 'codicology') then data:match-node($doc//tei:physDesc, $query, $type)
  else if($entity = 'manuscript' and $field = 'history') then data:match-node($doc//tei:history, $query, $type)

  else false()
};

declare function data:match-node(
  $nodes as node()*,
  $query as xs:string,
  $type as xs:string
) as xs:boolean {
  if(empty($nodes)) then false()
  else if($type = 'exact') then
    some $n in $nodes satisfies contains(lower-case(normalize-space(string($n))), lower-case($query))
  else
    some $n in $nodes satisfies ft:query($n, $query, data:search-options())
};


declare function data:default-fields-for-entity($entity as xs:string?) as xs:string* {
  if($entity = 'manuscript') then ('content', 'codicology', 'history')
  else if($entity = 'work') then ('title', 'author', 'language', 'subject')
  else if($entity = 'person') then ('name', 'biography')
  else if($entity = 'place') then ('name')
  else ()
};

declare function data:field-path(
  $entity as xs:string?,
  $field as xs:string?
) as xs:string? {
  if($entity = 'manuscript' and $field = 'content') then 'descendant::tei:msContents'
  else if($entity = 'manuscript' and $field = 'codicology') then 'descendant::tei:physDesc'
  else if($entity = 'manuscript' and $field = 'history') then 'descendant::tei:history'

  else if($entity = 'work' and $field = 'title') then 'descendant::tei:body/tei:bibl/tei:title'
  else if($entity = 'work' and $field = 'author') then 'descendant::tei:author'
  else if($entity = 'work' and $field = 'language') then 'descendant::tei:textLang'
  else if($entity = 'work' and $field = 'subject') then 'descendant::tei:note'

  else if($entity = 'person' and $field = 'name') then 'descendant::tei:persName'
  else if($entity = 'person' and $field = 'biography') then "descendant::tei:note[@type='biography']"

  else if($entity = 'place' and $field = 'name') then 'descendant::tei:placeName'
  else ''
};

declare function data:field-query(
  $path as xs:string,
  $term as xs:string,
  $type as xs:string
) as xs:string {
  if($type = 'exact') then
    concat($path, "[contains(lower-case(normalize-space(.)), lower-case('", data:clean-string($term), "'))]")
  else
    concat($path, "[ft:query(., '", data:clean-string($term), "', data:search-options())]")
};

declare function data:advanced-field-clause(
  $entity as xs:string?,
  $fields as xs:string*,
  $term as xs:string,
  $type as xs:string
) as xs:string {
  let $selected :=
    if(empty($fields)) then data:default-fields-for-entity($entity)
    else $fields

  let $clauses :=
    for $field in $selected
    let $path := data:field-path($entity, $field)
    where $path != ''
    return data:field-query($path, $term, $type)

  return
    if(empty($clauses)) then
      concat("ft:query(., '", data:clean-string($term), "', data:search-options())")
    else
      string-join($clauses, ' or ')
};

declare function data:advanced-entity-filter($entity as xs:string?) as xs:string {
  if($entity = 'manuscript') then 'descendant::tei:msDesc'
  else if($entity = 'work') then 'descendant::tei:body/tei:bibl'
  else if($entity = 'person') then 'descendant::tei:listPerson'
  else if($entity = 'place') then 'descendant::tei:listPlace'
  else 'true()'
};

declare function data:advanced-general-keyword() as xs:string? {
  let $q := normalize-space(request:get-parameter('generalKeyword', ''))
  return
    if($q = '') then ''
    else concat(
      "[",
      "ft:query(descendant::tei:body, '", data:clean-string($q), "', data:search-options())",
      " or ",
      "ft:query(descendant::tei:teiHeader, '", data:clean-string($q), "', data:search-options())",
      "]"
    )
};

declare function data:all-entity-fields-clause(
  $term as xs:string,
  $type as xs:string
) as xs:string {
  let $entities := ('manuscript', 'work', 'person', 'place')
  let $clauses :=
    for $e in $entities
    return concat(
      '((',  data:advanced-entity-filter($e), ') and (',
      data:advanced-field-clause($e, (), $term, $type),
      '))'
    )
  return string-join($clauses, ' or ')
};

declare function data:advanced-block-query($n as xs:integer) as xs:string? {
  let $term := normalize-space(request:get-parameter(concat('searchTerm_', $n), ''))
  let $entity := normalize-space(request:get-parameter(concat('entity_', $n), ''))
  let $type := normalize-space(request:get-parameter(concat('searchType_', $n), 'similar'))
  let $fields :=
    let $raw := normalize-space(request:get-parameter(concat('teiElements_', $n), ''))
    return
      if($raw = '') then ()
      else tokenize($raw, ',\s*')

  let $fieldClause :=
    if($entity = '' and empty($fields)) then
      data:all-entity-fields-clause($term, $type)
    else
      data:advanced-field-clause($entity, $fields, $term, $type)

  return
    if($term = '') then ''
    else if($entity != '') then
      concat("[(", data:advanced-entity-filter($entity), ") and (", $fieldClause, ")]")
    else
      concat("[", $fieldClause, "]")
};

declare function data:advanced-boolean-op($op as xs:string?) as xs:string {
  if($op = 'OR') then 'or'
  else if($op = 'NOT') then 'and not'
  else 'and'
};

declare function data:combine-advanced-blocks(
  $block1 as xs:string?,
  $block2 as xs:string?,
  $block3 as xs:string?
) as xs:string? {
  let $op2 := normalize-space(request:get-parameter('logicalOperator_2', 'AND'))
  let $op3 := normalize-space(request:get-parameter('logicalOperator_3', 'AND'))

  let $combined12 :=
    if($block1 = '' and $block2 = '') then ''
    else if($block1 = '') then $block2
    else if($block2 = '') then $block1
    else concat(
      "[",
      substring($block1, 2, string-length($block1) - 2),
      " ",
      data:advanced-boolean-op($op2),
      " ",
      substring($block2, 2, string-length($block2) - 2),
      "]"
    )

  return
    if($combined12 = '' and $block3 = '') then ''
    else if($combined12 = '') then $block3
    else if($block3 = '') then $combined12
    else concat(
      "[",
      substring($combined12, 2, string-length($combined12) - 2),
      " ",
      data:advanced-boolean-op($op3),
      " ",
      substring($block3, 2, string-length($block3) - 2),
      "]"
    )
};

declare function data:create-advanced-query($collection as xs:string?) as xs:string? {
  let $base := data:build-collection-path($collection)
  let $block1 := data:advanced-block-query(1)
  let $block2 := data:advanced-block-query(2)
  let $block3 := data:advanced-block-query(3)
  let $combined := data:combine-advanced-blocks($block1, $block2, $block3)

  let $hasAdvancedTerms :=
    normalize-space(request:get-parameter('searchTerm_1', '')) != '' or
    normalize-space(request:get-parameter('searchTerm_2', '')) != '' or
    normalize-space(request:get-parameter('searchTerm_3', '')) != ''

  let $general :=
    if($hasAdvancedTerms) then ''
    else data:advanced-general-keyword()

  return concat(
    $base,
    $general,
    $combined,
    slider:date-filter(())
  )
};


