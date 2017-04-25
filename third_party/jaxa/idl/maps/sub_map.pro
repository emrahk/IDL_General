;+
; Project     : SOHO-CDS
;
; Name        : SUB_MAP
;
; Purpose     : get subimage of an image map
;
; Category    : imaging
;
; Explanation : Calling this procedure with /plot will invoke PLOT_MAP
;               and sub region is selected with a cursor.
;               In this case, XRANGE and YRANGE are returned as outputs.
;               Alternatively, XRANGE and YRANGE can be input variables
;               and will be used for extraction.
;               If REF_MAP is a valid map, then its XRANGE, YRANGE are used
;               for extraction
;
; Syntax      : sub_map,map
;
; Inputs      : MAP = map structure created by MAKE_MAP
;
; Outputs     : SMAP = subimage of map
;
; Opt. Outputs: None
;
; Keywords    : NOPLOT = don't invoke PLOT_MAP for graphical selection
;               XRANGE = [x1,x2] = min/max x-coord's (data units)
;               YRANGE = [y1,y2] = min/max y-coord's
;               IRANGE =[x1,x2,y1,y2] = output subarray of indicies (pixel units)
;               INDEX = map index for multiple maps (if plotting)
;               REF_MAP = reference map for inferring XRANGE, YRANGE
;               PRESERVE = output dimensions of SMAP same as REF_MAP
;               PIXEL = XRANGE/YRANGE are in pixel units
;               INIT = start all over again
;               DIMENSIONS = [n1,n2] = dimensions of SMAP
;
; History     : Written 22 November 1997, D. Zarro, SAC/GSFC
;               Modified 10 June 2003, Zarro (EER/GSFC) - changed SUB keyword
;               to IRANGE
;               Modified 8 January 2012, Zarro (ADNET) 
;                 - added DIMENSIONS keyword (use with care) 
;               Modified 10 April 2013, Zarro (ADNET)
;                 - reverted to original version with pointer support
;               3 December 2014, Zarro (ADNET)
;                 - added logic to extract FOV from reference map
;                   based on heliographic coordinates
;                 - deprecated /NOPLOT and /INIT
;               11 December 2014, Zarro (ADNET)
;                 - adjusted for differential rotation (via proj_xy) 
;               2 November 2015, Zarro (ADNET)
;                 - allowed for either XRANGE or YRANGE to be specified
;
; Contact     : dzarro@solar.stanford.edu
;-

pro sub_map,map,smap,xrange=xrange,yrange=yrange,ref_map=ref_map,preserve=preserve,$
            noplot=noplot,err=err,irange=irange,fov=fov,pixel=pixel,$
            index=index,_extra=extra,init=init,$
            dimensions=dimensions

err=''

if ~valid_map(map,err=err) then begin
 pr_syntax,'sub_map,map,smap,xrange=xrange,yrange=yrange)'
 return
endif

if ~valid_map(ref_map) && valid_map(fov) then ref_map=fov
valid_ranges=valid_range(xrange) || valid_range(yrange)
do_plot= ~valid_ranges && ~valid_map(ref_map) && ~keyword_set(pixel)

;-- get data coordinates to extract

nmap=n_elements(map)
if ~exist(index) then index=0 else index=index < (nmap-1)

;-- get arcsec ranges of sub map

if do_plot then begin
 plot_map,map[index],err=err,_extra=extra
 if err ne '' then return
 region=get_sub_region(_extra=extra,pixel=pixel)
 xrange=[region[0],region[1]]
 yrange=[region[2],region[3]]
endif

;-- get pixel indicies (REF_MAP overrides input or plot-derived x/y ranges)

nref=n_elements(ref_map)
for i=0,nmap-1 do begin

 sz=get_map_size(map[i])
 nx=sz[0]
 ny=sz[1]
 
 if ~keyword_set(pixel) then begin

  if valid_map(ref_map) then begin
   k= i < (nref-1)

;-- compute heliographic center of map in coordinate frame of
;   reference map, allowing for differential rotation.
   
   h2=proj_xy(ref_map[k],map[i],_extra=extra)

;-- compute sub FOV around this center

   ixrange=get_map_prop(ref_map[k],/xrange)
   iyrange=get_map_prop(ref_map[k],/yrange)
   dxs=(max(ixrange)-min(ixrange))/2.
   dys=(max(iyrange)-min(iyrange))/2.
   xrange=[h2[0]-dxs,h2[0]+dxs]
   yrange=[h2[1]-dys,h2[1]+dys]
  endif

  pic=get_map_sub(map[i],xrange=xrange,yrange=yrange,arange=arange,$
                 irange=irange,count=count,err=err,/no_data)

  sub=irange
  if count le 2 then begin
   if nmap gt 1 then smess=' '+trim(i)+'.' else smess='.'
   err='Insufficient points in sub-region. Skipping map'+smess
   message,err,/info
   continue
  endif

  x1=irange[0]
  x2=irange[1]
  y1=irange[2]
  y2=irange[3]

 endif else begin
  if ~valid_range(xrange) && ~valid_range(yrange) then begin
   message,'Non-zero XRANGE or YRANGE must be entered for pixel selection.',/info
   continue
  endif
  if ~valid_range(xrange) then xrange=[0,nx-1]
  if ~valid_range(yrange) then yrange=[0,ny-1]
  x1=min(xrange,max=x2) > 0l
  x2=x2 < (nx-1)
  y1=min(yrange,max=y2) > 0l
  y2=y2 < (ny-1)
 endelse

;-- keep same pixel dimensions as REF_MAP map

 if valid_map(ref_map) and keyword_set(preserve) then begin
  nrx=get_map_prop(ref_map[k],/nx)
  nry=get_map_prop(ref_map[k],/ny)
  fspace=get_map_prop(ref_map[k],/space)
  dspace=get_map_prop(map[index],/space)
  d1=dspace[0]-fspace[0]
  d2=dspace[1]-fspace[1]
  if (abs(d1) ge dspace[0]) or (abs(d2) ge dspace[1]) then $
   message,'Warning, input image and reference image have different pixel spacings',/info
  x2=x1+nrx-1
  y2=y1+nry-1
 endif

;-- if user entered DIMENSIONS keyword, then they must really want to control
;   the output dimensions of the sub map.
 
 if n_elements(dimensions) eq 2 then begin
  x2=x1+dimensions[0]-1
  y2=y1+dimensions[1]-1
  if (x2 ge nx) or (y2 ge ny) then begin
   if nmap gt 1 then smess=' '+trim(i)+'.' else smess='.'
   err='Specified dimensions of sub map exceed input map size. Skipping map'+smess
   message,err,/info
   continue
  endif
 endif

;-- the following ensures that each map structure has the same dimensions as
;   the first map

 if i eq 0 then begin
  nxs=x2-x1+1
  nys=y2-y1+1
 endif else begin
  x2=x1+nxs-1
  y2=y1+nys-1
 endelse

 tmap=rep_tag_value(map[i],(map[i].data)[x1:x2,y1:y2],'data',/no_copy)
 xp=get_map_xp(map[i]) & yp=get_map_yp(map[i])
 tmap=repack_map(tmap,xp[x1:x2,y1:y2],yp[x1:x2,y1:y2],/no_copy)
 if i eq 0 then smap=temporary(tmap) else smap=[temporary(smap),temporary(tmap)]
endfor

return
end

