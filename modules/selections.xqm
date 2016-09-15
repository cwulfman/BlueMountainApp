xquery version "3.0";

module namespace selections="http://bluemountain.princeton.edu/modules/selections";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://bluemountain.princeton.edu/config" at "config.xqm";
import module namespace app="http://bluemountain.princeton.edu/modules/app" at "app.xql";
import module namespace kwic="http://exist-db.org/xquery/kwic";

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mets="http://www.loc.gov/METS/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare %templates:wrap function selections:search-results($node as node(), $model as map(*),
                                                     $where as xs:string?, $matchtype as xs:string?,
                                                     $querystring as xs:string?)
as map(*)?
{
    let $query-root      := "collection('" || $config:transcript-root || "')"
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
    
    return
     map {  "where" : $where-predicate, 
            "matchtype" : $matchtype, 
            "querystring" : $query-predicate, 
            "query": $query, 
            "hits": if ($fulltextp) then () else $hits,
            "ft-hits": if ($fulltextp) then $hits else (),
            "fulltextp" : $fulltextp
            }    

};
declare %templates:wrap function selections:search-results-old($node as node(), $model as map(*),
                                                     $where as xs:string?, $matchtype as xs:string?,
                                                     $querystring as xs:string?)
as map(*)?
{
    let $query-root      := "collection('" || $config:transcript-root || "')"
    let $where-predicate :=
                            if ($where = 'any') then
                                "/tei:TEI/(tei:teiHeader|tei:text/tei:body)"
                            else if ($where = 'title') then
                                "/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct//tei:title"
                            else if ($where = 'byline') then
                                "/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct//tei:persName"
                            else if ($where = 'full text') then
                                "/tei:TEI/tei:text"
                            else ()

    let $query-predicate := "[ft:query(., '" || $querystring ||  "')]" 
    
    let $query           := $query-root || $where-predicate || $query-predicate
    let $hits            := if ($query) then util:eval($query) else ()
    
    return
     map { "where" : $where-predicate, "matchtype" : $matchtype, "querystring" : $query-predicate, "query": $query, "hits": $hits }    

};

declare function selections:display-search-results($node as node(), $model as map(*))
{
    <dl>
        <dt>where</dt><dd>{ $model("where")  }</dd>
        <dt>matchtype</dt><dd>{ $model("matchtype")  }</dd>
        <dt>querystring</dt><dd>{ $model("querystring")  }</dd>
        <dt>query</dt><dd>{ $model("query")  }</dd>
        <dt>hit count</dt><dd>{ count($model("hits")) }</dd>
        <dt>ft-hit count</dt><dd>{ count($model("ft-hits")) }</dd>        
        <dt>full text?</dt><dd>{ $model("fulltextp") }</dd>

    </dl>,
    
     if ($model("fulltextp")) then
        selections:formatted-fulltext-table($node, $model) 
        else
        <ul>
        { for $hit in $model('hits') return <li>{ selections:formatted-item($hit)}</li> }
        </ul>
     

};



declare %templates:wrap function selections:selected-items-mods($node as node(), $model as map(*), 
                                                           $query as xs:string?, $byline as xs:string*,
                                                           $magazine as xs:string*)
