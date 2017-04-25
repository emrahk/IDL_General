pro rd_gxd_fits,time0,time1,gxd,_extra=_extra,sat=sat,keep_bad=keep_bad
;+
;   Name: rd_gxd_fits
;
;   Purpose: emulate rd_gxd api using "sdac" style GOES FITS 
;
;   Input Parameters:
;      time0,time1 - time range; any ssw/anytim.pro compatible fmt
;
;   Output Parameters:
;      gxd - associated GXD structures {time,day,lo,hi,spare[2])
;
;
;   History:
;      19-aug-2008 - S.L.Freeland - transition 
;      11-apr-2011 - S.L.Freeland - allow remote (no local $SSWDB) via rd_goes_sdac
;                    rd_gxd plug in for no-data return
;-

t0=anytim(time0,/ecs)
t1=anytim(time1,/ecs)

;gfits_r,stime=t0, etime=t1, tarr=tarr,yarr=yarr, $
;   /nosetbase,base_sec=base_sec, error=error, err_msg=err_msg,/SDAC, $
;   sat=sat
rd_goes_sdac,stime=t0, etime=t1, tarr=tarr, yarr=yarr, $
   /nosetbase,base_sec=base_sec, error=error, $
   err_msg=err_msg,/SDAC, sat=sat,_extra=_extra


if error then begin 
   box_message,'error: ' + err_msg
   gxd=-1
endif else begin 
   gbo_struct,gxd=gxd
   lo=reform(yarr(*,0))
   hi=reform(yarr(*,1))
   if not keyword_set(keep_bad) then begin
     ssok=where(lo ne -99999 and hi ne -99999,okcnt)
     if okcnt gt 0 and okcnt lt n_elements(lo) then begin 
        lo=lo(ssok)
        hi=hi(ssok)
        tarr=tarr(ssok)
     endif 
   endif
   nout=n_elements(tarr)
   gxd.spare(0)=sat
   gxd=replicate(gxd,nout)
   gxd.lo=lo
   gxd.hi=hi
   times=anytim(tarr+base_sec,/int)
   gxd.time=times.time
   gxd.day=times.day
endelse
return
end
