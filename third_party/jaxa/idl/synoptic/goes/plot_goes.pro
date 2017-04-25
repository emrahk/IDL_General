pro plot_goes, i1, i2,  bcolor=bcolor, quiet=quiet, 	$
        ascii=ascii, $
	fem=fem, fillnight=fillnight, saa=saa, fillsaa=fillsaa, $
	gdata=gxr_rec, low=low, high=high, gcolor=gcolor, $
	nodeftitle=nodeftitle, no6=no6, no7=no7, $
	three=three,title=title,thick=thick,_extra=plot_keywords, fast=fast, $
	grid_thick=grid_thick, timerange=timerange, noylab=noylab, intlab=intlab, $
	one_minute=one_minute, five_minute=five_minute, auto_range=auto_range, $
	hc=hc, hardcopy=hardcopy, landscape=landscape, portrait=portrait, $
	xsize=xsize, ysize=ysize, status=status, color=color, $
        goes6=goes6, goes7=goes7, goes8=goes8, goes9, goes10=goes10, goes11=goes11, goes12=goes12, $
        goes13=goes13, goes14=goes14, goes15=goes15, $
         primary=primary, secondary=secondary
;+
;   Name: goes_plot
;
;   Purpose: plot goes x-ray data (Yohkoh structure) 
;
;   Input Parameters:
;      input1 - user start time or goes xray data record structure array
;      input2 - user stop time
;
;   Optional Keyword Paramters:
;      fem - if set, overplot Yohko ephemeris grid (call fem_grid)
;      fillnight - (pass to fem_grid) - polyfill Yohkoh nights
;      fillsaa   - (pass to fem_grid) - polyfill Yohkoh saas
;      saa       - (pass to fem_grid) - show saa events overlay grid
;      low 	 - if set, only plot low energy
;      high      - if set, only plot high energy
;      title     - user title (appended to default title predicate)
;      nodeftitle- if set, dont append default title predicate
;	color    - color of lines
;      ascii     - if set, use sec ascii files in $SSWDB/goes/xray/
;      primary/secondary - switches -> ascii, support SEC Dec 1 2009 file name change
;
;   Calling Sequence:
;      plot_goes,'5-sep-92'		; start time + 24 hours
;      plot_goes,'5-sep-92',/three	; same, but use 3 second data
;      plot_goes,'5-sep-92',6		; start time +  6 hours
;      plot_goes,'5-sep-92','7-sep-92'  ; start time / stop time
;      plot_goes,gxtstr			; input goes records from rd_gxt
;      plot_goes,'5-sep',/fem		; overplot Yohkoh ephemeris grid
;      plot_goes,'5-sep',/fillnight	; ditto, but fill in Yohkoh nights 
;      plot_goes,'1-jun','30-jul',/low  ; only plot low energy
;
;      plot_goes,t1,t2,/one_minute	; one minute averages (default)
;      plot_goes,t1,t2,/five_minute	; five minute averages 
;      plot_goes,t1,t2,/auto		; use environmental goes_auto_range
;      plot_goes,t1,t2,auto=[.25,1.,5]  ; auto range (3 second/1 min/5 min)
;      plot_goes,t1,t2,/hc or /hardcopy	; PS hardcopy (default orient=landscape)
;      plot_goes,t1,t2,/portrait	; PS hardcopy (orient=portrait)
;
;   History: slf 22-sep-1992
;	     slf 11-oct-1992 - added low and high keywords, add documentation
;	     slf 26-oct-1992 - added nodeftitle keyword
;            slf 15-mar-1993 - return on no data
;	     mdm 24-Mar-1993 - corrected error due to integer overflow
;	     slf 19-Jul-1993 - implemented LO and HI keyword function
;	     slf 29-jul-1993 - added max_value keyword (pass to utplot)
;	     slf  4-sep-1993 - add charsize, no6, no7 keywords
;	     slf 22-Nov-1993 - added lots of plot keyowords
;	     jrl  1-dec-1993 - added thick, charthick, xtitle keywords
;	     slf  5-dec-1993 - set default xstyle = 1
;	     slf, 7-dec-1993 - a) added three (second) keyword and functions
;			       c) gave up on any and all hopes for clean logic
;	     slf 15-dec-1993 - a) yrange w/gxt input b) check deriv(valid)
;			       cleanup the input logic a little.
;	     ras 17-aug-1994 - no longer use call procedure by setting proc to 
;			       'utplot' or 'utplot_io' by just calling utplot and
;			       setting ytype as needed
;            slf, 19-aug-94  - make no6 default if start time after 17-aug
;            dmz 21-Aug-1994 - lumped all plot keywords into _EXTRA
;                              so that keyword inheritance will work with
;                              UTPLOT. Also replaced OUTPLOT by OPLOT and
;                              fixed potential bug in DVALID
;            slf, 25-aug-94 - merged divergent changes (19-aug / 21-aug)
;			      add /fast switch (use saved version if avail)
;	     gal, 13-aug-94 - added grid_thick switch to control goes grids.
;	     mdm, 20-Sep-94 - Added TIMERANGE option
;            slf,  9-oct-94 - Added NOYLAB keyword
;            slf, 30-aug-95 - add ONE_MINUTE and FIVE_MINUTE keywords
;			      add auto_ranging (via environ= goes_auto_range)
;			      preferentially use G71 instead of GXT if availble
;            slf, 26-sep-95 - protect against missing G6 
;	     slf, 28-sep-95 - add HC, HARDCOPY, LANDSCAPE, and PORTRAIT switches
;            slf, 5-oct-95  - add STATUS keyword (1=some data, 0=none)
;            jmm, 8-aug-96  - Fixed bugs to allow for the plotting of input
;                             data structures, changed a reference to GXR_DATA_REC
;                             to GXD_DATA_REC.    
;            slf, 13-aug-96 - make GOES 9 default after 1-july-1996
;	                      (replace GOES 7 , no goes7 after 14-aug-96)
;            slf, 18-aug-96 - add goes91/95 to the ydb_exist check
;            slf, 30-Jul-98 - GOES 9 off , make GOES8 the default
;            slf, 24-apr-99 - enable COLOR
;            Zarro, 4-Nov-99 - fixed vector bug when plotting input data
;            slf, 3-Jan-1999 - put wrapper around 'input1/input2' - pseudo Y2K 
;            slf, 16-apr-2003 - add GOES12, get time dependent default sat# from get_goes_defsat.pro
;            Zarro, 23 Apr-2004 - add check for GXRIN
;            S.L.Freeland - /ascii defaults to /ONE_MINUTE (/FIVE to override)
;                           fix historical /one & /five logic (ydb_exist search override)
;            S.L.Freeland - 4-dec-2009 - add /PRIMARY & /SECONDARY (SEC 1-dec-2009 file name chnage)
;
;  Side Effects:
;     /fast switch causes color table 15 load
;-

