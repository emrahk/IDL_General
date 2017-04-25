pro rd_gev, input1, input2, gev_data, indir=indir, status=status, $
	nearest=nearest, vnum=vnum, full_weeks=full_weeks, qdebug=qdebug, $
        genx=genx, ngdc=ngdc
;
;NAME:
;	rd_gev
;PURPOSE:
;	Read the GEV files (GOES Event Log Files)
;CALLING SEQUENCE:
;	rd_gev, roadmap(0),  roadmap(n), gev_data
;	rd_gev, '1-dec-91', '30-dec-91', gev_data
;	rd_gev,      weeks,       years, gev_data
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
;       ngdc (switch) - if set, read the 'genx' catalog derived
;                 from the NGDC (may eventually merge with release 'gev')
;                 assumes $SSWDB/ngdc/xray_events_genx installed
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
;	Written Jun-92 by M.Morrison
;	5-Apr-93 (MDM) - Modified to use RD_WEEK_FILE
;	7-Apr-93 (MDM) - Added FULL_WEEKS and QDEBUG options
;      27-oct-2004 - S.L.Freeland - add /NGDC keyword and function
;                    (set ngdc to default globally via:
;                    IDL> set_logenv,'ssw_ngdc_gev','1'
; Restrictions: 
;    Not all keywords supported for NGDC (via read_Genxcat.pro)
;-
;
ngdc=keyword_set(ngdc) or keyword_set(genx) or (get_logenv('ssw_ngdc_gev') ne '')
if ngdc then begin 
   genxdir=concat_dir('$SSWDB','ngdc/xray_events_genx')
   chkfils=findfile(genxdir)
   if chkfils(0) eq '' then begin
      status=1
      box_message,['You do not have NGDC xray events genx cat','','Try:...', $
         'IDL> sswdb_upgrade,"ngdc/xray_events_genx",/spawn,/loud']
      return
   endif
   read_genxcat,input1,input2,gev_data , status=status,topdir=genxdir
   status=1-status ; closer match to rd_gev STATUS interpretation
   
endif else begin 
   rd_week_file, input1, input2, 'GEV', gev_data, $
	vnum=vnum, indir=indir, nearest=nearest, status=status, $
	full_weeks=full_weeks, qdebug=qdebug
endelse
;
end
