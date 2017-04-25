;+
; Project     : SOHO - CDS     
;                   
; Name        : ANYTIM2CAL()
;               
; Purpose     : Converts (almost) any time format to calendar format.
;               
; Explanation : Tests the type of input and tries to use the appropriate
;               conversion routine to create the date/time in a user
;               selectable calendar format for, for example, printing in
;               documents, tables etc.
;               
; Use         : IDL>  utc = anytim2cal(any_format, form=xx)
;    
; Inputs      : any_format - date/time in any of the acceptable CDS 
;                            time formats -- for acceptable formats see file 
;                            aaareadme.txt.
;               
; Opt. Inputs : None
;               
; Outputs     : Function returns string array in format requested.
;               
; Opt. Outputs: None
;               
; Keywords    : 
;      FORM  = n   where... 
;			    n		  output format
;			    0		dd/mmm/yy hh:mm:ss  [default]
;			    1		dd-mmm-yy hh:mm:ss
;			    2		dd/mm/yy  hh:mm:ss
;			    3		dd-mm-yy hh:mm:ss
;			    4		mm/dd/yy hh:mm:ss
;			    5		mm-dd-yy hh:mm:ss
;			    6		yy/mm/dd hh:mm:ss
;			    7		yy-mm-dd hh:mm:ss
;			    8		yyyymmddhhmmss
;                           9           dd-mmm-yyyy hh:mm:ss.sss (VMS-like)
;                          10           dd-mmm-yyyy hh:mm:ss.ss (!stime-like)
;                          11           yyyy/mm/dd hh:mm:ss.sss (cpt use)
;			    etc TBD
;      DATE   - Output only the date in format above.
;      TIME   - Output only the time in format above.
;      MSEC   -	Include milliseconds in the "ss" fields above (="ss.sss").
;      ERRMSG - If defined and passed, then any error messages will be returned
;               to the user in this parameter rather than being printed to
;               the screen.  If no errors are encountered, then a null string 
;               is returned.  In order to use this feature, the string ERRMSG
;               must be defined first, e.g.,
;
;                   ERRMSG = ''
;                   ANYTIM2CAL, DT, ERRMSG=ERRMSG, ...
;                   IF ERRMSG NE '' THEN ...
;
; Calls       : ANYTIM2UTC, CHECK_EXT_TIME
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: If no parameters are passed, ERRMSG is returned as a string
;               array.  If any other error occurs and ERRMSG is set, ERRMSG
;		is returned as a string of '-1'.
;               
; Category    : Util, time
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 24-May-94
;               
; Modified    :	Version 1, C.D. Pike, RAL, 24 May 1994
;		Version 2, Donald G. Luttermoser, GSFC/ARC, 20 December 1994
;			Added the keyword ERRMSG.  Added forms 4 and 5.
;               Version 3, CDP, make work with vector input and
;                               added formats 6 & 7.   5-Jan-95
;               Version 4, CDP, fix round off giving 60 in seconds field.
;                               23-Jan-95
;		Version 5, William Thompson, GSFC, 25 January 1995
;			Changed to call intrinsic ROUND instead of NINT.  The
;			version of NINT in the Astronomy User's Library doesn't
;			automatically select between short and long integers as
;			the CDS version does.
;		Version 6, Donald G. Luttermoser, GSFC/ARC, 30 January 1995
;			Added ERRMSG keyword to internally called procedures.
;		Version 7, Donald G. Luttermoser, GSFC/ARC, 8 February 1995
;			Added form 8.  Allowed for input to be either scalar
;			or vector.
;		Version 8, Donald G. Luttermoser, GSFC/ARC, 13 February 1995
;			Added the /MSEC keyword.  Streamlined code to get
;			rid of redundancies.
;		Version 9, William Thompson, GSFC/ARC, 16 February 1995
;			Rewrote to call CHECK_EXT_TIME.  This is used instead
;			of the logic introduced in version 4 for checking the
;			validity of the time returned.
;               Version 10 Fixed array input bug in /msec code.  CDP, 20-Feb-95
;               Version 11 Add VMS and !stime-like formats 9/10. CDP, 15/3/95
;               Version 12 Add type 11 format.  CDP, 15-DEc-95
;		Version 13, 18-Mar-1998, William Thompson, GSFC
;			Use SAFE_STRING instead of STRING
;               Version 14, 27-Apr-2005, William Thompson, GSFC
;                       Fix problem with FORM=11 and /DATE or /TIME
;
; Version     :	Version 13, 18-Mar-1998
;-            

