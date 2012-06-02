pro get_date,dte
;+
; NAME:
;	GET_DATE
; PURPOSE:
;	Return the current date in DD/MM/YY format.  This is the format
;	required by the DATE and DATE-OBS keywords in a FITS header
;
; CALLING SEQUENCE:
;	GET_DATE, dte
; INPUTS:
;	None
; OUTPUTS:
;	dte = An eight character scalar string specifying the current day 
;		(0-31), current month (1-12), and last two digits of the 
;		current year
; EXAMPLE:
;	Add the current date to the DATE keyword in a FITS header,h
;     
;	IDL> GET_DATE,dte
;	IDL> sxaddpar, h, 'DATE', dte
;
; REVISION HISTORY:
;	Written      W. Landsman          March 1991
;-
 On_error,2

 if N_params() LT 1 then begin
     print,'Syntax - Get_date, dte'
     print,'  dte - 8 character output string giving current date'
     return
 endif

 mn = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct', $
       'Nov','Dec']

 st = !STIME
 day = strmid(st,0,2)
 month = strmid(st,3,3)
 month = where(mn EQ month) + 1
 yr = strmid(st,9,2)

 dte =  string(day,f='(I2.2)') + '/' + string(month,f='(i2.2)') + '/' + yr
 
 return
 end
