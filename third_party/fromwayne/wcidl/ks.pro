function ks,a
;***********************************************************************
; Logical function ks replaces keyword_set, which takes a lot of 
; space. Variables are:
;          a.................arguement, defined or undefined
;         ks.................function either 1 (a def.) or 0 (a undef.)
; 6/10/94 Current version
;***********************************************************************
result = keyword_set(a)
return,result
;***********************************************************************
; Thats all ffolks
;***********************************************************************
end 
