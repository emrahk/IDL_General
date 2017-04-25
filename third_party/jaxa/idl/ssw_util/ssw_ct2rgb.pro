pro ssw_ct2rgb, table, r,g,b, name, gamma=gamma, reverse=reverse, $
	    low=low, high=high, loadit=loadit,  loud=loud
;+
;   Name: ssw_ct2rgb
;
;   Purpose: return RGB for give IDL or SSW wavelength dependent color table
;
;   Input Parameters:
;      table - RSI color table number -OR- SSW wavelength
;
;   Output Parameters:
;      r,g,b
;      name - associated ascii color table name  
;    
;   Keyword Parameters:
;      gamma -   optional gamma factor (applied to given table)
;      reverse - switch, if set, reverse color table
;      low  - optional low (stretch range)
;      hight - optional high (stretch range)
;
;   Calling Sequence:
;    ssw_ct2rgb,table, r,g,b [name, /reverse, gamma=gamma, low=low, high=high]
;               -OR-
;    ssw_ct2rgb,WAVE , r,g,b [name, /reverse, gamma=gamma, low=low, high=high]
;  
;   History:
;      2-Jun-1997 - S.L.Freeland - simplify some WWW work
;      3-Jun-1997 - S.L.Freeland - restore incoming rgb, document
;     25-apr-1998 - S.L.Freeland - combine 'ssw_colors' and 'ct2rgb' functions
;
;   Method: uses Z-buffer 
;
;   Side Effects:
;     May change color table (if /loadit set OR no output RGB supplied)
;-
; -----------------------------------------------------------------
type=data_chk(table,/type)

if is_member(data_chk(table,/type), [0,7,8]) then begin
   box_message,['IDL> ssw_ct2rgb, TABLEnn, R,G,B [,name, /reverse, gamma=gamma', $
		'IDL> ssw_ct2rgb, WAVELENTH, R,G,B, ,name, /reverse, gamma=gamma']
   return
endif
table_file=concat_dir(get_logenv('SSW_SETUP_DATA'), 'color_table.eit')
if n_elements(names) eq 0 then begin        ; get the ascii names
   names=''
   loadct,  get_names=names, file=table_file
endif

ncols=n_elements(names)
offset=41                   ; last RSI table

if table gt offset then begin
  wmap=[171, 195, 284, 304, 1216, 1550, 1600, 1700]  ; wave -> ctable map
  cmap=[  42, 43, 44,  45,   3,   4,    8,     15 ]	
  ctab=where(table eq wmap,ccnt)
  if ccnt gt 0 then itable=cmap(ctab(0)) < ncols else begin
     box_message,['Unrecognized table/wavelenth: ' + strtrim(table,2), $
		  'Loading Table 0 (B/W)']
     itable=0
  endelse
endif  else itable=table > 0 < ncols
; -------------------- set some  CT parameters --------------------
reverse=keyword_set(reverse)
if n_elements(low) eq 0 then low=0
if n_elements(high) eq 0 then high =255
lowr=([low,high])(reverse)
hir =([high,low])(reverse)
if n_elements(gamma) eq 0 then gamma=1.0
; -----------------------------------------------------------------

; ----------------- generate&read the CT ------------------------
tvlct,rr,gg,bb,/get                         ; save incoming
dtemp=!d.name                               ; save plot device
set_plot,'z'                                ; use Z buffer
loadct,itable,silent=(1-keyword_set(loud)),$;
	file=table_file                     ; load table
stretch,lowr,hir,gamma                      ; adjust table
tvlct,r,g,b,/get                            ; readback output
set_plot,dtemp                              ; restore plot device
tvlct,rr,gg,bb      			    ; restore original rgb
; -----------------------------------------------------------------

name=names(itable)                          ; ascii name

loadit=keyword_set(loadit) or n_params() eq 1
if loadit then tvlct, r, g, b

return
end
