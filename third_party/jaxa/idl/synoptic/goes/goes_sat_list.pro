;+
; Project     : HESSI
;
; Name        : GOES_SAT_LIST
;
; Purpose     : List GOES satellite numbers to search
;
; Category    : synoptic gbo
;
; Inputs      : SAT = satellite number to search for
;                    [def = latest current satellite]
;
; Outputs     : SEARCH = satellite search list, with input SAT first
;               COUNT = number of list elements
;
; Keywords    : NO_CYCLE - set to not return list, just input
;                          satellite (if valid)
;
; History     : Written 20 Jan 2012, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function goes_sat_list,sat,no_cycle=no_cycle,_extra=extra,err=err,count=count

err=''
cycle=~keyword_set(no_cycle)
sats=goes_sat(/number,_extra=extra)
if ~is_number(sat) then sat=goes_sat(/number,/latest,_extra=extra)
chk=where(sat eq sats,count,complement=complement)
if cycle then begin
 if count eq 0 then search_sats=sats else search_sats=[sat,sats[complement]]
endif else begin
 if count eq 0 then begin
  err='GOES'+trim(sat)+' is not a valid satellite.'
  message,err,/info
  return,-1
endif else search_sats=sat
endelse

count=n_elements(search_sats)

return,search_sats
end
