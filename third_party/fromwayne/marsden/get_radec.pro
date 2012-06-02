pro get_radec,idfs,idfe,ra,dec,idf=idf,yra=yra,$
              ydec=ydec,qu=qu,time=time
;********************************************************
; Program gets the ra and dec for the 
; spacecraft pointing axis (x) for a 
; range of IDFs. This is adapted from the 
; program getRAandDEC.c (Tom Gasaway)
; The variables are:
;    idfs,idfe.........start,stop idfs
;       ra,dec.........equatorial coordinates of x
;          idf.........array of idfs
;          rst.........reset file pointer if def.
;     yra,ydec.........equatorial coordinates of y
;           qu.........array of quaternions vs time
;         time.........sc time coordinate of quaternion  
;********************************************************
; Now do usage:
;********************************************************
if (n_elements(idfs) eq 0) then begin
   print,'USAGE: GET_RADEC,IDFSTART,IDFEND,' + $
         'RA_DEG,DEC_DEG,[IDF=OUTPUT IDFS],' + $
         '[YRA=YRA],[YDEC=YDEC]' + $
         '[QU=QUATERNION VS TIME],[TIME=TIME]'
   return
endif
;********************************************************
; Make some variables
;********************************************************
t = double(1.)
id = long(0)
q = fltarr(4)
num = idfe - idfs + 1
if (num eq 1)then quat = fltarr(4) else $
quat = fltarr(4,num)
idf = lonarr(num)
count = 0.
;********************************************************
; Find a good starting point for the file pointer
;********************************************************
lidf0 = long(3784495)
if (long(idfs) lt lidf0)then begin
   print,'MIN IDF TOO SMALL FOR ATTITUDE.DATA FILE!!!!'
   ra = 0. & dec = 0.
   return
endif
;pointer = $
;long(24)*(long(7808)+long(64)*(long(idfs)-lidf0))
pointer = long(24)*long(7936)
;********************************************************
; Open the file and set the file pointer 
;********************************************************
get_lun,unit
openr,unit,'/apid14/attitude.data'
point_lun,unit,pointer
on_ioerror,dumb
;********************************************************
; Search to the desired starting idf
;********************************************************
while (id ne idfs) do begin
   idsave = id & qsave = q
   readu,unit,t,q
   id = long(t/16.)
   count = count + 1
endwhile
count = 0. & bcount = 0.
;********************************************************
; Read *all* the data for each idf, and 
; compute the average quaternion for each
; idf.
;********************************************************
nidf = 0.
id0 = id
qidf = [0.,0.,0.,0.]
time = t
qu = q
while (id le idfe and count lt num)do begin
   readu,unit,t,q
   id = long(t/16.)
   if (id eq id0 and id le idfe)then begin
      qidf = $
      transpose([transpose(qidf),transpose(q)])
      qu = transpose([transpose(qu),transpose(q)])
      time = [time,t]
      bcount = bcount + 1.
   endif
   if (id ne id0)then begin
      bcount = bcount + 1.
      n = n_elements(qidf(0,*)) - 1.
      nn = n_elements(qu(0,*))
      if (num gt 1)then begin
         quat(*,count) = $
         qidf(*,1:n)#replicate(1.,n)/n
      endif else quat = qidf(*,1:n)#replicate(1.,n)/n
      idf(count) = id0
      nskip = id - id0 - long(1)
      if (nskip gt 0)then begin
;********************************************************
; Oops! Do the case for skipping of idfs
;********************************************************
         skipped = id0 + long(1) + lindgen(nskip)
         in = where(skipped le idfe)
         if (in(0) ne -1)then begin 
            skipped = skipped(in)
            nskip = n_elements(in)
         endif
         quat(*,count:count+nskip-1) = [0.,0.,0.,0.]
         skipped = id0 + long(1) + lindgen(nskip-1)
         idf(count:count+nskip-1) = skipped
         count = count + nskip
      endif else count = count + 1.
      id0 = id
   endif
