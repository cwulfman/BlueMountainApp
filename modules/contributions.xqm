xquery version "3.0";

module namespace contributions="http://bluemountain.princeton.edu/modules/contributions";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://bluemountain.princeton.edu/config" at "config.xqm";
import module namespace app="http://bluemountain.princeton.edu/modules/app" at "app.xql";
import module namespace kwic="http://exist-db.org/xquery/kwic";
import module namespace title="http://bluemountain.princeton.edu/modules/title" at "title.xqm";
import module namespace contributors="http://bluemountain.princeton.edu/modules/contributors" at "contributors.xqm";
import module namespace selections="http://bluemountain.princeton.edu/modules/selections" at "selections.xqm";

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mets="http://www.loc.gov/METS/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";


declare function contributions:contributions($node as node(), $model as map(*), $titleURN as xs:string, $authid as xs:string)
as map(*)
{
    let $titleRec :=
        if ($titleURN) then
            collection($config:data-root)//mods:identifier[@type='bmtn' and . = $titleURN]/ancestor::mods:mods
        else ()
    let $issues := collection($config:data-root)//mods:mods[./mods:relatedItem[@type='host' and @xlink:href = $titleURN]]
    let $constituents := $issues//mods:relatedItem[@type='constituent' and .//mods:name/@valueURI = $authid]
    return
        map { 'contributor' : $authid, 'contributions' : $constituents, 'selected-title' : $titleRec }
};


declare function contributions:contributions-tei($node as node(), $model as map(*), $authid as xs:string)
as map(*)
{
    let $contributions := collection($config:transcript-root)//tei:relatedItem[@type='constituent' and .//tei:persName/@ref = $authid]
    return map {'contributor' : $authid, 'contributor-label' : contributors:label(contributors:rec($authid)),  'contributions' : $contributions }
};

declare function contributions:contributions-tei-old($node as node(), $model as map(*), $titleURN as xs:string?, $authid as xs:string)
as map(*)
{
    let $titleRec :=
        if ($titleURN) then
            title:title-doc($titleURN)
        else ()
    let $issues := title:issues($titleURN)
    let $constituents := $issues//tei:relatedItem[@type='constituent' and .//tei:persName/@ref = $authid]
    return
        map { 'contributor' : $authid, 'contributions' : $constituents, 'selected-title' : $titleRec }
};

declare function contributions:count($node as node(), $model as map(*))
{
    count($model('contributions'))
};

declare function contributions:contributor($node as node(), $model as map(*))
{
    let $viafid := $model('contributor')
    let $doc := 
        if ($viafid) then doc($viafid || '/rdf.xml')
        else ()
    let $label :=
        if ($doc) then $doc//skos:prefLabel[@xml:lang='en-US'][1]
        else "not found"
    return xs:string($label)
};

declare function contributions:contributor-label($node as node(), $model as map(*))
{
    $model('contributor-label')
};

declare function contributions:magazine($node as node(), $model as map(*))
{
    $model('selected-title')/mods:titleInfo[1]/mods:title[1]/text()
};


declare function contributions:magazine-tei($node as node(), $model as map(*))
{
    title:selected-title-label($node, $model)
};


declare
    %templates:wrap
function contributions:table($node as node(), $model as map(*))
{
    let $contributions := $model('contributions')
    return
        <table class="table">
            {
                for $contribution in $contributions
                let $title   := xs:string($contribution/mods:titleInfo[1]/mods:title[1])
                let $issueid := xs:string($contribution/ancestor::mods:mods/mods:identifier[@type='bmtn'])
                let $date    := xs:string($contribution/ancestor::mods:mods/mods:originInfo/mods:dateIssued[@keyDate='yes'])
                let $id      := $contribution/@ID
                let $label   := $title || '  (' || $date || ')'
                let $link    := 'contribution.html?issueid=' || $issueid || '&amp;constid=' || $id
                order by $date
                return
                    <tr>
                        <td><a href="{$link}">{ $title }</a></td>
                        <td>{ $date  }</td>
                    </tr>
            }
        </table>
};

declare
 %templates:wrap
function contributions:listing($node as node(), $model as map(*))
{
        <ul>
        { for $hit in $model('contributions') return <li>{ selections:formatted-item($hit)}</li> }
        </ul>

};

declare
    %templates:wrap
function contributions:table-tei($node as node(), $model as map(*))
{
    let $contributions := $model('contributions')
    return
        <table class="table">
            {
                for $contribution in $contributions
                let $title   := xs:string($contribution/tei:biblStruct/tei:analytic/tei:title[@level='a'][1])
                let $bylines := $contribution//tei:biblStruct/tei:analytic/tei:respStmt/tei:persName
                let $issueid := xs:string(title:docID($contribution/ancestor::tei:TEI))
                let $date    := xs:string($contribution/ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblStruct//tei:imprint//tei:date/@when)
                let $id      := $contribution/@xml:id
                let $label   := $title || '  (' || $date || ')'
                let $link    := 'contribution.html?issueid=' || $issueid || '&amp;constid=' || $id
                order by $date
                return
                    <tr>
                        <td><a href="{$link}">{ $title }</a></td>
                        <td>{ string-join($bylines, '; ') }</td>
                        <td>{ $date  }</td>
                    </tr>
            }
        </table>
};










