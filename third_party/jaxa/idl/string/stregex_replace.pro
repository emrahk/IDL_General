;+
; Project     : Hinode Science Data Centre Europe (Oslo SDC)
;                   
; Name        : STREGEX_REPLACE
;               
; Purpose     : Using built-in STREGEX to make a (global) replace function
;               
; Explanation : Strangely enough, IDL does not provide a search-and-replace
;               function. This is one possible implementation of it, using the
;               built-in STREGEX function. Note that replacements are always
;               "global", i.e. it keeps going until no more replacements are
;               possible, unless the keyword ONCE is set. Note also that the
;               replacements start from the *END* of the string, not from the
;               beginning. It's possible to end up with an infinite recursion
;               if e.g. the pattern matches the replacement.
;
; Use         : result = stregex_replace(original,pattern,replacement)
;
; Inputs      : See "Use"
; 
; Opt. Inputs : None.
;
; Outputs     : Returns string, substitution performed.
;               
; Opt. Outputs: None.
;               
; Keywords    : ONCE: Set to make only one substitution, not a 'global'
;                     replace
;
; Calls       : Only built-ins and itself
;
; Common      : None
;               
; Restrictions: ?
;               
; Side effects: None known.
;               
; Categories  : STRING
;               
; Prev. Hist. : None
;
; Written     : SVH Haugan, UiO, 15 August 2011
;               
; History     : 
;
; Contact     : s.v.h.haugan@astro.uio.no
;-

FUNCTION stregex_replace,original,pattern,replacement,once=once
  IF n_elements(original) GT 1 THEN BEGIN
     result = original
     result[*] = ''
     FOR i=0,n_elements(original)-1 DO BEGIN
        result[i] = stregex_replace(original[i],pattern,replacement,once=once)
     END
     return,result
  END
  
  search_pattern = '(.*)('+pattern+')(.*)'
  
  subexpr = stregex(original,search_pattern,/subexpr,/extract)
  
  IF subexpr[0] EQ '' THEN return,original ;; No match for us
  
  remainder = subexpr[1]+replacement+subexpr[3]
  
  IF keyword_set(once) THEN return,remainder
  
  return,stregex_replace(remainder,pattern,replacement) ;; Divine ;-)
END 
