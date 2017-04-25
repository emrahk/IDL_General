;+
; Project     : HESSI
;
; Name        : REPRODUCE
;
; Purpose     : Reproduce any input any number of times
;               (REPLICATE and REBIN have almost the same
;                functionality, but have problems with array
;                and string inputs)
;
; Category    : Utility
;                   
; Inputs      : SOURCE = input (e.g. ['a','b','c'])
;               TIMES = times to reproduce (e.g. 3)
;
; Outputs     : RESULT = replicated source 
;               (e.g. [['a','b','c'],['a','b','c'],['a','b','c']]
;
; Keywords    : None
;
; History     : Written, 4-June-2001,  D.M. Zarro (EITI/GSFC) 
;               Based upon a clever idea by R. Schwartz
;               11-March-2010, Zarro (ADNET)
;               - changed FIX to LONG
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function reproduce,source,times

if ~exist(source) then return,-1
if ~exist(times) then return,source
if long(times) lt 2 then return,source

return,(replicate( {a:source},long(times))).a

end

