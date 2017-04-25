function ssw_unspike_cube, index,  data, outindex, threshold=threshold, $
         loud=loud, verbose=verbose, display=display, $
         logfile=logfile, new=new, update_hist=update_hist
;+
; Project     : SSW (TRACE/CDS/SXT/SXI...)
;
; Name        : ssw_unspike_cube
;
; Purpose     : temporal despiking of CCD image cube using neighbor images
;
; Category    : Image processing
;
; Explanation : (from trace_unpike_time header)
;               This algorithm cleans up spiky pixel in TRACE images which are either
;		high because of a cosmic ray hit or represent "hot pixels" that are 
;		temporarily enhanced. Because this algorithm is based on spatial and
;		temporal next neighbors (from the 3x3x3 cube around the spiky pixel) it 
;		requires a 3D data cube with a sequence of images DATA(*,*,NTIMES), 
;		NTIMES>3. It filters out noisy spikes that exceed a threshold factor THRES 
;		above the average of 2x8 nearest spatial neighbors of the preceding and
;		following image. The 8 nearest spatial neighbors in the simultaneous image
;		are not used because of the ring-like sidelobes produced by the jpeg compression
;		around a cosmic ray hit. The spiky pixel is replaced by the average of the
;		nearest 2 temporal pixels if the spikly pixel is a cosmic ray hit but 
;		not a "hot pixel". The noisy pixel is replaced by average of the 2x8 nearest 
;		(non-simultaneous) spatial neighbors if it is a "hot pixel".
;		This algorighm works similar to TRACE_DESPIKE and TRACE_DESTREAK, 
;		but seems to produce cleaner images for long exposure times where 
;		cosmic ray hit rate is high. Multiple iterations of this algorithm are 
;		recommended for deep cleaning (e.g. THESH=1.15), while a single iteration
;		if sufficient for coarse cleaning (e.g. THRESH=1.5).
;		This IDL algorithm is a vectorized version. 
;
;
;   Input Parameters: 
;      index, data - standaard read_xxx 'index,data' output
; 
;   Output Paramters:
;      outindex - optional, index with .HISTORY updated 
;
;    Keyword Parameters:
;      threshold - sensitivity threshold, default = 1.5
;      verbose/loud (synonyms) - if set, be noiser to TTY
;      display - if set, display to image device
;      logfile - if string, name of logfile to write statistics too
;                if set (/LOGFILE), log to $HOME/trace_unspkike_time.dat
;      new - if set and logfile defined or set, force new logfile (def=append)
;      update_hist - if set, update .HISTORY tag of input index vector
;                    [optionally, can return same in 3rd parameter to avoid
;                     clobbering input]
;  
;    Calling Sequence:
;       cleaned=ssw_unspike_cube(index,data [,newindex] [,theshold=threshold] , $
;                   [ /verbose, /loud, /logfile, /display]
;    History
;      Version 1,  30-MAR-1990,  Markus J. Aschwanden, LMSAL,  Written
;      Version 2,  19-July-1999, S.L.Freeland, LMSAL, rename ->function
;                   sswify it, remove explicit LUN, make it quiet
;                   by default, make logging statistics optional
;      Version 2.1 20-July-1999, S.L.F. added UPDATE_HISTORY keyword and function
;      Version 2.2 15-Sep-1999,  S.L.F. correct a call to 'concat_dir'
;      Version 2.3 24-jul-2000, S.L.Freeland - minor gentrification and
;                               -> ssw/gen
;
;    Usage:
;       Suggest 2D despiking pass first and image registration
;       Cadence should be reasonable relative to lifetime of transient 
;       small features (XRay Bright Points for example)
;       
; Contact     : aschwanden@lmsal.com / freeland@penumbra.nascom.nasa.gov
;-

if not keyword_set(threshold) then threshold=1.5
loud=keyword_set(loud) or keyword_set(verbose)
display=keyword_set(display)
logging=keyword_set(logging)
new=keyword_set(new)

case 1 of 
   data_chk(logfile,/string): ; user supplied
   logging:                   logfile=concat_dir('$HOME','/ssw_unspike3d.dat')
   else:
endcase

if n_params() lt 2 then begin
    box_message,'IDL>cleaned=trace_unspike_time(index,data [,thresh=xx] ...)
    return,-1
endif    

if loud then print,'Threshold= ',threshold
cleaned_data=data

; - slf, use 'data_chk' to find nx/ny/nz 
nx=data_chk(data,/nx)
ny=data_chk(data,/ny)
nz=data_chk(data,/nimage)

if not data_chk(index,/struct) or nz lt 3 then begin
   box_message,['Standard "index,data" , 3 images minimum...']
   return,-1
endif

lmess=strarr(nz)                                 ; message for logfile
hmess=strarr(nz)                                 ; message for history
cfract=fltarr(nz)                                ; corrected fraction per image

if display then wdef,im=data(*,*,0)

for iz=0,nz-1 do begin
 nclean	=0
 if loud then print   ,'Filter image #',iz,'   size=',nx,ny
 iz1	=iz-1	&if (iz eq 0)    then iz1=iz+2
 iz2	=iz+1	&if (iz eq nz-1) then iz2=nz-3
 for j=0,ny-1 do begin
  j1	=j-1	&if (j eq 0)    then j1=j+2
  j2	=j+1	&if (j eq ny-1) then j2=ny-3
  a1	=shift(data(*,j1,iz1),-1)	;8 nearest neighbors at t(i-1) 
  a2	=      data(*,j1,iz1)    
  a3	=shift(data(*,j1,iz1),+1) 
  a4	=shift(data(*,j ,iz1),-1) 
  a0	=      data(*,j ,iz1)    
  a5	=shift(data(*,j ,iz1),+1) 
  a6	=shift(data(*,j2,iz1),-1) 
  a7	=      data(*,j2,iz1)    
  a8	=shift(data(*,j2,iz1),+1) 
  b1	=shift(data(*,j1,iz2),-1) 	;8 nearest neighbors at t(i+1)
  b2	=      data(*,j1,iz2)    
  b3	=shift(data(*,j1,iz2),+1) 
  b4	=shift(data(*,j ,iz2),-1) 
  b0	=      data(*,j ,iz2)    
  b5	=shift(data(*,j ,iz2),+1) 
  b6	=shift(data(*,j2,iz2),-1) 
  b7	=      data(*,j2,iz2)    
  b8	=shift(data(*,j2,iz2),+1) 
  a_avg	=(a0+a1+a2+a3+a4+a5+a6+a7+a8)/8. ;average at time t(i-1)
  b_avg	=(b0+b1+b2+b3+b4+b5+b6+b7+b8)/8. ;average at time t(i+1)
  zav8	=((a_avg+b_avg)/2.)>0		 ;average of 16 pixels
  zav1	=((a0+b0)/2.)>0			 ;average of 2 nearest pixels in time
  zgood	=zav1
  ibad	=where(zav1 gt zav8*threshold,nbad)     ;bad high pixel
  if (nbad ge 1) then zgood(ibad)=zav8(ibad) ;replace bad 2-pixel average by 16-pixel average
  ispike=where(data(*,j,iz) gt zgood*threshold,nspike)	  ;spike detection
  if (nspike gt 0) then cleaned_data(ispike,j,iz)=zgood(ispike) ;replace central noispy spike
  nclean=nclean+nspike
 endfor
 fcleaned=float(nclean)/float(nx*ny)
 lmess(iz)=string('image #',iz,'   Fraction of noisy pixels cleaned = ',fcleaned)
 if loud then print, lmess(iz)
 cfract(iz)=fcleaned
 zmax	=median(data(*,ny/2,iz))
 zmin	=min(data(*,ny/2,iz))
 if display then tv,bytscl(cleaned_data(*,*,iz),min=zmin,max=zmax)
endfor

if logging then begin
   file_append,logfile,'NEXT ITERATION________________________________________________'
   file_append,logfile, lmess
endif

update_hist=keyword_set(update_hist)
if n_params() eq 3 or update_hist then begin ; handle history updates
   outindex=index                                ; copy in->out
   ipat='ITERATION# '
   ehist=reform([strarrcompress(get_history(index,ipat,found=found,/caller),/col)])
   if found then itnum=max(str2number(ehist)) + 1 else itnum=1
   update_history,outindex,ipat + strtrim(itnum,2)
   update_history,outindex,'THRESHOLD: ' + strtrim(threshold,2)
   update_history,outindex,'Fraction Corrected: ' + strtrim(cfract,2),/mode
   if update_hist then begin
       if loud then box_message,'Updating input index with history...'
       index=outindex
   endif
endif

return,cleaned_data
end
