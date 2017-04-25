; ------------------------------------------------------------
function select_menu, menu, item
;
; "set" selected item in a FORMs pulldown menu

omenu=menu
keyword='<OPTION>'
select='<OPTION SELECTED>'
iitem=strcapitalize(strtrim(item,2))
imenu=strcapitalize(strtrim(strmid(menu,8,80),2))
ss=where(iitem eq imenu ,sscnt)
if sscnt gt 0 then omenu(ss(0))=str_replace(omenu(ss(0)),keyword,select)
return,omenu
end
; ------------------------------------------------------------

function mk_formt_html, start_select, stop_select, $
   varname=varname, outfile=outfile, title=title, action=action, himg=himg, $
   notime=notime, nostop=nostop, t0=t0, t1=t1, timerange=timerange
;+
;   Name: mk_formt_html
;
;   Purpose: make FORM-ready html segment for times (start [and stop])
;
;   Input Paramters:
;      start_select - set default start time
;      stop_select  - set default stop time
;
;   Calling Sequence:
;      outarray=mk_formt_html(start_select [,stop_select], t0=tim0, t1=tim1)
;
;   History:
;      1-Jan-1996 (Circa) - S.L.Freeland - for auto-WWW FORM generation
;     12-Jan-1997         - S.L.Freeland - head off millenium crisis
;                                          (call anytim)
;                                          auto-range if select times
;                                          not within TIMERANGE
;-
; form generic string menus for dates
mins=string(lindgen(6)*10,format='(i2.2)')
hours=string(indgen(24),format='(i2.2)')
days=string(indgen(31)+1,format='(i2)')
months=strcapitalize(strmid(timegrid('1-jan','30-dec',day=32,/string),3,3))
today=ut_time()

if n_elements(timerange) eq 2 then begin
   t0=timerange(0)
   t1=timerange(1)
endif

; ------------- if title supplied, include FORM header and setup HTML
if keyword_set(title) then begin
   header=['<html>','<head>','<title>' + title,'</head>','<body>']
   if data_chk(himg,/string) then header=[header, $
   'IMG SRC="'+himg+'">']
   header=[header,'<h1>'+title+'</h1>','<hr>']
   if data_chk(action,/string) then header=[header, $
      '<FORM METHOD="POST" ACTION="' + action + '">']
endif else header=''

; ---------------------------------------------------------------------
if n_elements(t0) eq 0 then t0='1-jan-1990'
if n_elements(t1) eq 0 then t1='31-dec-1999'
t0=anytim(t0,out='ecs',/trunc)
t1=anytim(t1,out='ecs',/trunc)

if n_elements(start_select) eq 0 then start_select=t0 else $
   start_select=fmt_tim(start_select)
if n_elements(stop_select) eq 0 then stop_select=t1 else $
   stop_select=fmt_tim(stop_select)

start_select=anytim(start_select,out='ecs',/trunc)
stop_select=anytim(stop_select,out='ecs',/trunc)

yr1=min(long(strmid([t0,start_select],0,4)))
yr2=max(long(strmid([t1,stop_select],0,4)))
years=string(lindgen(yr2-yr1+1)+yr1,format='(i4.4)')

; ------- start day menu ------------
mmin='<OPTION> ' + mins
mhour='<OPTION> ' + hours
mdays='<OPTION> '  + days
mmonths='<OPTION> ' + months
myears='<OPTION> '  + years

startarr=str2arr(anytim(start_select,out='vms',/date_only),'-')
sdays=select_menu(mdays,startarr(0))
smonths=select_menu(mmonths,startarr(1))
syears=select_menu(myears,string((fix((str2arr(startarr(2),' '))(0))) mod 1900)+1900)
; ------------------------------------

; ------- stop day menu ----------------
endarr=str2arr(anytim(stop_select,out='vms',/date_only),'-')

edays=select_menu(mdays,endarr(0))
emonths=select_menu(mmonths,endarr(1))
eyears=select_menu(myears,string((fix((str2arr(endarr(2),' '))(0))) mod 1900)+1900)

; ---------------------------------------
thead=(["Time:",""])(keyword_set(nohead))
dhead=(["Date:",""])(keyword_set(nohead))

start_menu=[dhead,					$
          '<SELECT NAME="start_day">',sdays,'</SELECT>', $
          '<SELECT NAME="start_month">',smonths,'</SELECT>', $
          '<SELECT NAME="start_year">',syears,'</SELECT>']

if not keyword_set(notime) then start_menu= $
          [thead,					$
          '<SELECT NAME="start_hour">',mhour,'</SELECT>','<b>:</b>', $
          '<SELECT NAME="start_min">',mmin,'</SELECT>', start_menu]

if data_chk(varname,/string) then $
   start_menu=str_replace(start_menu,"start_",varname+"_")

stop_menu =[dhead,					$
          '<SELECT NAME="stop_day">',edays,'</SELECT>', $
          '<SELECT NAME="stop_month">',emonths,'</SELECT>', $
          '<SELECT NAME="stop_year">',eyears,'</SELECT>']

if not keyword_set(notime) then stop_menu= [thead,		$
          '<SELECT NAME="stop_hour">',mhour,'</SELECT>','<b>:</b>', $
          '<SELECT NAME="stop_min">',mmin,'</SELECT>', stop_menu]

nostop=keyword_set(nostop) or keyword_set(varname)
if n_elements(varname) eq 0 then varname="Start"
body=[strcapitalize(varname),start_menu]

if not keyword_set(nostop) then body=[body, "<p>Stop",stop_menu]

retval=[header,body]

return, retval
end
