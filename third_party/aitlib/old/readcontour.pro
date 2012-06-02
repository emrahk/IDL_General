PRO readcontour,datei,par1,par2,chi
;+
; NAME:
;       readcontour
;
;
; PURPOSE:
;       reads a logfile created by XSPEC containing the output while
;       steppar was running. readcontour returns the read values in
;       arrays which can be plotted with plotcontour
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;       readcontour,filename,par1,par2,chi
;
; 
; INPUTS:
;       filename : the name of the logfile
;
;
; OPTIONAL INPUTS:
;
;
;	
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;       par1 : array containing the values of stepping parameter 1
;       par2 : array containing the values of stepping parameter 2
;       chi  : array containing the values of chisquare belonging to
;              the above apramters
;
;
; RESTRICTIONS:
;       the logfile has to be created just before the steppar command and
;       closed as soon as steppar is finished. All Text inside is
;       detected and ignored but the log file must not containg lots
;       of ordinary XSPEC output.
;
;
; PROCEDURE:
;       a line is read from the log file and searched for illegal
;       contents like 'Number of trials exceeded -'. Those lines are
;       ignored. The others are split into three columns : parameter
;       1, 2 and chisquare
;
;
; EXAMPLE:
;      create a log file as described above
;      readcontour,'test.log',par1,par2,chi
;
;
; MODIFICATION HISTORY:
;       written 1996 by Ingo Kreykenbohm
;-

;; open file for reading
openr,unit,datei,/get_lun

;; initialize some variables
tchi = fltarr(20000) ;ATTENTION : 20000 is maximum number of elements.
tpar1 = tchi
tpar2 = tpar1
zeile = string('a')
text = intarr(5)
c = 0

;; read in a line and check for some keywords. If these are found this
;; line is not transformed into a value. This is improtant because
;; XSPEC produces lines like "Number of trials exceeded - last
;; iteration delta = ...". These must be removed.

WHILE (NOT eof(unit)) DO BEGIN 
    readf,unit,zeile
    zeile = strlowcase(zeile)
    text(0) = strpos(zeile,'due')
    text(1) = strpos(zeile,'is')
    text(2) = strpos(zeile,'of')
    text(3) = strpos(zeile,'xspec')
    text(4) = strpos(zeile,'chi')

    idx = where(text NE -1)
    IF (idx(0) EQ -1) THEN BEGIN 
        p = str_sep(zeile,' ')
        idx = where(strlen(p) gt 1)
        IF (idx(0) NE -1) THEN BEGIN 
            tchi(c) = float(p(idx(0)))
            tpar1(c) = float(p(idx(2)))
            tpar2(c) = float(p(idx(3)))
            c=c+1
        ENDIF 
    ENDIF 
ENDWHILE 

;; create new arrays without trailing 0's

chi = tchi(0:c-1)
par1 = tpar1(0:c-1)
par2 = tpar2(0:c-1)

END 
