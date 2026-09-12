xquery version "3.1";

(:~
 : Year-range / exact-year date matching for the advanced search form (fix/search-date).
 :
 : RANGE  ("From (not before)" / "To (not after)" inputs) -> interval-overlap match
 :   Record lower bound = @notBefore, else @from, else @when, else earliest year in text
 :   Record upper bound = @notAfter,  else @to,   else @when, else latest year in text
 :   (@when is kept as a fallback for BOTH bounds so a point date such as
 :    <date when="1038"/> still answers "before 1050". Remove the ds:year($date/@when)
 :    line from ds:lower / ds:upper for strict notBefore/notAfter/from/to-only
 :    semantics.)
 :   A bound with no source is open (empty()). The record matches when its interval
 :   overlaps the query interval:  recStart <= qEnd  and  recEnd >= qStart
 :   (inclusive; an open end drops that half of the test).
 :
 : EXACT  ("Exact year" input, value Z) -> "the date is pinned to year Z"
 :   year(@when) = Z
 :   else @notBefore = @notAfter = Z          (a bracket that pins a single year)
 :   else @from = @to = Z
 :   else Z is one of the standalone 1-4 digit numbers in the date's text value
 :        ("1038", "in 1038 CE", "1038-1042" all yield 1038; the "103" inside
 :         "1038" is NOT matched)
 :   Exact year overrides From / To when both are supplied.
 :
 : A record with no usable date in the searched field is dropped, unless
 : "Include undated records" (includeUndated_<n>) was ticked.
 :
 : Runs as an in-memory post-filter (ds:filter) over the hit set already narrowed
 : by the term/entity query - no collection.xconf / range index is involved.
 :
 : NOTE: Syriaca @syriaca-computed-start / -end (normalised, machine-sortable
 : bounds) are intentionally NOT consulted (they do not occur anywhere in the
 : current majlis-data). If the data later populates them reliably they are the
 : best source - add ds:year($date/@syriaca-computed-start) as the first entry of
 : ds:lower and ds:year($date/@syriaca-computed-end) as the first entry of ds:upper.
 :
 : KNOWN LIMITATIONS (verified against majlis-data, fix/search-date):
 :
 :  1. Non-Gregorian years in the text bleed into the bounds when a <date> has no
 :     usable @when/@notBefore/@from/@notAfter/@to. ds:text-years() just collects
 :     every 1-4 digit run, so a Hijri year counts as a Gregorian one.
 :       person/14 birth = <date notAfter="1045">before 436 AH/1045 CE</date>
 :       -> derived interval [436, 1045]  (436 is the AH year)
 :       - "Birth To (not after) <= 950"  -> MATCHES  (upper 1045 unknown-low; ok)
 :       - "Birth From 500 To 900"        -> MATCHES  (WRONG - 436 is a false low)
 :       - "Birth Exact 436"              -> MATCHES  (WRONG - 436 is the AH year)
 :       - "Birth Exact 1045" / "<= 1045" -> MATCHES  (fine)
 :     Impact is limited: a spurious low bound only widens an interval, so it can
 :     only cause false POSITIVES for a fully-bounded "From X To Y" query, never a
 :     false negative. Real @notBefore/@notAfter always win over the text.
 :
 :  2. "Nth century" text is read as the number N, not the century span.
 :       <date>11th century</date>  -> interval [11, 11]  (NOT [1001, 1100])
 :       - "To (not after) <= 1050" -> MATCHES   (11 <= 1050, accidentally right)
 :       - "From (not before) >= 1000" -> NO MATCH  (WRONG - 11th c. is after 1000)
 :       - "From 1001 To 1100"      -> NO MATCH   (WRONG)
 :       - "Exact 11"               -> MATCHES    (odd)
 :     Not currently triggered by majlis-data persons/works: every "Nth century"
 :     string there also carries a real @when (e.g. <date when="1000">10th
 :     century</date>), and @when wins. Only bare century text is affected.
 :
 :  3. Multiple <date> children under one event + "Include undated records" ON:
 :     ds:any-match() is an OR over the children, and an empty <date/> child
 :     evaluates to the include-undated flag, so ONE blank sibling makes the whole
 :     event match anything.
 :       person/5 death = [<date when="1000">10th century</date>, <date/>]
 :       - "Death From (not before) >= 1050", undated OFF -> NO MATCH  (correct)
 :       - "Death From (not before) >= 1050", undated ON  -> MATCHES   (quirk)
 :       - "Death Exact 1200",              undated ON    -> MATCHES   (quirk)
 :     With the toggle OFF the real date is judged normally. Accepted as
 :     consistent with "be permissive when Include undated is on".
 :)
module namespace ds = "http://srophe.org/srophe/date-search";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

