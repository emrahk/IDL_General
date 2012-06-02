pro do_latest,dc,opt,counts,lvtme,disp,a_counts,a_lvtme,det,cp,dt,$
              num_dets,rates0,rates1,num_chns,num_spec
;****************************************************************************
; Program calculates rates for latest idf.
; Variables are:
;         dc.................detector code
;        int.................integration  
;         cp.................cluster position
;        opt.................data display option
;    idf_hdr.................science header data
;     rates0.................counts/sec for single idf
;     rates1.................counts/sec for accumulated
;     counts.................1 idf counts(position,det,num_spec,chn)
;      lvtme.................1 idf livetme(position,det,num_spec)
;   a_counts.................accumulated counts(position,det,chn)
;    a_lvtme.................accumulated livetme(position,det)
;  idfs,idfe.................idf start,stop #s for accum.
;        idf.................current idf
;        dts.................start,date,time array
;         dt.................start,stop date,time array
;   num_spec.................# of spectra/det
;   num_chns.................# channels
;   num_dets.................# detectors
;       disp.................show 1 idf(0) of accumulated(1)
;      start.................first time(0) or subsequent(1)
;        new.................new file(1) or not(0)
;  num_lines.................# of gaussian lines
;      clear.................clear variable arrays if defined
;      trate.................total count rate (all chns)
;       fnme.................filename for storage
;        typ.................type of data set
;        rep.................repeat or not 
;       wait.................if activated wait an idf
;****************************************************************************
sz = size(rates1)
if (sz(0) eq 3)then prs = 1 else prs = 0
chans = replicate(1.,num_chns)
for i = 0,num_dets - 1 do begin
 if(opt eq 1)then begin
;****************************************************************************
; on - sum off rates (NET ON). ;****************************************************************************
    net_on,a_counts,a_lvtme,rates1,pr=prs
    if (disp eq 0)then rates0(i,*,*) = 0. 
 endif
 if(opt eq 2)then begin
;***************************************************************************
; off(+) - off(-) (NET OFF)
;***************************************************************************
    net_off,a_counts,a_lvtme,rates1,pr=prs
    if (disp eq 0)then rates0(i,*,*) = 0.
 endif
 if (opt gt 2)then begin
;***************************************************************************   
; single orientation
;***************************************************************************
    op = opt - 3
    in = where(lvtme(op,i,*) ne 0.)
    if (in(0) ne -1)then $
    rates0(i,in,*) = counts(op,i,in,*)/(reform(lvtme(op,i,in))#chans)
    if (prs) then begin
       in = where(a_lvtme(op,i,*) ne 0.)
       if (in(0) ne -1)then $
       rates1(i,in,*) = a_counts(op,i,in,*)/(reform(a_lvtme(op,i,in))#chans)
    endif else begin
       if (a_lvtme(op,i) ne 0.)then $
       rates1(i,*) = a_counts(op,i,*)/a_lvtme(op,i)
    endelse
 endif
endfor
;***************************************************************************
; Thats all, ffolks
;***************************************************************************
return
end
