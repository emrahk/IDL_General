;+
; Project     : SOHO - CDS     
;                   
; Name        : QZDBASE
;               
; Purpose     : Print the current value of env. var. ZDBASE
;               
; Explanation : 
;               
; Use         : IDL> qzdbase
;    
; Inputs      : None
;               
; Opt. Inputs : None
;               
; Outputs     : None
;               
; Opt. Outputs: None
;               
; Keywords    : None
;
; Calls       : getenv
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Database
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 3-Feb-95
;               
; Modified    : Handle case when ZDBASE not defined.  CDP, 17-May-95
;               Use FIND_ALL_DIR.    CDP< 09-Aug-96
;
; Version     : Version 3, 09-Aug-96
;-            

pro qzdbase

;
;  get current value of ZDBASE
;
z = find_all_dir('ZDBASE')

;
;  if not defined then say so and exit
;
if z(0) eq '' then begin
   print,'ZDBASE not defined.'
   return
endif

;
;  how many elements?
;
n = n_elements(z)

;
;  get access priviledge
;
if !priv ne 2 then acc = '(write protected)' else acc = '(writable)'

print,' '
print,'ZDBASE --> '+acc
if n eq 1 then begin
   print,' '
   print,z+' --> '+acc
   print,' '
endif else begin
   print,' '
   for i=0,n-1 do begin
         print,z(i)
         if i lt (n-1) then print,'        |'
   endfor
endelse

end
