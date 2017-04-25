;+
; NAME:
;        EMENU
; PURPOSE:
;        same as WMENU but can handle almost infinite size lists
; CALLING SEQUENCE:
;        e=emenu(list,mtitle=mtitle,init=init,imax=imax)
; INPUTS:
;        list=string array of menu items
; OUTPUTS:
;        index of selected menu item with 0 denoting first item
; KEYWORDS:
;        Same as WMENU, but with IMAX and MTITLE extra
;        IMAX = size of submenu blocks into which LIST is subdivided [def=50]
;        MTITLE = optional string title for menu, may be an array 
;        (NB: MTITLE is kept separate from LIST elements, unlike in WMENU)
; PROCEDURE:
;        if !D.NAME eq 'X' then uses WMENU on subdivisions of LIST to 
;        avoid hitting internal hard limit of WMENU.
;        If X-windows not available, then items are listed in blocks of 20.
; MODIFICATION HISTORY:
;        Written by DMZ (ARC, Mar'91)
;	 mod, ras, 20-aug-94, allow mtitle to be a string array
;        27-Sep-2010, William Thompson, use [] indexing
;-


function emenu,list,mtitle=mtitle,init=init,imax=imax

on_error,1
line='---------------------------------------------------------'

;-- check for X-windows capability (else invoke tektronix format)

numerals=string(indgen(10),'(i1)')     ;-- string array of [0,1,2,3,4...9]

;-- check inputs

ni=n_elements(list)
if ni eq 0 then message,'needs an item list'
if n_elements(imax) eq 0 then begin
 if !d.name eq 'X' then imax=50 else imax=20
endif

checkvar, mtitle, ''				;ras
num_title = n_elements(mtitle)			;ras
if num_title gt 1 then begin
	mtitle = [mtitle,strmid(line,0,15)]
	num_title=num_title+1
endif
;if n_elements(mtitle) 	eq 0 then mtitle=''	;ras

if n_elements(init) eq 0 then init=num_title

if !d.name eq 'X' then begin          ;-- X-Windows support

;-- break up items LIST into blocks of IMAX elements

; isub=mtitle & index=0 			;ras
 isub=mtitle & index=intarr(num_title)-1 	;ras

 for i=0,ni-1 do begin
  isub=[isub,list[i]] & index=[index,i] & nsub=n_elements(isub)
  if (nsub gt imax) or (i eq (ni-1)) then begin
   if i ne (ni-1) then isub=[isub,'MORE ITEMS']
   select:
   sel=wmenu(isub,title=0,init=init)
   if (sel ge num_title) and (sel lt nsub) then return, index[sel] $
	else begin
		print,'Choose from the items below the description.'
		goto, select
	endelse
 isub=mtitle & index=intarr(num_title)-1 	;ras
  ; isub=mtitle & index=0      ;-- prepare WMENU for next subdivision of LIST
  endif
 endfor

endif else begin                     ;-- Tektronix, etc

; print,mtitle & print,line		;ras
 for i=0,num_title-1 do print,mtitle[i] & print,line

 for i=0,ni-1 do begin
  print,string(i+1,'(i3)')+') '+list[i]
  if ((i+1) mod imax) eq 0 then begin
   print,'* hit any key to continue listing, or S to skip listing...' 
   key='' & read,'---> ',key & action=strupcase(strmid(key,0,1))
   if action eq 'Q' then message,'aborting...'
   if action eq 'S' then i=ni-1
  endif
 endfor

 repeat begin
  print,line
  print,'* enter number of menu item (enter q to quit): '
  ent='' & read,'---> ',ent
  action=strupcase(strmid(ent,0,1)) 
  if action eq 'Q' then message,'aborting...'
  numeric=where(action eq numerals,cnum)                 ;check if a number was entered
  if cnum eq 0 then begin
   if action eq 'M' then begin 
    val=ni-1 & num_ent=1 
   endif else begin
    num_ent=0 & val=-1 
   endelse
  endif else begin
   val=fix(ent) & num_ent=1
  endelse 
  val=val-1
  valid=((val ge 0) and (val le ni-1) and (ent ne '') and num_ent)
 endrep until valid
 return,val
endelse

message,'if you got this far, then you got problems buddy'
end

