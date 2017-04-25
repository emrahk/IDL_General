pro rd_gxd, input1, input2, gxd_data, indir=indir, status=status, $
	nearest=nearest, vnum=vnum, full_weeks=full_weeks, qdebug=qdebug, $
	goes6=goes6, goes7=goes7, goes8=goes8, goes9=goes9,_extra=extra, 		$
	one_minute=one_minute, five_minute=five_minute, $
        goes10=goes10, goes12=goes12 , remote=remote, check_sdac=check_sdac
;+
;NAME:
;	rd_gxd
;PURPOSE:
;	Read the GXD type files (GOES 3 sec light curve data files for
;	S/C 6,7,8,9, or derived 1 minute average data files).  Default is
;	to read 3 sec data for spacecraft 7.
;CALLING SEQUENCE:
;	rd_gxd, roadmap(0),  roadmap(n), gxd_data
;	rd_gxd, '1-dec-91', '30-dec-91', gxd_data
;	rd_gxd,      weeks,       years, gxd_data
;INPUT:
;		  INPUT CAN BE OF TWO FORMS
;
;		  (A) Input starting and ending times
;	input1	- Starting time in either (i) standard string format,
;		  or (ii) a structure with .time and .day fields
;		  (the 7 element time vector form is not allowed)
;	input2	- Ending time.  If ending time is omitted, the
;		  ending time is set to 24 hours after starting time.
;
;		  (B) Input can be a vector of week/year number
;	input1	- a vector of the week numbers to read
;	input2	- a vector of the year of the week to be read
;		  if the weeks vector is all within one year, the
;		  year parameter can be a scalar.
;OUTPUT:
;	data	- the data structure containing the data in the files
;		  See the structure definition for further information
;OPTIONAL KEYWORD INPUT:
;	goes6	- If set, use 3 sec data for GOES spacecraft 6
;	goes7	- If set, use 3 sec data for GOES spacecraft 7
;	goes8	- If set, use 3 sec data for GOES spacecraft 8
;	goes9	- If set, use 3 sec data for GOES spacecraft 9
;       goes10  - If set, use 3 sec data for GOES 10
;       goes12  - If set, use 3 sec data for GOES 12
;       goes11(13,14,15...) - via inherit /GOESxx
;	one_minute- If set, use 1 minute average light curve data derived
;		  from 3 sec digitial data.
;	five_minute- If set, use 5 minute average light curve data derived
;		  from 3 sec digitial data.
;
;	indir	- Input directory of data files.  If not present, use
;		  $DIR_GEN_xxx logical directory
;	vnum	- The file version number to use.  If not present, a call
;		  to WEEKID is made and that latest version is used.
;	nearest	- If set, then the time span is adjusted a day at a time
;		  until it finds some data.  It decrements the starting
;		  date by a day and increments the ending date by a day
;		  up to 14 days (28 day total span)
;       full_weeks - If set, then do not extract the entries that just
;                 cover the times covered in the start/end time.  Return
;                 all data for weeks covered by the start/end time. This
;                 allows a user to have start and end time be the same
;                 and still get some data.
;       remote - if set, force remote (even if local data was found...) - testing.
;       check_sdac - if set, when no data found in yohkoh files, check sdac files. Default=1.
;
;OPTIONAL KEYWORD OUTPUT:
;	status	- The read status
;		  Some data is available if (status le 0)
;			 0 = no error
;			 1 = cannot find the file
;			 2 = cannot find data in the time period
;			-1 = found data, but had to go outside of the requested
;			     period (only true if /NEAREST is used).  
;HISTORY:
;	Written 15-Apr-93 by M.Morrison
;	15-Aug-94 (MDM) - Added ;+ to the header
;       29-aug-95 (SLF) - Added ONE_MINUTE and FIVE_MINUTE keyword and function
;        2-apr-96 (SLF) - Add GOES8 and GOES9 support
;	30-Oct-96 (RDB) - Default to GOES9 if start date is after 1-Jul-96
;       21-Jul-98 (SLF) - update for GOES10
;        8-APR-2003  (SLF) - update for GOES12
;       16-Apr-2003 (SLF) - enhanced time dependent defaults a bit
;       17-Jan-2006 (DMZ) - added _EXTRA for pass thru keywords
;        4-May-2007 (SLF) - added GOES11 (13,14,15.. for later)
;       11-apr-2011 (SLF) - try remote if nothing found in local $SSWDB
;       6-Jun-2011 (Kim Tolbert) - added check_sdac keyword
;       20-Jan-2012 (Zarro) - passed REMOTE keyword to RD_WEEK_FILE
;-
;

checkvar, check_sdac, 1

case 1 of 
   keyword_set(one_minute):suffix='1'	; one minute averages
   keyword_set(five_minute):suffix='5'  ; five minute averages
   else: suffix='D'			; default is 3 second files
endcase

sz = size(input1)
typ = sz(sz(0)+1)
if typ eq 7 or typ eq 8 then $
  date1 = anytim2ints(input1) $			;normally string or structure
else begin
  date1 = week2ex(input2(0),input1(0))		;assume week,year
  date1 = anytim2ints(date1)
endelse
     
case 1 of 
   keyword_set(goes6): gsat='6'
   keyword_set(goes7): gsat='7'
   keyword_set(goes8): gsat='8'
   keyword_set(goes9): gsat='9'
   keyword_set(goes10): gsat='0'
   keyword_set(goes12): gsat='2'
   data_chk(extra,/struct): begin
      tnames=tag_names(extra)
      ssg=where(strpos(tnames,'G') ne -1,gcnt)
      if gcnt gt 0 then gsat=strlastchar(tnames(ssg(0)))
   endcase
   else:
endcase 
if n_elements(gsat) eq 0 then begin 
   gsat=strlastchar(get_goes_defsat(input2,/string_ret))
   print,'trying GOES'+gsat
endif

;	Note: Will have problems if start is before and end date is well 
;	after the changeover date!! (RDB)
prefix='G' + gsat + suffix

;
rd_week_file, input1, input2, prefix, gxd_data, $
	vnum=vnum, indir=indir, nearest=nearest, status=status, $
	full_weeks=full_weeks, qdebug=qdebug,_extra=extra,remote=remote
;
if check_sdac and (~data_chk(gxd_data,/struct) or keyword_set(remote)) then begin 
   box_message,'trying fits/remote'
   ;get best guess at first satellite
   sat=get_goes_defsat(input1)
   rd_gxd_fits,input1, input2, gxd_data,sat=sat,_extra=_extra, /sdac,/remote
endif 

end