function anytim2cal, dt, form=form, date=date, time=time, msec=msec, $
   errmsg=errmsg

on_error, 2   ;  Return to the caller of this procedure if error occurs.

if n_params() eq 0 then begin
   message = strarr(16)
   message = [ ' ','Syntax:  STYLE = ANYTIM2CAL(DATE-TIME [, FORM=x, /DATE, '+$
    '/TIME ])', ' where x determines output format:',$
    '     x          format',         '    ---         ------', $
    '     0      dd/mmm/yy hh:mm:ss [default]', $
    '     1      dd-mmm-yy hh:mm:ss',   '     2      dd/mm/yy hh:mm:ss', $
    '     3      dd-mm-yy hh:mm:ss',    '     4      mm/dd/yy hh:mm:ss', $
    '     5      mm-dd-yy hh:mm:ss',    '     6      yy/mm/dd hh:mm:ss', $
    '     7      yy-mm-dd hh:mm:ss',    '     8      yyyymmddhhmmss',$
    '     9      dd-mmm-yyyy hh:mm:ss.sss', $
    '    10      dd-mmm-yyyy hh:mm:ss.ss',$
    '    11      yyyy/mm/dd hh:mm:ss.sss']
   if n_elements(errmsg) ne 0 then errmsg = message else $
      print_str,message,/num
   return,'-1'
endif
;
;  Month names;
;
mon = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
 
;
;  Convert any time format to external
;
ext = anytim2utc(dt, /ext, errmsg=errmsg)
if n_elements(errmsg) ne 0 then $
   if errmsg(0) ne '' then return, '-1'
;
;  Unless the /MSEC keyword was set, round off to the nearest second.
;
if (not keyword_set(msec)) then begin
   ext.second = round(float(ext.second) + float(ext.millisecond)/1000.)
   ext.millisecond = 0
endif

;
;  Make sure that it's a valid time, especially considering the above
;  round-off.
;
check_ext_time, ext, errmsg=errmsg
if n_elements(errmsg) ne 0 then $
   if errmsg(0) ne '' then return, '-1'
;
;  User wants default format
;
if not keyword_set(form) then form=0

