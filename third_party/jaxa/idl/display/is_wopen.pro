;+
; Project     : HESSI
;                  
; Name        : IS_WOPEN
;               
; Purpose     : platform/OS independent check if current window
;               is available
;                             
; Category    : system utility graphics
;               
; Explanation : uses 'wshow' and 'catch'
;               
; Syntax      : IDL> a=is_wopen(id)
;                                        
; Inputs      : ID = window index
;               
; Outputs     : 1/0 if yes/no
;                   
; Restrictions: Works best in version 5
;               
; Side effects: None
;               
; History     : Version 1,  4-Nov-1999, Zarro (SM&A/GSFC)
;               Modified, 19-Jun-01, Zarro (EITI/GSFC) - fixed Z-buffer support
;               Modified, 13-Dec-01, Zarro (EITI/GSFC) - added ALLOW_WINDOWS check
;
; Contact     : dzarro@solar.stanford.edu
;-    

function is_wopen,id,show=show

wbuff=(!d.name eq 'Z') or (!d.name eq 'PS')
if wbuff then return,1b 

if (1-is_number(id)) then return,0b
if (1-allow_windows()) then return,0b

show=keyword_set(show)

device,window=ow
chk1=where(ow ne 0,count1)
if count1 eq 0 then return,0b
chk2=where(id eq chk1,count2)
if count2 eq 0 then return,0b

if show then wshow2,id
return,1b


end
