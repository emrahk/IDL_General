;+
; NAME:
;       BSC_CHECK
; PURPOSE:
;       check that index or data structure is of type BSC
; CALLING SEQUENCE:
;       S=BSC_CHECK(BSC_INDEX,NSC_DATA)
; INPUTS:
;       BSC_INDEX    - BSC index structure
;       BSC_DATA     - BSC data structure
; OUTPUTS:
;       S            - 1 if BSC structure type
;                    - 0 otherwise
; PROCEDURE:
;       Simple use of TAG_NAMES function
;       if BSC_DATA is entered, then also checks if n_elements match
; HISTORY:
;       written by DMZ (ARC) - Mar'93
;       April'94 - added check for FLUX tag (DMZ)
;-

function bsc_check,bsc_index,bsc_data 

on_error,1


stc=datatype(bsc_index)
if stc ne 'STC' then return,0b

tags=strupcase(tag_names(bsc_index))
bsc=where(tags eq 'BSC',count1)
data=where( (tags eq 'COUNTS') or (tags eq 'FLUX'),count2)

if n_params() eq 1 then return,((count1 gt 0) or (count2 gt 0))

stc=datatype(bsc_data)
if stc ne 'STC' then return,0b

tags=strupcase(tag_names(bsc_data))
data=where( (tags eq 'COUNTS') or (tags eq 'FLUX'),count3)
bsc=where(tags eq 'BSC',count4)

ok=0
ok2=(count1 gt 0) and (count3 gt 0)
ok3=(count2 gt 0) and (count4 gt 0)
if ok2 or ok3 then ok=(n_elements(bsc_data) eq n_elements(bsc_index)) 

return,ok & end
   
