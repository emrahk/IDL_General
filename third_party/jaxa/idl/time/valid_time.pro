;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       VALID_TIME()
;
; PURPOSE:
;       To test if the given time has the valid format
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;       Result = valid_time(time [, err, /zero])
;
; INPUTS:
;       time - Any date/time format
;
; INPUT KEYWORDS:
;       zero - if set, 0 is a valid time.
;
; OUTPUTS:
;       Result - 1 if the time format is valid, 0 otherwise
;
; OPTIONAL OUTPUTS:
;       ERR  - A string scalar containing err message. If the time format
;                is correct, ERR will be a null string
;
; CATEGORY: time
;
; PREVIOUS HISTORY:
;       Written May 5, 1995, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, GSFC/ARC, May 5, 1995
;       Version 2, vectorized, Zarro (SM&A/GSFC), April 9, 2000
;       Version 3, added check for non-string input, Zarro (LAC/GSFC), August 1, 2002
;       Version 4, added zero keyword, Kim, June 15, 2005
;       Modified, 28-Dec-2005, Zarro (L-3Com/GSFC) - improved
;       6-Jan-2014, Zarro (ADNET) - changed "not" to "~'
;
;-

   function valid_time, time, err2,count=count,err=err, zero=zero

   count=0
   err = ''
   nt=n_elements(time)
   if nt eq 0 then begin
    err = 'syntax: aa = valid_time(time)'
    err2=err
    return,0b
   endif

   bool=bytarr(nt) & err=strarr(nt)
   for i=0,nt-1 do begin
    terr='' & stime=time[i]
    if ~is_string(stime) then begin
     if is_number(stime) then begin
      if (stime le 0) and ~keyword_set(zero) then terr='Input time must be > 0' else stime=double(stime)
     endif
    endif
    if (terr eq '') then begin
     sz=size(stime)
     dtype=sz[n_elements(sz)-2]
     if (dtype eq 7) then if (trim(stime) eq '') then terr='Input time must be non-blank'
    endif
    if (terr eq '') then begin
     temp = anytim2utc(stime, err = terr)
     terr=trim(terr)
    endif
    bool[i]=terr eq ''
    have=where(terr eq err,count)
    if count eq 0 then err[i]=terr
   endfor
   err=trim2(arr2str(terr))
   if nt eq 1 then bool=bool[0]
   chk=where(bool,count)
   err2=err
   return,bool
   end


