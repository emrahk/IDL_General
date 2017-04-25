pro ssw_build_mosaic, index, data, mindex, mdata, ref_fov=ref_fov, $
		rotate=rotate, fast=fast, $
 	        center=center, fov=fov, csize=csize, $
		_extra=_extra, pixmap=pixmap, zbuffer=zbuffer, $
	        composite=composite, debug=debug, ref_image=ref_image
;+
;   Name: ssw_build_trace
;
;   Purpose: build a mosaic from components w/ssw std.
;
;   Input Parameters:
;      index, data  - standard SSW 'index,data' cubes (trace,sxt,...)
;      
;   Output Parameters:
;      mindex - the mosaic composite 'index' (index2map et al ready...)
;      mdata  - the mosaic data
;  
;   Keyword Parameters:
;      ref_fov - optional complete list of reference index for fov determ.
;      csize - (pixels) composite size (default is extremes of components)
;      fov   - solar FOV in arcminutes (default is extremes of components)
;      pixmap - if set, build mosaic in off screen PIXMAP
;      zbuffer - if set, build mosaic in Z-buffer  
;      composite - type of compositing to do (per plot_map)
;                  default=3 for "TRACE-like" (auto vignette correct)
;      rotate - if set, diff-rot (via drot_map) components relative to reference
;      fast   - if set, do fast diff-rot (translational) - ~ok if close in time
;  
;      _extra=_extra - most others passed to plot_map
;
;   Calling Seqeunce:
;     [select, process, and scale your 'data' (mosaic cube) as desired, then...]
;     IDL> ssw_build_mosiac, index, data, mindex, mdata [options]
;
;   Method:
;      index2map and index2fov, $
;         Then apply Dominic Zarro mapping SW to position/composite
;
;   Restrictions:
;     Need index,data with SSW standards (ex: read_trace default output)
;     Need at least one SOHO instrument in  SSW path  
;  
;   History:
;      28-April-1998 - S.L.Freeland - apply SSW/Mapping techniques to TRACE
;       2-Nov-1999   - S.L.Freeland - made interface copecetic, "genericize"
;                                     derive default center and fov using
;                                     index2fov,/extreme call
;      22-Nov-1999   - S.L.Freeland - add PERCENTD to history info
;      23-Nov-1999   - S.L.Freeland - add drot_map.pro hooks  (/rotate,/fast)
;      18-May-2000   - B.N.Handy    - Change an 'endif' to 'endelse' so this
;                                     works on solaris/IDL5.3
;-
debug=keyword_set(debug)
fast=keyword_set(fast)
rotate=keyword_set(rotate) or fast

if not data_chk(index,/struct) or n_params() lt 2 then begin
   box_message,$
     'IDL> ssw_build_mosiac, index, data, mindex, mdata [,csize=[nx,ny],fov=[x,y]' 
   return
endif    

case 1 of
   data_chk(ref_image,/struct):    refss=tim2dset(index,ref_image)
   data_chk(ref_image,/undefined): refss=0
   else: refss=ref_image
endcase

; ------------------ set up defaults/title -------------------------------
time_window,index,t0,t1                                 ; mosic start/stop times

; -------- derive fov, center, mosaic size information --------------
case 1 of
   data_chk(ref_fov,/struct): $
	index2fov,ref_fov,/extreme, center_fov=center_fov, size_fov=size_fov
   else:index2fov,index,/extreme, center_fov=center_fov, size_fov=size_fov
endcase

asppix=[min(gt_tagval(index,/cdelt1,miss=2.5)), $
        min(gt_tagval(index,/cdelt2,miss=2.5))]

case n_elements(csize)  of 
   0: csize=size_fov/asppix                           ; default output (pix)
   1: csize=replicate(csize,2)                        ; NX=NY
   else:                                              ; supplied
endcase   

csize=ceil(csize+2)                                     ; pad up to pixel
if not keyword_set(fov) then fov=size_fov/60.         ; arcmin 
if not keyword_set(center) then center=center_fov     ; arcsec 
; -----------------------------------------------------------------

; set up window
dtemp=!d.name
zbuff=keyword_set(zbuffer) or !d.name eq 'Z'

case 1 of
   !d.name eq 'Z':  
   keyword_set(zbuffer): 
   keyword_set(pixmap):
   max(csize) gt 1024: begin
      box_message,'Too large, forcing use of Z-buffer...
      zbuffer=1
   endcase     
   else:
endcase

wdef, zwin, zbuffer=zbuffer, csize(0), csize(1)
erase
; ------- initialize window with minimum ----------
;tv,make_array(csize(0),csize(1),value=min(data)-1,/int),/words,/channel
pmm,tvrd(/channel,/words)

; --------------- the MOSAIC part ---------------------------
index2map,index(refss),data(*,*,refss), rmap     ; reference index/data->map 

; ---------- plot reference using 
plot_map2, rmap, fov=fov, center=center, $
  /noaxes, /noxticks, /noyticks, /notitle, /nolable, $ ; inhibit plot stuff
  _extra=_extra, zbuffer=zbuffer,$
  xmargin=[0,0], ymargin=[0,0]

if not keyword_set(composite) then composite=3         ; def="trace-like"
; ---------------------------------------------
ss=rem_elem(lindgen(n_elements(index)),refss)          ; remaining subscripts
for j=0,n_elements(ss)-1 do begin                      ; each additional piece
   index2map,index(ss(j)),data(*,*,ss(j)), map         ; index,data->map
   if rotate then map=drot_map(map,time=index(refss), fast=fast)
   plot_map2, map, _extra=_extra, $
      zbuffer=zbuffer,composite=composite , /noxticks, /noyticks
endfor
; -------------------------------------------------------------------------

; ---------------------------------------------
if n_params() ge 4 then begin              ; read back mosaic => mdata
  case 1 of 
     !d.name ne 'Z': mdata=tvrd()          ; X or PIXMAP, 8 bit transfer
     else: begin
       trans16=data_chk(data,/type) ne 1
       mdata=tvrd(/words,/channel)
     endelse       
  endcase
endif  
; ---------------------------------------------

; define output index and add history
; ---------------------------------------------
mindex=index(refss)                              ; use reference as template
mindex.xcen=center(0)  & mindex.ycen=center(1)   ; center=> mosaic
mindex.naxis1=csize(0) & mindex.naxis2=csize(1)  ; nx/ny => mosaic
hstring='Reference: ' + anytim(mindex,/ecs)
hstring=[hstring,anytim(index,/ecs,/trunc) + ' ' + $
	 get_infox(index,'xcen,ycen,percentd')]
drot='Diff. Rotation Correction: ' + $
      (['NONE','YES'])(rotate) + (['','/FAST'])(fast)
hstring=[hstring,'Diff. Rotation Correction: ' + $
	          (['NONE','YES'])(rotate) + (['','/FAST'])(fast)]
update_history,mindex,hstring
; ---------------------------------------------

if debug then stop
set_plot,dtemp                                    ; reset window

return
end
