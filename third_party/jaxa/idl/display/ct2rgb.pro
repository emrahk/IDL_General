pro ct2rgb, table, r,g,b, name, gamma=gamma, reverse=reverse
;
;   Name: ct2rgb
;
;   Purpose: return RGB for give IDL color table
;
;   Input Parameters:
;      table - RSI color table number (see loadct.pro)
;
;   Output Parameters:
;      r,g,b
;      name - associated ascii color table name  
;    
;   Keyword Parameters:
;      gamma -   optional gamma factor (applied to given table)
;      reverse - switch, if set, reverse color table
;
;   Calling Sequence:
;      ct2rgb,nn, r,g,b [name, /reverse, gamma=gamma]
;  
;   History:
;      2-Jun-1997 - S.L.Freeland - simplify some WWW work
;      3-Jun-1997 - S.L.Freeland - restore incoming rgb, document
;
;   Restrictions:
;      full range (0-255) assumed (uses z-buffer)   
;-
; -----------------------------------------------------------------
common ct2rgb_blk, names              ; save ascii name array
type=data_chk(table,/type)

if is_member(data_chk(table,/type), [0,7,8]) then begin
   prstr,strjustify(['IDL> ct2rgb, TABLEnn, R,G,B [,name, /reverse, gamma=gamma]'],/box)
   return
endif

if n_elements(names) eq 0 then begin        ; get the ascii names
   names=''
   loadct,get_names=names
endif

ncols=n_elements(names)
itable=table > 0 < ncols

; -------------------- set some  CT parameters --------------------
reverse=keyword_set(reverse)
lowr=([0,255])(reverse)
hir =([255,0])(reverse)
if n_elements(gamma) eq 0 then gamma=1.0

; -----------------------------------------------------------------

; ----------------- generate&read the CT ------------------------
tvlct,rr,gg,bb,/get                         ; save incoming
dtemp=!d.name                               ; save plot device
set_plot,'z'                                ; use Z buffer
loadct,itable,/silent                       ; load table
stretch,lowr,hir,gamma                      ; adjust table
tvlct,r,g,b,/get                            ; readback output
set_plot,dtemp                              ; restore plot device
tvlct,rr,gg,bb      			    ; restore original rgb
; -----------------------------------------------------------------

name=names(itable)                          ; ascii name

end
