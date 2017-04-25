;+
; Project     : VSO
;
; Name        : WALK_DOM*
;
; Purpose     : Print the contents of an XML DOM structure
;
; Explanation : Prints the contents of an XML DOM structure, for use in
;               debugging XML structures.
;
; Category    : Utility, Class3
;
; Syntax      : IDL> walk_dom, domObject
;
; History     : Ver 1,   08-Nov-2005, J A Hourcle.  Released
;               Derived from IDL's documentation, with some extra error checking
;
; Contact     : oneiros@grace.nascom.nasa.gov
;
; Inputs      : oNode   - the DOM Node(s) (or NodeList(s)) to walk
;             : indent  - (assumed 0), number of columns to indent the report
;
; Outputs     : None
;
;-


PRO walk_dom, oNode, indent
   if ( not is_number(indent) ) then  indent = 0

   if ( not obj_valid(oNode) ) then begin
        print, 'No start node supplied!'
        return
   endif

; were we passed a 'stack' object?
    if ( obj_class( oNode[0] ) eq 'STACK'  ) then $
        if ( oNode->n_elements() eq 0 ) then begin
            print, '(Empty Stack)'
            return
    endif else begin
        print, '(Stack)'
        oNode = oNode->contents()
    endelse

;is it an array?
   if ( n_elements(oNode) gt 1 ) then begin
        print, indent GT 0 ? STRJOIN(REPLICATE(' ', indent)) : '', $
            '(Array ['+ strtrim(n_elements(oNode),2)+'])'
        for i=0, n_elements(oNode)-1 do $
            walk_dom, oNode[i], indent+3
        return
   endif

; were we passed a nodelist ?
    if ( obj_class(oNode) eq 'IDLFFXMLDOMNODELIST' ) then begin
        print, indent GT 0 ? STRJOIN(REPLICATE(' ', indent)) : '', $
            '(NodeList)'
        for i=0, oNode->getLength()-1 do $
            walk_dom, oNode->item(i), indent+3
    endif else begin
        type = ''
        if ( oNode->GetNodeType() eq 1 ) then begin
               type = oNode->GetAttribute('xsi:type')
               if ( not n_elements(type) ) then type = '[unknown]'
        endif else if ( oNode->GetNodeType() eq 3 ) then begin
            type = 'textNode'
        endif

       ; "Visit" the node by printing its name and value
       PRINT, indent GT 0 ? STRJOIN(REPLICATE(' ', indent)) : '', $
          oNode->GetNodeName(),' ('+type+'):', oNode->GetNodeValue()

       ; Visit children
       oSibling = oNode->GetFirstChild()
       WHILE OBJ_VALID(oSibling) DO BEGIN
          walk_dom, oSibling, indent+3
          oSibling = oSibling->GetNextSibling()
       ENDWHILE
   endelse
END
