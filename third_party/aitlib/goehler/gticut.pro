function gticut, time, gti
;+
; NAME: 
;                   GTICUT
;
; PURPOSE:
;                   Select times which match in a good-time interval 
;                   definition
;
;
; CATEGORY:
;                   timing?  
;
;
; CALLING SEQUENCE:
;                   index=GTICUT(time, gti)
;
;
; INPUTS:
;                   time - array containing time information of the
;                          data structure. Time units must match the
;                          gti information
;                   gti  - array of good-time intervals which are
;                          defined by the start and stop
;                          time. Therefore each interval is given by
;                          an array with 2 entries.
;                          Example: gti=[[0,0.2], [0.7,15]]
;                          CURRENTLY THE INTERVALS MUST NOT OVERLAP!!!
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;                  returns an array containing the indices of the
;                  times which lie within the good-time intervals.
;
;
;
; OPTIONAL OUTPUTS:
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-

    index = -1                             ; define index array with first dummy element

    for i=0,(n_elements(gti)/2-1) do begin ; for each gti interval
        ind = where((gti[0,i] le time) and (gti[1,i] ge time)) ; look for times in interval
        if ind[0] ne -1 then index=[index,ind]                 ; add to index 
    endfor

    if n_elements(index) gt 1 then begin
        index=index[1:n_elements(index)-1]    ; remove dummy element
        index=index[uniq(index,sort(index))]  ; remove double elements, sort it
    endif


    return, index
end
