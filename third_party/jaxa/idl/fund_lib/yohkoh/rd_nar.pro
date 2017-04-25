pro rd_nar, input1, input2, nar_data, indir=indir, status=status, $
	nearest=nearest, vnum=vnum, full_weeks=full_weeks, qdebug=qdebug
;
;NAME:
;	rd_nar
;PURPOSE:
;	Read the NAR files (NOAA Active Region files)
;CALLING SEQUENCE:
;	rd_nar, roadmap(0),  roadmap(n), nar_data
;	rd_nar, '1-dec-91', '30-dec-91', nar_data
;	rd_nar,      weeks,       years, nar_data
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
;-
;
rd_week_file, input1, input2, 'NAR', nar_data, $
	vnum=vnum, indir=indir, nearest=nearest, status=status, $
	full_weeks=full_weeks, qdebug=qdebug
;
end
