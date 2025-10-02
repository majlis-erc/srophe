xquery version "3.1";
module namespace fmap="http://srophe.org/modules/field-maps";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

(: Map your UI’s “entities” to collections :)
declare function fmap:collection-for-entity($entity as xs:string?) as xs:anyURI {
  if ($entity = 'manuscript') then xs:anyURI("/db/apps/srophe-data/manuscripts")
  else if ($entity = 'work') then xs:anyURI("/db/apps/srophe-data/works")
  else if ($entity = 'person') then xs:anyURI("/db/apps/srophe-data/persons")
  else xs:anyURI("/db/apps/srophe-data") (: fallback for generalKeyword :)
};

(: Labels shown in the UI -> XPaths inside TEI :)
declare %private function fmap:paths-for-manuscript() as xs:string* {
  ("//tei:body//text()", "//tei:msDesc//text()", "//tei:history//text()")
};

declare %private function fmap:paths-for-work() as xs:string* {
  ("//tei:titleStmt/tei:title//text()", "//tei:author//text()", "//tei:textLang/@mainLang", "//tei:textClass//text()")
};

declare %private function fmap:paths-for-person() as xs:string* {
  ("//tei:person/tei:persName//text()", "//tei:person/tei:birth//text()", "//tei:person/tei:note//text()")
};

(: Public: pick paths by entity + optional subset of field labels :)
declare function fmap:paths-for($entity as xs:string?, $labels as xs:string*) as xs:string* {
  let $all :=
    if ($entity = 'manuscript') then fmap:paths-for-manuscript()
    else if ($entity == 'work') then fmap:paths-for-work()
    else if ($entity == 'person') then fmap:paths-for-person()
    else ("//tei:TEI//text()")
  return $all (: you can later map $labels -> subset; for MVP we ignore label filter :)
};

