(:  NAME: Colophon Search Query
    AUTHORS: Anthony Davis, Justin Arnwine, Dr. David Michelson
    BEGIN DATE:  4/5/2014
    SUMMARY:  XQuery with one input: Syriaca.org manuscript TEI/XML.  Returns colophons from the manuscripts
    INITIALS: AD:  Anthony Davis; JA: Justin Arnwine; DM: Dr. David Michelson
    NOTES:
    20140405:   AD-  original query.  Returns 1) Manuscript URI, 2) <colophon>, and 3) <addition><item> referenced in <colophon>
    
    :)
   
xquery version "3.0";
 
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace functx = "http://www.functx.com";
 
 
(: 20140322: AD- created local function :)
declare function local:find-colophons($manuscript as element()*)   as item()*
    {
    (:  1) Test query loads all manuscripts. 
        2) Finds all <p> elements found in <additions>
        3) Returns all <p> elements that have text matching term "note" :)
        
       
         for $manuscript in $manuscript
            let $URI := $manuscript//tei:publicationStmt//tei:idno[@type = 'URI']/text()
                
                let $colophons := $manuscript//tei:colophon
                let $item_seq :=
                for $addition_nums in data($manuscript//tei:colophon/tei:ref/@target)
                for $item_id in data($manuscript//tei:additions/tei:list/tei:item/@xml:id)
                let $item := $manuscript//tei:additions/tei:list/tei:item[@xml:id = $item_id]
                where (fn:matches($addition_nums, $item_id))
                return $item
         return (concat("<h1>", "Manuscript URI:  ",$URI,"</h1>"),  $colophons,  $item_seq)
         
    };
    
   let $input := fn:collection("/db/apps/srophe/data/manuscripts/")
   (: TESTING ONLY: let $input := fn:doc("/db/apps/srophe/data/manuscripts/4.xml") :)
    let $manuscript := $input//tei:TEI
   return local:find-colophons($manuscript)
  