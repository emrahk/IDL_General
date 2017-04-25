function str2html_anchor, anchor_names, anchor_text, $
   drop_anchor=drop_anchor, link_anchor=link_anchor
;+
;   Name: str2html_anchor
;
;   Purpose: add anchor html to input vector 
;
;   Input Parameters:
;      anchor_names - one or more anchor reference strings 
;      anchor_text - optional anchor text (default is same as ANCHOR_NAMES)
;
;   Output:
;      function returns specifed anchor html; nelements=n_elements(anchor_names)
;
;   Keyword Parameters:
;      link_anchor - output html is: <A href="#ANCHOR_NAMES">ANCHOR_TEXT</A>"
;      drop_anchor - output html is: <A name="ANCHOR_NAMES"></a>'
;
;   Calling Sequence:
;      The following 2 line sequence sets an forward anchor reference link
;      with text='anchor 1 test' and then marks then anchor later in the 
;      html document.
;      
;      IDL> str2html_anchor,'anchor1','anchor 1 test', /link_anchor
;           [---- some intervening html -----]
;      IDL> str2html_anchor,'anchor1', /drop_anchor       
;
;   History:
;      20-Jan-2000 - S.L.Freeland
;-
drop_anchor=keyword_set(drop_anchor)
link_anchor=1-drop_anchor

retval=''
if not data_chk(anchor_names,/string) then begin 
   box_message,['Need to supply string anchor name(s)',$
                'IDL> str2html_anchor,anchorname[,anctext] [,/set] [,/drop]']
   return,retval
endif

if n_elements(anchor_text) eq 0 then anchor_text=anchor_names

case 1 of 
   link_anchor: retval='<A href="#'+anchor_names+'">'+anchor_text+'</A>'
   drop_anchor: retval='<A name="' +anchor_names+'">'+anchor_text+'</A>'
   else: box_message,'Cannot happen..'
endcase

return,retval
end  