ascii=keyword_set(ascii)
hardcopy=keyword_set(hc) or keyword_set(hardcopy) or keyword_set(landscape) $
	or keyword_set(portrait)

portrait=keyword_set(portrait) 
landscape=keyword_set(landscape) or (1-portrait)

loud=1-keyword_set(quiet)

if keyword_set(fast) then begin
   if file_exist(concat_dir('$DIR_GEN_SHOWPIX',concat_dir('new_data','GOES_PLOT_24h.genx')))  then begin
      fl_goesplot, image, R, G, B
      wdef,yyy, image=image,/uleft
      tv,image
      loadct,15
      tbeep
      prstr,['','--------- Current UT Time is: ' + ut_time() + ' ---------',''] 
   endif else message,/info,"Your site does not support /fast switch..."
   return
endif

if hardcopy then begin
  if not keyword_set(xsize) then xsize=([6.5,9])(landscape)
  if not keyword_set(ysize) then ysize=([3,6])(landscape)
;  print,"Postscript " + (['portrait','landscape'])(landscape) + " size= " + $
;	strtrim(xsize,2) + " X " + strtrim(ysize,2)  +  " inches"
  dtemp=!d.name			; save
  set_plot,'ps'
;  exe=execute( (["device,/portrait","device,/landscape"])(landscape))
  if landscape then device,/landscape else device,/portrait
