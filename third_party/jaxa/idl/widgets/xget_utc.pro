;---------------------------------------------------------------------------
; Document name: xget_utc.pro
; Created by:    Liyun Wang, GSFC/ARC, April 3, 1996
;
; Last Modified: Wed Apr  3 15:33:13 1996 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       XGET_UTC()
;
; PURPOSE:
;       A widget program to select date/time (UTC) interactively
;
; CATEGORY:
;       Widget, utility
;
; SYNTAX:
;       Result = xget_utc( [date] )
;
; INPUTS:
;       None required.
;
; OPTIONAL INPUTS:
;       DATE - Initial Date/Time in any ECS time formats
;
; OUTPUTS:
;       RESULT - Date/Time (UTC time structure unless other keyword is set);  
;                -1 IF an error occurs
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       GROUP  - ID of widget which serves as a group leader
;       ERROR  - Error message returned; null string if no error
;       YRANGE - 2-element integer array indicating allowed time range
;                in years; default to [1995, 2010]
;       CENTER - Set this keyword to have the widget centered in the screen
;       _EXTRA - Any keywords accepted by ANYTIM2UTC
;
; COMMON:
;       None.
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       Caller widget program is frozen till XGET_UTC is killed.
;
; HISTORY:
;       Version 1, April 3, 1996, Liyun Wang, GSFC/ARC. Written
;       Version 2, August 12, 1996, Zarro, GSFC, added check for valid handle
;
; CONTACT:
;       Liyun Wang, GSFC/ARC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;

FUNCTION day_max, month, year
;---------------------------------------------------------------------------
;  Returns number of maximum days in a give month and year
;---------------------------------------------------------------------------
   day30 = [4, 6, 9, 11]
   IF (WHERE(day30 EQ month))(0) GE 0 THEN RETURN, 30
   IF month EQ 2 THEN BEGIN
      IF leap_year(year) THEN RETURN, 29 ELSE RETURN, 28
   ENDIF
   RETURN, 31
END

PRO adjust_day, info
   IF info.time_stc.day GT info.dmax THEN BEGIN
      info.time_stc.day = info.dmax
      WIDGET_CONTROL, info.day_txt, $
         set_value=STRING (info.dmax, FORMAT='(i2.2)')
      WIDGET_CONTROL, info.day_sld, set_value=info.dmax
   ENDIF
END

PRO xget_utc_event, event
   WIDGET_CONTROL, event.top, get_uvalue=unseen
   info = get_pointer(unseen, /no_copy)
   if datatype(info) ne 'STC' then return

   CASE event.id OF
      info.day_txt : BEGIN
         WIDGET_CONTROL, event.id, get_value=val
         val = FIX(val(0))
         val = ((val > 1) < info.dmax)
         WIDGET_CONTROL, info.day_sld, set_value=val
         val = STRING (val, FORMAT='(i2.2)')
         WIDGET_CONTROL, event.id, set_value=val
      END
      info.mon_txt : BEGIN
         WIDGET_CONTROL, event.id, get_value=val
         ii = WHERE(STRUPCASE(info.month_str) EQ STRTRIM(STRUPCASE(val(0)),2))
         IF ii(0) LT 0 THEN BEGIN
            msg = 'Unrecognized month name.'
            xack, msg, group=event.top, /modal
         ENDIF ELSE BEGIN
          info.time_stc.month = ii(0)+1
          info.dmax = day_max(info.time_stc.month, info.time_stc.year)
          adjust_day, info
          WIDGET_CONTROL, info.mon_sld, set_value=info.time_stc.month
          WIDGET_CONTROL, event.id, set_value=$
             info.month_str(info.time_stc.month)
         ENDELSE
      END
      info.yea_txt : BEGIN
         WIDGET_CONTROL, event.id, get_value=val
         val = FIX(val(0))
         val = ((val > info.yrange(0)) < info.yrange(1))
         info.time_stc.year = val
         info.dmax = day_max(info.time_stc.month, info.time_stc.year)
         adjust_day, info
         WIDGET_CONTROL, info.yea_sld, set_value=val
         val = STRING (val, FORMAT='(i4.4)')
         WIDGET_CONTROL, event.id, set_value=val
      END
      info.hou_txt : BEGIN
         WIDGET_CONTROL, event.id, get_value=val
         val = FIX(val(0))
         val = ((val > 0) < 23)
         info.time_stc.hour = val
         WIDGET_CONTROL, info.hou_sld, set_value=val
         val = STRING (val, FORMAT='(i2.2)')
         WIDGET_CONTROL, event.id, set_value=val
      END
      info.min_txt : BEGIN
         WIDGET_CONTROL, event.id, get_value=val
         val = FIX(val(0))
         val = ((val > 0) < 59)
         info.time_stc.mini = val
         WIDGET_CONTROL, info.min_sld, set_value=val
         val = STRING (val, FORMAT='(i2.2)')
         WIDGET_CONTROL, event.id, set_value=val
      END
      info.sec_txt : BEGIN
         WIDGET_CONTROL, event.id, get_value=val
         val = FIX(val(0))
         val = ((val > 0) < 59)
         info.time_stc.sec = val
         WIDGET_CONTROL, info.sec_sld, set_value=val
         val = STRING (val, FORMAT='(i2.2)')
         WIDGET_CONTROL, event.id, set_value=val
      END
      info.day_sld : BEGIN
         WIDGET_CONTROL, event.id, get_value=val
         val = ((val > 1) < info.dmax)
         info.time_stc.day = val
         val = STRING (val, FORMAT='(i2.2)')
         WIDGET_CONTROL, info.day_txt, set_value=val
      END
      info.mon_sld : BEGIN
         WIDGET_CONTROL, event.id, get_value=val
         info.time_stc.month = val
         info.dmax = day_max(info.time_stc.month, info.time_stc.year)
         adjust_day, info
         WIDGET_CONTROL, info.mon_txt, set_value=info.month_str(val-1)
      END
      info.yea_sld : BEGIN
         WIDGET_CONTROL, event.id, get_value=val
         info.time_stc.year = val
         info.dmax = day_max(info.time_stc.month, info.time_stc.year)
         adjust_day, info
         WIDGET_CONTROL, info.yea_txt, set_value=STRING(val, FORMAT='(i4.4)')
      END
      info.hou_sld : BEGIN
         WIDGET_CONTROL, event.id, get_value=val
         info.time_stc.hour = val
         WIDGET_CONTROL, info.hou_txt, set_value=STRING(val, FORMAT='(i2.2)')
      END
      info.min_sld : BEGIN
         WIDGET_CONTROL, event.id, get_value=val
         info.time_stc.mini = val
         WIDGET_CONTROL, info.min_txt, set_value=STRING(val, FORMAT='(i2.2)')
      END
      info.sec_sld : BEGIN
         WIDGET_CONTROL, event.id, get_value=val
         info.time_stc.sec = val
         WIDGET_CONTROL, info.sec_txt, set_value=STRING(val, FORMAT='(i2.2)')
      END

      info.accept: BEGIN
         info.status = 1
         xtext_reset,info
         xkill,event.top
      END
      info.cancel: BEGIN
         info.status = 0
         xtext_reset,info
         xkill,event.top
      END

      ELSE:
   ENDCASE

   set_pointer, unseen, info, /no_copy

