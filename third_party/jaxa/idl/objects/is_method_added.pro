;+
; Project     : HESSI
;
; Name        : IS_METHOD_ADDED
;
; Purpose     : check if a method has been added to a class
;
; Category    : utility objects
;
; Explanation : checks output of help,/rout for CLASS::METHOD
;
; Syntax      : IDL> added=is_method_added(method,class)
;
; Inputs      : METHOD = scalar string method name
;               CLASS = scalar string class or object name
;
; Outputs     : 1/0 if added/not added
;
; History     : Written 30 Aug 2000, D. Zarro, EIT/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;               31-Aug-2001, Kim.  Use stregex to ensure that 
;               correct class/method is searched for
;               (e.g.  previously, searching for fits::clone found lfits::clone)
;-

function is_method_added,method,class

if size(method,/tname) ne 'STRING' then return,0b
tmethod=strupcase(strtrim(method[0],2))

ctype=size(class,/tname)
if ctype eq 'OBJREF' then tclass=strupcase(obj_class(class[0])) else $
 if ctype eq 'STRING' then tclass=strupcase(strtrim(class[0],2)) else return,0b

help,out=out,/rout

search_string='^'+tclass+'::'+tmethod        ;^ forces match to beginning of string

;chk=where(strpos(out,search_string) gt -1,count)
chk =where (stregex (out, search_string, /boolean, /fold_case) gt 0, count)
return,count gt 0
end

