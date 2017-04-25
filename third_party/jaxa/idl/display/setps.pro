pro setps, fnam, landscape=landscape, portrait=portrait, $
		reset=reset, print=print, qdebug=qdebug
;+
;NAME:
;	setps
;PURPOSE:
;	To make a "set_plot" call and optional "device" calls.  It's
;	useful because the "set_plot,'ps',/interpolate" should be the
;	default and is not.  It also does not work properly if the current
;	plot device is PS so this routine does a "set_plot,'null'"
;	before the "set_plot,'ps'".  THe /portrait option uses the full
;	page.
;SAMPLE CALLING SEQUENCE:
;	setps
;	setps, 'myplot.ps', /land
;	setps, /reset, /print
;OPTIONAL INPUT:
;	fnam	- The PS output file name.  Default is "idl.ps"
;OPTIONAL KEYWORD INPUT:
;	landscape- If set, then plot as landscape
;	portrait- If set, then plot as portrait (full page)
;	reset	- If set, return the plot device to what it was when
;		  setps was called last.  Also do a device,/close
;	print	- If set, then call "pprint" to send the ps file to
;		  the printer.
;HISTORY:
;	Written 6-Nov-96 by M.MOrrison (I didn't use CDS's PS.PRO
;		because of several of the defaults it was using)
;	15-Aug-97 (MDM) - Modified to not use the /INTERPOLATE 
;			  option if running 8 bit color
;
;
common setps_blk1, save_dev
;
if (!d.name ne 'PS') then save_dev = !d.name
;
;The following is required so that "set_plot, 'ps', /interpolate" works
;when setting device when it's already ps
if (getenv('ys_batch') eq '') and (getenv('ssw_batch') eq '') then begin
    set_plot,'x'
    window,/free,xs=2,ys=2,/pix
    plot, findgen(10)
    wdelete
end
;
qint = 1
if (!d.name ne 'PS') and (!d.n_colors le 256) then qint = 0
if (keyword_set(qdebug)) then print, 'QINT = ', qint
set_plot, 'ps', interpolate=qint
;
if n_elements(fnam) gt 0 then device,file=fnam
;
if (keyword_set(landscape)) then begin
    device, /land
end else begin
    DEVICE, /PORTRAIT, /INCHES, XOFFSET=0.75, YOFFSET=0.75, XSIZE=7.0, YSIZE=9.5
end
;
if (keyword_set(print)) then begin
    if (!d.name eq 'PS') then device, /close
    pprint
end
;
if (keyword_set(reset)) then begin
    if (!d.name eq 'PS') then device, /close
    if (keyword_set(save_dev)) then set_plot, save_dev
end
;
;CHOOSE THIS TO CENTER 2 PLOTS ON A LANDSCAPE PAGE (use 4.75 in size img)
;  device,/land,bits=8,yoffs=10.25,xoffs=1.875,ysize=4.75,xsize=9.5,/in
;CHOOSE THIS TO CENTER 4 PLOTS ON A LANDSCAPE PAGE (use 3.75 in size img)
;  device,/land,bits=8,yoffs=10.5,xoffs=0.5,ysize=7.5,xsize=10.0,/in
;CHOOSE THIS TO CENTER 6 PLOTS ON A LANDSCAPE PAGE (use 3.5 in size img)
;  device,/land,bits=8,yoffs=10.5,xoffs=0.5,ysize=7.5,xsize=10.5,/in
;CHOOSE THIS TO CENTER 1 PLOT ON A PORTRAIT PAGE
;  device,/port,bits=8,xoffs=.5,yoffs=1.0,xsize=7.5,ysize=7.5,/in
;CHOOSE THIS TO CENTER 1 PLOT FILLING A FULL PORTRAIT PAGE
;  device,/port,bits=8,xoffs=.5,yoffs=0.75,xsize=7.5,ysize=9.5,/in
end