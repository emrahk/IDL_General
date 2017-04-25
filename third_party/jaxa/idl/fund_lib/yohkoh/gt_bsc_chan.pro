;+
; NAME:
;       GT_BSC_CHAN
; PURPOSE:
;       extract channel nos and/or channel IDs BSC index
; CALLING SEQUENCE:
;       chans=gt_bsc_chan(bsc_index,string=string)
; INPUTS:
;       bsc_index = bsc_index structure or array of indicies
; OUTPUTS:
;       chans = array of channel nos (or ion names) in index
; KEYWORDS
;       string    = if set, then return channels as ion names
;	uniq	  = if set, only return unique channel values
;       smm       = if set, return SMM BCS channel values
; HISTORY:
;    11-Sep-93, D. Zarro (ARC), Written
;     3-Feb-94, Zarro, added SMM capability
;    15-Mar-94, Zarro, added /CONT to message for invalid channels
;    1-Sep-94, Zarro, fixed potential bug with UNIQ
;-

function gt_bsc_chan,bsc_index,string=string,unique=unique,smm=smm

on_error,1

yoh_ions=['Fe XXVI','Fe XXV','Ca XIX','S XV']

smm_ions = ['Ca XVIII-XIX','Fe K-alpha  ','Fe XVIII-XXI', $
       'Fe XXII-XXV ','Fe XXIII     ','Fe XXIV     ','Fe XXV (R)  ', $
       'Fe XXVI K-al']

cok=bsc_check(bsc_index)

spacecraft='YOH'
if cok then begin
 chans=fix(bsc_index.bsc.chan) 
 spacecraft=string(bsc_index(0).bsc.st$spacecraft)
endif else begin
 dtype=datatype(bsc_index,2)
 if keyword_set(smm) then spacecraft='SMM'
 if (dtype le 5) and (dtype ge 1) then chans=bsc_index else $
  message,'usage ---> CHANS=GT_BSC_CHAN(BSC_INDEX,/STRING)'
endelse

nchans=n_elements(chans)

if (spacecraft eq 'SMM') then ions=smm_ions else ions=yoh_ions

nions=n_elements(ions) 
schans=strarr(nchans)+'???'
for i=1,nions do begin
  cfind=where(chans eq i,count)
  if count gt 0 then schans(cfind)=ions(i-1)
endfor

;-- check legal channels

chk=where((chans lt 1) or (chans gt nions),count)
if count gt 0 then begin
 chans(chk)=-1 & schans(chk)='???'
endif

;-- select unique channels

if keyword_set(unique) then begin
 if n_elements(chans) eq 1 then chans=[chans]
 ii = (uniq(chans,sort([chans])))
 chans = chans(ii)
 schans = schans(ii)
 j=where(chans ne -1,count)
 if count eq 0 then message,'invalid input channel(s)',/cont else begin
  chans=chans(j)
  schans=schans(j)
 endelse
endif

if keyword_set(string) then chans=schans else chans=fix(chans)

return,chans & end
