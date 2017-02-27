xquery version "3.1";


module namespace contributors="http://bluemountain.princeton.edu/modules/contributors";
import module namespace templates="http://exist-db.org/xquery/templates" ;

declare namespace skos="http://www.w3.org/2004/02/skos/core#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace schema="http://schema.org/";

declare default collation "?lang=en-US";

declare function contributors:id($rdf as node())
as xs:string
{
    xs:string($rdf//rdf:Description[rdf:type/@rdf:resource="http://schema.org/Person"]/@rdf:about)
};

declare function contributors:rec($id as xs:string)
as element()
{
    collection('/db/data/bmtn/auth/viaf')//rdf:Description[@rdf:about= $id]/ancestor::rdf:RDF
};

declare function contributors:all($node as node(), $model as map(*))
as map(*)?
{
    map{ "contributors" := collection('/db/data/bmtn/auth/viaf')//rdf:Description[rdf:type/@rdf:resource = 'http://schema.org/Person']/ancestor::rdf:RDF }
};

declare
 %templates:wrap
function contributors:list($node as node(), $model as map(*))
as element()
{
    <ol> {
           for $c in $model("contributors")
           let $label := contributors:label($c)
           order by $label 
           return
            <li><a href="contributions.html?authid={contributors:id($c)}">{ $label }</a></li>
    }</ol>
};

declare %templates:wrap function contributors:label($contributor-rdf)
as xs:string
{
    let $label := 
        if ($contributor-rdf//rdf:Description[./skos:inScheme/@rdf:resource="http://viaf.org/authorityScheme/LC"]/skos:prefLabel)
         then $contributor-rdf//rdf:Description[./skos:inScheme/@rdf:resource="http://viaf.org/authorityScheme/LC"][1]/skos:prefLabel[1]
        else if ($contributor-rdf//rdf:Description[./skos:inScheme/@rdf:resource="http://viaf.org/authorityScheme/BNF"]/skos:prefLabel)
         then $contributor-rdf//rdf:Description[./skos:inScheme/@rdf:resource="http://viaf.org/authorityScheme/BNF"][1]/skos:prefLabel[1]
        else if ($contributor-rdf//rdf:Description[./skos:inScheme/@rdf:resource="http://viaf.org/authorityScheme/DNB"]/skos:prefLabel)
         then $contributor-rdf//rdf:Description[./skos:inScheme/@rdf:resource="http://viaf.org/authorityScheme/DNB"][1]/skos:prefLabel[1]         
        else if ($contributor-rdf//rdf:Description[./skos:inScheme/@rdf:resource="http://viaf.org/authorityScheme/ICCU"]/skos:prefLabel)
         then $contributor-rdf//rdf:Description[./skos:inScheme/@rdf:resource="http://viaf.org/authorityScheme/ICCU"][1]/skos:prefLabel[1]
        else if ($contributor-rdf//rdf:Description[./skos:inScheme/@rdf:resource="http://viaf.org/authorityScheme/PTBNP"]/skos:prefLabel)
         then $contributor-rdf//rdf:Description[./skos:inScheme/@rdf:resource="http://viaf.org/authorityScheme/PTBNP"][1]/skos:prefLabel[1]
        else if ($contributor-rdf//rdf:Description[./skos:inScheme/@rdf:resource="http://viaf.org/authorityScheme/SUDOC"]/skos:prefLabel)
         then $contributor-rdf//rdf:Description[./skos:inScheme/@rdf:resource="http://viaf.org/authorityScheme/SUDOC"][1]/skos:prefLabel[1]
        else if ($contributor-rdf//rdf:Description[./skos:inScheme/@rdf:resource="http://viaf.org/authorityScheme/ISNI"]/skos:prefLabel)
         then $contributor-rdf//rdf:Description[./skos:inScheme/@rdf:resource="http://viaf.org/authorityScheme/ISNI"][1]/skos:prefLabel[1]
        else if ($contributor-rdf//rdf:Description[./skos:inScheme/@rdf:resource="http://viaf.org/authorityScheme/NLI"]/skos:prefLabel)
         then $contributor-rdf//rdf:Description/skos:prefLabel[@xml:lang='en-IL'][1]
        else if ($contributor-rdf//rdf:Description[./skos:inScheme/@rdf:resource="http://viaf.org/authorityScheme/NII"]/skos:prefLabel)
         then $contributor-rdf//rdf:Description[./skos:inScheme/@rdf:resource="http://viaf.org/authorityScheme/NII"][1]/skos:prefLabel[1]
        else if ($contributor-rdf//rdf:Description[./skos:inScheme/@rdf:resource="http://viaf.org/authorityScheme/NTA"]/skos:prefLabel)
         then $contributor-rdf//rdf:Description[./skos:inScheme/@rdf:resource="http://viaf.org/authorityScheme/NTA"][1]/skos:prefLabel[1]
        else if ($contributor-rdf//rdf:Description[./skos:inScheme/@rdf:resource="http://viaf.org/authorityScheme/NLA"]/skos:prefLabel)
         then $contributor-rdf//rdf:Description[./skos:inScheme/@rdf:resource="http://viaf.org/authorityScheme/NLA"][1]/skos:prefLabel[1]
         else if ($contributor-rdf//skos:prefLabel[@xml:lang='en-US'])
         then $contributor-rdf//skos:prefLabel[@xml:lang='en-US'][1]
        else if ($contributor-rdf//schema:name[@xml:lang="en"])
         then $contributor-rdf//schema:name[@xml:lang="en"][1]
        else if ($contributor-rdf//schema:name)
          then $contributor-rdf//schema:name[1]
        else "no label"

    return
         $label 
};