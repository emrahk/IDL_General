function ssw_index2nar, index, nar_only=nar_only



case 1 of 
   required_tags(index,'time,day') or required_tags(index,'time,mjd'): $
      itimes=anytim(index,/utc_int)
   required_tags(index,'date_obs'): itimes=anytim(index.date_obs,/utc_int)
   else: begin 
      box_message,'Need structure(s) with some SSW time standard
      return,-1
   endcase
endcase


retval=lonarr(n_elements(index))

time_window,itimes, nt0, nt1, days=2         ; +/- 15 days (conservative)

nar=get_nar(nt0,nt1)

outstr={ar:'',dT_secs:0l,dPos_arcsecs:0l}
outstr=add_tag(outstr,nar(0),'nar_rec')
nind=n_elements(index)
retval=replicate(outstr,nind)
tind=anytim(itimes,/ecs)
for ii=0,nind-1 do begin 
   dnar=drot_nar(nar,tind(ii),count=count)
   dist=sqrt((dnar.x-index(ii).xcen)^2 + (dnar.y-index(ii).ycen)^2)
   ssc=(where(dist eq min(dist)))(0)
   narrec=nar(ssc)
   retval(ii).ar=narrec.noaa
   retval(ii).dt_secs=ssw_deltat(narrec,ref=itimes(ii),/sec)
   retval(ii).dpos_arcsecs=dist(ssc)
   retval(ii).nar_rec=narrec
endfor
return,retval
end