endwhile
;********************************************************
; Somehow we may have skipped entirely over the 
; requested range of idfs. In this case we can 
; interpolate.
;********************************************************
if (id gt idfe and count eq 0)then begin
   print,'INTERPOLATING ATTITUDE DATA FOR IDFS'
   print,idfs,' TO ',idfe,'!!!!!'
   idf = idfs + lindgen(num)
   xidf = (idf-idsave)/(id-idsave)
   for i = 0,3-1 do quat(i,*) = $
   interpolate([qsave(i),q(i)],xidf)
endif
;********************************************************
; Update file pointer and close file
;********************************************************
close,unit
free_lun,unit
;********************************************************
; Now calculate the ra and dec of the detector
; axis for each requested idf. This part ripped 
; off (unabashedly) from TMG code. For more 
; information see Wertz (Spacecraft Attitude 
; Determination and Control). First compute
; attitude matrix. 
;********************************************************
att = fltarr(3,3,num)
q11 = quat(0,*)*quat(0,*)
q22 = quat(1,*)*quat(1,*)
q33 = quat(2,*)*quat(2,*)
q44 = quat(3,*)*quat(3,*)
q12 = quat(0,*)*quat(1,*)
q34 = quat(2,*)*quat(3,*)
q13 = quat(0,*)*quat(2,*)
q24 = quat(1,*)*quat(3,*)
q23 = quat(1,*)*quat(2,*)
q14 = quat(0,*)*quat(3,*) 
;
att(0,0,*) = q11 - q22 - q33 + q44
att(0,1,*) = 2.*(q12 + q34)
att(0,2,*) = 2.*(q13 - q24)
att(1,0,*) = 2.*(q12 - q34)
att(1,1,*) = -q11 + q22 - q33 + q44
att(1,2,*) = 2.*(q23 + q14)
att(2,0,*) = 2.*(q13 + q24)
att(2,1,*) = 2.*(q23 - q14)
att(2,2,*) = -q11 - q22 + q33 + q44
;********************************************************
; Now calculate the ra and dec for the spacecraft
; X axis.
;********************************************************
ay = double(att(0,1,*))
ax = double(att(0,0,*))
bx = abs(ax)
by = abs(ay)
phi = bx*0d
crd = double(180.)/!dpi
dec = reform(crd*asin(att(0,1,*)),num)
in = where(ax eq 0d and ay gt 0d)
if (in(0) ne -1)then phi = !dpi/2d
in = where(ax eq 0d and ay lt 0d)
if (in(0) ne -1)then phi = 3d*!dpi/2d
in = where(ax gt 0d and ay ge 0d)
if (in(0) ne -1)then phi = atan(by/bx)
in = where(ax lt 0d and ay le 0d)
if (in(0) ne -1)then phi = !dpi + atan(by/bx)
in = where(ax gt 0d and ay le 0d) 
if (in(0) ne -1)then phi = 2d*!dpi - atan(by/bx)
ra = phi*crd
;********************************************************
; Now calculate the ra and dec for the spacecraft
; Y axis.
;********************************************************
ay = double(att(1,1,*))
ax = double(att(1,0,*))
bx = abs(ax)
by = abs(ay)
phi = bx*0d
ydec = reform(crd*asin(att(1,1,*)),num)
in = where(ax eq 0d and ay gt 0d)
if (in(0) ne -1)then phi = !dpi/2d
in = where(ax eq 0d and ay lt 0d)
if (in(0) ne -1)then phi = 3d*!dpi/2d
in = where(ax gt 0d and ay ge 0d)
if (in(0) ne -1)then phi = atan(by/bx)
in = where(ax lt 0d and ay le 0d)
if (in(0) ne -1)then phi = !dpi + atan(by/bx)
in = where(ax gt 0d and ay le 0d) 
if (in(0) ne -1)then phi = 2d*!dpi - atan(by/bx)
yra = phi*crd
;********************************************************
; Thats all ffolks I
;********************************************************
return
;********************************************************
; Error : Thats all ffolks II
;********************************************************
dumb : print,'ERROR READING ATTITUDE FILE - ' + $
             ' ARE IDFS IN RANGE?'
close,unit
ra = fltarr(num) & dec = ra
yra = ra & ydec = dec
idf = idfs + lindgen(num)
return
end