(:~
 : Leading (optionally negative, optionally zero-padded) year of a single value:
 : xs:date "1038-05-28", xs:gYear "1038", ISO negative "-0431", or year-leading
 : free text ("1038 CE"). Anything else -> empty(). 1-4 digit rule matches
 : search:get-record-year().
 :)
declare function ds:year($value as xs:string?) as xs:integer? {
    let $v := normalize-space(string($value))
    return
        if ($v != '' and matches($v, '^-?\d{1,4}'))
        then xs:integer(replace($v, '^(-?\d{1,4}).*$', '$1'))
        else ()
};

(:~
 : Every standalone 1-4 digit number in a free-text date value, as integers.
 : Splitting on non-digits keeps "1038" a token (so "103" never matches inside
 : "1038") while still finding the year in "in 1038 CE" or "1038-1042".
 :)
declare function ds:text-years($text as xs:string?) as xs:integer* {
    for $tok in tokenize(normalize-space(string($text)), '\D+')
    where $tok ne '' and string-length($tok) le 4 and $tok castable as xs:integer
    return xs:integer($tok)
};

(:~ Earliest possible year of a tei:date; empty() = no lower bound. :)
declare function ds:lower($date as element(tei:date)) as xs:integer? {
    (ds:year($date/@notBefore),
     ds:year($date/@from),
     ds:year($date/@when),
     min(ds:text-years(string($date))))[1]
};

(:~ Latest possible year of a tei:date; empty() = no upper bound. :)
declare function ds:upper($date as element(tei:date)) as xs:integer? {
    (ds:year($date/@notAfter),
     ds:year($date/@to),
     ds:year($date/@when),
     max(ds:text-years(string($date))))[1]
};

(:~
 : Does one tei:date satisfy $spec (a ds:spec map)? A date with no usable value
 : follows $include-undated.
 :)
declare function ds:date-passes(
    $date as element(tei:date),
    $spec as map(*),
    $include-undated as xs:boolean
) as xs:boolean {
    if ($spec?mode = 'exact')
    then
        (: pinned-to-year-Z test :)
        let $z    := $spec?year
        let $when := ds:year($date/@when)
        let $nb   := ds:year($date/@notBefore)
        let $na   := ds:year($date/@notAfter)
        let $from := ds:year($date/@from)
        let $to   := ds:year($date/@to)
        let $txt  := ds:text-years(string($date))
        return
            if (exists($when))                      then $when = $z
            else if (exists($nb) and $nb = $na)     then $nb = $z
            else if (exists($from) and $from = $to) then $from = $z
            else if (exists($txt))                  then $txt = $z
            else $include-undated
    else
        (: interval-overlap test, open bounds allowed on either side :)
        let $lo := ds:lower($date)
        let $hi := ds:upper($date)
        return
            if (empty($lo) and empty($hi))
            then $include-undated
            else
                ((empty($lo) or empty($spec?hi) or $lo <= $spec?hi)
                 and
                 (empty($hi) or empty($spec?lo) or $hi >= $spec?lo))
};

(:~
 : Does ANY of $dates satisfy $spec? An empty $dates sequence (the record has no
 : such date element at all) follows $include-undated.
 :)
declare function ds:any-match(
    $dates as element(tei:date)*,
    $spec as map(*),
    $include-undated as xs:boolean
) as xs:boolean {
    if (empty($dates))
    then $include-undated
    else some $d in $dates satisfies ds:date-passes($d, $spec, $include-undated)
};

(:~
 : Build the date spec for one date group of criteria block $n from request
 : parameters. $prefix is '' for the bare work / manuscript params (notBefore_1,
 : exactYear_1) or 'birth' / 'death' / 'florit' for the person params
 : (deathNotBefore_1 ...). Returns
 :   map { "mode": "exact", "year": Z }
 :   map { "mode": "range", "lo": xs:integer?, "hi": xs:integer? }
 :   empty()   when the user supplied nothing for this group
 : Legacy When_ params (old bookmarked URLs) are still read and treated as an
 : exact year.
 :)
declare function ds:spec($prefix as xs:string, $n as xs:integer) as map(*)? {
    (: bare params are lower-camel (notBefore_1); prefixed ones capitalise the
       suffix (deathNotBefore_1) - match whatever the form actually submits. :)
    let $key := function($suffix as xs:string) as xs:string {
        if ($prefix = '')
        then lower-case(substring($suffix, 1, 1)) || substring($suffix, 2) || '_' || $n
        else $prefix || $suffix || '_' || $n
    }
    let $get := function($suffix as xs:string) as xs:string {
        normalize-space(request:get-parameter($key($suffix), ''))
    }
    let $exact := ($get('ExactYear')[. ne ''], $get('When')[. ne ''])[1]
    return
        if (exists($exact) and $exact castable as xs:integer)
        then map { "mode": "exact", "year": xs:integer($exact) }
        else
            let $lo := $get('NotBefore')
            let $hi := $get('NotAfter')
            return
                if ($lo eq '' and $hi eq '')
                then ()
                else map {
                    "mode": "range",
                    "lo": (if ($lo ne '' and $lo castable as xs:integer) then xs:integer($lo) else ()),
                    "hi": (if ($hi ne '' and $hi castable as xs:integer) then xs:integer($hi) else ())
                }
};

