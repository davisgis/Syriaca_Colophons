xquery version "3.0";
 
declare namespace tei="http://www.tei-c.org/ns/1.0";
 
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";
 
declare function local:render($node) {
    typeswitch($node)
        case text() return $node
        case element(tei:colophon) return (<br/>, <h1>{local:recurse($node)}</h1>, <br/>)
        (:case element(tei:w) return $node/text()
        case element(tei:c) return " "
        case element(tei:pc) return $node/text() :)
        case element(tei:p) return (<p>{local:recurse($node)}</p>)
        (: case attribute(tei:placeName) return (<a href="{local:recurse($node/@*)}"/>) :)
        case element(tei:placeName) return (<a href="{$node/@ref}">{local:recurse($node)}</a>)
        case element(tei:persName) return (<a href="{$node/@ref}">{local:recurse($node)}</a>)
        case element(tei:item) return (<h1>{local:recurse($node)}</h1>, <br/>)
        (: case element(tei:locus) return (<br/>,<br/>,<b>{local:recurse($node)}: </b>) :)
        case element(tei:quote) return (<br/>,<br/>,local:recurse($node))
        case element(tei:fw) return ()
        default return local:recurse($node)
};
 
declare function local:recurse($node) {
    for $child in $node/node()
    return
        local:render($child)
};
 <html>
    <head>
           <title>Colophon XML -> HTML Testing Results</title>
           </head>
           <body>
{
  local:recurse(fn:doc("/db/Colophons/Data/Query_Results.xml"))
}
</body>
</html>