pro mreadfits_fixup, index, data, loud=loud
;+
;   Name: mreadfits_fixup
;
;   Purpose: adjust some standard fields after mreadfits rebinning
;
;   Input Parameters:
;      index (input/output) - structure array (see mreadfits.pro)
;      data  - corresponding data array (post-rebinning)
;
;   Output Parameters:
;      index - fields adjusted for previous rebinning
;     
;   Calling Sequence:
;      mreadfits_fixup, index, data [,/loud]
;      (by the time you read this, it may be called WITHIN mreadfits)
;  
;   History:
;      4-Jun-1997 - S.L.Freeland
;      5-Jun-1997 - S.L.Freeland - fix an 'off-by-1' error
;      5-may-2004 - S.L.Freeladn - relax constraint on all or nothing 
;      14-May-2008, William Thompson, GSFC
;               Correct CRPIX calculation
;               Handle WCS alt. coord system keywords, CRPIX1A, etc.
;     
;-
if n_params() ne 2 then begin
   prstr,strjustify('IDL> mreadfits_fixup, index, data',/box)
   return
endif

xn=float(gt_tagval(index,/naxis1))
yn=float(gt_tagval(index,/naxis2))
sdata=float(size(data))
fx=xn/sdata(1) & fy=yn/sdata(2)
ss=where(fx ne 1 or fy ne 1,ncnt)

; list of tags which are adjusted - add to list as required
tag_adjust=str2arr('cdelt1,cdelt2,solar_r,crpix1,crpix2')
nonemissing=(where(tag_index(index,tag_adjust) eq -1,mcnt))(0) eq -1

; dont adjust unless required - and ONLY if proper tags found
if (ncnt gt 0)  then begin 
   message,/info,"applying temporary mreadits parameter fixup..."
   if tag_exist(index,'cdelt1') then begin
       index.cdelt1=(fx)*index.cdelt1
       for ib = 97b,122b do begin       ;step through alphabet
           name = 'cdelt1' + string(ib)
           if tag_exist(index,name) then begin
               ipos = tag_index(index,name)
               index.(ipos) = (fx)*index.(ipos)
           endif
       endfor
   endif
   if tag_exist(index,'cdelt2') then begin
       index.cdelt2=(fy)*index.cdelt2
       for ib = 97b,122b do begin       ;step through alphabet
           name = 'cdelt2' + string(ib)
           if tag_exist(index,name) then begin
               ipos = tag_index(index,name)
               index.(ipos) = (fy)*index.(ipos)
           endif
       endfor
   endif
   if tag_exist(index,'crpix1') then begin
       index.crpix1  = (1/fx) * (index.crpix1 - 0.5) + 0.5
       for ib = 97b,122b do begin       ;step through alphabet
           name = 'crpix1' + string(ib)
           if tag_exist(index,name) then begin
               ipos = tag_index(index,name)
               index.(ipos)  = (1/fx) * (index.(ipos) - 0.5) + 0.5
           endif
       endfor
   endif
   if tag_exist(index,'crpix2') then begin
       index.crpix2  = (1/fy) * (index.crpix2 - 0.5) + 0.5
       for ib = 97b,122b do begin       ;step through alphabet
           name = 'crpix2' + string(ib)
           if tag_exist(index,name) then begin
               ipos = tag_index(index,name)
               index.(ipos)  = (1/fy) * (index.(ipos) - 0.5) + 0.5
           endif
       endfor
   endif
   if tag_exist(index,'solar_r') then index.solar_r = (1/fy) * index.solar_r
   index.naxis1=sdata(1)
   index.naxis2=sdata(2)
endif 

return
end
