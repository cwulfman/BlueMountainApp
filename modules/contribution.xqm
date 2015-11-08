xquery version "3.0";


module namespace contribution="http://bluemountain.princeton.edu/modules/contribution";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://bluemountain.princeton.edu/config" at "config.xqm";
import module namespace app="http://bluemountain.princeton.edu/modules/app" at "app.xql";
import module namespace kwic="http://exist-db.org/xquery/kwic";

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mets="http://www.loc.gov/METS/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function contribution:contribution($node as node(), $model as map(*), $issueid as xs:string, $constid as xs:string)
as map(*)
{

let $issue := collection('/db/bluemtn/transcriptions')/tei:TEI[./tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[. = $issueid]]

    let $constituent := $issue//tei:div[@corresp = $constid]
    return
        map { 'current-issue' : $issue, 'current-constituent' : $constituent, 'issueid' : $issueid, 'constid' : $constid }
};

declare function contribution:transcription($node as node(), $model as map(*))
{
    let $constituent := $model('current-constituent')
    let $xsl := doc($config:app-root || "/resources/xsl/tei.xsl")
    let $transcription := transform:transform($constituent, $xsl,())
        
    return $transcription
};

declare function contribution:facsimile-list($node as node(), $model as map(*))
{
    let $constituent := $model('current-constituent')
    let $issue       := $model('current-issue')
    let $issueid     := $model('issueid')
    let $facs-links  := $constituent//element()/@facs
    let $zones       := 
        for $link in $facs-links
        return $issue/id($link)
      let $graphics-uris :=
        for $zone in $zones return $zone/ancestor::tei:surface/tei:graphic/@url
    return
    <ol>
        {
            for $url in distinct-values($graphics-uris) 
            order by $url 
            return 
                <li>
                    <img src="{ app:image-path($issueid,$url) }" alt="page image" />
                </li>
        }
    </ol>
};

declare function contribution:facsimile($node as node(), $model as map(*))
{
    let $constituent := $model('current-constituent')
    let $issue       := $model('current-issue')
    let $issueid     := $model('issueid')
    let $facs-links  := $constituent//element()/@facs
    let $zones       := 
        for $link in $facs-links
        return $issue/id($link)
    let $graphics-uris :=
        for $zone in $zones return $zone/ancestor::tei:surface/tei:graphic/@url
    let $page-uris :=
        for $url in distinct-values($graphics-uris)
        order by $url
        return app:image-path($issueid, $url)
    let $strings :=
        for $s in $page-uris return "&quot;" || $s || "&quot;" 
    return
        <script type="text/javascript">
            var PAGES = [
            { string-join($strings, ",") }
            ]
        </script>
};

declare 
    %templates:wrap
function contribution:title($node as node(), $model as map(*))
{
    let $constid := $model('constid')
    let $issue := $model('current-issue')
    let $relitem := $issue/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:relatedItem[@xml:id = $constid]
    return $relitem/tei:biblStruct/tei:analytic/tei:title/tei:seg
};

declare 
    %templates:wrap
function contribution:author($node as node(), $model as map(*))
{
    let $constid := $model('constid')
    let $issue := $model('current-issue')
    let $relitem := $issue/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:relatedItem[@xml:id = $constid]
    let $resps := $relitem/tei:biblStruct/tei:analytic/tei:respStmt
    let $strings :=
        for $resp in $resps
        return
            if ($resp/tei:persName) then xs:string($resp/tei:persName)
            else if ($resp/tei:orgName) then xs:string($resp/tei:orgName)
            else ""
    return string-join(($strings), ',')
        
};