xquery version "3.0";

module namespace app="http://bluemountain.princeton.edu/modules/app";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://bluemountain.princeton.edu/config" at "config.xqm";

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mets="http://www.loc.gov/METS/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace tei="http://www.tei-c.org/ns/1.0";




(:~
 : Returns a valid xs:date from a w3cdtf-formatted string.
 : The input string may simply be a year (e.g., '2015'), in which
 : case the function appends January 1 to it (e.g., 2015-01-01);
 : if it is a YearMonth, then the function returns default first of 
 : the month.
 :
 : The function works by seeing if it can cast the input string as
 : an xs:date type.
 : @param $d a string in w3cdtf format
 :)
declare function app:w3cdtf-to-xsdate($d as xs:string) as xs:date
{
  let $dstring :=
  if ($d castable as xs:gYear) then $d || "-01-01"
  else if ($d castable as xs:gYearMonth) then $d || "-01"
  else if ($d castable as xs:date) then $d
  else error($d, "not valid w3cdtf")
  return xs:date($dstring)
};

(:~
 : Given the id of a magazine issue (e.g., bmtnaap_1921-11_01),
 : return the URL to the issue in the Blue Mountain Veridian instance.
 : 
 : Veridian has an unusual internal syntax for its urls; this function
 : defines sections of the URL and concatenates them together.
 : @param $bmtnid The id of an issue (e.g., bmtnaap_1921-11_01)
 :)
declare function app:veridian-url-from-bmtnid($bmtnid as xs:string)
as xs:string
{
    let $protocol    := "http://",
        $host        := "bluemountain.princeton.edu",
        $servicePath := "bluemtn",
        $scriptPath  := "cgi-bin/bluemtn",
        $a           := "d",
        $e           := "-------en-20--1--txt-IN-----"
        
    let $idtok       := tokenize($bmtnid, ':')[last()]
    
    let $vid         := replace($idtok, '-','')
    let $vid         := replace($vid, '(bmtn[a-z]{3})_([^_]+)_([0-9]+)', '$1$2-$3')
    
    let $args        := '?a=' || $a || '&amp;d=' || $vid || '&amp;e=' || $e

    return $protocol || $host || '/' || $servicePath || '/' || $scriptPath || $args
}; 

(:~
 : Given a title id (e.g., bmtnaap), return a URL to the title in Veridian.
 :
 : Much like app:veridian-url-from-bmtnid(), but the syntax differs.
 : (Possible code refactoring here.)
 :)
declare function app:veridian-title-url-from-bmtnid($bmtnid as xs:string)
as xs:string
{
    let $protocol    := "http://",
        $host        := "bluemountain.princeton.edu",
        $servicePath := "bluemtn",
        $scriptPath  := "cgi-bin/bluemtn",
        $a           := "cl",
        $cl          := "CL1",
        $e           := "-------en-20--1--txt-txIN-------"
    
     let $idtok       := tokenize($bmtnid, ':')[last()]
    
     let $args        := '?a=' || $a || '&amp;cl=' || $cl || '&amp;sp=' || $idtok || '&amp;e=' || $e

    return $protocol || $host || '/' || $servicePath || '/' || $scriptPath || $args
}; 

(:~
 : Returns the title to use in the interface.  If there is a
 : titleInfo element marked as "primary", the use that; otherwise,
 : use the first titleInfo element in the record.
 :)
declare function app:use-title($modsrec as element())
as element()
{
    if ($modsrec/mods:titleInfo[@usage='primary'])
    then $modsrec/mods:titleInfo[@usage='primary']
    else $modsrec/mods:titleInfo[1]
};

declare function app:use-title-tei($tei as element())
as element()
{
    let $title :=
    $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title[@level='j']
    return
        if ($title) then $title
        else <tei:title>no title</tei:title>
};

declare function app:image-url($issueid as xs:string, $imgname as xs:string)
as xs:string
{
    let $protocol := "http://",
        $host     := "libimages.princeton.edu",
        $service  := "loris2",
        $region   := "full",
        $size     := "120,",
        $rotation := "0",
        $quality  := "default",
        $format   := "png"

    let $base     := "bluemountain/astore%2Fperiodicals"
    
    
    let $fulltok  := tokenize($issueid, ':')[last()],
        $idtok    := substring-before($fulltok, '_'),
        $datetok  := substring-after($fulltok, '_'),
        $datetok  := replace($datetok, '-', '%2F')
        
    let $path     := string-join( ($base,$idtok,'issues',$datetok,'delivery', $fulltok), '%2F'),
        $path     := string-join( ($path, $imgname), '_')
        
    let $uri      := string-join((string-join(($protocol,$host,$service,$path,$region,$size,$rotation,$quality), '/'),$format), '.')
    
        
    return $uri
};

declare function app:image-path($issueid as xs:string, $imgname as xs:string)
as xs:string
{
    let $protocol := "http://",
        $host     := "libimages.princeton.edu",
        $service  := "loris2",
        $region   := "full",
        $size     := "360,",
        $rotation := "0",
        $quality  := "default",
        $format   := "png"

    let $base     := "bluemountain/astore%2Fperiodicals"
    
    
    let $fulltok  := tokenize($issueid, ':')[last()],
        $idtok    := substring-before($fulltok, '_'),
        $datetok  := substring-after($fulltok, '_'),
        $datetok  := replace($datetok, '-', '%2F')
        
    let $path     := string-join( ($base,$idtok,'issues',$datetok,'delivery', $fulltok), '%2F'),
        $path     := string-join( ($path, $imgname), '_')   
        
    return $path
};

declare function app:mets-from-id($issueid as xs:string)
as element()
{
    let $uri-prefix := "urn:PUL:bluemountain"
    let $modsid     := string-join(($uri-prefix,$issueid), ':')
    return collection($config:data-root)//mods:identifier[@type='bmtn' and . = $modsid]/ancestor::mets:mets
};

declare function app:tei-issue-id($issue as element())
as xs:string
{
    $issue/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='bmtnid']
};

declare function app:tei-title-id($title as element())
as xs:string
{
    app:tei-issue-id($title)
};