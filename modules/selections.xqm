xquery version "3.1";

module namespace selections="http://bluemountain.princeton.edu/modules/selections";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://bluemountain.princeton.edu/config" at "config.xqm";
import module namespace app="http://bluemountain.princeton.edu/modules/app" at "app.xql";
import module namespace kwic="http://exist-db.org/xquery/kwic";

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mets="http://www.loc.gov/METS/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare
 %templates:wrap 
function selections:search-results($node as node(), $model as map(*), $where as xs:string?, $matchtype as xs:string?, $bmtnid as xs:string?,$querystring as xs:string?)
as map(*)?
{
    let $collection      :=
        if ($bmtnid) then
            string-join(($config:transcript-root, $bmtnid), '/') 
        else $config:transcript-root
    let $query-root      := "collection('" ||$collection || "')"
    let $where-predicate :=
                            if ($where = 'any') then
                                "//tei:relatedItem[@type='constituent']"
                            else if ($where = 'title') then
                                "/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct//tei:title"
                            else if ($where = 'byline') then
                                "/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct//tei:persName"
                            else if ($where = 'fulltext') then
                                "/tei:TEI/tei:text/tei:body//tei:div[@type='TextContent']"
                            else ()
                            
    let $fulltextp := if ($where = 'fulltext') then true() else false()

    let $query-predicate := "[ft:query(., '" || $querystring ||  "')]" 
    
    let $query           := $query-root || $where-predicate || $query-predicate
    let $hits            := if ($querystring) then util:eval($query) else ()
    let $hits :=
            if ($where = ('title', 'byline')) then
            for $h in $hits return $h/ancestor-or-self::tei:relatedItem
        else $hits
    
    return
     map {  "where" : $where,
            "where-predicate" : $where-predicate, 
            "matchtype" : $matchtype, 
            "query-predicate" : $query-predicate,
            "querystring" : $querystring,
            "query": $query, 
            "hits": if ($fulltextp) then () else $hits,
            "ft-hits": if ($fulltextp) then $hits else (),
            "fulltextp" : $fulltextp,
            "bmtnid" : $bmtnid
            }    

};

declare 
%templates:default("debug", "true")
function selections:display-search-results($node as node(), $model as map(*), $debug as xs:string)
{
    if ($debug = 'true') then
    <dl>
        <dt>where-predicate</dt><dd>{ $model("where-predicate")  }</dd>
        <dt>matchtype</dt><dd>{ $model("matchtype")  }</dd>
        <dt>query string</dt><dd>{ $model("querystring") }</dd>
        <dt>query predicate</dt><dd>{ $model("query-predicate")  }</dd>
        <dt>query</dt><dd>{ $model("query")  }</dd>
        <dt>bmtnid</dt> <dd>{ $model("bmtnid") }</dd>
        <dt>hit count</dt><dd>{ count($model("hits")) }</dd>
        <dt>ft-hit count</dt><dd>{ count($model("ft-hits")) }</dd>        
        <dt>full text?</dt><dd>{ $model("fulltextp") }</dd>
        <dt>debug?</dt><dd>{ $debug }</dd>

    </dl> else (),
    
     if ($model("fulltextp")) then
        selections:formatted-fulltext-accordion($node, $model) 
        else
        <ul>
        { for $hit in $model('hits') return <li>{ selections:formatted-item($hit)}</li> }
        </ul>
     

};

declare %templates:wrap function selections:selected-items($node as node(), $model as map(*), 
                                                           $query as xs:string?, $byline as xs:string*,
                                                           $magazine as xs:string*)
