xquery version "3.0";

module namespace app="http://localhost:8080/exists/apps/colophon/templates";

declare namespace tei="http://www.tei-c.org/ns/1.0";
 
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://localhost:8080/exists/apps/colophon/config" at "config.xqm";

(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with an attribute: data-template="app:test" or class="app:test" (deprecated). 
 : The function has to take 2 default parameters. Additional parameters are automatically mapped to
 : any matching request or function parameter.
 : 
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:test($node as node(), $model as map(*)) {
    <p>Dummy template output generated by function app:test at {current-dateTime()}. The templating
        function was triggered by the class attribute <code>class="app:test"</code>.</p>
};

(: AD: 20140418-  app function that creates a sequence of all colophons.  
Filtered by $name and $colo_type which are passed from "colophon_search.html" :)
declare function app:colophon_search($node as node(), $model as map(*), $name as xs:string?, $colo_type as xs:string?) {
    let $input := fn:collection("/db/apps/srophe/data/manuscripts/")
    let $manuscript := $input//tei:TEI
    (:let $name := "expense":)
    for $manuscript in $manuscript
    let $man_title := $manuscript//tei:titleStmt/tei:title/text()
    let $URI := substring-before(($manuscript//tei:publicationStmt//tei:idno[@type = 'URI']/text()), "/source")
    let $colophons := $manuscript//tei:colophon 
        let $item_seq :=
            for $addition_nums in data($manuscript//tei:colophon/tei:ref/@target)
            for $item_id in data($manuscript//tei:additions/tei:list/tei:item/@xml:id)
            let $item := $manuscript//tei:additions/tei:list/tei:item[@xml:id = $item_id]
            let $locus_from := data($item/tei:locus/@from)
            let $locus_to := data($item/tei:locus/@to)
            let $type := data($manuscript//tei:additions/tei:list/tei:item/@syriacatags)
            where (fn:matches($addition_nums, $item_id))
         return if(($name and fn:matches($item, $name)) or ($colo_type and fn:matches($type, $colo_type))) then (<p style="text-indent: 5em;"><b>Colophon Type: </b> {$type}</p>, <p style="text-indent: 5em;"><b> Locus From: </b> {$locus_from} <b> Locus To: </b> {$locus_to}</p>, app:recurse($item)) else ()
    return if(($name and $item_seq) or ($colo_type and $item_seq)) then (<p><h3><b>MANUSCRIPT TITLE: {$man_title}</b></h3></p>, <p style="text-indent: 5em;"><b><em>Manuscript URI: </em></b><a href="{$URI}">{$URI}</a></p>, $item_seq) else () 
    
};

(: AD: 20140418-  First app function used to recursively create various html elements. :)
declare function app:render($node) {
    typeswitch($node)
        case text() return $node
        (:
        case element(tei:head) return <h1>{app:recurse($node)}</h1>
        case element(tei:w) return $node/text()
        case element(tei:c) return " "
        case element(tei:pc) return $node/text()
        case element(tei:lb) return " / "
        case element(tei:stage) return (<p><b>Stage direction:</b> <i>{app:recurse($node)}</i></p>, <br/>)
        case element(tei:speaker) return (<br/>,<br/>,<b>{app:recurse($node)}: </b>) :)
        case element(tei:persName) return (<a href="{$node/@ref}">{app:recurse($node)}</a>)
        case element(tei:placeName) return (<a href="{$node/@ref}">{app:recurse($node)}</a>)
        default return app:recurse($node)
};
 
 (: AD: 20140418-  Second app function used to recursively create various html elements. :)
declare function app:recurse($node) {
    for $child in $node/node()
    return
        app:render($child)
};