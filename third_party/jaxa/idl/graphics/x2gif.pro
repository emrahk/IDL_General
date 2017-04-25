;+
; Project     :	SDAC
;
; Name        :	X2GIF
;
; Purpose     :	read and write X window to GIF file
;
; Explanation :	Uses TVRD to grab window
;
; Use         :	X2GIF,FILE
;              
; Inputs      :	FILE = GIF file name
;
; Opt. Inputs : R, G, B = color table values
;
; Outputs     :	None.
;
; Opt. Outputs:	None.
;
; Keywords    :	
;               WINDOW = index of window to be plotted
;               XSIZE, YSIZE = window size to select [def = whole window]
;               TITLE = title for GIF file
;               XPOS, YPOS = position of title
;               PSIZE = extra keywords for xyouts
;               RESIZE = [nx,ny] = dimensions to resize GIF image to
;               
;
; Calls       :	SSW_WRITE_GIF, HAVE_WINDOWS()
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Category    :	Graphics
;
; Prev. Hist. :	None.
;
; Written     :	Dominic Zarro (ARC)
;
; Version     :	Version 1.0, 1 July 1994
;               Version 2.0, 13-Aug-2003, William Thompson
;                       Use SSW_WRITE_GIF instead of WRITE_GIF
;               Version 3.0, 03-Sep-2004, William Thompson
;                       Fixed problem with true-color display
;                       Use have_windows() to support Windows (not just X)
;               Version 4, 25-Jan-2006, William Thompson
;                       Fixed problem with plotting parameters being reset by
;                       unnecessary set_plot call.
;               Version 5, 17-Mar-2016, WTT, call TVREAD for Mac compatibility
;-
 
pro x2gif,file,rr,gg,bb,window=window,xsize=xsize,ysize=ysize,title=title,$
               _extra=psize,xpos=xpos,ypos=ypos,resize=resize,err=err

err=''

if datatype(file) ne 'STR' then begin
 file='idl.gif'
 message,'GIF file saved in '+file,/cont
endif

break_file,file,dsk,dir,name,ext
out_dir=trim(dsk+dir)
cd,curr=curr
if out_dir eq '' then out_dir=curr
ok=test_open(out_dir,/write)
if not ok then begin
 err='Cannot write GIF file to '+out_dir
 message,err,/cont
 return
endif

if ((n_elements(window) eq 0) and (!d.window eq -1)) or (not have_windows()) then begin
 err='NO WINDOW ACTIVE'
 message,err,/cont
 return
endif


if n_elements(window) ne 0 then begin
 if window gt -1 then wset,window
endif
 
;-- read window

if n_elements(xsize) eq 0 then xsize=!d.x_size
if n_elements(ysize) eq 0 then ysize=!d.y_size

;-- write title

if datatype(title) eq 'STR' then begin
 if n_elements(xpos) eq 0 then xpos=.1
 if n_elements(ypos) eq 0 then ypos=.9
 xyouts,xpos,ypos,title,_extra=psize,norm=1,size=1.5,charthick=1.5,font=-1
endif

dev_save=!d.name
select_windows
;
;  Keep track of whether the user supplied colors.
;
cload=0
if n_elements(rr)*n_elements(gg)*n_elements(bb) ne 0 then begin
    cload=1
    r = rr
    g = gg
    b = bb
endif
;
;  If a true-color display, then use color_quan to map into a GIF-compatible
;  color table.
;
true = (!d.n_colors ne !d.table_size) and (cload eq 0)
a=tvread(true=true)
if true then begin
    a = color_quan(a,3,r,g,b)
    cload = 1
endif
if n_elements(resize) eq 2 then begin
 if (resize[0] ne xsize) or (resize[1] ne ysize) then $
  a=congrid(a,resize[0],resize[1])
endif

;-- load user-supplied colors, else check what is in COMMON COLORS


if cload eq 0 then begin
 tvlct,r,g,b,/get
 cload=1
endif

if cload then ssw_write_gif,file,a,r,g,b else ssw_write_gif,file,a

if !d.name ne dev_save then set_plot,dev_save


return & end
