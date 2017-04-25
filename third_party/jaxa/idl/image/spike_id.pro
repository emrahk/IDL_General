FUNCTION spike_id,img,cutoff,remove=remove,width=width

;+
;       NAME: spike_id
;
;       PURPOSE: To locate single pixel spikes, like Cosmic Rays,
;		 in 2-D images.
;
;       METHOD: Default uses a three point median filter as a 
;		reference, takes the difference and compares it with the
;		cutoff value. The returned variable is a vector of pointers 
;		to spikes in the input variable.
;
;       CALLING SEQUENCE:
;		out = spike_id(img,cutoff,[remove=remove,width=width])
;
;
;       PARAMETERS: 	img		input image 
;			cutoff		comparison cutoff
;
;	KEYWORDS:	remove		when set return corrected 
;					image
;			width		median filter size (default
;					is 3).
;	CALLS: 	 COORD_V2L
;
;       HISTORY: Drafted by A.McAllister, following a B.Labonte
;		 algorythm, 10-jun-93.
;		 Added code to handle borders, and keyword to
;		 return corrected image, 2-jul-93.
;		 trap for no spikes, 9-aug-93.
;		 added control to filter size (default is the orginal
;		 value of 3), also added absolute value on difference
;		 12-Jan-94, gal
;                LWA, 3/8/94, made from spikes.pro to remove absolute
;                   value feature installed by GAL.
;		 LWA, 3/12/94, Corrected header and fixed width keyword.
;-

sz=size(img)
xmax=sz(1)-1
ymax=sz(2)-1

if NOT keyword_set(width) then width = 3 else width = width ;default filter size
medn=median(img,width)
spkes=where((img - medn) gt cutoff)
if keyword_set(remove) and spkes(0) ne -1 then img(spkes)=medn(spkes)

for i=0,ymax do begin			;vertical boundries

   ym=(i-1)>0
   yp=(i+1)<ymax
   medy0=median(img(0:1,ym:yp))
   medym=median(img((xmax-1):xmax,ym:yp))
   x0ss=where((img(0,i)-medy0) gt cutoff)
   xmss=where((img(xmax,i)-medym) gt cutoff)
   if x0ss(0) eq 0 then begin
     ll=coord_v2l([0,i],sz)
     spkes=[spkes,ll]
     if keyword_set(remove) then img(ll)=medy0
   end
   if xmss(0) eq 0 then begin
     ll=coord_v2l([xmax,i],sz)
     spkes=[spkes,ll]
     if keyword_set(remove) then img(ll)=medym
   end

endfor

for j=0,xmax do	begin		;horizontal boundries

   xm=(j-1)>0
   xp=(j+1)<xmax
   medx0=median(img(xm:xp,0:1))
   medxm=median(img(xm:xp,(ymax-1):ymax))
   y0ss=where((img(j,0)-medx0) gt cutoff)
   ymss=where((img(j,ymax)-medxm) gt cutoff)
   if y0ss(0) eq 0 then begin
     ll=coord_v2l([j,0],sz)
     spkes=[spkes,ll]
     if keyword_set(remove) then img(ll)=medx0
   endif
   if ymss(0) eq 0 then begin
     ll=coord_v2l([j,ymax],sz)
     spkes=[spkes,ll]
     if keyword_set(remove) then img(ll)=medxm
   endif

endfor

return,spkes

end