as map(*)? 
{
    let $name-hits  := 
        if ($query !='')
            then collection($config:data-root)//mods:relatedItem[ft:query(.//mods:displayForm, $query)]
         else ()
    let $title-hits := 
        if ($query != '')
        then collection($config:data-root)//mods:relatedItem[ft:query(.//mods:titleInfo, $query)]
        else ()
    let $restrictions :=
        if ($byline != '')
        then 
         for $line in $byline return 
             collection($config:data-root)//mods:relatedItem[ft:query(.//mods:displayForm, $line)]
        else ()
    
    
    let $query-hits := $name-hits union $title-hits
    let $hits :=
        if ($restrictions)
        then $query-hits intersect $restrictions
        else $query-hits
    let $hits :=
        if ($magazine)
        then $hits[./ancestor::mods:mods/mods:relatedItem[@type='host']/@xlink:href = $magazine]
        else $hits

    return map { "selected-items" : $hits, "query" : $query }    
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

declare function selections:foo-mods($node as node(), $model as map(*))
{
    <form action="">
        <label for="thequery">Query Terms: </label>
        <input name="query" id="query" value="{$model('query')}"/>
        <br/>
       <fieldset>
        <legend>with byline</legend>
        <ol>
        {
           let $names := $model("selected-items")//mods:displayForm
           let $normalized-names := for $name in $names return normalize-space(lower-case($name))
           for $name in distinct-values($normalized-names, "?strength=primary") 
            let $count := count($normalized-names[.= $name])
            order by $count descending
            return <li><input type="checkbox" name="byline" value="{$name}">{$name} ({$count})</input></li>  
        }
        </ol>
       </fieldset>
       <fieldset>
        <legend>in magazine</legend>
        <ol>
            {
            let $mags := $model("selected-items")/ancestor::mods:mods/mods:relatedItem[@type='host']/@xlink:href
            for $mag in distinct-values($mags)
             let $title := collection($config:data-root)//mods:mods[./mods:identifier = $mag]/mods:titleInfo[1]/mods:title[1]/text()
             let $count := count($mags[.= $mag])
             order by $count descending
             return
                <li><input type="checkbox" name="magazine" value="{$mag}">{$title} ({$count})</input></li>
            }
        </ol>
       </fieldset>
        <input type="submit" value="Search"/>
    </form>
};

declare %templates:wrap function selections:foo($node as node(), $model as map(*))
{
    <form action="">
        <label for="thequery">Query Terms: </label>
        <input name="query" id="query" value="{$model('query')}"/>
        <br/>
       <fieldset>
        <legend>with byline</legend>
        
        <ol>
        {
           let $names := $model("selected-items")//tei:persName
           let $normalized-names := for $name in $names return normalize-space(lower-case($name))
           for $name in distinct-values($normalized-names, "?strength=primary") 
            let $count := count($normalized-names[.= $name])
            order by $count descending
            return <li><input type="checkbox" name="byline" value="{$name}">{$name} ({$count})</input></li>  
        }
        </ol>
       </fieldset>
       <fieldset>
        <legend>in magazine</legend>
        <ol>
            {
            let $mags := $model("selected-items")/ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:relatedItem[@type='host']/@target
                         union
                         $model("ft-hits")/ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:relatedItem[@type='host']/@target
            for $mag in distinct-values($mags)
             let $title := collection($config:data-root)//mods:mods[./mods:identifier = $mag]/mods:titleInfo[1]/mods:title[1]/text()
             let $count := count($mags[.= $mag])
             order by $count descending
             return
                <li><input type="checkbox" name="magazine" value="{$mag}">{$title} ({$count})</input></li>
            }
        </ol>
       </fieldset>
        <input type="submit" value="Search"/>
    </form>
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

declare function selections:formatted-item-mods($item as element())
{
    let $nonSort :=
        if ($item/mods:titleInfo/mods:nonSort)
        then $item/mods:titleInfo/mods:nonSort/text()
        else ()
    let $title :=
        if ($item/mods:titleInfo/mods:title)
        then $item/mods:titleInfo/mods:title/text()
        else ()
    let $subtitle :=
        if ($item/mods:titleInfo/mods:subTitle)
        then string-join((':', $item/mods:titleInfo/mods:subTitle/text()), ' ')
        else ()
    let $names :=
        if ($item/mods:name)
        then
            for $name in $item/mods:name return $name/mods:displayForm/text()
        else ()
    let $journal := $item/ancestor::mods:mods[1]
    let $journalTitle :=
        $journal/mods:titleInfo/mods:title/text()
    let $volume :=
        if ($journal/mods:part[@type='issue']/mods:detail[@type='volume'])
        then concat("Vol. ", $journal/mods:part[@type='issue']/mods:detail[@type='volume']/mods:number[1])
        else ()
    let $number :=
        if ($journal/mods:part[@type='issue']/mods:detail[@type='number'])
        then concat("No. ", $journal/mods:part[@type='issue']/mods:detail[@type='number']/mods:number[1])
        else ()
    let $date := $journal/mods:originInfo/mods:dateIssued[@keyDate = 'yes']
    (: let $issueLink := app:veridian-url-from-bmtnid($journal/mods:identifier[@type='bmtn']) :)
    let $issueLink := concat('issue.html?issueURN=',$journal/mods:identifier[@type='bmtn'])
        
    return
    (<span class="itemTitle">
        {
            string-join(($nonSort,$title,$subtitle), ' ')
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

declare function selections:formatted-item($item as element())
{
    let $title :=
        if ($item/tei:biblStruct[1]/tei:analytic[1]/tei:title[1]/tei:seg[@type='main'])
        then $item/tei:biblStruct[1]/tei:analytic[1]/tei:title[1]/tei:seg[@type='main'][1]/text()
        else $item/tei:biblStruct[1]/tei:analytic[1]/tei:title[1]/text()

    let $nonSort :=
        if ($title and $item/tei:biblStruct[1]/tei:analytic[1]/tei:title[1]/tei:seg[@type='nonSort'])
        then $item/tei:biblStruct[1]/tei:analytic[1]/tei:title[1]/tei:seg[@type='nonSort'][1]/text()
        else ()

    let $subtitle :=
        if ($title and $item/tei:biblStruct[1]/tei:analytic[1]/tei:title[1]/tei:seg[@type='sub'])
        then string-join((':', $item/tei:biblStruct[1]/tei:analytic[1]/tei:title[1]/tei:seg[@type='sub'][1]/text()), ' ')
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
            return        concat("Vol. ", $v)
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
            string-join(($nonSort,$title,$subtitle), ' ')
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
    let $title :=
        if ($item/tei:biblStruct[1]/tei:analytic[1]/tei:title[1]/tei:seg[@type='main'])
        then $item/tei:biblStruct[1]/tei:analytic[1]/tei:title[1]/tei:seg[@type='main'][1]/text()
        else $item/tei:biblStruct[1]/tei:analytic[1]/tei:title[1]/text()

    let $nonSort :=
        if ($title and $item/tei:biblStruct[1]/tei:analytic[1]/tei:title[1]/tei:seg[@type='nonSort'])
        then $item/tei:biblStruct[1]/tei:analytic[1]/tei:title[1]/tei:seg[@type='nonSort'][1]/text()
        else ()

    let $subtitle :=
        if ($title and $item/tei:biblStruct[1]/tei:analytic[1]/tei:title[1]/tei:seg[@type='sub'])
        then string-join((':', $item/tei:biblStruct[1]/tei:analytic[1]/tei:title[1]/tei:seg[@type='sub'][1]/text()), ' ')
        else ()
    let $names :=
        if ($item//tei:persName)
        then
            for $name in $item//tei:persName return $name/text()
        else ()
   
    return
    (<span class="itemTitle">
        {
            string-join(($nonSort,$title,$subtitle), ' ')
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
    let $magazine := collection('/db/bmtn-data/transcriptions/periodicals')//tei:idno[. = $bmtnid]/ancestor::tei:TEI
    return xs:string($magazine/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr//tei:title[@level='j'][last()])
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

declare function selections:formatted-fulltext-table($node as node(), $model as map(*))
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
{
    let $journalTitle :=
        $journal//tei:title[@level='j'][last()]/tei:seg[@type='main']/text()
    let $volume :=
        if ($journal/tei:imprint/tei:biblScope[@unit='vol'])
        then 
            for $v in $journal/tei:imprint/tei:biblScope[@unit='vol']
            return        concat("Vol. ", $v)
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