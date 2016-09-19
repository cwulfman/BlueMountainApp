xquery version "3.0";

module namespace titles="http://bluemountain.princeton.edu/modules/titles";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://bluemountain.princeton.edu/config" at "config.xqm";
import module namespace app="http://bluemountain.princeton.edu/modules/app" at "app.xql";
import module namespace title="http://bluemountain.princeton.edu/modules/title" at "title.xqm";

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare %templates:wrap function titles:all-tei($node as node(), $model as map(*)) 
as map(*) 
{
    let $titleSequence :=
        for $doc in collection($config:transcript-root)/tei:TEI[tei:teiHeader/tei:profileDesc/tei:textClass/tei:classCode='300215389']
        order by lower-case(app:use-title-tei($doc))
        return $doc
    return map { "titles" := $titleSequence }
};

declare function titles:count($node as node(), $model as map(*)) 
as xs:integer 
{ count($model("titles")) };


declare function titles:table-tei($node as node(), $model as map(*))
as element()*
{
    let $xsl := doc($config:app-root || "/resources/xsl/titles-table.xsl")

	return
	   <table class="table table-fixed" id="listing">
	   <tbody>
	{ 
		for $title in $model("titles")

		let $xsl-parameters :=
        <parameters>
            <param name="app-root" value="{$config:app-root}"/>
            <param name="title-icon" value="{title:icon(app:tei-title-id($title)) }"/>
        </parameters>
		return
		transform:transform($title, $xsl, $xsl-parameters)
	}
	   </tbody>
	   </table>
};
