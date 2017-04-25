;+
; Project     : SOHO-CDS
;
; Name        : GET_MAP_SUB
;
; Purpose     : extract sub-field from a map
;
; Category    : imaging
;
; Syntax      : sub=get_map_sub(map,xrange=xrange,yrange=yrange)
;
; Inputs      : MAP = image map
;
; Outputs     : SUB = extracted 2d-sub-field array
;
; Keywords    : XRANGE  = x-coord range to extract (e.g. [100,200])
;               YRANGE  = y-coord range to extract (e.g. [300,400])
;               ARANGE  = actual coordinates ranges [xstart,xend,ystart,yend]
;               IRANGE  = indicies of extracted coords [istart,iend,jstart,jend]
;               COUNT   = # of points extracted
;               VERBOSE = echo messages
;               ERR     = error string ('' if all ok)
;               TAG_ID  = tag to extract (def = .data)
;               XCOR,YCOR   = optional coordinate arrays to base extraction on
;                        (if other than what is in MAP)
;               NO_OVERLAP = don't include overlapping pixel outside
;               xrange/yrange
;               XP, YP = coordinates of extracted subarray
;               NO_DATA = don't return extracted data
;
; History     : Written 16 Feb 1999, D. Zarro, SM&A/GSFC
;               Modified 18 Feb 2000, Zarro (SM&A/GSFC) - added /NO_OVERLAP
;               Modified 10 May 2008, Zarro (ADNET) 
;                - interchanged XCOR,XP & YCOR,YP
;               Modified 10 March 2013, Zarro (ADNET)
;                - added /NO_DATA
;               Modified 22 October 2014, Zarro (ADNET)
;                - use double-precision arithmetic
;               Modified 21 April 2015, Zarro (ADNET)
;                - support truecolor image map data
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_map_sub,map,xrange=xrange,yrange=yrange,count=count,err=err,$
        arange=arange,irange=irange,verbose=verbose,tag_id=tag_id,$
        xp=xp,yp=yp,no_overlap=no_overlap,xcor=xcor,ycor=ycor,no_data=no_data

err=''
count=0l
verbose=keyword_set(verbose)
data=-1

if ~valid_map(map) then begin
 pr_syntax,'region=get_map_sub(map,[xrange=xrange,yrange=yrange])'
 return,data
endif

arange=0. & irange=0.
xenter=0b
if n_elements(xrange) ge 2 then begin
 dxmin=min(xrange,max=dxmax)
 xenter=dxmin lt dxmax
endif

yenter=0b
if n_elements(yrange) ge 2 then begin
 dymin=min(yrange,max=dymax)
 yenter=dymin lt dymax
endif

if ~exist(tag_id) then tag_no=get_tag_index(map,'data') else $
 tag_no=get_tag_index(map,tag_id)
if tag_no eq -1 then begin
 err='Invalid TAG input'
 mprint,err
 return,data
endif
sz=get_map_size(map)
nx=sz[0] & ny=sz[1]

;-- extract 1-d coordinate arrays

if ~exist(xcor) then xarr=get_map_xp(map,/oned,nx=nx) else begin
 sz=size(xcor)
 nx=sz[1]
 xmin=min(xcor,max=xmax)
 xarr=xmin+dindgen(nx)*(xmax-xmin)/(nx-1.d0)
endelse

if ~exist(ycor) then yarr=get_map_yp(map,/oned,ny=ny) else begin
 sz=size[ycor]
 ny=sz[2]
 ymin=min(ycor,max=ymax)
 yarr=ymin+dindgen(ny)*(ymax-ymin)/(ny-1.d0)
endelse

if ~xenter then begin
 temp=get_map_xrange(map)
 dxmin=temp[0] & dxmax=temp[1]
endif

if ~yenter then begin
 temp=get_map_yrange(map)
 dymin=temp[0] & dymax=temp[1]
endif

;-- include overlapping pixel around extraction region

pixel=keyword_set(pixel) and xenter and yenter
dx=map.dx
dy=map.dy
dx2=dx/2.d0 & dy2=dy/2.d0

overlap=~keyword_set(no_overlap)
if overlap then begin
  dx2=-dx2 & dy2=-dy2 
endif

if ~xenter then begin
 xstart=0l & xend=nx-1l 
 xcount=nx
endif else begin
 xwhere=where( ( (xarr+dx2) le dxmax) and ( (xarr-dx2) ge dxmin),xcount)
 if xcount gt 0 then begin
  xstart=min(xwhere,max=xend) 
 endif else begin
  err='No data in specified X-range.'
  if verbose then mprint,err
  return,data
 endelse
endelse

if ~yenter then begin 
 ystart=0l & yend=ny-1l 
 ycount=ny
endif else begin
 ywhere=where( ( (yarr+dy2) le dymax) and ( (yarr-dy2) ge dymin),ycount)
 if ycount gt 0 then begin
  ystart=min(ywhere,max=yend)
 endif else begin
  err='No data in specified Y-range.'
  if verbose then mprint,err
  return,data
 endelse
endelse

if pixel then begin
 xstart=min(xrange,max=xend)
 ystart=min(yrange,max=yend)
 xstart = xstart > 0
 xend = xend < (nx-1)
 yend= yend < (ny-1)
 xcount=xstart-xend+1
 ycount=ystart-yend+1
endif

count=xcount*ycount 
arange=[temporary(xarr[xstart]),temporary(xarr[xend]),$
        temporary(yarr[ystart]),temporary(yarr[yend])]
irange=[xstart,xend,ystart,yend]

nx_old=nx
ny_old=ny
nx=xend-xstart+1
ny=yend-ystart+1
if (nx lt 2) or (ny lt 2) then begin
 err='Extracted data is not 2-D.'
 if verbose then mprint,err
endif

if ~keyword_set(no_data) then data=get_sub_data(map.(tag_no),irange)

;-- return coordinate subarrays

if arg_present(xp) then begin
 xp=get_map_xp(map)
 xp=xp[xstart:xend,ystart:yend]
endif

if arg_present(yp) then begin
 yp=get_map_yp(map)
 yp=yp[xstart:xend,ystart:yend]
endif

return,data

end

