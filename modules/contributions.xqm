xquery version "3.0";

module namespace contributions="http://bluemountain.princeton.edu/modules/contributions";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://bluemountain.princeton.edu/config" at "config.xqm";
import module namespace app="http://bluemountain.princeton.edu/modules/app" at "app.xql";
import module namespace kwic="http://exist-db.org/xquery/kwic";

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mets="http://www.loc.gov/METS/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace tei="http://www.tei-c.org/ns/1.0";


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

declare function contributions:count($node as node(), $model as map(*))
{
    count($model('contributions'))
};

declare function contributions:contributor($node as node(), $model as map(*))
{
    $model('contributor')
};

declare function contributions:magazine($node as node(), $model as map(*))
{
    $model('selected-title')/mods:titleInfo[1]/mods:title[1]/text()
};

declare
    %templates:wrap
function contributions:listing($node as node(), $model as map(*))
{
    let $contributions := $model('contributions')
    return
        <ol>
            {
                for $contribution in $contributions
                let $title := xs:string($contribution/mods:titleInfo[1]/mods:title[1])
                let $date  := xs:string($contribution/ancestor::mods:mods/mods:originInfo/mods:dateIssued[@keyDate='yes'])
                let $id    := $contribution/@ID
                let $label := $title || '  (' || $date || ')'
                order by $date
                return
                    <li>{ $label }</li>
            }
        </ol>
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
                let $link    := 'contribution.html?issueid=' || $issueid || '&amp;id=' || $id
                order by $date
                return
                    <tr>
                        <td><a href="{$link}">{ $title }</a></td>
                        <td>{ $date  }</td>
                    </tr>
            }
        </table>
};










