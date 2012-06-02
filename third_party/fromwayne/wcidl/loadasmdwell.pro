function loadasmdwell, fl, cut=cut, rebin=leng


;; Load in the ASM data
;;
;; The "Data by Dwell" ASCII files contain twelve columns: 
;;    0.MJD of the observation (JD - 2,400,000.5) 
;;    1.SSC unit number 
;;    2.Dwell sequence number 
;;    3.Dwell number 
;;    4.Reduced chi-square of the fit 
;;    5.Number of sources in the field of view 
;;    6.Earth angle (degrees) 
;;    7.Fitted ASM unit count rate (counts/second; Crab is ~75) 
;;    8.Estimated error (counts/second) 
;;    9.Exposure time (seconds) 
;;   10.Long-axis angle theta (degrees) 
;;   11.Short-axis angle phi (degrees) 

;; In the case of rebinning, the output is
;;
;;    0.MJD of the observation (JD - 2,400,000.5) 
;;    1.Averaged ASM unit count rate
;;    2.RMS estimated error (counts/second) 
;;    3.RMS deviation of the points from the mean (counts/second) 
;;      (someday, right now it's set to 0)
;;    4.Number of dwells averaged 


temp=dblarr(12)
data=[0]

openr,unit,fl,/get_lun
while not eof(unit) do begin
   readf,unit,temp,format='(12f0)'
   if (data(0) eq 0) then begin
      data=[temp]
   endif else begin
      data=[[data],[temp]]
   endelse 
endwhile
free_lun,unit

data=double(data)

;; Cut Criteria
if (keyword_set(cut)) then begin
   ; 1.Reduced chi-square of the fit <1.5, except for Sco X-1 <8.0 
   w=where(data(4,*) lt 1.5)
   data=data(0:11,w)

   ; 2.Number of sources in the field of view <16 
   w=where(data(5,*) lt 16)
   data=data(0:11,w)

   ; 3.Earth angle >75 degrees 
   w=where(data(6,*) gt 75)
   data=data(0:11,w)

   ; 4.Exposure time >30 seconds 
   w=where(data(9,*) gt 30)
   data=data(0:11,w)

   ; 5.Long-axis angle -41.5< theta <46 degrees 
   w=where(data(10,*) gt -41.5 and data(10,*) lt 46.)
   data=data(0:11,w)

   ; 6.Short-axis angle -5< phi <5 degrees 
   w=where(data(11,*) gt -5 and data(11,*) lt 5)
   data=data(0:11,w)

endif

;; Rebin the data (if desired)
if (keyword_set(leng)) then begin
   leng=double(leng)
   tmp1=dblarr(5)
   tmp2=dblarr(5)
   i=data(0,0)
   while ( i lt max(data(0,*)) ) do begin
      w=where( (data(0,*) ge i) and (data(0,*) lt (i+leng)),cnt)
      if (cnt gt 0) then begin
         tmp1(0)=i + leng/2.d
         tmp1(1)=total(data(7,w)/(data(8,w)^2.d))/total(1.d/(data(8,w)^2.d))
         tmp1(2)=sqrt(1.d/total(1.d/(data(8,w)^2.d)))
         tmp1(3)=0.0
         tmp1(4)=cnt
   
         if (tmp2(0) eq 0) then begin
            tmp2=[tmp1]
         endif else begin
            tmp2=[[tmp2],[tmp1]]
         endelse
      endif
      i=i+leng
   end
   data=tmp2
end


;;
;; That's All FFolks!
;;

return,data
end