;
;  Format according to instructions (the following parameters are the same
;  for all different types of FORM.
;
dd = strmid(safe_string(ext.day+100,format='(i3)'),1,2)
hh = strmid(safe_string(ext.hour+100,format='(i3)'),1,2)
mn = strmid(safe_string(ext.minute+100,format='(i3)'),1,2)
if keyword_set(msec) then begin
	ss  = ext.second+(ext.millisecond/1000.0)+100.
	ss  = strmid(safe_string(ss,format='(f7.3)'),1,6)
endif else begin
	ss  = round(ext.second+(ext.millisecond/1000.0))+100
	ss  = strmid(safe_string(ss,format='(i3)'),1,2)
endelse
;
; Find typical time string-length for /DATE and /TIME keyword procedures.
;
timelen = strlen(hh+':'+mn+':'+ss)
timelen = timelen(0)  ;  This will be constant for all output.

case 1 of
; dd/mmm/yy hh:mm:ss or dd-mmm-yy hh:mm:ss
   (form eq 0) or (form eq 1): begin
         if form eq 0 then c = '/' else c = '-'
         yy  = safe_string((ext.year-fix(ext.year/100)*100)+100,form='(i3)')
         yy  = strmid(yy,1,2)
         mmm = mon(ext.month-1)

         out = dd+c+mmm+c+yy+' '+hh+':'+mn+':'+ss

         if keyword_set(date) then out = strmid(out,0,9)
         if keyword_set(time) then out = strmid(out,10,timelen)
      end
; dd/mm/yy hh:mm:ss or dd-mm-yy hh:mm:ss 
   (form eq 2) or (form eq 3): begin
         if form eq 2 then c = '/' else c = '-'
         yy  = safe_string((ext.year-fix(ext.year/100)*100)+100,form='(i3)')
         yy  = strmid(yy,1,2)
         mm  = safe_string((ext.month-fix(ext.month/100)*100)+100,form='(i3)')
         mm  = strmid(mm,1,2)

         out = dd+c+mm+c+yy+' '+hh+':'+mn+':'+ss

         if keyword_set(date) then out = strmid(out,0,8)
         if keyword_set(time) then out = strmid(out,9,timelen)
      end
; mm/dd/yy hh:mm:ss or mm-dd-yy hh:mm:ss 
   (form eq 4) or (form eq 5): begin
         if form eq 4 then c = '/' else c = '-'
         yy  = safe_string((ext.year-fix(ext.year/100)*100)+100,form='(i3)')
         yy  = strmid(yy,1,2)
         mm  = safe_string((ext.month-fix(ext.month/100)*100)+100,form='(i3)')
         mm  = strmid(mm,1,2)

         out = mm+c+dd+c+yy+' '+hh+':'+mn+':'+ss

         if keyword_set(date) then out = strmid(out,0,8)
         if keyword_set(time) then out = strmid(out,9,timelen)
      end
; yy/mm/dd hh:mm:ss or yy-mm-dd hh:mm:ss 
   (form eq 6) or (form eq 7): begin
         if form eq 6 then c = '/' else c = '-'
         yy  = safe_string((ext.year-fix(ext.year/100)*100)+100,form='(i3)')
         yy  = strmid(yy,1,2)
         mm  = safe_string((ext.month-fix(ext.month/100)*100)+100,form='(i3)')
         mm  = strmid(mm,1,2)

         out = yy+c+mm+c+dd+' '+hh+':'+mn+':'+ss

         if keyword_set(date) then out = strmid(out,0,8)
         if keyword_set(time) then out = strmid(out,9,timelen)
      end
; yyyymmddhhmmss
   (form eq 8): begin
         yyyy= safe_string(ext.year,form='(i4)')
         mm  = safe_string((ext.month-fix(ext.month/100)*100)+100,form='(i3)')
         mm  = strmid(mm,1,2)
	 out = yyyy+mm+dd+hh+mn+ss

         if keyword_set(date) then out = strmid(out,0,8)
         if keyword_set(time) then out = strmid(out,8,timelen-2)
      end
;  VMS style
   (form eq 9): begin
                   out = anytim2utc(dt,errmsg=errmsg)
                   if n_elements(errmsg) ne 0 then $
                         if errmsg ne '' then return,'-1'
                   out = utc2str(out,/vms)
                   if keyword_set(date) then out = strmid(out,0,11)
                   if keyword_set(time) then out = strmid(out,12,12)
                end

; IDL !stime style
   (form eq 10): begin
                    out = anytim2utc(dt,errmsg=errmsg)
                    if n_elements(errmsg) ne 0 then $
                         if errmsg ne '' then return,'-1'
                    out = utc2str(out,/stime)
                    if keyword_set(date) then out = strmid(out,0,11)
                    if keyword_set(time) then out = strmid(out,12,12)
                 end
       
; yyyy/mm/dd hh:mm:ss 
      (form eq 11): begin
         c = '/' 
         yy  = trim(ext.year)
         mm  = safe_string((ext.month-fix(ext.month/100)*100)+100,form='(i3)')
         mm  = strmid(mm,1,2)

         out = yy+c+mm+c+dd+' '+hh+':'+mn+':'+ss

         if keyword_set(date) then out = strmid(out,0,10)
         if keyword_set(time) then out = strmid(out,11,timelen)
      end
  else: begin
	 if n_elements(errmsg) ne 0 then errmsg = $
	   'The values of "form=n" must fall in the range of 0 <= n <= 8.' $
	   else print,$
            'The values of "form=n" must fall in the range of 0 <= n <= 8.'
           return, '-1'
      end
endcase
;
;  And return
;
return,out


end
