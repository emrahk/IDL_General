;+
; Project     : SOHO - CDS
;
; Name        : X2PS
;
; Purpose     : convert X window plot to postscript file
;
; Category    : plotting
;
; Explanation : uses TVREAD
;
; Syntax      : IDL> x2ps,file,window=window
;
; Inputs      : FILE = filename to print
;
; Opt. Inputs : FILE - output postscript file name
;
; Outputs     : None
;
; Opt. Outputs: None
;
; Keywords    :
;               window = index of window to be plotted (def = last window)
;               nocolor = for B/W
;               x_size,y_size = size of current window to read (def = whole)
;               print  = send PS file to printer
;               err    = err string
;               delete = delete plot file when done
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Version 1,  1-Sep-1995,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-
 
pro x2ps,file,window=window,x_size=x_size,y_size=y_size,_extra=e,$
          nocolor=nocolor,print=print,err=err,delete=delete

err=''
color=1-keyword_set(nocolor)

if datatype(file) ne 'STR' then begin
 file='idl.ps'
 if not keyword_set(delete) then message,'PS file saved in '+file,/cont
endif

break_file,file,dsk,dir,name,ext
out_dir=trim(dsk+dir)
cd,curr=curr
if out_dir eq '' then out_dir=curr
ok=test_open(out_dir,/write)
if not ok then begin
 err='Cannot write PS file to '+out_dir
 message,err,/cont
 return
endif

if ((n_elements(window) eq 0) and (!d.window eq -1)) or (!d.name ne 'X') then begin
 err='NO WINDOW ACTIVE'
 message,err,/cont
 return
endif

if n_elements(window) ne 0 then begin
 if window gt -1 then wset,window
endif

;-- defaults

xsize=18
ysize=18
yoff=25.5
bits=8

;-- read window

if n_elements(x_size) eq 0 then x_size=!d.x_size
if n_elements(y_size) eq 0 then y_size=!d.y_size

dev_save=!d.name
select_windows
a=tvrd(0,0,x_size,y_size)

yscale=float(y_size)/float(x_size)

;-- output to Postscript

set_plot,'PS',/copy
device,/land,xsize=xsize,ysize=xsize*yscale,yoff=yoff,bits=bits,_extra=e,$
       color=color,file=file
tv,a

;-- close and set back

device,/close
set_plot,dev_save

if keyword_set(print) then xprint,file,delete=delete,/confirm

return & end


