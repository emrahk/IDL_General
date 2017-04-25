pro index2fov, index, east, west, north, south, $
	       extremes=extremes, heliographic=heliographic, $
	       center_fov=center_fov, size_fov=size_fov, $ 
               l1=l1, soho=soho
;+
;   Name: index2fov
;
;   Purpose: FOVs for input index(s) - optionally EXTREMEs of multiple FOVs
;  
;   Input Parameters:
;      index - vector of SSW structures (inc pointing and time standards..)
;
;   Output Parameters:
;      east, west, north, south - image edges in arcseconds
;
;   Keyword Parameters:
;      extremes - (input) - switch, if set, outputs are for "composite"
;                           (used for mosaic building, for example)
;      heliographic - input - switch, if set, outputs are heliographic
;      l1/soho - (input) switches - synonym for L1 in arcmin2hel call
;                             (default=heliocentric in arcsec)
;      center_fov - (output) - if /extremes, then "composite" fov center
;      size_fov   - (output) - if /extremes, then "composite" fov nx,ny
;
;   History:
;      Circa 1999 - S.L.Freeland - for mosaic building - Extremes of multi FOV
;      10-Feb-2003 - S.L.Freeland - /HELIO extensions (need arcmin2hel mod??) 
;-

if not required_tags(index,'naxis1,xcen,cdelt1',missing=missing ) then begin
   box_message,['The following required tags are missing', '   ' + missing, $
		'IDL> index2fov,index, east,west,north,south']
   return
endif   


; ---------- extract the required info ---------
xcen=gt_tagval(index,/xcen)
ycen=gt_tagval(index,/ycen)
cdelt1=gt_tagval(index,/cdelt1)
cdelt2=gt_tagval(index,/cdelt2,missing=cdelt1)
naxis1=gt_tagval(index,/naxis1)
naxis2=gt_tagval(index,/naxis2)

; ---------- calc fov in " from sun center ---------
dx=float(naxis1*cdelt1)/2.
dy=float(naxis2*cdelt2)/2.
east=xcen-dx
west=xcen+dx                                ; WEST Positive
north=ycen+dy                               ; NORTH Positive
south=ycen-dy

if keyword_set(extremes) then begin         ; limits for multiple FOVs
   east=min(east)                           
   west=max(west)
   north=max(north)
   south=min(south)
   size_fov=[west-east, north-south]             ; NX,NY
   center_fov=([west,north]) - float(size_fov)/2.
endif
if keyword_set(heliographic) then begin 
   l1=keyword_set(l1) or keyword_set(soho) or $
      (strupcase(gt_tagval(index(0),/TELESCOP)) eq 'SOHO')
   utcints=anytim(index,/utc_int)

   quad=str2arr('helul,helll,helur,hellr')
   ew  =str2arr('east,east,west,west')
   ns  =str2arr('north,south,north,south')
   for i=0,3 do begin 
      estring=quad(i)+'=arcmin2hel('+ew(i)+'/60.,'+ns(i)+ $
         '/60.,soho=l1,date=utcints,off=off)'
      estat=execute(estring)
      if off then begin
         estring=quad(i)+'=reverse(conv_a2h(['+ew(i)+ ','+ ns(i)+ $
            '],anytim(utcints,/ints)))'
         estat=execute(estring) 
      endif
   endfor

   south=helul(0,*) < helll(0,*)
   north=helur(0,*) > hellr(0,*)
   west=(helul(1,*) > helur(1,*)) > (-90) < 90
   east=(helll(1,*) < hellr(1,*)) > (-90) < 90 
endif

return
end