as map(*)? 
{

    let $name-hits  := 
        if ($query !='')
            then collection($config:transcript-root)//tei:relatedItem[ft:query(.//tei:persName, $query)]
         else ()
    let $title-hits := 
        if ($query != '')
            then collection($config:transcript-root)//tei:relatedItem[ft:query(.//tei:title, $query)]
         else ()

    let $restrictions :=
        if ($byline != '')
        then 
            for $line in $byline return 
        collection($config:transcript-root)//tei:relatedItem[ft:query(.//tei:persName, $line)]
        else ()
    
    
    let $query-hits := $name-hits union $title-hits
    let $hits :=
        if ($restrictions)
        then $query-hits intersect $restrictions
        else $query-hits
    let $hits :=
        for $hit in $hits order by ft:score($hit) descending return $hit
    let $hits :=
        if ($magazine)
        then $hits[./ancestor::tei:TEI//tei:relatedItem[@type='host']/@target = $magazine]
        else $hits

    let $ft-hits :=
        if ($query != '')
            then
                for $hit in collection($config:transcript-root)//tei:div[ft:query(.//tei:ab, $query)]
                order by ft:score($hit) descending
                return $hit
        else ()
    let $ft-hits :=
        if ($magazine)
        then $ft-hits[./ancestor::tei:TEI//tei:relatedItem[@type='host']/@target = $magazine]
        else $ft-hits


    return map { "query" : $query , 
                 "selected-items" : $hits , 
                 "ft-hits" : $ft-hits }    
};



declare function local:name-link($name as xs:string) as element()
{
    <a href="selections.html?byline=&quot;{replace($name, ' ', '+')}&quot;">{ $name }</a>
};

declare %templates:wrap function selections:name-facet($node as node(), $model as map(*))
{
    let $names := $model("selected-items")//mods:displayForm
    let $normalized-names := for $name in $names return normalize-space(lower-case($name))
    return
        <ol>
            {
                for $name in distinct-values($normalized-names, "?strength=primary") 
                let $count := count($normalized-names[.= $name])
                order by $count descending
                return <li>{ local:name-link($name) } ({$count})</li>
            }
        </ol>
};

declare  %templates:wrap function selections:selected-items-listing($node as node(), $model as map(*))
as element()*
{
    let $items := $model("selected-items")
   for $item in $items return
                <li>{ selections:formatted-item($item) }</li>
};

declare function selections:formatted-item($item as element())
{
    let $title := $item//tei:title[1]
    let $main :=
        if ($title/tei:seg[@type='main'])
        then $title/tei:seg[@type='main'][1]/text()
        else $title/text()

    let $nonSort :=
        if ($title/tei:seg[@type='nonSort'])
        then $title/tei:seg[@type='nonSort']/text()
        else ()

    let $subtitle :=
        if ($title/tei:seg[@type='sub'])
        then concat(': ', $title/tei:seg[@type='sub'][1]/text())
        else ()
    let $names :=
        if ($item//tei:persName)
        then
            for $name in $item//tei:persName return $name/text()
        else ()
    let $journal := $item/ancestor::tei:sourceDesc/tei:biblStruct/tei:monogr
    let $journalTitle :=
        $journal/tei:title/tei:seg[@type='main']/text()
    let $volume :=
        if ($journal/tei:imprint/tei:biblScope[@unit='vol'])
        then 
            for $v in $journal/tei:imprint/tei:biblScope[@unit='vol']
            return concat("Vol. ", $v)
        else ()
    let $number :=
        if ($journal/tei:imprint/tei:biblScope[@unit='issue'])
        then 
            for $i in $journal/tei:imprint/tei:biblScope[@unit='issue']
            return concat("No. ", $i)
        else ()
    let $date := 
        for $d in $journal/tei:imprint/tei:date
        return xs:string($d/@when)
    (: let $issueLink := app:veridian-url-from-bmtnid($journal/mods:identifier[@type='bmtn']) :)
    let $issueLink := concat('issue.html?issueURN=',$journal/ancestor::tei:teiHeader/tei:publicationStmt/tei:idno[@type='bmtnid'])
        
    return
    (<span class="itemTitle">
        {
            string-join(($nonSort,$main,$subtitle), ' ')
        }
    </span>, <br/>,
    <span class="names">
        {
            string-join($names, ', ')
        }
    </span>, <br/>,
    <span class="imprint">
        <a href="{$issueLink}">
        { string-join(($journalTitle,$volume,$number), ', ') } ({ $date })
        </a>
    </span>
    )
};

declare function selections:formatted-item-brief($item as element())
{
    let $title := $item//tei:title[1]
    let $main :=
        if ($title/tei:seg[@type='main'])
        then $title/tei:seg[@type='main'][1]/text()
        else $title/text()

    let $nonSort :=
        if ($title/tei:seg[@type='nonSort'])
        then $title/tei:seg[@type='nonSort']/text()
        else ()

    let $subtitle :=
        if ($title/tei:seg[@type='sub'])
        then concat(': ', $title/tei:seg[@type='sub'][1]/text())
        else ()
    let $names :=
        if ($item//tei:persName)
        then
            for $name in $item//tei:persName return $name/text()
        else ()
   
    return
    (<span class="itemTitle">
        {
            string-join(($nonSort,$main,$subtitle), ' ')
        }
    </span>, <br/>,
    <span class="names">
        {
            string-join($names, ', ')
        }
    </span>
    )
};

declare function selections:magazine-label($bmtnid as xs:string)
as xs:string
{
    let $label := app:magazine-label($bmtnid)

    return
        if ($label) then $label
        else "no title"
};

declare function selections:issue-label($bmtnid as xs:string)
as xs:string
{
    let $issue-imprint := 
     collection('/db/bmtn-data/transcriptions/periodicals')//tei:idno[. = $bmtnid]/ancestor::tei:TEI//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint
    let $volume :=
        if ($issue-imprint/tei:biblScope[@unit='vol'])
        then 
            for $v in $issue-imprint/tei:biblScope[@unit='vol']
            return concat("Vol. ", $v)
        else ()
    let $number :=
        if ($issue-imprint/tei:biblScope[@unit='issue'])
        then 
            for $i in $issue-imprint/tei:biblScope[@unit='issue']
            return concat("No. ", $i)
        else ()
    let $date := 
        for $d in $issue-imprint/tei:date
        return xs:string($d/@when)
    (: let $issueLink := app:veridian-url-from-bmtnid($journal/mods:identifier[@type='bmtn']) :)
    let $issueLink := concat('issue.html?issueURN=',$bmtnid)
        
    return
    <span class="imprint">
        <a href="{$issueLink}">
        { string-join(($volume,$number), ', ') } ({ $date })
        </a>
    </span>
};

declare function selections:formatted-fulltext-accordion($node as node(), $model as map(*))
{
    <div id="accordion" class="panel-group">
    {
        for $hit in $model("ft-hits")
        group by $magazine := $hit/ancestor::tei:TEI//tei:relatedItem[@type='host']/@target
        order by count($model("ft-hits")/ancestor::tei:TEI//tei:relatedItem[@target = $magazine]) descending
        return
  <div class="panel panel-default">
    <div class="panel-heading">
        <h4 class="panel-title">
        <a data-toggle="collapse" data-parent="#accordion" href="#collapse{$magazine}">
          { selections:magazine-label($magazine) } ({ count($model("ft-hits")/ancestor::tei:TEI//tei:relatedItem[@target = $magazine]) })
        </a>
      </h4>
    </div>

    <div id="collapse{$magazine}" class="panel-collapse collapse">
      <div class="panel-body">
      <ul>
        {
            for $chunk in subsequence($hit, 1, 5)
            let $issue := $chunk/ancestor::tei:TEI

            let $issueid := $issue//tei:idno[@type='bmtnid']
            group by $issueid
            order by $issueid
            return 
                <li><a href="issue.html?issueURN={$issueid}">{ selections:issue-label($issueid) }</a>
                    <ul>
                    {
                        for $constituent in $chunk
(:                        let $expanded := kwic:expand($constituent):)
                        let $id := $constituent/@corresp
                        (: let $relItem := $constituent/ancestor::tei:TEI//tei:relatedItem[@xml:id = $id] :)
                        let $relItem := $constituent/id($id)
                        let $citation := if ($relItem) then 
                            selections:formatted-item-brief($relItem)
                        else string-join(("no citation available for",$id), ' ')
                        order by ft:score($constituent) descending
                        return
                        <li> {$citation}
                            <br/>
                            { kwic:summarize($constituent, <config width="40"/>)}
                        </li>
                    }
                    </ul>
 
                </li>
        }
      </ul>
      {
        if (count($hit) > 5) then
            <p><b><a href="search.html?where={$model('where')}&amp;matchtype={$model('matchtype')}&amp;bmtnid={$magazine}&amp;querystring={$model("querystring")}">more</a></b></p>
            else ()
      }
      </div>
    </div>
  </div>
   
    }
    </div>
};

declare function selections:formatted-fulltext-table($node as node(), $model as map(*))
{
    <ol> {
        for $hit in $model("ft-hits")
        group by $magazine := xs:string($hit/ancestor::tei:TEI//tei:relatedItem[@type='host']/@target),
                 $relItems := $hit/ancestor::tei:div[@type='TextContent']/@corresp
        order by count($model("ft-hits")/ancestor::tei:TEI//tei:relatedItem[@target = $magazine]) descending
        return
            <li>{$magazine}|{selections:magazine-label($magazine)}, count is { count($model("ft-hits")/ancestor::tei:TEI//tei:relatedItem[@target = $magazine]) }
                { for $h in $hit return xs:string($h/@corresp) }
            </li>
        }</ol>
};

declare function selections:formatted-fulltext-table-slow($node as node(), $model as map(*))
{
    for $hit in $model("ft-hits")
    let $magazine    := xs:string($hit/ancestor::tei:TEI//tei:relatedItem[@type='host']/@target)

    group by $magazine
    order by $magazine
    return
        <div>
            <h1>{ selections:magazine-label($magazine) }</h1>
            {
            for $h2 in $hit
            let $issue := $h2/ancestor::tei:TEI//tei:idno[@type='bmtnid']
            group by $issue
            order by $issue
            return
            <div>
                <h2>{ selections:issue-label($issue) }</h2>
                {
                for $h3 in $h2
                let $constituentid := $h3/@corresp
                let $item := $h3/ancestor::tei:TEI//tei:relatedItem[@xml:id = $h3/@corresp]
                let $item-label :=
                    if ($item) then
                        selections:formatted-item-brief($item[1])
                    else <span>no label</span>
                group by $constituentid
                order by $constituentid
                return
                <div>
                    <h3 class="item-label">{ $item-label }</h3>
                    { kwic:summarize($h3[1], <config width="40"/>) }
                </div>
                }
            </div>
            }
        </div>

    
    
};


declare function selections:format-issue-title($journal as element())
as element()
{
    let $journalTitle :=
        $journal//tei:title[@level='j'][last()]/tei:seg[@type='main']/text()
    let $volume :=
        if ($journal/tei:imprint/tei:biblScope[@unit='vol'])
        then 
            for $v in $journal/tei:imprint/tei:biblScope[@unit='vol']
            return concat("Vol. ", $v)
        else ()
    let $number :=
        if ($journal/tei:imprint/tei:biblScope[@unit='issue'])
        then 
            for $i in $journal/tei:imprint/tei:biblScope[@unit='issue']
            return concat("No. ", $i)
        else ()
    let $date := 
        for $d in $journal/tei:imprint/tei:date
        return xs:string($d/@when)
    (: let $issueLink := app:veridian-url-from-bmtnid($journal/mods:identifier[@type='bmtn']) :)
    let $issueLink := concat('issue.html?issueURN=',$journal/ancestor::tei:teiHeader/tei:publicationStmt/tei:idno[@type='bmtnid'])
        
    return
    <span class="imprint">
        <a href="{$issueLink}">
        { string-join(($journalTitle,$volume,$number), ', ') } ({ $date })
        </a>
    </span>
};

declare  %templates:wrap function selections:full-text-KWIC-old($node as node(), $model as map(*))
as element()*
{
 let $hits := $model("ft-hits")
 for $hit in $hits
     let $summary := kwic:summarize($hit, <config width="40" />)
     let $corresp := $hit/ancestor::tei:div/@corresp[1]
     let $constituent := $hit/ancestor::tei:TEI//tei:relatedItem[@xml:id = $corresp][1]
     let $ref :=
        if ($constituent)
        then selections:formatted-item($constituent)
        else "unknown"
    order by ft:score($hit) descending
    return
    (<dt>{$ref}</dt>,
    <dd>{ $summary }</dd>)
};

declare  %templates:wrap function selections:full-text-KWIC($node as node(), $model as map(*))
as element()*
{
 let $hits := $model("ft-hits")
 for $hit in $hits
     let $corresp := $hit/ancestor-or-self::tei:div/@corresp[1]
     let $constituent := $hit/ancestor::tei:TEI//tei:relatedItem[@xml:id = $corresp][1]
     let $ref :=
        if ($constituent)
        then selections:formatted-item($constituent)
        else "unknown"
    order by ft:score($hit) descending
    return
    (<dt>{$ref}</dt>,
    <dd>{ kwic:summarize($hit, <config width="40" />) }</dd>)
};