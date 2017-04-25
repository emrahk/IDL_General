;+
; Project     : SOHO - CDS     
;                   
; Name        : WTITLE
;               
; Purpose     : Add a title to a window AFTER it has been created
;               
; Category    : utility
;               
; Explanation : IDL doesn't seem to provide a utility to change the title
;               of a regular plot window after it has been created. 
;               This program does the job by creating a new window and
;               using DEVICE,/COPY to copy the contents of the old window to
;               the new window.
;               
; Syntax      : IDL> wtitle,title,id or wtitle,id,title
;    
; Examples    : 
;
; Inputs      : TITLE = new title
;               
; Opt. Inputs : ID = window ID to affect [def = current window]
;               
; Outputs     : None
;
; Opt. Outputs: None
;               
; Keywords    : None
;
; Common      : None
;               
; Restrictions: Some window properties such as RETAIN may not be preserved
;               
; Side effects: Window label is changed
;               
; History     : Version 1,  26-Jan-1998, Zarro (SAC/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-            

pro wtitle,title,window,title=title2,verbose=verbose,_extra=extra

on_error,1

;--check argument inputs

valid=[1,2,3,4,5]

ok=where(datatype(title,2) eq valid,count)
if count gt 0 then win_id=title else if datatype(title) eq 'STR' then $
 win_title=title

ok=where(datatype(window,2) eq valid,count)
if count gt 0 then win_id=window else if datatype(window) eq 'STR' then $
 win_title=window

;-- check if user entered title as keyword

if (datatype(win_title) ne 'STR') and (datatype(title2) eq 'STR') then $
 win_title=title2

if (datatype(win_title) eq datatype(win_id)) or (datatype(win_title) ne 'STR') then begin
 message,'syntax --> wtitle,title,[window,verbose=verbose]',/cont
 return
endif

verbose=keyword_set(verbose)
if verbose then help,win_title,win_id

;-- check what windows are open

device,window=init_windows
curr_wind=!d.window

;-- user didn't enter a window number, so just create a new free one if
;   no window is currently open

if exist(win_id) then source_wind=win_id else source_wind=curr_wind
is_open=where(source_wind eq where(init_windows),count)
if (count eq 0) or (source_wind lt 0) then begin
 if (source_wind lt 0) then begin
  window,title=win_title,/free,_extra=extra
  device,window=new_windows
  check=where_vector(where(init_windows),where(new_windows),$
                     rest=rest,rcount=rcount)
  if (rcount gt 0) and verbose then begin
   new_wind=(where(new_windows))(rest)
   message,'new window ID = '+trim(string(new_wind(0))),/cont
  endif
 endif else window,source_wind,title=win_title,$
             _extra=extra,free=(source_wind gt 31)
 return
endif

;-- user entered a valid & open window number. Copy contents to 
;   temporary pixmap, delete the source window, make a new one with
;   the requested title and same ID, and copy back

xsize=!d.x_size & ysize=!d.y_size
device,get_window_pos=wpos
window,xsize=xsize,ysize=ysize,/pix,/free

;-- save pixmap ID

device,window=new_windows
check=where_vector(where(init_windows),where(new_windows),$
                   rest=rest,rcount=rcount)
pix_wind=(where(new_windows))(rest)
pix_wind=pix_wind(0)
wset,pix_wind
device,copy=[0,0,xsize,ysize,0,0,source_wind]

;-- delete source window 

wdelete,source_wind

;-- remove following keywords from call so they can be overidden

if datatype(extra) eq 'STC' then begin
 extra=rem_tag(extra,['xpos','ypos','title','xsize','ysize'])
 if datatype(extra) ne 'STC' then delvarx,extra
endif

;-- create new window

window,source_wind,xsize=xsize,ysize=ysize,free=(source_wind gt 31),$
        title=win_title,xpos=wpos(0),ypos=wpos(1),_extra=extra

;-- copy from pix map and delete it

wset,source_wind
device,copy=[0,0,xsize,ysize,0,0,pix_wind]
wdelete,pix_wind

return & end

