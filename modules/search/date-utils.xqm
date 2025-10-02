xquery version "3.1";
module namespace dtu="http://srophe.org/modules/date-utils";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function dtu:int($s as xs:string?) as xs:integer? {
  if (not($s) or $s = "") then ()
  else xs:integer($s)
};

(: Basic overlap on @when/@notBefore/@notAfter :)
declare function dtu:overlaps-year($n as element(), $start as xs:string?, $end as xs:string?) as xs:boolean {
  let $s := dtu:int($start)
  let $e := dtu:int($end)
  let $when := dtu:int(string(($n//tei:origDate/@when)[1]))
  let $nb   := dtu:int(string(($n//tei:origDate/@notBefore)[1]))
  let $na   := dtu:int(string(($n//tei:origDate/@notAfter)[1]))
  let $low  := ($when, $nb,  -999999)[1]
  let $high := ($when, $na,  999999)[1]
  let $rqL  := coalesce(($s, -999999))
  let $rqH  := coalesce(($e,  999999))
  return not($high lt $rqL or $low gt $rqH)
};

declare function dtu:coalesce($seq as item()*) as item()? { head($seq[. != ()]) };

