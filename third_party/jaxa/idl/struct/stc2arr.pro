;+
; Project     : HESSI
;
; Name        : STC2ARR
;
; Purpose     : Convert a structure with tag arrays to a structure array
;               where each tag is an element of each tag array. The output 
;               structure array will have a dimension equal to the dimension 
;               of the tag arrays. If tags have different dimensions, then 
;               the output structure will have a dimension equal to the tag 
;               with the maximum dimension.
;
; Example     : IDL> stc={a:findgen(100),b:findgen(100)}
;               IDL> out=stc2arr(stc)
;               IDL> help,out
;               OUT    STRUCT    = -> <Anonymous> Array[100]
;
; Category    : utility structures
;
; Syntax      : IDL> array=stc2arr(struct)
;
; Inputs      : struct= structure to convert
;
; Outputs     : array = structure converted to array
;
; History     : Written 14 July 2008, D. Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function stc2arr,struct

if ~is_struct(struct) then begin
 pr_syntax,'array=stc2arr(struct)'
 return,-1
endif

if n_elements(struct) gt 1 then begin
 message,'input structure already an array',/cont
 return,struct
endif

;-- first create a single element template structure with each tag type

snames=tag_names(struct)
tmp=create_struct(snames[0],(struct.(0))[0])
nmax=n_elements(struct.(0))

for i=1,n_elements(snames)-1 do begin
 tmp=create_struct(tmp,snames[i],(struct.(i))[0])
 nmax= nmax > n_elements(struct.(i))
endfor

;-- next replicate and populate, allowing for different size tags

tmp=replicate(tmp,nmax)
for i=0,n_elements(snames)-1 do begin 
 np=n_elements(struct.(i))
 if np eq nmax then tmp.(i)=struct.(i) else begin
  temp=tmp.(i)
  temp[0:np-1]=struct.(i)
  tmp.(i)=temporary(temp)
 endelse
endfor
return,tmp
end 
