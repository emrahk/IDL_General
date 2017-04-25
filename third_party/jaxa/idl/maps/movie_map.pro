;+
; Project     : SOHO-CDS
;
; Name        : MOVIE_MAP
;
; Purpose     : make movie of series of map images
;
; Category    : imaging
;
; Syntax      : movie_map,map
;
; Inputs      : MAP = array of map structures created by MAKE_MAP
;
; Keywords    : ROTATE = differentially rotate images
;               TREF = reference time to rotate to [def = first image]
;               GIF = make series of GIF files
;               MAX = data max to scale to
;               CMAP = contour map to overlay
;               CMIN,CMAX = min/max values for contoured data
;               TSTART/TSTOP = movie start/stop times
;               CROTATE = diff_rot contour images
;               GNAME = name for GIF frame [def = frame, e.g. frame00.gif]
;               RATE = RATE to show movie, percent of max rate (def=100)
;               NOSCALE = If set, don't scale to min/max of all images (def=0)
;
; History     : Written 22 November 1996, D. Zarro, ARC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
; Modifications:
;  9-Dec-2004, Kim Tolbert.  Removed xkill,/all
;  10-Feb-2005, Kim Tolbert.  Added noscale, rate, and abort keywords.  Also, previously if
;     a window existed, used its xsize,ysize and ignored keywords.  Now open new window with
;     requested size, and close it when finished.  Use xinteranimate2 instead of xinteranimate
;     (cleans up after itself in a crash), remove /keep keyword, and
;     set /track on.
;  29-March-2008, Zarro (ADNET) - added check for array of maps
;-

pro movie_map,map,tref=tref,xsize=xsize,ysize=ysize,trans=trans,$
 rotate=rotate,gif=gif,dmax=dmax,dmin=dmin,cmap=cmap,cmax=cmax,cmin=cmin,$
 tstart=tstart,tstop=tstop,use_cont=use_cont,ctol=ctol,crotate=crotate,$
 positive=positive,negative=negative,frames=frames,log=log,$
 tag_id=tag_id,remap=remap,gname=gname,drange=drange,rate=rate,noscale=noscale,$
 abort=abort, _extra=extra

abort = 0

if not valid_map(map) then begin
 pr_syntax,'movie_map,map'
 return
endif

if n_elements(map) lt 2 then begin
 message,'Need more than 1 map to make a movie',/cont
 return
endif

checkvar, rate, 100

;-- setup window

if datatype(gname) ne 'STR' then gname='frame'
;get_xwin,index,xsize=xsize,ysize=ysize
orig_window = !d.window
window, /free, xsize=xsize, ysize=ysize
window=!d.window
sx=!d.x_size & sy=!d.y_size

cont=exist(cmap)
if cont then ctimes=get_map_time(cmap,/tai)

;-- handle times

mtimes=get_map_time(map,/tai)
mvtimes=mtimes
use_cont=keyword_set(use_cont)
if cont and use_cont then mvtimes=ctimes
tmin=min(mvtimes)
tmax=max(mvtimes)
err=''
pstart=anytim2tai(tstart,err=err)
if err ne '' then pstart=tmin
err=''
pstop=anytim2tai(tstop,err=err)
if err ne '' then pstop=tmax

ntimes=n_elements(mtimes)
do_movie=where( (mtimes ge pstart) and (mtimes le pstop),fcount)
if fcount eq 0 then begin
 message,'no images during specified TSTART/STOP',/cont
 return
endif

;-- handle frame numbers

frame=exist(frames)
if frame then begin
 do_movie=indgen(ntimes)
 if (n_elements(frames) gt 1) then begin
  match,frame,indgen(ntimes),sa,sb
  if count eq 0 then begin
   message,'no images for specified frame numbers',/cont
   return
  endif
  do_movie=frame(sa)
 endif
endif

;-- which tag to display?

if not exist(tag_id) then tag_id='DATA'
tag_no=get_tag_index(map,tag_id,err=err)
if tag_no lt 0 then begin
 message,err,/cont
 return
endif

;-- check if 3-d and get min/max for scaling

sz=size(map(0).data)
three_d=sz(0) eq 3

if n_elements(drange) eq 2 then begin
 if not exist(dmin) then dmin=drange(0)
 if not exist(dmax) then dmax=drange(1)
endif

if not keyword_set(noscale) then begin
	if not exist(dmin) then begin
	 if three_d then dmin=min(map(*,*,do_movie).(tag_no)) else $
	  dmin=min(map(do_movie).(tag_no))
	endif

	if not exist(dmax) then begin
	 if three_d then dmax=max(map(*,*,do_movie).(tag_no)) else $
	  dmax=max(map(do_movie).(tag_no))
	endif
endif

if keyword_set(positive) then dmin=0.
if keyword_set(negative) then dmax=0.

dprint,'%dmax, ',dmax
dprint,'%dmin, ',dmin

;-- solar rotate?

rotate=keyword_set(rotate)
crotate=keyword_set(crotate)
err=''
time=anytim2tai(tref,err=err)
if (err ne '') and (rotate or crotate) then time=get_map_time(map(do_movie(0)))

;-- make animate window

;xkill,/all
if not frame then xinteranimate2,set=[sx,sy,fcount], /track, abort=abort
if abort then return
cleanplot

if not exist(ctol) then ctol=0
for j=0,fcount-1 do begin
 i=do_movie(j)
 tmap=map(i)
; if three_d then tmap=reg_map(map,i) else tmap=map(i)
 if rotate then tmap=drot_map(tmap,time=time,no_remap=1-keyword_set(remap))
 plot_map,tmap,xsize=xsize,ysize=ysize,window=window,$
  dmin=dmin,dmax=dmax,trans=trans,positive=positive,negative=negative,$
  tag_id=tag_no,log=log,_extra=extra,/original
 if cont then begin
  diff=abs(get_map_time(tmap,/tai)-ctimes)
  use=where(diff eq min(diff))
  dprint,'% base image time:    '+get_map_time(tmap)
  dprint,'% contour image time: '+get_map_time(cmap(use))
  if ctol eq 0 then do_it=1 else do_it=(min(diff) le ctol)
  if do_it then begin
   plot_map,cmap(use),/over,max=cmax,min=cmin,rotate=crotate,$
    tref=time,/positive,lcolor=2,border=0,_extra=extra
   plot_map,cmap(use),/over,max=cmax,min=cmin,rotate=crotate,$
    tref=time,/negative,lcolor=5,border=0,_extra=extra
  endif else dprint,'% diff: ',min(diff)
 endif
 window=!d.window

 if frame then gif=0
 if not frame then xinteranimate2,frame=j,window=[window,0,0,sx,sy], abort=abort
 if abort then break
 if keyword_set(gif) then begin
  counter=trim(string(j))
  if j lt 10 then counter='0'+counter
  gif_file=gname+counter+'.gif'
  x2gif,gif_file
 endif
endfor

if not frame and not abort then xinteranimate2,rate

wset, orig_window
wdelete, window

if keyword_set(gif) then begin
 spawn,'ls '+gname+'*.gif > agif.lis'
 message,'created GIF filenames are listed in file: agif.lis',/cont
endif

return & end

