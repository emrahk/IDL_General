;+
; Project     : SOHO - CDS     
;                   
; Name        : XWIDUMP
;               
; Purpose     : Dump (or return) full contents of a widget hierarchy 
;               
; Explanation : Produces a recursive listing of the contents of a widget
;               hierarchy.
;               
; Use         : XWIDUMP,BASE [,TEXT,ID]
;    
; Inputs      : BASE : The base of the widget hierarchy to be examined.
; 
; Opt. Inputs : None. 
;               
; Outputs     : TEXT : Text array containing a description of the widget
;                      hierarchy.
;
;               ID : Array of the widget IDs corresponding to TEXT
;               
; Opt. Outputs: None.
;               
; Keywords    : NO_TEXT : Set to skip text generation..
;
; Calls       : default, datatype, trim
;
; Common      : None.
;               
; Restrictions: None.
;               
; Side effects: None.
;               
; Category    : Widget tools
;               
; Prev. Hist. : None.
;
; Written     : Stein Vidar Haugan, UiO, March 1997
;               
; Modified    : Not yet.
;
; Version     : 1, 13 May 1997
;-            

FUNCTION xwidump_text,wid
  
  widget_control,wid,get_uvalue=uvalue
  
  type = widget_info(wid,/name)
  
  IF type EQ 'BUTTON' OR type EQ 'LABEL' THEN BEGIN
     widget_control,wid,get_value=value
     type = type + " '"+value+"'"
  END
  
  func = widget_info(wid,/event_func)
  IF func NE '' THEN type = type + ' [F:'+func+']'
  proc = widget_info(wid,/event_pro)
  IF proc NE '' THEN type = type + ' [P:'+proc+']'
  
  IF n_elements(uvalue) EQ 0 THEN return,type + ' <>'
  
  IF datatype(uvalue) NE 'STC' THEN BEGIN
     IF n_elements(uvalue) EQ 1 THEN  $
        return,type + ' <'+datatype(uvalue)+':'+trim(uvalue(0))+'>'
     return,type + ' <'+datatype(uvalue)+'(ndim:'+trim((size(uvalue))(0))+')>'
  END
  
  tags = tag_names(uvalue,/structure_name)
  
  IF tags EQ "" THEN tags = tag_names(uvalue)
  
  return, type + "<{"+TAGS(0)+"...}>"
END


PRO xwidump,base,text,id,level,no_text=no_text
  
  default,level,0
  
  IF level EQ 0 THEN id = [base] $
  ELSE id = [id,base]
  
  IF NOT widget_info(base,/valid_id) THEN BEGIN
     print,"Non-valid widget ID passed to XWIDUMP"
     return
  END
  
  do_text = NOT keyword_set(no_text)
  
  IF do_text THEN BEGIN 
     IF level GT 0 THEN pretext = string(replicate(32b,level)) $
     ELSE               pretext = ""
     IF level EQ 0 THEN text = [pretext+xwidump_text(base)] $
     ELSE text = [text,pretext+xwidump_text(base)]
     pretext = pretext+" "
  END
  
  next = widget_info(base,/child)
  
  WHILE widget_info(next,/valid_id) DO BEGIN
     IF widget_info(next,/child) ne 0 THEN $
        xwidump,next,text,id,level+1,no_text=no_text $
     ELSE BEGIN
        IF do_text THEN text = [text,pretext+xwidump_text(next)]
        id = [id,next]
     END
     next = widget_info(next,/sibling)
  END
  
  IF do_text THEN BEGIN
     IF n_params() EQ 1 THEN BEGIN
        print,text,format='(A)'
     END
  END
END


PRO xwidump_test
  
  base = widget_base(/column)
  su = widget_base(base,/row,uvalue='SU')
  su1 = widget_base(su,/column,uvalue='SU1')
  but = widget_button(su1,value='Button',uvalue='BUT')
  su2 = widget_base(su,/column,uvalue='SU2')
  but2 = widget_button(su2,value='Button2',uvalue='BUT2')
  widget_control,base,/realize
  xwidump,base
END






