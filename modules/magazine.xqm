xquery version "3.1";
module namespace magazine="http://bluemountain.princeton.edu/modules/magazine";
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://bluemountain.princeton.edu/config" at "config.xqm";
declare namespace tei="http://www.tei-c.org/ns/1.0";


declare function magazine:from-id($id as xs:string)
as element()
{

};

declare function magazine:bmtnid($magObj as element())
as xs:string
{
	$magObj/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='bmtnid']
};

declare function magazine:title($magObj as element())
as xs:string
{

};