;+
; Project     : HESSI
;
; Name        : GET_METHODS
;
; Purpose     : return all methods of a class or object
;
; Category    : utility objects
;
; Explanation : checks output of help,/rout for CLASS::METHOD
;
; Syntax      : IDL> methods=get_methods(class)
;
; Inputs      : CLASS = scalar string class or object name 
;
; Outputs     : METHODS = string array of method names
;
; History     : Written 13 Nov 2000, D. Zarro, EIT/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_methods,class

ctype=size(class,/tname)
if n_elements(class) ne 1 then begin
 message,'input argument must be scalar',/cont
 return,''
endif

;-- find parents of class/object

case 1 of
 ctype eq 'OBJREF': begin
  tclass=obj_class(class)
  parents=obj_class(class,/super)
 end
 ctype eq 'STRING': begin
  tclass=strupcase(strtrim(class[0],2))
  if not valid_class(tclass) then return,''
  temp=obj_new(tclass)
  parents=obj_class(temp,/super)
  obj_destroy,temp
 end
 else: return,''
endcase

ok=where(trim(parents) ne '',count)
args=tclass
if count gt 0 then args=[tclass,parents[ok]]
np=n_elements(args)

;-- search for all names with ::method

help,out=out,/rout

for i=0,np-1 do begin
 regex='('+args[i]+'::)([^ ]+)( +)(.?)'
 chk=stregex(out,regex,/fold,/extra,/subex)
 ok=where(chk[2,*] ne '',count)
 if count gt 0 then begin
  temp=reform(strlowcase(chk[2,ok]))
  methods=append_arr(methods,temp,/no_copy)
 endif
endfor

if not exist(methods) then methods=''
return,reform(methods)
end

