;+
; Project     : Virtual Solar Observatory
;
; Name        : XMLPARSER__DEFINE
;
; Purpose     : To organize various XML parsing functions
;
; Category    : Utility, VSO
;
; Explanation : The XMLparser object handles the necessary procedures
;               to deal with xml input as a string (not file), and
;               organize some generic dom-walking functions
;
; Syntax      : IDL> a = obj_new('xmlparser')
;
; Examples    : IDL> a = obj_new('xmlparser')
;               IDL> dom = xmlparser->dom(xmlstring)
;               IDL> print, xmlparser->getText(dom)
;
; History     : Version 1,   08-Nov-2005, J A Hourcle. Released
;               Version 1.1, 18-Nov-2005, Hourcle.  fixed memory leaks
;               Version 1.2, 2-Dec-2005, Zarro, made FOR loop variables LONG
;               Version 1.3, 27-Dec-2005, Hourcle.  more robust 'walktree'
;               Version 1.4, 04-Apr-2008, Hourcle, cleaning up old
;               commented code
;               Version 1.5, 11-May-2012, Zarro (ADNET). Added
;               XMLSTRING string load option to avoid file I/O, added
;               call method around string keyword to please compiler.
;
; Contact     : oneiros@grace.nascom.nasa.gov
;-

function xmlparser::init, _ref_extra=extra
    return, 1

end

;==========

; Convenience function -- given an XML string, will write
; it to a temporary file to use IDL's XML parsing routines,
; and then clean up behind it.

; Input :
;   XMLSTRING : string : an xml string
; Output :
;   object : a DOM document

function xmlparser::dom, xmlstring, _extra=extra

if is_blank(xmlstring) then return,''

error=0
catch,error
if error ne 0 then begin
 catch,/cancel
 message,err_state(),/info
 return,''
endif

;-- if new version, then no need to write and read it via a temporary file

new_version=since_version('6.4')
dom = obj_new('IDLffXMLDOMDocument', _extra=extra)

if new_version then begin
 call_method,'load',dom,string=xmlstring[0]
 return,dom
endif

;-- if old IDL version, then have to use file load

file  = get_temp_file()
openw, lun, file, /get_lun
printf, lun, xmlstring
close_lun, lun
dom->load, filename=file
file_delete,file,/quiet

return, dom
end                  

;==========

; I have no idea where to put this --
; when you're working with DOM, GetElementByName will only return
; exact string matches, which will mess you up using xml, and
; you're not sure if it might have a namespace (or what the
; namespace is)

; trying to return a nodelist may be more trouble than it's worth
; unfortunately, I can't return an array of pointers to the nodes,
; because IDL doesn't support empty arrays, which is a distinct
; possibility

; Input:
;   REGEX : string ; a regular expression to match against names.
;   DOM   : object ; the DOM Node to base the search from
; Optional Input:
;   TYPE  : string ; a regular extression to match against types
; Output:
;   object : 'stack' of Nodes that match.
;            (see stack__define.pro)

function xmlparser::findelement, regex, dom, type=type, _extra=extra

    ; if no dom, we want to return an empty node list
    ; but if we just try to make one, and then use it,
    ; IDL dumps ... hard
    if not obj_valid(dom) then begin
        message, 'No DOM tree passed in',/cont
        return, obj_new('stack')
    endif

    ; now for more sensible conditions -- we were given a regex.
    nodes = dom->getElementsByTagName('*')

    ; there were no nodes ... no reason to go through them
    if nodes->getlength() eq 0 then return, obj_new('stack')

    ; need a place to stash the ones to keep
    temp = obj_new('stack')
    for i=0l, (nodes->getlength()-1) do begin
        node = nodes->item(i)
        name = node->GetTagName()
        if stregex( name, regex, /boolean, _extra=extra ) then $
            temp->push,node
    endfor

    ; were we passed in a type to match?
    if ( n_elements(type) and temp->n_elements() ne 0) then begin

        save = temp
        temp = obj_new('stack')
        for i=0l, (save->n_elements()-1) do begin
            node = save->item(i)
            if ( node->GetNodeType() eq 1 ) then begin
                nodetype = node->GetAttribute('xsi:type')
                if stregex( nodetype, type, /boolean, _extra=extra ) then $
                    temp->push, node
            endif
        endfor
; 2004/11/19 : better garbage collection -- JAH
        obj_destroy,save
    endif
    return, temp
end

;==========

; will talk the tree from that node, finding all text elements
; and returning a concatinated string

