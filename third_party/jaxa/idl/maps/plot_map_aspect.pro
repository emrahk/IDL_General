;+
; Name: plot_map_aspect
;
; Purpose: include file for plot_map
;-

;-- this is a kludge so that if user enters POSITION as a 4-element keyword,
;   it can be swallowed in the EXTRA keyword for plotting. If it is a scalar 
;   then it is treated as the keyword POSITIVE_ONLY
 
position_entered=0b
if n_elements(positive_only) eq 4 then begin
 extra=rep_tag_value(extra,positive_only,'position')
endif
ename='position'
if is_struct(extra) then begin
 etags=tag_names(extra)
 epos=where(strpos(etags,'POS') gt -1,count)
 if count gt 0 then begin
  dposition=extra.(epos[0])
  if n_elements(dposition) eq 4 then begin
   position=dposition
   ename=strlowcase(trim(etags(epos[0])))
   if ename ne 'position' then extra=rep_tag_name(extra,ename,'position')
   position_entered=1b
  endif
 endif
endif

;-- fix aspect ratio

aspect=1
if is_number(square_scale) then aspect=square_scale ne 0

do_multi=pny*pnx gt 1

if (n_elements(position) eq 4) then begin
 if (position[0] eq position[2]) or (position[1] eq position[3]) then begin
  err='invalid position values'
  message,err,/cont
  return
 endif
endif

if aspect and (not do_multi) and (not over) and (not position_entered) then begin
 dpos=get_aspect(xrange=dxrange,yrange=dyrange,margin=margin)
 extra=rep_tag_value(extra,dpos,'position')
endif

if (not aspect) and (not cont) and keyword_set(cbar) then begin
 if have_tag(extra, 'position') then extra.position = extra.position * [1.,1.,1.,.9] else begin
  position = [.1,.1, .9, .85]
  sz = size(extra)
  if sz[n_elements(sz)-2] eq 8 then extra = add_tag (extra, position, 'position') else $
   extra = {position: position}
 endelse
endif


