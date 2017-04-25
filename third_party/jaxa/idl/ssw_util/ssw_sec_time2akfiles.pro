function ssw_sec_time2akfiles, time0, time1, count=count, last2=last2, last7=last7

count=0
last2=keyword_set(last2)
last7=keyword_set(last7)
case 1 of
   keyword_set(last2) or keyword_set(last7): begin 
      time0=([reltime(days=-7),reltime(days=-2)])(last2)
      time1=([reltime(days=-7),reltime(days=-2)])(last2)
   endcase
   n_params() eq 1: time1=time0
   n_params() eq 2:  
   else: begin 
      box_message,'Need a time or time range...'
      return,''
   endcase
endcase

t0=anytim(time0,/ecs)
t1=anytim(time1,/ecs)
secparent='http://www.sec.noaa.gov/ftpdir/lists/geomag/'
case 1 of
   ssw_deltat(t0,ref=reltime(/now),/days) ge -2 or keyword_set(last2): $
      retval=secparent+['AK.txt']
   ssw_deltat(t0,ref=reltime(/now),/days) ge -7 or keyword_set(last7): $
      retval=secparent+['7day_AK.txt']
   ssw_deltat('1-jan-2004',t0,/day) gt 0: begin 
      mgrid=timegrid(reltime(t0,days=-30),t1,/month)
      fnames=strmid(time2file(mgrid),0,6)+'AK.txt'
      retval=secparent+fnames
   endcase
   else: begin 
      box_message,'No SEC A/K files available(?)
      retval=''
   endcase
endcase

count=n_elements(retval)*(retval(0) ne '')

return,retval
end
