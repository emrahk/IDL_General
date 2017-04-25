;+
; Project     : SOHO - CDS
;
; Name        : IPRINT
;
; Purpose     : Print array with counter, e.g. 1) value
;
; Category    : Utility
;                            
; Syntax      : IDL> iprint,array
;
; Inputs      : ARRAY = array to print
;
; Opt. Inputs : PAGE = no of lines per page
; 
; Keywords    : NO_QUIT = inhibit Quit button
;
; Outputs     : Terminal output

; History     : 25-May-1997,  D.M. Zarro.  Written
;               24-Dec-2014, Zarro (ADNET) - added /NO_QUIT
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-


pro iprint,a,page,no_quit=no_quit

if is_blank(a) then return
if is_number(page) then page=(page > 1) else page=20
for i=0l,n_elements(a)-1 do begin
 chk=(i mod page)
 if (chk eq 0) and (i ne 0) and ~keyword_set(no_quit) then begin
  print,'Enter Q to quit, else continue...'
  ans='' & read,ans
  if strupcase(ans) eq 'Q' then return
 endif
 print,i,') ',a(i)
endfor
return & end
