    NOTES:
    20130326:   AD-  original query.  Returns 1) normalized text sequence; 2) <p> and all child elements, and; 3) URI
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
         for $additions in $manuscript//tei:additions/tei:list/tei:item/tei:p
         let $addition-text := $manuscript//tei:additions/tei:p/text()
         let $URI := $manuscript//tei:publicationStmt//tei:idno[@type = 'URI']/text()
         where (fn:matches($additions, "note"))
         (: return count($manuscript//tei:additions/tei:list/tei:item/tei:p//tei:placeName) :)
         return (fn:normalize-space($additions) (:,$additions :)  , $URI) 
         
         (: ******** TESTING ONLY **********
         return if(fn:matches($additions, "note")) then (fn:normalize-space($additions), $URI)
         else "" :)
         
    };
    
    let $input := fn:collection("/db/apps/srophe/data/manuscripts")
    let $manuscript := $input//tei:TEI
    return local:find-colophons($manuscript)