END

FUNCTION xget_utc, time, group=group, yrange=yrange, error=error, $
                   center=center, _extra=extra

   error = ''
   IF N_ELEMENTS(time) EQ 0 THEN get_utc, curr_time, /ecs ELSE $
      curr_time = anytim2utc(time, /ecs, err=error)
   IF error NE '' THEN BEGIN
      MESSAGE, error, /cont
      RETURN, -1
   ENDIF
   IF N_ELEMENTS(yrange) EQ 0 THEN yrange = [1995, 2010]
   status = 0

   year = STRMID(curr_time,0,4)
   month = STRMID(curr_time,5,2)
   day = STRMID(curr_time,8,2)
   hour = STRMID(curr_time,11,2)
   mini = STRMID(curr_time,14,2)
   sec = STRMID(curr_time,17,2)
   time_stc = {year:FIX(year), month:FIX(month), day:FIX(day), $
               hour:FIX(hour), mini:FIX(mini), sec:FIX(sec)}
   month_str = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug',$
                'Sep', 'Oct', 'Nov', 'Dec']

   dmax = day_max(time_stc.month, time_stc.year)

   title = 'XGET_UTC'
   font = '-misc-fixed-bold-r-normal--13-100-100-100-c-70-iso8859-1'
   font = (get_dfont(font))(0)
   IF font EQ '' THEN font = 'fixed'

   bfont = '-misc-fixed-bold-r-normal--15-140-75-75-c-90-iso8859-1'
   bfont = (get_dfont(bfont))(0)
   IF bfont EQ '' THEN bfont = 'fixed'

   bfont2 = '-adobe-courier-bold-r-normal--20-140-100-100-m-110-iso8859-1'
   bfont2 = (get_dfont(bfont2))(0)

   base = WIDGET_BASE(title=title, /column)
   ctr_base = WIDGET_BASE(base, /column, /frame)
   cmd_base = WIDGET_BASE(base, /row, xpad=60)

   tmp = WIDGET_BASE(ctr_base, /row)
   mon_txt = WIDGET_TEXT(tmp, xsize=3, value=month_str(time_stc.month-1) , $
                         /editable, font=font)
   day_txt = WIDGET_TEXT(tmp, xsize=2, value=day, $
                         /editable, font=font)
   tmp1 = WIDGET_LABEL(tmp, value=',', font=font)
   yea_txt = WIDGET_TEXT(tmp, xsize=4, value=year, $
                         /editable, font=font)
   tmp1 = WIDGET_LABEL(tmp, value='  ', font=font)
   hou_txt = WIDGET_TEXT(tmp, xsize=2, value=hour, $
                         /editable, font=font)
   tmp1 = WIDGET_LABEL(tmp, value=':', font=font)
   min_txt = WIDGET_TEXT(tmp, xsize=2, value=mini, $
                         /editable, font=font)
   tmp1 = WIDGET_LABEL(tmp, value=':', font=font)
   sec_txt = WIDGET_TEXT(tmp, xsize=2, value=sec, $
                         /editable, font=font)
   xsize = 250
   tmp = WIDGET_BASE(ctr_base, /column, /frame)
   tmp1 = WIDGET_BASE(tmp, /row)
   ret = WIDGET_LABEL(tmp1, value='Month', font=bfont)
   mon_sld = WIDGET_SLIDER(tmp1, /drag, xsize=xsize, min=1, max=12, $
                           /suppress_value, value=time_stc.month)
   tmp1 = WIDGET_BASE(tmp, /row)
   ret = WIDGET_LABEL(tmp1, value='  Day', font=bfont)
   day_sld = WIDGET_SLIDER(tmp1, /drag, xsize=xsize, min=1, max=31, $
                           /suppress_value, value=time_stc.day)
   tmp1 = WIDGET_BASE(tmp, /row)
   ret = WIDGET_LABEL(tmp1, value=' Year', font=bfont)
   yea_sld = WIDGET_SLIDER(tmp1, /drag, xsize=xsize, min=yrange(0), $
                           max=yrange(1), /suppress_value, value=time_stc.year)
   tmp1 = WIDGET_BASE(tmp, /row)
   ret = WIDGET_LABEL(tmp1, value=' Hour', font=bfont)
   hou_sld = WIDGET_SLIDER(tmp1, /drag, xsize=xsize, min=0, max=23, $
                           /suppress_value, value=time_stc.hour)
   tmp1 = WIDGET_BASE(tmp, /row)
   ret = WIDGET_LABEL(tmp1, value='  Min', font=bfont)
   min_sld = WIDGET_SLIDER(tmp1, /drag, xsize=xsize, min=0, max=59, $
                           /suppress_value, value=time_stc.mini)
   tmp1 = WIDGET_BASE(tmp, /row)
   ret = WIDGET_LABEL(tmp1, value='  Sec', font=bfont)
   sec_sld = WIDGET_SLIDER(tmp1, /drag, xsize=xsize, min=0, max=59, $
                           /suppress_value, value=time_stc.sec)

   accept = WIDGET_BUTTON(cmd_base, value='Accept', font=bfont2, $
                          resource_name='AcceptButton')
   cancel = WIDGET_BUTTON(cmd_base, value='Cancel', font=bfont2, $
                          resource_name='QuitButton')

   offsets = get_cent_off(base, valid=valid)
   IF KEYWORD_SET(center) AND valid THEN $
      WIDGET_CONTROL, base, /realize, /map, tlb_set_xoff=offsets(0),$
      tlb_set_yoff=offsets(1), /show $
   ELSE $
      WIDGET_CONTROL, base, /realize, /map, /sho

   make_pointer, unseen

   info = {mon_txt:mon_txt, day_txt:day_txt, yea_txt:yea_txt, hou_txt:hou_txt,$
           min_txt:min_txt, sec_txt:sec_txt, mon_sld:mon_sld, day_sld:day_sld,$
           yea_sld:yea_sld, hou_sld:hou_sld, min_sld:min_sld, sec_sld:sec_sld,$
           accept:accept, cancel:cancel, status:status, time_stc:time_stc,$
           month_str:month_str, dmax:dmax, yrange:yrange}

   set_pointer, unseen, info, /no_copy
   WIDGET_CONTROL, base, set_uvalue=unseen

   xmanager, 'xget_utc', base, group=group, /modal
   if xalive(base) then xmanager
   info = get_pointer(unseen, /no_copy)
   free_pointer, unseen
   if datatype(info) eq 'STC' then status=info.status else status=0
   IF not status THEN BEGIN
      out = anytim2utc(curr_time,_extra=extra, err=error)
   ENDIF ELSE BEGIN
      ecs = STRTRIM(STRING(info.time_stc.year,form='(i4.4)'),2)+'/'+$
         STRTRIM(STRING(info.time_stc.month,form='(i2.2)'),2)+'/'+$
         STRTRIM(STRING(info.time_stc.day,form='(i2.2)'),2)+' '+$
         STRTRIM(STRING(info.time_stc.hour,form='(i2.2)'),2)+':'+$
         STRTRIM(STRING(info.time_stc.mini,form='(i2.2)'),2)+':'+$
         STRTRIM(STRING(info.time_stc.sec,form='(i2.2)'),2)+'.000'
      out = anytim2utc(ecs, _extra=extra, err=error)
   ENDELSE
   IF error NE '' THEN BEGIN
      MESSAGE, error, /cont
      RETURN, -1
   ENDIF ELSE RETURN, out
END

;---------------------------------------------------------------------------
; End of 'xget_utc.pro'.
;---------------------------------------------------------------------------
