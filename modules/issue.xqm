xquery version "3.0";

module namespace issue="http://bluemountain.princeton.edu/modules/issue";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://bluemountain.princeton.edu/config" at "config.xqm";
import module namespace app="http://bluemountain.princeton.edu/modules/app" at "app.xql";

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mets="http://www.loc.gov/METS/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function issue:uv-embed($node as node(), $model as map(*))
as element()
{
    let $bmtnid := app:tei-issue-id($model("selected-issue"))
    
    return
    <div id="viewer"
        class="uv" 
        data-uri="{$config:iiif-root}/{$bmtnid}/manifest"
        data-collectionindex="0" data-manifestindex="0" data-sequenceindex="0"
        data-canvasindex="0"
        data-rotation="0" style="height:600px; background-color:
        #000" />
};

declare function issue:mirador-script($node as node(), $model as map(*), $issueURN as xs:string?)
as element()
{
    let $mets    := $model("selected-issue")/ancestor::mets:mets
    let $bmtnid  := substring-after($mets//mods:mods//mods:identifier[@type='bmtn'], 'urn:PUL:bluemountain:')
    let $coverdivid := xs:string($mets//mets:div[@TYPE='OUTSIDE_FRONT_COVER']/@ID)
    let $coverdiv-imgfileid := $mets//mets:div[@TYPE='OUTSIDE_FRONT_COVER']//mets:area[not(@BEGIN)]/@FILEID
    let $pagegrp  := xs:string($mets//mets:file[@ID=$coverdiv-imgfileid]/@GROUPID)
    return
    <script type="text/javascript">
        var MANIFESTS = [ &quot;{ $bmtnid }&quot;
        ]
        
        var COVERDIV = &quot;{ $pagegrp }&quot;
</script>
};


(:~
 : Generate a javascript variable, PAGES, to be used in conjunction with Open Seadragon.
 :)
declare function issue:pages-script($node as node(), $model as map(*), $issueURN as xs:string?)
as element()
{
(:    let $mets    := $model("selected-issue")/ancestor::mets:mets:)
    let $mets     := app:mets-from-id(app:tei-issue-id($model("selected-issue")))
    let $pageuris :=
        for $file in $mets//mets:fileGrp[@USE='Images']/mets:file
        return replace(substring-after(xs:string($file/mets:FLocat/@xlink:href), 'file:///usr/share/BlueMountain/'), '/', '%2F')

    let $pageuris-static := ('bluemountain%2Fastore%2Fperiodicals%2Fbmtnaap%2Fissues%2F1921%2F11_01%2Fdelivery%2Fbmtnaap_1921-11_01_0001.jp2',
                'bluemountain%2Fastore%2Fperiodicals%2Fbmtnaap%2Fissues%2F1921%2F11_01%2Fdelivery%2Fbmtnaap_1921-11_01_0002.jp2'
                )
     let $strings := for $s in $pageuris return "&quot;bluemountain%2F"||$s||"&quot;"
    return
    <script type="text/javascript">
        var PAGES = [
        { string-join($strings, ",")}
        ]
    </script>

};

declare function issue:selected-issue-transcription($node as node(), $model as map(*))
as map(*)?
{
    let $issue-id := $model("selected-issue")/mods:identifier[@type='bmtn']
    let $transcription := collection($config:transcript-root)/tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='bmtnid'] = $issue-id]
    return map { "selected-issue-transcription" := $transcription }
};

(: Modifies issue:selected-issue-transcription and replaces mods version below. Can both of those be removed? :)
declare function issue:selected-issue($node as node(), $model as map(*), $issueURN as xs:string?)
as map(*)?
{
    if ($issueURN) then
    let $transcription := 
    collection($config:transcript-root)/tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='bmtnid'] = $issueURN]
    return map { "selected-issue" := $transcription }
    else ()
};