;  device, color=0, /inches, xsize=xsize, ysize=ysize, xoffset=.5, yoffset=.5 
endif

qtemp=!quiet
if n_elements(i1) eq 0 then i1=gt_day(addtime(syst2ex(),delta=-24*60),/str)
if n_elements(i2) eq 0 then i2=36	

; inhibit goes 6 after 00:00 17-aug
secs=int2secarr(anytim(i1(0),/int),'17-aug-94')  ;-- (add (0), DMZ)
no6=keyword_set(no6) or secs gt 0

def9=int2secarr(anytim(i1(0),/int),'1-jul-96') gt 0  ;-- (add (0), DMZ)
no7=keyword_set(no7)

def8=int2secarr(anytim(i1(0),/int),'25-jul-98') gt 0 ;-- (add (0), DMZ)
goes8=keyword_set(goes8) or get_logenv('plot_goes_goes8') ne ''

; set defaults for tektronics files		; ancient "default"
ytype= 0		
yrange=[101,679]				; default is gxt files
; 15-dec - backwardly compatible - allow gxt structure input directly
gxrin=0
;if data_chk(i1,/struct) then gxrin=tag_names(i1,/struct) eq 'GXR_DATA_REC'
;GXR_DATA_REC to GXD_DATA_REC, jmm 8-aug-1996
if data_chk(i1,/struct) then gxrin=tag_names(i1,/struct) eq 'GXD_DATA_REC';

; ------------------------------------------------------------------------
if not gxrin then begin	
   input1=fmt_tim(i1)		; any yohkoh fmt
   case data_chk(i2,/type) of
      8: input2=fmt_tim(i2)				    ; yohkho struct
      7: input2=i2
      else: input2=fmt_tim(anytim2ints(i1,offset=float(i2)*60.*60.))
   endcase
; ------------------------------------------------------------------------

; select sat
sats=str2arr('6,7,8,9,10,11,12,13,14,15')        ; keyword check (extend list as required)

for i=0,n_elements(sats) -1 do $
   estat=execute('if keyword_set(goes'+sats(i)+') then gnum=sats(i)')

if n_elements(gnum) eq 0 then gnum=get_goes_defsat(input2)

gkeyword='/goes'+ strtrim(gnum,2)

; select count cadence - one_minute is default 
  chk_auto=get_logenv('goes_auto_range')
  five_minute=keyword_set(five_minute)		; slf, 30-aug-95
  three=keyword_set(three)			; 3 second
  one_minute=keyword_set(one_minute)
  input1=fmt_tim(input1)
  input2=fmt_tim(input2)
  case 1 of 
      one_minute and (1-ascii):   one_minute  =ydb_exist([input1,input2],/range,'G71')
      five_minute and (1-ascii):  five_minute =ydb_exist([input1,input2],/range,'G75')
      three:
      n_elements(auto_range) eq 3:  arange=auto_range
      data_chk(auto_range,/scaler) and  get_logenv('goes_auto_range') ne '': $
      arange=float(str2arr(get_logenv('goes_auto_range')))
      else: one_minute=1
   endcase

   if n_elements(arange) eq 3 then begin	; cutoffs [three-second, onemin, five]
      offday=(int2secarr(anytim2ints([input1,input2])))(1)/86400.
      which=where(offday gt arange,cnt)      
      type=(['three','one_minute','five_minute'])(cnt>0<2)
;     set appropriate keyword
      exestat=execute(type + '=1')      
      if loud then message,/info,"Auto-ranging is enabled..."
   endif

