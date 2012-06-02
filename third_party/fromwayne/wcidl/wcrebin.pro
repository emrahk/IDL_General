pro wcrebin, time, rate, terr, rerr, sec

time=double(time)
rate=double(rate)
terr=double(terr)
rerr=double(rerr)
sec=double(sec)

q=size(time)
nbins=q(1)

tzero=min(time)
frst=0
i=0
nb=0

while (nb lt nbins) do begin
   w=where((time ge tzero+double(i)*sec) and $
           (time lt tzero+double(i+1.d)*sec), count)

   if (count ne 0) then begin
      if (min(time(w)) ne tzero+double(i)*sec) then begin
         tzero=min(time(w))
         i=0
         w=where((time ge tzero+double(i)*sec) and $
                 (time lt tzero+double(i+1.d)*sec), count)
      endif
   endif
      
   if (count ne 0) then begin
      q=size(w)
      nb=nb+q(1)
      if (frst eq 0) then begin

         ttime=(max(time(w))+min(time(w)))/2.d
         tterr=(max(time(w))-min(time(w)))/2.d

         trate=total(rate(w)/rerr(w)^2.d)/total(1.d/rerr(w)^2.d)
         trerr=1.d/sqrt(total(1.d/rerr(w)^2.d))
         frst=1

      endif else begin
         ttime=[ttime,(max(time(w))+min(time(w)))/2.d]
         tterr=[tterr,(max(time(w))-min(time(w)))/2.d]

         trate=[trate,total(rate(w)/rerr(w)^2.d)/total(1.d/rerr(w)^2.d)]
         trerr=[terr,1.d/sqrt(total(1.d/rerr(w)^2.d))]
      endelse
   endif

   i=i+1

endwhile

time=ttime
terr=tterr
rate=trate
err= trerr

return
end