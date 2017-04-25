;+
; Project     : SOHO - CDS
;
; Name        : OPLOT_NAR
;
; Purpose     : Oplot NOAA AR pointing structures from GET_NAR
;
; Category    : planning
;
; Syntax      : IDL> oplot_nar,nar or oplot_nar,time,nar
;
; Inputs      : NAR = NOAA AR pointing structures from GET_NAR
;               (if TIME is input, GET_NAR is called)
;
; Keywords    : EXTRA = plot keywords passed to XYOUTS
;               OFFSET = offset coordinates to shift labelling 
;               [data units, e.g., off=[100,100])
;               IMAP - if set, generate imagemap coords   
;               IMAGEMAP_COORD - (output) return the coords if /IMAP set
;               IMCIRCLE - if set, IMAP coords are "xc,yc,diam" (circle)
;                          default corrds are "minx,miny,maxx,maxy"
;               IMARS - (output) if IMAP, then return 1:1 AR#:IMAGEMAP_COORD
;               IMNOCONVERT - return IMAGEMAP_COORD in IDL convention
;                             (default=html imagemap w/(0,0)=upper right 
; Restrictions: A base plot should exist
;
; History     : Version 1,  20-June-1998,  D.M. Zarro.  Written
;             : Version 1.1, 28-March-2002, S.L. Freeland - IMAP support
;             : Version 2, 17-June-2002, Zarro (LAC/GSFC) - 'I4.4' AR plotting
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro oplot_nar,time,nar,quiet=quiet,offset=offset,_extra=extra, $
   imap=imap, imagemap_coord=imagemap_coord, $
   imnoconvert=imnoconvert, imcircle=imcircle, imars=imars

on_error,1
count=0
imap=keyword_set(imap)
nar_entered=datatype(time) eq 'STC'
if nar_entered then nar_entered=tag_exist(time,'NOAA')
if nar_entered then begin
 nar=time 
 count=n_elements(nar)
endif else begin
 if not exist(time) then begin
  pr_syntax,'oplot_nar,time,nar OR oplot_nar,nar'
  return
 endif else nar=get_nar(time,count=count,quiet=quiet,/unique)
endelse

;-- any offsets

xs=0. & ys=0.
if exist(offset) then begin
 xs=offset(0)
 ys=xs
 if n_elements(offset) eq 2 then ys=offset(1)
endif

if imap then begin                 ; imagemap coordinate return requested
  imagemap_coord=strarr(count)     ; init imap coord vector
  imars=strarr(count)              ; init AR list (1:1 map to imap coord)
endif

if count gt 0 then begin
 for i=0,count-1 do begin
  ari=trim(str_format(nar(i).noaa,'(i4.4)'))
  x=xs+nar(i).x & y=ys+nar(i).y
  if imap then dat0=tvrd()			  ; before AR annotate
  xyouts,x,y,ari,/data,_extra=extra               ; AR annotate
  if imap then begin                              ; IMAP request? 
     imars(i)=ari				  ; AR(i)->output list	
     dat1=tvrd()         			  ; after AR annotate 
     imagemap_coord(i)= $                         ; Annotate->IMAP coord
       get_imagemap_coord(dat0,dat1,/string, $
          circle=imcircle,noconvert=imnoconvert)   
     delvarx,dat0,dat1
  endif
 endfor
endif

return & end