declare %templates:wrap function issue:constituents($node as node(), $model as map(*))
as map(*)
{
    map { "selected-issue-constituents" := $model("selected-issue")//tei:relatedItem[@type='constituent'] }    
};

declare %templates:wrap function issue:selected-title-link($node as node(), $model as map(*))
{
    let $titleID := $model('selected-issue')//tei:relatedItem[@type='host']/@target
    let $titleDoc := collection($config:transcript-root)//tei:idno[@type='bmtnid' and .= $titleID]/ancestor::tei:TEI
    let $xsl := doc($config:app-root || "/resources/xsl/title.xsl")
    let $xslt-parameters := 
        <parameters>
            <param name="context" value="selected-title-label-brief"/>
        </parameters>
    let $label := transform:transform($titleDoc, $xsl, $xslt-parameters)
    return <a href="title.html?titleURN={$titleID}">{$label}</a>
};

declare function issue:thumbnails($node as node(), $model as map(*))
as element()+
{
    let $scheme   := "http://",
        $server   := "libimages.princeton.edu",
        $prefix   := "loris2/bluemountain",
        $region   := "full",
        $size     := "120,",
        $rotation := "0",
        $quality  := "default",
        $format   := "png"
        
    let $mets    := $model("selected-issue")/ancestor::mets:mets
    for $file in $mets//mets:fileGrp[@USE='Images']/mets:file
        let $identifier := replace(substring-after(xs:string($file/mets:FLocat/@xlink:href), 'file:///usr/share/BlueMountain/'), '/', '%2F')
        let $uri := string-join((string-join(($scheme,$server,$prefix,$identifier,$region,$size,$rotation,$quality), '/'), $format), '.')
    return <img src="{$uri}"/>
};

declare function issue:thumbnailURL($issue as element())
as xs:string
{
    let $scheme   := "http://",
        $server   := "libimages.princeton.edu",
        $prefix   := "loris2/bluemountain",
        $region   := "full",
        $size     := "120,",
        $rotation := "0",
        $quality  := "default",
        $format   := "png"

    let $firstPage  := $issue/ancestor::mets:mets//mets:fileGrp[@USE='Images']/mets:file[1]
    let $identifier := replace(substring-after(xs:string($firstPage/mets:FLocat/@xlink:href), 'file:///usr/share/BlueMountain/'), '/', '%2F')
    let $uri := string-join((string-join(($scheme,$server,$prefix,$identifier,$region,$size,$rotation,$quality), '/'), $format), '.')
    return $uri
};

declare function issue:thumbnailURL-tei($issueid as xs:string)
as xs:string
{
    app:image-url($issueid, '0001.jp2', '60')
};

declare %templates:wrap function issue:label($node as node(), $model as map(*))
as element()
{
    let $selected-issue := 
        if (empty($model)) then fn:error(xs:QName("app:noModel"), "no model", $model)
        else if (empty($model("selected-issue")))
        then fn:error(xs:QName("app:noSelectedIssueError"), "no selected issue", $model)
        else $model("selected-issue")
    let $issue-title := $selected-issue/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title
    let $xsl := doc($config:app-root || "/resources/xsl/issue.xsl")

    return transform:transform($issue-title, $xsl, ())
};


declare function issue:volume($node as node(), $model as map(*))
as xs:string*
{
    let $issue := $model("selected-issue")
    let $volume := $issue/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:biblScope[@unit='vol']
    return string($volume)
};

declare function issue:number($node as node(), $model as map(*))
as xs:string*
{
    let $issue := $model("selected-issue")
    let $number := $issue/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:biblScope[@unit='issue']
    return string-join($number, ', ')
};

declare function issue:pubDate($node as node(), $model as map(*))
as xs:string*
{
    let $issue := $model("selected-issue")
    let $pubDate := $issue/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:date/@when
    return string($pubDate)
};

declare function issue:pubPlace($node as node(), $model as map(*))
as xs:string*
{
    let $issue := $model("selected-issue")
    let $pubPlace := $issue/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:pubPlace
    return xs:string($pubPlace)    
};

declare function issue:editors($node as node(), $model as map(*))
as xs:string*
{
    let $issue := $model("selected-issue")
    let $editors := $issue/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:respStmt[tei:resp='edt']
    return string-join(($editors/tei:persName), '; ')
};

declare %templates:wrap function issue:icon($node as node(), $model as map(*))
 as element()
 {
    let $issueURN := $model("selected-issue")//mods:identifier
    let $iconpath := issue:icon-path($issueURN)
    return <img src="{$iconpath}/large.jpg" />
};


declare function issue:icon2($issueURN as xs:string)
{
    let $iconpath := issue:icon-path($issueURN)
    return $iconpath || "/large.jpg"
};


declare function issue:icon-path($bmtnURN as xs:string)
as xs:string
{
    let $icon-root := "/exist/rest/" || $config:app-root || "/resources/icons/periodicals/"
    let $bmtnid   := tokenize($bmtnURN, ':')[last()] (: e.g., bmtnaae_1920-03_01 :)
    let $iconpath := replace($bmtnid, '(bmtn[a-z]{3})_([^_]+)_([0-9]+)', '$1/issues/$2_$3') (: e.g., bmtnaae/issues/1920-03_01 :)
    let $iconpath := replace($iconpath, '-', '/')
    return $icon-root || $iconpath
};

declare function issue:link($node as node(), $model as map(*))
as element()
{
    let $issueURN := $model("selected-issue")//mods:identifier[@type='bmtn']
    return <a href="{ app:veridian-url-from-bmtnid($issueURN) }">Read issue in the archive</a>
};

declare function issue:reader-link($node as node(), $model as map(*))
as element()
{
    let $issueURN := $model("selected-issue")//mods:identifier[@type='bmtn']
    return <a href="issue-viewer.html?issueURN={ $issueURN }">Read issue in the viewer</a>
};

declare function issue:constituents-table($node as node(), $model as map(*))
as element()
{
    <table class="table" id="constituents-table">{
        
        let $issueURN := app:tei-issue-id($model("selected-issue"))
        let $titleURN := $model("selected-issue")//tei:relatedItem[@type='host']/@target
        for $constituent in $model("selected-issue-constituents")
        let $xsl := doc($config:app-root || "/resources/xsl/issue.xsl")
        let $xslt-parameters := 
            <parameters>
                <param name="context" value="constituent-listing-table"/>
                <param name="titleURN" value="{ xs:string($titleURN) }" />
                <param name="issueURN" value="{ xs:string($issueURN) }" />
                <param name="veridianLink" value="{app:veridian-url-from-bmtnid($issueURN)}"/>
            </parameters>
        let $row := transform:transform($constituent, $xsl, $xslt-parameters)
        return
            $row
    }</table>
};
 
declare %templates:wrap function issue:ms-description($node as node(), $model as map(*))
as element()?
{ 
    let $msDesc := $model("selected-issue")/tei:teiHeader//tei:msDesc
    let $xsl    := doc($config:app-root || "/resources/xsl/msdesc.xsl")
    let $div    := transform:transform($msDesc, $xsl, ())
    return $div
};