xquery version "3.0";

import module namespace config="http://srophe.org/srophe/config" at "modules/config.xqm";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

(:
<div>
    $exist:path : {$exist:path}<br/>
    $exist:resource : {$exist:resource } <br/>
    $exist:controller : {$exist:controller} <br/>
    $exist:prefix : {$exist:prefix} <br/>
    $exist:root : {$exist:root}
</div>

<div>
$exist:record-uris : {$exist:record-uris} <br/>
$exist:collection-uris : {$exist:collection-uris}
</div>
:)

(: Get variables for Srophe collections. :)
declare variable $exist:record-uris  := 
    distinct-values(for $collection in $config:get-config//repo:collection
    let $short-path := replace($collection/@record-URI-pattern,$config:base-uri,'')
    return $short-path)    
;

(: Get variables for Srophe collections. :)
declare variable $exist:collection-uris  := 
    distinct-values(for $collection in $config:get-config//repo:collection
    let $short-path := replace($collection/@app-root,$config:base-uri,'')
    return concat('/',$short-path,'/'))    
; 

(: Get variables for Srophe collections. :)
declare variable $exist:app-root  := 
    distinct-values(for $collection in $config:get-config//repo:collection
    let $app-root := string($collection/@app-root)
    return string($collection/@app-root))    
; 