; Input:
;   NODE : either a DOM node, or a DOM NodeList
; Output:
;   string[n] : complete concatination of the node's tree.
;   (returns an array if given a NodeList)

function xmlparser::getText, node

    if not obj_valid(node) then return, ''

    ; we were passed in an array of items
    if ( n_elements(node) gt 1 ) then begin
        temp = obj_new('stack')
        for i = 0l,n_elements(node)-1 do begin
            temp->push, self->getText( node[i] )
        endfor
; 2004/11/19 : better garbage collection -- JAH
;        return, temp->contents()
        text = temp->contents()
        if obj_valid(temp) then obj_destroy,temp

        return, text
    endif

    ; it's a node list
    if ( obj_class( node ) eq 'IDLFFXMLDOMNODELIST' ) then begin
        temp = obj_new('stack')
        for i = 0l,node->getlength()-1 do $
            temp->push, self->getText( node->item(i) )
; 2004/11/19 : better garbage collection -- JAH
;        return, temp->contents()
        text = temp->contents()
        if obj_valid(temp) then obj_destroy,temp

        return, text
    endif

    text = ''
    ; does it have children?
    if ( node->hasChildNodes() ) then begin
        children = node->getChildNodes()
        for i = 0l, children->getLength()-1 do $
            text = text + self->getText( children->item(i) )
        return, text
    endif

    ; no children
    if ( node->GetNodeType() eq 3 ) then return, node->getNodeValue()

end

;==========

; convenience function, because I'm lazy
; given a DOM node, and an element name, will extract the value of the child element

; Input:
;   NODE : a DOM node
;   NAME : string ; the name of the element to find
; Optional Flags:
;   INTEGER : return an integer (fix)
;   LONG    : return a long
;   FLOAT   : return a float
;   DOUBLE  : return a double
; Output:
;   string (maybe) ; the value of the named element
;   output type may vary if optional flags are passed

function xmlparser::getElementValue, node, name, integer=integer, long=long,  float=float, double=double
    string = self->gettext( self->walktree( node, name ) )
    if keyword_set(integer) then return, fix(string)
    if keyword_set(long)    then return, long(string)
    if keyword_set(float)   then return, float(string)
    if keyword_set(double)  then return, double(string)
    return, strtrim(string,2)
end


;==========

; similar in concept to 'findelement', this will attempt
; to walk down the tree, looking for a node.
; if there are two items with the same name, it's going to take the first branch,
; so it's not very robust.

; it sure would be nice to have XPath support

; Input :
;   DOM : a dom document/node/whatever to start from
;   PATH : string[n] : the path to walk down
; Output :
;   0 -> didn't find it
;   (or) a DOM node

function xmlparser::walktree, dom, path
    ; they didn't give us anything to look for
    if n_elements(path) eq 0 then return, 0

    item = path[0]
    regex = '(^|:)' + item + '$'

    ; might not pass in a dom if an incomplete record
    if ( not obj_valid(dom) ) then return, 0
    if ( not dom->hasChildNodes() ) then return, 0
    nodes = dom->getChildNodes()

    for i=0l, (nodes->getlength()-1) do begin
        node = nodes->item(i)
        name = node->GetTagName()
        if stregex( name, regex, /boolean, _extra=extra ) then begin
            ; found the next item
            if ( n_elements(path) gt 1 ) then $
                return, self->walktree( node, path[1:*] )
            return, node
        endif
    endfor

    ; we didn't find it
    return, 0
end

;==========

; This is just a placeholder ...
; it's really difficult to deal with this, as we might have named elements,
; and want to use name structs, but they might have optional elements
; that aren't used now, and will be used later, resulting in IDL complaining
; as I try to dynamically assign them ...

; blah.

function xmlparser::dom2struct, node, debug=debug
    if ( not n_elements(node) ) then return, 0

    if ( keyword_set( debug ) ) then begin
        name  = node ->getTagName()
        attrs = node ->getAttributes()
        type  = attrs->getNamedItem('xsi:type')
        type  = type ->getNodeValue()

        print, 'Element ['+name+'] is of type ['+type+']'
    endif


    ; does the node have any children?
    if  ( not node->HasChildNodes() ) then begin
        ; it's a simple type
        if ( node->GetNodeType() eq 3 ) then begin
            ; text node
        endif

    endif else begin
        ; complex types
        if stregex( node->getTagName(), '(^|:)Array$', /boolean ) then begin
            ; looks like an array

        endif
    endelse

    return, node
end
;==========

pro xmlparser__define
    struct = { xmlparser, INHERITS gen, empty:'' }

return & end
