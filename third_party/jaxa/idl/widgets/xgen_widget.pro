pro xgen_widget, infil, event, tit
;+
;NAME:
;	xgen_widget
;PURPOSE:
;	Takes a text file and creates a widget.  The
;	text file has three items
;	   a) A label used to identify the button selected
;	   b) How to block the widget (organization)
;	   c) The label for the widget button
;	The use of a text file can allow the layout to be
;	adjusted varily easily, and the event handler can be
;	simplified.
;SAMPLE CALLING SEQUENCE:
;	wfil = concat_dir('$MDI_CAL_INFO', 'xjitter.widg')
;	xgen_widget, wfil, 'xjitter_event', 'XJITTER'
;METHOD:
;	The input text file has # as the comment character
;	A sample file contents is:
;
;               #
;               #
;               #
;               Button Code     Blk     Label
;               --------------- ----    --------------------------
;               QUIT            1a      Quit
;               LIST_TFR        1a      List TFR
;               LIST_ISSSUM     1a      List ISS_SUM
;               DATE_ST         1a      Start Date/Time
;
;               MK_SUM          1b      Make Summary File
;               RD_SUM          1b      Read ISS_SUM File
;               RESET_BLKS      1b      Select all blocks
;               SEL_BLKS        1b      Select which Blocks
;
;               #(label)                2b      FFT Spectra Plot
;               #FFTS-1         2b      PZT Average A (Z)
;               #FFTS-2         2b      PZT Average B
;               #FFTS-3         2b      PZT Average C
;
;               (label)         2b      Location/Amp/Phase
;               LAP-1           2b      PZT Average A (Z)
;               LAP-2           2b      PZT Average B
;
;               INT_SELIMG      5a      Select blks to integrate on image
;               INT_SELBKG      5a      Select bkg blocks to integrate on image
;               INT_CALC        5a      Re-calculate average spectra
;	The "BLK" column indicates how to cluster the button
;	layout.  The number indicates the column and the letter
;	indicates the grouping within that column.
;
;	See "XJITTER.PRO" in the SOHO/MDI tree for an example of
;	how the routine can be used.
;DISCLAIMER:
;	The module was put together in one day without
;	extensive thought.  At this time there is only ONE
;	IDL routine which uses it.
;HISTORY:
;	Written 30-Jan-97 by M.Morrison
;	15-Apr-97 (MDM) - Added documentation header
;-
;
strarray = rd_tfile(infil, nocomment='#')
remtab, strarray, strarray
strarray = strarray(where(strarray ne ''))
temp = [strarray(1), strarray]
mat = str2cols(temp, ncol=3)   
mat = mat(*,3:*)
n = n_elements(mat(0,*))          
mat = strcompress(strtrim(mat,2))
;
codes = reform(mat(0,*))
groups = reform(mat(1,*))
labels = reform(mat(2,*))
ugroups = groups(uniq(groups, sort(groups)))
nugroups = n_elements(ugroups)         
;
;-----
;
font = get_xfont(closest=12,/only_one,/fixed)
if (getenv('MDI_DEF_FONT') ne "") then font = getenv('MDI_DEF_FONT')
widget_control, default_font=font
device, font=font
if (!d.window eq 32) then begin & wdelete & wdef, 16, 640, 512 & end            ;MDM added 15-Sep-95

base00=widget_base(/column, title=tit, xoff=0, yoff=0)
base0=widget_base(base00, /row)            

for igroup=0,nugroups-1 do begin
    if (strmid(ugroups(igroup), 1, 1) eq 'a') then begin	;start a new column
	base_col = widget_base(base0, /column, /frame)
    end            
    ss = where(groups eq ugroups(igroup), nss)
    if (codes(ss(0)) eq '(label)') then begin
	xx = widget_label(base_col, value = labels(ss(0)))
	ss = ss(1:*)
    end
    qexclusive = strpos(ugroups(igroup), 'X') ne -1
    xmenu, labels(ss), base_col, /column, /frame, uvalue=codes(ss), $
		exclusive = qexclusive
end
;
all = {base:base0, $
	junk:0}

widget_control,set_uvalue=all, base00
widget_control,base00,/realize
widget_control,set_uvalue=all, base00
xmanager, tit, base00, event_handler=event

end