(:~ Was "Include undated records" ticked for criteria block $n? :)
declare function ds:include-undated($n as xs:integer) as xs:boolean {
    normalize-space(request:get-parameter('includeUndated_' || $n, '')) = ('1', 'true', 'on', 'yes')
};

(:~ Selected entity for block $n; the explicit "All Entities" option maps to ''. :)
declare function ds:entity($n as xs:integer) as xs:string {
    let $e := normalize-space(request:get-parameter('entity_' || $n, ''))
    return if ($e = 'all') then '' else $e
};

(:~
 : The tei:date elements a given date-group kind points at, relative to a record
 : (tei:TEI). Paths mirror the ones the old data:date-predicate() used, loosened
 : to the descendant axis so they tolerate small structural variation.
 :)
declare function ds:dates($rec as node(), $kind as xs:string) as element(tei:date)* {
    if ($kind = 'birth')            then $rec//tei:birth/tei:date
    else if ($kind = 'death')       then $rec//tei:death/tei:date
    else if ($kind = 'floruit')     then $rec//tei:floruit/tei:date
    else if ($kind = 'work')        then $rec/tei:text/tei:body/tei:bibl/tei:date
    else if ($kind = 'provenance')  then $rec//tei:history/tei:provenance/tei:date
    else if ($kind = 'acquisition') then $rec//tei:history/tei:acquisition/tei:date
    else if ($kind = 'relation')    then $rec//tei:listRelation/tei:relation/tei:desc/tei:date
    else ()
};

(:~
 : The active date groups for criteria block $n, as maps of
 : { "kind": <ds:dates selector>, "spec": <ds:spec result> }.
 : Only groups valid for the block's selected entity are produced; the caller
 : discards those whose spec is empty(). The form only shows date inputs once a
 : concrete entity is chosen, so "All Entities" contributes no date filter.
 :)
declare function ds:groups($n as xs:integer) as map(*)* {
    let $entity := ds:entity($n)
    return
        if ($entity = 'person') then (
            map { "kind": "birth",   "spec": ds:spec('birth', $n) },
            map { "kind": "death",   "spec": ds:spec('death', $n) },
            map { "kind": "floruit", "spec": ds:spec('florit', $n) }
        )
        else if ($entity = 'work') then
            map { "kind": "work", "spec": ds:spec('', $n) }
        else if ($entity = 'manuscript') then
            let $dt := normalize-space(request:get-parameter('dateType_' || $n, ''))
            return
                if ($dt = ('provenance', 'acquisition', 'relation'))
                then map { "kind": $dt, "spec": ds:spec('', $n) }
                else ()
        else ()
};

(:~
 : Post-filter a hit set (tei:TEI elements) by every date group active across the
 : three criteria blocks. Groups within a block are ANDed - matching the old
 : behaviour where filling both Birth and Death required both to match - and the
 : blocks themselves are ANDed. Returns $hits unchanged when the form carried no
 : date parameters, so this is a safe no-op on ordinary keyword / browse queries.
 :)
declare function ds:filter($hits as node()*) as node()* {
    fold-left(1 to 3, $hits,
        function($acc as node()*, $n as xs:integer) as node()* {
            let $undated := ds:include-undated($n)
            let $active  := ds:groups($n)[exists(?spec)]
            return
                if (empty($active))
                then $acc
                else
                    filter($acc, function($rec as node()) as xs:boolean {
                        every $g in $active
                        satisfies ds:any-match(ds:dates($rec, $g?kind), $g?spec, $undated)
                    })
        })
};

(:~
 : True when the request carries ANY advanced date parameter (From/To a.k.a.
 : *NotBefore_ / *NotAfter_, or the exact-value *ExactYear_ / legacy *When_) for
 : any of the three criteria blocks. Used by search.xqm / data.xqm to decide
 : whether the advanced-query path (and ds:filter) should run at all.
 :)
declare function ds:has-date-params() as xs:boolean {
    let $names := (
        for $n in 1 to 3
        for $suffix in ('NotBefore', 'NotAfter', 'When', 'ExactYear')
        return (
            (: bare params - work / manuscript :)
            (lower-case(substring($suffix, 1, 1)) || substring($suffix, 2) || '_' || $n),
            (: person birth / death / floruit :)
            ('birth'  || $suffix || '_' || $n),
            ('death'  || $suffix || '_' || $n),
            ('florit' || $suffix || '_' || $n)
        )
    )
    return some $name in $names satisfies normalize-space(request:get-parameter($name, '')) ne ''
};
