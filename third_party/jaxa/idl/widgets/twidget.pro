;+
; PROJECT:
;	SDAC
; NAME:
;             TWIDGET
; PURPOSE:
;             This procedure provides a MOTIF interface for date or date&time selection.
; CATEGORY:
;             widgets
; CALLING SEQUENCE:
;             TWIDGET, RDATE [,/ALL, /TIMES, /YEAR, /MONTH,
;                      /DAY, /DOY, /HOUR, /MIN, /SEC, MESSAGE=MESSAGE,
;                      ERROR=ERROR, GROUP_LEADER=GROUP]
;             or
;             TWIDGET, RDATE [,/ALL, /TIMES, YEAR=[Y1,Y2], MONTH=[M1,M2],
;                      /DAY, DOY=[D1,D2], /HOUR, /MIN, /SEC, MESSAGE=MESSAGE,
;                      ERROR=ERROR, GROUP_LEADER=GROUP]
;             or
;             TWIDGET, RDATE [,YEAR=Y, MONTH=M, DAY=D, DOY=DOY, HOUR=H,
;                      MIN=M, SEC=S, MESSAGE=MESSAGE,
;                      /INIT, ERROR=ERROR, GROUP_LEADER=GROUP]
; EXAMPLES:
;             twidget, outtime=rtime1, group_leader=base, /all, error=error
; OUTPUTS:
;             RDATE = structure = {date,year:0,month:0,day:0,doy:0,
;                                  hour:0,minute:0,sec:0}
; CALLS:
;             PARSE_ATIME, ANYTIM, UT_2_YYDOY, YYDOY_2_UT
; KEYWORD ARGUMENTS:
;
;             OUTTIME = Returns selected time in external ut format (7-element
;                     array [hh,mm,ss,msec,dd,mm,yy]
;             ALL =   If set, enable selection of year, month, day, (or day
;                     of year if DOY is passed), hour, minute, and second.
;             TIMES = If set, enable selection of hour, minute, and second.
;             NOWILD =If set, then year, month, and day will not have 'all'
;                     option.
;             YEAR =  =1 means enable selection of year.
;                     =N with /INIT means initialize year to N.
;                     =[Y1,Y2] defines range of years allowed.
;             MONTH = =1 means enable selection of month.
;                     =N with /INIT means initialize month to N.
;                     =[M1,M2] defines range of months allowed.
;             DAY =   =1 means enable selection of day.
;                     =N with /INIT means initialize day to N.
;             DOY =   =1 means enable selection of day of year..
;                     =N with /INIT means initialize day of year to N.
;                     =[D1,D2] defines range of days of year allowed.
;             HOUR =  =1 means enable selection of hour.
;                     =N with /INIT means initialize hour to N.
;             MIN =   =1 means enable selection of minute.
;                     =N with /INIT means initialize minute to N.
;             SEC =   =1 means enable selection of second.
;                     =N with /INIT means initialize second to N.
;             INIT =  If set, initialize RDATE structure to values passed
;                     in keywords YEAR, MONTH, etc.  Do not bring up widget.
;                     and return.
;             MESSAGE = String (scalar or array) containing message to print
;                     in time selection widget box.
;             ERROR = On return, 0/1 means no error / error.  Error is due to:
;                     User aborted via CANCEL button.
;                     Widgets not available.
;                     TWIDGET already registered (in use).
;			  TIME_INIT = Used only with INIT option.  Contains time to initialize widget
;					  to instead of using values in keywords YEAR, MONTH, etc.
;			  OUTSEC = Returns selected time in seconds in addition to silly rdate structure
; RESTRICTIONS:
;             needs X-windows
; PROCEDURE:
;             Default is to enable selection of year, month, and day.
;             DOY keyword takes priority over MONTH and DAY keywords.
;             YEAR, MONTH, and DOY keywords can be passed as 2-element
;             arrays to define the range of allowed values or can simply
;             be turned on via the /keyword format (e.g. /YEAR).
;             Time selected is returned in the structure RDATE described above.
;             To initialize the time in RDATE, call TWIDGET with time elements
;             you want to set (e.g. YEAR=1980). and call with /INIT.
; MODIFICATION HISTORY:
;             written 12/92 by Kim Tolbert (based on SDA written by D. Zarro)
;             Mod. 11/93 KT.  Added nowild option, and corrected error when
;               hour=0 was specified (was using keyword_set)
;             Mod. Jul 1 94 by KT.  Added outtime keyword.  Returns selected
;               time in external ut format in addition to the rdate structure.
;             Version 4, richard.schwartz@gsfc.nasa.gov, 5-feb-1997, use parse_atime to convert final output.
;             Version 5, richard.schwartz@gsfc.nasa.gov, 24-sep-1997, anytim.pro supports
;		4 digit year strings, revised accordingly.
;             Version 6, richard.schwartz@gsfc.nasa.gov, 18-may-1998, make compatible with WIN.
;			11/10/99, Kim.
;				Added time_init keyword.
;				Added outsec keyword
;				Current selection in list widgets now highlighted.
;				xsize of text widget must be set explicitly in Windows.
;				Modal keyword set in xmanager call generates an error message.  Set modal
;				  in widget_base call if keyword group is set (required).
;				When wildcard dates are allowed, first year in list (which corresponds to
;					'all' in the widget is now 0 instead of 1979.
;

;-

pro twidget_event, event                         ;TWIDGET event handler

common time_widgets, wtext, wyear, wmonth, wday, wdoy, $  ; widget id's
   whour, wmin, wsec, $                                   ; more widget id's
   do_year, do_month, do_day, do_doy, do_hour, do_min, do_sec, $ ;user's choices
   yearvals, monthvals, dayvals, doyvals, $  ; allowed values
   mode, $                          ; mode = 'TIME' or 'DATE'
   sdate, $                         ; selected date in same structure as RDATE
   serror                           ; 0/1 = no error / error


;-- get event type

widget_control, event.id, get_uvalue = uservalue
if (n_elements(uservalue) eq 0) then uservalue = ''
wtype = strmid(tag_names(event,/structure_name),7,1000)

;-- LIST widget?

if wtype eq 'LIST' then begin
   if event.id eq wyear then sdate.year = yearvals(event.index)
   if event.id eq wmonth then sdate.month = monthvals(event.index)
   if event.id eq wday then sdate.day = dayvals(event.index)
   if event.id eq wdoy then sdate.doy = doyvals(event.index)
   if event.id eq whour then sdate.hour = event.index
   if event.id eq wmin then sdate.minute = event.index
   if event.id eq wsec then sdate.sec = event.index
endif

;-- BUTTON widget?

if wtype eq  'BUTTON' then begin
   buttname = strtrim(uservalue,2)

   if buttname eq  'DONE' then begin
      widget_control,event.top,/destroy
      serror = 0
      goto, getout
   endif

   if buttname eq  'CANCEL' then begin
      widget_control,event.top,/destroy
      serror = 1
      goto, getout
   endif
endif

; Construct string with currently selected date and/or time for display

if sdate.year le 1979 then yr = '19**' else yr = string(sdate.year,'(i4.2)')
if do_doy then begin
   ; if not a leap year, make sure doy is <= 365.
   if (sdate.year mod 4) ne 0 then sdate.doy = (sdate.doy < 365)
   if sdate.doy le 0 then doy = '**' else doy = string(sdate.doy,'(i3.3)')
   cdate = yr + '/' + doy
endif else begin
   ;--check for errors in month or day number
   month_30 = [4,6,9,11]  ; months with 30 days
   find = where(sdate.month eq month_30,count)
   if (count gt 0) then sdate.day = (sdate.day < 30)
   if (sdate.month eq 2) then begin  ; for leap year, Feb has max 29 days
      if (sdate.year mod 4) eq 0 then sdate.day = (sdate.day < 29) else $
         sdate.day = (sdate.day < 28)
   endif
   if sdate.month le 0 then mon = '**' else mon = string(sdate.month,'(i2.2)')
   if sdate.day le 0 then day = '**' else day = string(sdate.day,'(i2.2)')
   cdate = yr+'/'+mon+'/'+day
endelse

if do_hour or do_min or do_sec then begin
   hr = string(sdate.hour, '(i2.2)')
   minute = string(sdate.minute, '(i2.2)')
   sec = string(sdate.sec, '(i2.2)')
   cdate = cdate + ', ' + hr + minute + ':' + sec
endif

widget_control,wtext,set_value = 'NEW SELECTED ' + mode + ': ' + cdate

getout:
return & end

;------------------------------------------------------------------------------

pro twidget, rdate, outtime=outtime, all=all, times=times, $
    year=u_year, month=u_month, day=u_day, doy=u_doy, $
    hour=u_hour, min=u_min, sec=u_sec, $
    init=init, message=message, $
    error = error, group_leader=group, just_reg=just_reg, nowild=nowild, $
    time_init=time_init, outsec=outsec

common time_widgets, wtext, wyear, wmonth, wday, wdoy, $  ; widget id's
   whour, wmin, wsec, $                                   ; more widget id's
   do_year, do_month, do_day, do_doy, do_hour, do_min, do_sec, $ ;user's choices
   yearvals, monthvals, dayvals, doyvals, $  ; allowed values
   mode, $                          ; mode = 'TIME' or 'DATE'
   sdate, $                         ; selected date in same structure as RDATE
   serror                           ; 0/1 = no error / error

serror = 1  ; initialize error flag to 'Yes, error'

if not have_windows() then begin
   message,'widgets are unavailable'
   return
endif

set_plot,xdevice()

if (xregistered('twidget')) then return                       ;-register once

serror = 0     ; Set error flag to 'no error'

if keyword_set(nowild) then nowild = 1 else nowild = 0

;-- autosize screen

; if structure for date has not been defined, initialize it.
s = size(sdate)
if s(s(0)+1) ne 8 then $
   sdate = {year:1980,month:2,day:14,doy:45,hour:0,minute:0,sec:0}

; If TWIDGET called with /INIT, initialize the specified time elements and
; return
if keyword_set(init) then begin
   if keyword_set(time_init) then begin
   		date = anytim(time_init, /utc_ext, error=serror)
   		if serror then goto, getout
   		copy_struct, date, sdate
   		sdate.sec = date.second
   endif else begin
	   if n_elements(u_year) ne 0 then sdate.year = u_year
	   if n_elements(u_month) ne 0 then sdate.month = u_month
	   if n_elements(u_day) ne 0 then sdate.day = u_day
	   if n_elements(u_doy) ne 0 then sdate.doy = u_doy
	   if n_elements(u_hour) ne 0  then sdate.hour = u_hour
	   if n_elements(u_min) ne 0 then sdate.minute = u_min
	   if n_elements(u_sec) ne 0 then sdate.sec = u_sec
   endelse
   goto, getout
endif

device,get_screen_size=sc
fspace = .0146*sc(0)*.5
fxpad = .0117*sc(0)*.5
fypad = .0146*sc(1)*.5

; Initialize options for time elements to display widgets for to none.
do_year=0 & do_month=0 & do_day=0 & do_doy=0 & do_hour=0 & do_min=0 & do_sec=0

case 1 of

   keyword_set(all): begin
      do_year=1 & do_month=1 & do_day=1 & do_hour=1 & do_min=1 & do_sec=1
      end

   keyword_set(times): begin
      do_year=0 & do_month=0 & do_day=0 & do_hour=1 & do_min=1 & do_sec=1
      end

   else: begin
      if keyword_set(u_year) then do_year = 1
      if keyword_set(u_month) then do_month = 1
      if keyword_set(u_day) then do_day = 1
      if keyword_set(u_hour) then do_hour = 1
      if keyword_set(u_min) then do_min = 1
      if keyword_set(u_sec) then do_sec = 1
      end

endcase

; If no options were selected, use defaults (year, month, day)
ncolumns = do_year+do_month+do_day+do_hour+do_min+do_sec
if ncolumns eq 0 then begin
   do_year=1 & do_month=1 & do_day=1
endif

; If Day of Year option was selected, disable month and day options.
if keyword_set(u_doy) then begin
   do_doy=1 & do_month=0 & do_day=0
endif

ncolumns = do_year+do_month+do_day+do_hour+do_min+do_sec

;-- some defaults


mode = 'DATE'
if do_hour or do_min or do_sec then mode = 'TIME'

btitle = ' WIDGET DIAL-A-' + mode

; in newer versions of IDL, modal must be set on base call, instead of xmanager call.
; But group must be set when modal is called.  For compatibility with older programs,
; only set modal here if group is set.  Otherwise set it in xmanager, and it will
; generate error message (but still work).
if keyword_set(just_reg) then modal = 0  else modal = 1
if not keyword_set(group) then modal = 0
base = widget_base(TITLE = btitle, XPAD = fxpad, YPAD = fypad,$
                   SPACE = fspace, /column,/frame, modal=modal, group_leader=group)

;-- 1st row

row1 = widget_base(base,/column,space = fspace)

temp = widget_base(row1,/column)
mess_size = n_elements(message) - 1
if mess_size lt 0 then begin
   message = 'SELECT OBSERVATION '+mode
   mess_size = 0
endif
for i = 0,mess_size do wlabel = widget_label(temp,value=message(i))

temp = widget_base(row1,/column,xpad=fxpad,ypad=fypad,space=fspace)

if sdate.year le 1900 then yr = '19**' else yr = string(sdate.year,'(i4.2)')
if sdate.month le 0 then mon = '**' else mon = string(sdate.month,'(i2.2)')
if sdate.day le 0 then day = '**' else day = string(sdate.day,'(i2.2)')
if sdate.doy le 0 then doy = '**' else doy = string(sdate.doy,'(i3.3)')

cdate = yr + '/' + mon + '/' + day
if do_doy then cdate = yr + '/' + doy

if do_hour or do_min or do_sec then begin
   hr = string(sdate.hour, '(i2.2)')
   minute = string(sdate.minute, '(i2.2)')
   sec = string(sdate.sec, '(i2.2)')
   cdate = cdate + ', ' + hr + minute + ':' + sec
endif

text = 'LAST SELECTED '+mode+': '+cdate
wtext = widget_text(temp,value = text, xsize=strlen(text))

;-- 2nd row of buttons

fx = (7 - ncolumns) > 1  ; factor for spacing depends on number of columns
row2 = widget_base(base,/row,space=2*fx*fspace,xpad=fx*fxpad,ypad=fypad)

; Set width of list widget.  Want it wider (7) if we have fewer columns.
width = 7
if ncolumns gt 3 then width = 5

; Set up widgets for each element user requested (do_xxx variables).  If a
; range of values was passed in the u_xxx keyword, then use that to set
; the values displayed in the widget.  Otherwise, use the defaults (years
; 1980-1999, all months, all days, etc.). The widget id (wxxx variables)
; will be 0 for widgets that aren't set up.
;
if do_year then begin
   c1row2 = widget_base(row2, /column, space=fspace, xpad=fxpad, ypad=fypad)
   wtemp = widget_text (c1row2, value = 'YEAR', xsize=width)
   if (size(u_year))(0) eq 1 then $
      yearvals = [0,u_year(0) + indgen(u_year(1)-u_year(0)+1)] $
      else yearvals = [0, indgen(20)+1980]
   year_st = [' all',string(yearvals(1:*),format='(i4)')]
   if nowild then begin
      yearvals = yearvals(1:*)
      year_st = year_st(1:*)
   endif
   wyear = widget_list(c1row2,value=year_st, ysize=13)
   selected = where (yr eq year_st, count)
   if count eq 1 then widget_control, wyear, set_list_select=selected
endif else wyear = 0

if do_month then begin
   c2row2 = widget_base(row2, /column, space=fspace, xpad=fxpad, ypad=fypad)
   wtemp = widget_text (c2row2, value = 'MONTH', xsize=width+1)
   if (size(u_month))(0) eq 1 then $
      monthvals = [0, u_month(0) + indgen(u_month(1)-u_month(0)+1)] $
      else monthvals = indgen(13)
   if nowild then begin
      monthvals = monthvals(1:*)
   endif
   months = [' all', ' JAN', ' FEB', ' MAR', ' APR', ' MAY', ' JUN', $
                     ' JUL', ' AUG', ' SEP', ' OCT', ' NOV', ' DEC']
   month_st = months(monthvals)
   wmonth = widget_list(c2row2,value=month_st, ysize=13)
   selected = where (months(mon) eq month_st, count)
   if count eq 1 then widget_control, wmonth, set_list_select=selected
endif else wmonth = 0

if do_day then begin
   c3row2 = widget_base(row2, /column, space=fspace, xpad=fxpad, ypad=fypad)
   wtemp = widget_text (c3row2, value = ' DAY ', xsize=width)
   dayvals = [0, indgen(31)+1]
   day_st = [' all', string(indgen(31)+1, format='(i2)')]
   if nowild then begin
      dayvals = dayvals(1:*)
      day_st = day_st(1:*)
   endif
   wday = widget_list(c3row2,value=day_st, ysize=13)
   selected = where (string (day, format='(i2)') eq day_st, count)
   if count eq 1 then widget_control, wday, set_list_select=selected
endif else wday = 0

if do_doy then begin
   c33row2 = widget_base(row2, /column, space=fspace, xpad=fxpad, ypad=fypad)
   wtemp = widget_text (c33row2, value = ' DOY ', xsize=width)
   ; IDL will only format 265 values at a time, so break the 366 days into
   ; two calls to STRING.
   if (size(u_doy))(0) eq 1 then $
      doyvals = [0, u_doy(0) + indgen(u_doy(1)-u_doy(0)+1)] $
      else doyvals = indgen(367)
   ntot = n_elements(doyvals)
   n = n_elements(doyvals) / 2
   if ntot gt 256 then $
      doy_st = [' all', string(doyvals(1:n),format='(i3)'),$
                 string(doyvals(n+1:*), format='(i3)')] $
      else doy_st = [' all', string(doyvals(1:ntot-1),format='(i3)')]
   if nowild then begin
      doyvals = doyvals(1:*)
   endif
   wdoy = widget_list(c33row2,value=doy_st(doyvals), ysize=13)
   selected = where (string (doy, format='(i3)') eq doy_st, count)
   if count eq 1 then widget_control, wdoy, set_list_select=selected
endif else wdoy = 0

if do_hour then begin
   c4row2 = widget_base(row2, /column, space=fspace, xpad=fxpad, ypad=fypad)
   wtemp = widget_text (c4row2, value = 'HOUR ', xsize=width)
   hourvals = string(indgen(24), format='(i2)')
   whour = widget_list(c4row2,value=hourvals, ysize=13)
   selected = where (string (hr, format='(i2)') eq hourvals, count)
   if count eq 1 then widget_control, whour, set_list_select=selected
endif else whour = 0

if do_min then begin
   c5row2 = widget_base(row2, /column, space=fspace, xpad=fxpad, ypad=fypad)
   wtemp = widget_text (c5row2, value = ' MIN ', xsize=width)
   minvals = string(indgen(60), format='(i2)')
   wmin = widget_list(c5row2,value=minvals, ysize=13)
   selected = where (string (minute, format='(i2)') eq minvals, count)
   if count eq 1 then widget_control, wmin, set_list_select=selected
endif else wmin = 0

if do_sec then begin
   c6row2 = widget_base(row2, /column, space=fspace, xpad=fxpad, ypad=fypad)
   wtemp = widget_text (c6row2, value = ' SEC ', xsize=width)
   secvals = string(indgen(60), format='(i2)')
   wsec = widget_list(c6row2,value=secvals, ysize=13)
   selected = where (string (sec, format='(i2)') eq secvals, count)
   if count eq 1 then widget_control, wsec, set_list_select=selected
endif else wsec = 0

;-- done and cancel buttons

e = 5.
if ncolumns gt 3 then e = 10.
row3 = widget_base (base, /row, space=3.*fspace, xpad=e*fxpad, ypad=fypad)
cancel = widget_button(row3,value='           CANCEL          ', $
    uvalue='CANCEL', /no_release)
done = widget_button(row3,value='           READY           ',uvalue='DONE', $
    /no_release)

;-- realize main widget

widget_control,base,/realize
if keyword_set(just_reg) then modal = 0  else modal = 1
; if group is set then we've already set modal in call to widget_base. Unset modal here
; so we don't generate an error message.  (for compatibility with older programs, when
; group isn't set, let xmanager set modal attribute.)
if keyword_set(group) then modal=0
xmanager, 'twidget', base, group_leader=group, modal=modal, just_reg=just_reg

; If CANCELed, exit immediately
if serror then goto, getout

;-- Before exiting, set day of year if year/month/day were selected,
;   and vice versa, so RDATE structure will have correct month/day and doy.
;
if do_doy then begin
   if (sdate.doy gt 0) and (sdate.year gt 1979) then begin

      parse_atime, yydoy_2_ut([sdate.year,sdate.doy]), month=month,day=day
      sdate.month = month
      sdate.day = day
   endif else begin
      sdate.month = 0
      sdate.day = 1
   endelse
endif else begin
   if (sdate.year gt 1979) and (sdate.month gt 0) and $
      (sdate.day gt 0) then begin
      bintime = [sdate.hour, sdate.minute, sdate.sec, 0, sdate.day, sdate.month, sdate.year]
      parse_atime, bintime, /string, year=yr, month=mon, day=day
      sdate.doy = (ut_2_yydoy(bintime))(1)
      ;yr = string (sdate.year-1900,'(i2.2)')
      ;mon = string(sdate.month,'(i2.2)')
      ;day = string(sdate.day,'(i2.2)')
      ;bintime = utime (yr + '/' + mon + '/' + day)
      ;sdate.doy = fix ((bintime - utime(yr+'/1/1')) / 86400.d0) + 1
   endif else sdate.doy = 0
endelse
;
getout:
;-- return date and error flag
rdate = sdate
outtime = [rdate.hour, rdate.minute, rdate.sec, 0, $
          rdate.day, rdate.month, rdate.year]
outsec = anytim ( outtime, /sec )
error = serror
end