;  verify selected gxd file exists 
   if not ascii then begin ; don't do these checks for /ASCII, slf 2008/01/29 
   if one_minute  then one_minute=ydb_exist([input1,input2],/range,'G71') or $
      ydb_exist([input1,input2],/range,'G91') or $
      ydb_exist([input1,input2],/range,'G81')

   if five_minute then five_minute=ydb_exist([input1,input2],/range,'G75') or $
      ydb_exist([input1,input2],/range,'G95') or $
      ydb_exist([input1,input2],/range,'G85')
   endif ; the 'ydb_exist' block needs some review...

   gxd=three or one_minute or five_minute

   if not gxd then begin
      message,/info,"Forcing GXD one minute..."
      one_minute=1 
      gxd=1
   endif

   repeats= ([gxd * (1-keyword_set(no6) and 1-no7) + 1,1])(def9)
							;FUTURE - allow 8&9
;  ------------------------------------------------------------------------
    if gxd then begin
      mess='Using 3 second data '
      if not three then mess=mess + $
         (['(One','(Five'])(five_minute) + ' Minute Averages) ' + '...'
      if loud then message,/info,mess
      case 1 of 		; messy due to maintaining existing logic
         ascii: begin
                rd_goesx_ascii,input1,input2,gxr_rec,  $
                   goes9=goes9, goes8=goes8, goes10=goes10, goes11=goes11,goes12=goes12, goes13=goes13, goes14=goes14, goes15=goes15,  $
                   five_minute=five_minute, one_minute=(1-five_minute), $
                   primary=primary, secondary=secondary
         endcase
         else: begin 
           estring='rd_gxd,input1,input2,gxr_rec,one_minute=one_minute,five_minute=five_minute,'+$
               gkeyword
           estat=execute(estring)
         endcase
      endcase
      yrange=[1.e-9, 1.e-3]
      ytype = 1
   endif else begin
      rd_gxt,input1, input2, gxr_rec 
   endelse                               
endif else begin                ;jmm, 8-aug-1996, to allow plotting of input data structures
   gxr_rec = i1
   gxd = 1
   repeats= gxd * (1-keyword_set(no6) and 1-keyword_set(no7)) + 1
   yrange=[1.e-9, 1.e-3]
   ytype = 1
endelse

status=1
if n_elements(gxr_rec) lt 2 then begin	; return on no data
   status=0
   types=['',' three second ']
   message,/info,'No ' + types(three) + 'GOES data available for specified time'
   return
endif

gapsize=10						;dont plot gaps
labels=['G7 Low','G6 Low','G7 High','G6 High']
delim=['',': ']

if exist(gnum) then mtitle='GOES '+ strtrim(gnum,2) + ' X-Rays' 

if keyword_set(nodeftitle) then mtitle=''
if not keyword_set(title) then title=''
mtitle=mtitle + delim(keyword_set(mtitle)) + title
linestyle=[0,1,0,1]
psym=[-3,3,-3,3]
symsize=[.7,1,.7,1]
usersym,[-1,1],[0,0]
offset=2					 	; first data field
yticks=6

intlab=keyword_set(intlab)
noylab=keyword_set(noylab) or intlab
ytickname=['1E-9','A  ','B  ','C  ','M  ','X  ','1E-3']
if keyword_set(noylab) then ytickname(*)=' '

yticklen=.001
yminor=1
ymax=679
if (n_elements(timerange) eq 1) then timerange=[input1, input2]

; set up the axis labels and plot scaling

; slf 7-dec-1993 - add three second option - use log plot if 3 sec
yrtemp=!y.crange
!y.crange=yrange
utplot, gxr_rec,indgen(n_elements(gxr_rec)) < ymax ,/nodata, $
    yminor=yminor, yticks=yticks, ytickname=ytickname, $	; JRL set yticklen = .001
    title=mtitle,yrange=yrange,xstyle=1,ystyle=1,ytype=ytype,$
    thick=thick,_extra=plot_keywords, timerange=timerange

!quiet=0		;utplot stuff clobbers this!
; determine which channels to plot
tags=tag_names(gxr_rec)
lochan=where(strpos(tags,'LO') ne -1)
hichan=where(strpos(tags,'HI') ne -1)
g6chan=where(strpos(tags,'G6') ne -1)
g7chan=where(strpos(tags,'G7') ne -1)

