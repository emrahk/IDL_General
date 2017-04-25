FUNCTION itool_getfile, start_cur, stop_cur, path, count=count, $
              dlog=dlog, start_date=start_date, end_date=end_date
;+
; PROJECT:
;       SOHO
;
; NAME:
;       ITOOL_GETFILE()
;
; PURPOSE: 
;       Get list of files for given dates and path
;
; CATEGORY:
;       IMAGE_TOOL, utility
; 
; SYNTAX: 
;       Result = itool_getfile(start, stop, path)
;
; INPUTS:
;       START - Starting date, in YYYY/MM/DD format
;       STOP  - End date, in YYYY/MM/DD format
;       PATH  - Complete directory path in which data reside
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       RESULT - String array or scalar, containing the file list
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS: 
;       COUNT      - Number of files returned
;       DLOG       - Modified dlog
;       START_DATE - Modified start date
;       END_DATE   - Modified end date
;
; COMMON:
;       None.
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, January 15, 1997, Liyun Wang, NASA/GSFC. Written
;       Version 2, May 20 1998, Zarro (SAC/GSFC) - added call to RSTRMID
;       Version 3, July 23 2001, Zarro (EITI/GSFC) - sped up file search
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 2

;---------------------------------------------------------------------------
;  Get files in directory specified by PATH month by month
;---------------------------------------------------------------------------
   start_tmp = str2arr(start_cur, '/')
   stop_tmp = str2arr(stop_cur, '/')

   file_found = ''
   IF start_tmp(0) EQ stop_tmp(0) THEN BEGIN
;---------------------------------------------------------------------------
;     searching period in the same year boundary
;---------------------------------------------------------------------------
      n_month = FIX(stop_tmp(1))-FIX(start_tmp(1))
      FOR i=0, n_month DO BEGIN
         cmonth = STRING(FIX(start_tmp(1)+i), format='(i2.2)')
         filter = '*'+start_tmp(0)+cmonth+'*.*'
         dprint,'% ITOOL_GETFILE: ',filter
         file_found = [temporary(file_found), loc_file(concat_dir(path, filter),/recheck)]
      ENDFOR
   ENDIF ELSE BEGIN
;---------------------------------------------------------------------------
;     searching period crosses year boundary
;---------------------------------------------------------------------------
      cur_year = FIX(start_tmp(0))
      cur_month = FIX(start_tmp(1))-1
      end_year=FIX(stop_tmp(0))
      end_month=FIX(stop_tmp(1))
      not_done = 1
      WHILE (not_done) DO BEGIN
         cur_month = cur_month+1
         IF cur_month GT 12 THEN BEGIN
            cur_year = cur_year+1
            cur_month = 1
         ENDIF
         yearstr = STRING(cur_year, format='(i4.4)')
         monthstr = STRING(cur_month, format='(i2.2)')
         filter = '*'+yearstr+monthstr+'*.*'
         file_found = [temporary(file_found), loc_file(concat_dir(path, filter),/recheck)]
         IF cur_year EQ end_year AND cur_month EQ end_month THEN $
            not_done=0
      ENDWHILE
   ENDELSE

   count = N_ELEMENTS(file_found)
   if is_blank(file_found) then begin
    count=0
    file_found=''
   endif
   IF count GT 1 THEN BEGIN
      file_found = file_found(1:*)
      count = count-1
   ENDIF ELSE count = 0
   
;---------------------------------------------------------------------------
;  Further filter out those files which do not fall in the specified time
;  period
;---------------------------------------------------------------------------

   start_date = date_code(start_cur)
   end_date=date_code(stop_cur)
   IF count GT 0 THEN BEGIN
    break_file, file_found(0), dlog
    ftimes=fid2time(file_found,/tai)
    ts=anytim2tai(start_cur)
    te=anytim2utc(stop_cur)
    if te.time eq 0 then te.mjd=te.mjd+1
    te=anytim2tai(te)
    chk=where( (ftimes ge ts) and (ftimes le te), count)
    if count gt 1 then begin
     ftimes=ftimes(chk)
     file_found=file_found(chk) 
     jj=bsort(ftimes,/rev)
     file_found=file_found(jj)
    endif
   ENDIF
   if count eq 0 then file_found=''
   return,file_found
    
END