(: Send to content negotiation:)
declare function local:content-negotiation($exist:path, $exist:resource){
(:    if(starts-with($exist:resource, ('search', 'browse'))) then:)
    if(starts-with($exist:resource, 'browse')) then
        let $format := request:get-parameter('format', '')
        return 
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">        
            <forward url="{$exist:controller}/modules/content-negotiation/content-negotiation.xql"/>
            <add-parameter name="format" value="{$format}"/>
        </dispatch>
    else
        let $id := if($exist:resource = ('tei','xml','txt','pdf','json','geojson','kml','jsonld','rdf','ttl','atom')) then
                        tokenize(replace($exist:path,'/tei|/xml|/txt|/pdf|/json|/geojson|/kml|/jsonld|/rdf|/ttl|/atom',''),'/')[last()]
                   else replace(xmldb:decode($exist:resource), "^(.*)\..*$", "$1")
        let $record-uri-root := substring-before($exist:path,$id)
        let $id := if($config:get-config//repo:collection[ends-with(@record-URI-pattern, $record-uri-root)]) then
                        concat($config:get-config//repo:collection[ends-with(@record-URI-pattern, $record-uri-root)][1]/@record-URI-pattern,$id)
                   else $id
        let $html-path := concat($config:get-config//repo:collection[ends-with(@record-URI-pattern, $record-uri-root)][1]/@app-root,'record.html')
        let $format := if($exist:resource = ('tei','xml','txt','pdf','json','geojson','kml','jsonld','rdf','ttl','atom')) then
                            $exist:resource
                       else if(request:get-parameter('format', '') != '') then request:get-parameter('format', '')                            
                       else fn:tokenize($exist:resource, '\.')[fn:last()]
        return 
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">        
                <forward url="{$exist:controller}/modules/content-negotiation/content-negotiation.xql">
                    <add-parameter name="id" value="{$id}"/>
                    <add-parameter name="format" value="{$format}"/>
                </forward>
            </dispatch>
};

if ($exist:path eq '') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{request:get-uri()}/"/>
    </dispatch>
    
else if ($exist:path eq "/") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>

else if(contains($exist:path,'/d3xquery/')) then
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
    
else if(contains($exist:path,'/documentation/') and ends-with($exist:path,('.tei','.xml','.txt','.pdf'))) then
    (: Pass though XML,pdf and txt records everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
    
(: Passes any api requests to correct endpoint:)    
else if (contains($exist:path,'/api/')) then
  if (ends-with($exist:path,"/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{concat($config:nav-base,'/api-documentation/index.html')}"/>
    </dispatch> 
   else if($exist:resource = 'index.html') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{concat($config:nav-base,'/api-documentation/index.html')}"/>
    </dispatch>
   else if($exist:resource = 'oai') then
     <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{replace($exist:path,'/api/oai',concat($exist:controller,'/modules/oai.xql'))}"/>
     </dispatch>
   else if($exist:resource = 'sparql') then
     <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{replace($exist:path,'/api/sparql',concat($exist:controller,'/sparql/run-sparql.xql'))}"/>
     </dispatch>
    (: for new search :)
    
    (: end for new search :)
 
   else if(contains($exist:path, '/geo/')) then
        let $format := tokenize($exist:path,'/')[last()]
        return 
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{concat($exist:controller,'/modules/content-negotiation/content-negotiation.xql')}">
                <add-parameter name="api" value="'true'"/>
                <add-parameter name="geo" value="'true'"/>
                <add-parameter name="format" value="{if($format = 'json') then 'geojson' else if($format='kml') then 'kml' else 'xml'}"/>
            </forward>
        </dispatch>
   else
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <redirect url="{concat($config:nav-base,'/api-documentation/index.html')}"/>
        </dispatch>

(: new search: serve the single new search page at /search.html from modules/search/index.html :)        
(: /search.html → serve modules/search/index.html :)
else if ($exist:path = "/search.html") then
  <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <!-- RELATIVE to the app root; avoids wrong /db/apps/... path -->
    <forward url="modules/search/index.html"/>
    <cache-control cache="no"/>
  </dispatch>

(: Redirect old per-entity search pages to the single Advanced Search: /{entity}/search(.html) → /search.html, preserve query string  :)
else if (matches($exist:path, "^/(works|persons|places|relations|manuscripts|geo|bibl)/search(\\.html)?/?$")) then
  let $qs := request:get-query-string()
  let $app-url-base := request:get-context-path() || "/apps/majlis"   (: e.g. "/exist/apps/majlis" :)
  return
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
      <redirect url="{ $app-url-base || '/search.html' || (if ($qs) then '?'||$qs else '') }"/>
    </dispatch>

(: normalize: /search/, /search or /search/index.html → /search.html :)
else if (matches($exist:path, "^/search(/index\\.html)?/?$")) then
  let $qs := request:get-query-string()
  let $app-url-base := request:get-context-path() || "/apps/majlis"
  return
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
      <redirect url="{ $app-url-base || '/search.html' || (if ($qs) then '?'||$qs else '') }"/>
    </dispatch>

(: snippets for new seach ends here :)

        
(: Passes data to content negotiation module:)
else if(request:get-parameter('format', '') != '' and request:get-parameter('format', '') != 'html') then
    local:content-negotiation($exist:path, $exist:resource)
else if(ends-with($exist:path,('/tei','/xml','/txt','/pdf','/json','/geojson','/kml','/jsonld','/rdf','/ttl','/atom'))) then
    local:content-negotiation($exist:path, $exist:resource)
else if(ends-with($exist:resource,('.tei','.xml','.txt','.pdf','.json','.geojson','.kml','.jsonld','.rdf','.ttl','.atom'))) then
    local:content-negotiation($exist:path, $exist:resource)
else if(request:get-parameter('doc', '') != '') then
     <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <view>
                <forward url="{$exist:controller}/modules/view.xql"/>
            </view>
            <error-handler>
       			<forward url="{$exist:controller}/error-page.html" method="get"/>
       			<forward url="{$exist:controller}/modules/view.xql"/>
       		</error-handler>
        </dispatch>
(: Checks for any record uri patterns as defined in repo.xml :)   

else if(replace($exist:path, $exist:resource,'') =  $exist:record-uris or replace($exist:path, $exist:resource,'') = $exist:app-root) then
(:    if($exist:resource = ('index.html','search.html','browse.html','about.html')) then    :)
    if($exist:resource = ('index.html','browse.html','about.html')) then    
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <view>
                <forward url="{$exist:controller}/modules/view.xql"/>
            </view>
            <error-handler>
       			<forward url="{$exist:controller}/error-page.html" method="get"/>
       			<forward url="{$exist:controller}/modules/view.xql"/>
       		</error-handler>
        </dispatch>
    else 
        let $id := replace(xmldb:decode($exist:resource), "^(.*)\..*$", "$1")
        let $record-uri-root := replace($exist:path,$exist:resource,'')
        let $id := if($config:get-config//repo:collection[ends-with(@record-URI-pattern, $record-uri-root)]) then
                        concat($config:get-config//repo:collection[ends-with(@record-URI-pattern, $record-uri-root)][1]/@record-URI-pattern,$id)
                   else if($config:get-config//repo:collection[ends-with(@app-root, $record-uri-root)]) then      
                        concat($config:get-config//repo:collection[ends-with(@app-root, $record-uri-root)][1]/@record-URI-pattern,$id)
                   else $id
        let $html-path := if($config:get-config//repo:collection[ends-with(@record-URI-pattern, $record-uri-root)]) then 
                            concat($config:get-config//repo:collection[ends-with(@record-URI-pattern, $record-uri-root)][1]/@app-root,'record.html')
                          else concat($config:get-config//repo:collection[ends-with(@app-root, $record-uri-root)][1]/@app-root,'record.html')
        let $format := fn:tokenize($exist:resource, '\.')[fn:last()]
        return 
        (:<div>HTML page for id: [{$id}] root: [{$record-uri-root}] HTML: [{$html-path}] controler: [{$exist:controller}]</div>:)
           <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:controller}{$html-path}"></forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name="id" value="{$id}"/>
                    </forward>
                </view>
                <error-handler>
                    <forward url="{$exist:controller}/error-page.html" method="get"/>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </error-handler>
            </dispatch>
else if (ends-with($exist:resource, ".html")) then
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>

(: Resource paths starting with $nav-base are resolved relative to app :)
else if (contains($exist:path, "/$nav-base/")) then
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{concat($exist:controller,'/', substring-after($exist:path, '/$nav-base/'))}">
                <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
            </forward>
        </dispatch> 
        
(: Resource paths starting with $shared are loaded from the shared-resources app :)
else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>
    
(: Redirect folder roots to index.html:)    
else if ($exist:resource eq '' or ends-with($exist:path,"/")) then 
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{concat($config:nav-base,'/',$exist:path,'/index.html')}"/>
    </dispatch>   
    
    
(: Redirects paths with directory, and no trailing slash to index.html in that directory :)    
else if (matches($exist:resource, "^([^.]+)$")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{concat($config:nav-base,'/',$exist:path,'/index.html')}"/>
    </dispatch>  

else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