case 1 of
   keyword_set(low) and 1-keyword_set(high):  wchan=lochan
   keyword_set(high) and 1-keyword_set(low):  wchan=hichan
   keyword_set(no6) and (1-gxd): wchan=g7chan
   keyword_set(no7) and (1-gxd): wchan=g6chan
   else: wchan=[lochan, hichan]
endcase

if n_elements(wchan) eq 2 or repeats eq 2 then psym=[-3,-3]

case 1 of 
   n_elements(color) eq n_elements(wchan):
   n_elements(color) eq 0: color=intarr(4)+255
   n_elements(color) lt n_elements(wchan): $
	color=replicate(color(0),n_elements(wchan))
   else:color=color(0:n_elements(wchan)-1)
endcase

if !d.name eq 'PS' then color = 255 - color 
if n_elements(thick) eq 0 then thick=1

for rep=0, repeats-1 do begin			; loop added for 3 second

; now plot the valid points
for i=0, n_elements(wchan)-1 do begin		; for each desired channel
   valid=where(gxr_rec.(wchan(i))+1)		; initial val=-1
;
; ------------------- uplot_gap.pro subroutine?? -------------------------

   dvalid=-1                                    ; initialize DVALID (DMZ)
   if valid(0) ne -1 then dvalid=deriv_arr(valid)	; identify gaps
   rgst=0 & rgsp=n_elements(valid)-1		; at least one interval!
   gapsp = where(dvalid gt gapsize, count)	; discontinuity > gapsize
   if count gt 0 then begin			; at least one gap
      gapst=gapsp+1
      rgst=[rgst,gapst] & rgsp = [gapsp,rgsp]	; define subranges
   endif
   for j = 0, n_elements(rgst)-1 do begin ; plot each interval
      if rgst(j) ne rgsp(j) then $		; kludge for now
         oplot,anytim(gxr_rec( valid (rgst(j):rgsp(j))))-getutbase(), $
            gxr_rec(valid(rgst(j):rgsp(j))).(wchan(i)), color=color(i), $
            psym=psym(i), symsize=symsize(i), max=670,thick=thick
   endfor
;------------------------------------------------------------------------
endfor

!quiet=0		;utplot stuff clobbers this!

;-- Don't go here if GOES data structure is input (Zarro, April'04)

;  more 3 second logic stuff
   if repeats eq 2 and rep eq 0 and (not gxrin) then begin
      psym=[3,3]
      message,/info,'reading goes 6
      rd_gxd,input1,input2, gxr_rec,  /goes6, $
         one_minute=one_minute, five_minute=five_minute
      if not data_chk(gxr_rec,/struct) then begin
         message,/info,"Sorry, No GOES 6 data for this interval..."
         rep=repeats		;**** UNSTRUCTURED FOR LOOP EXIT ****
      endif
   endif

endfor
;
; overplot Yohkoh ephemeris grid on request
!y.crange=yrange
fem = keyword_set(fem) or keyword_set(fillnight) or $
   keyword_set(fillsaa) or keyword_set(saa)
if fem then $
   fem_grid,fillnight=fillnight, fillsaa=fillsaa, saa=saa
;------------------------------------------------------
; 
; draw grid indicating goes level
if not keyword_set(gcolor) then gcolor=bytarr(6)+255
if !d.name eq 'PS' then gcolor=255-gcolor
goes_grid, color=gcolor, grid_thick=grid_thick ; , color=bindgen(6)*50+50
;
;------------------------------------------------------

if intlab then begin
   device,get_graphics=oldg
   arr=['','A','B','C','M','X']   
   gpos=(indgen(6) * (!y.window(1)-!y.window(0))/6.) + (!y.window(0) + .005)
   device,set_graphics=6
   for i=0,5 do xyouts,!x.window(0)+.01,gpos(i),arr(i),/norm,charsize=1.3
   device,set_graphics=oldg
endif
;
if hardcopy then begin
   pprint
   set_plot,dtemp
endif

!quiet=qtemp

return
end
