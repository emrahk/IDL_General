PRO PHAGEN, FILENAME=file, DETNAM=Detnam, EXPOSURE=Exposure, $
            Channels, Counts, Quality, Comments, METstarts=METstarts,$          
             METstops=METstops,VERBOSE=ver,back=back,rmfile=rmfile,$
              arfile=arfile
;*****************************************************************************
; Forms an OGIP-standard HEXTE PHA Count spectrum given channels and counts
; Parameters:
; Detnam   (<) (string) - HEXTE detector name, eg. "PWA0", or "PWB3"
; Channels (<) (FLTARR(npha)) - array of detector channel #s
; Counts   (<) (FLTARR(npha)) - array of COUNT data
; Quality  (<) (INTARR(npha)) - OGIP standard quality flags for data (0=good)
; Exposure (<) (float) - livetime for the count data
; Comments (<) (STRARR(ncomm)) - strings for the "COMMENTS" field.
; METstarts=METstarts (<) (FLTARR(ngti)) - optional array of start times
; METstops=METstops (<) (FLTARR(ngti)) - optional array of stop times
; VERBOSE=ver (<) (Logical) - if set, verbose output is enabled.
; Routine calls:
; Note: All of these are from the NASA/GSFC IDL Astronomy collection's
; "IDL Software for FITS Binary Tables", by W. Thompson.
; avaliable by anonymous ftp from idlastro.gsfc.nasa.gov. 
; FXADDPAR - adds or replaces a keyword in a FITS header string array
; FXBADDCOL - adds column keywords to a FITS header string array
; FXBCREATE - writes a FITS binary extension header string array to a file
; FXBHMAKE - creates a binary table extension header string array
; FXBWRITE - writes rows to a FITS binary extension
; FXBFINISH - finishes off and closes a FITS file binary extension
; FXHMAKE - create a FITS  format header string array from scratch
; FXWRITE - writes a FITS primary header string array to a file
;*****************************************************************************
PROGNAME='PHAGEN v1.3'
Syntax = 'PHAGEN, FILENAME=file, DETNAM=Detnam, EXPOSURE=Exposure, '  + $
        'Channels, Counts, Quality, [Comments=], [METstarts=METstarts],' + $ 
         '[METstops=METstops],[arfile=],[rmfile=],[back=]'
IF N_PARAMS() EQ 0 THEN BEGIN
   PRINT, 'Syntax: ', Syntax
   RETURN
ENDIF
counts = long(counts)
npha = N_ELEMENTS(Channels)
fn = strcompress(file,/remove_all)
IF KEYWORD_SET(ver) THEN MESSAGE, 'Creating the primary FITS header...', /INFO
FXHMAKE, header, /INITIALIZE, /EXTEND, /DATE
FXADDPAR, header, 'CONTENT', 'SPECTRUM', $
                             'File contains spectral data'
FXADDPAR, header, 'AUTHOR', 'HEXTE GROUP CASS/UCSD', $
                            'Author of this file'
FXADDPAR, header, 'CREATOR', STRTRIM(PROGNAME,2), $
                             'Software that generated this file'
FXADDPAR, header, 'ORIGIN', 'HEXTE/UCSD', $
                            'Organization which created this file'

IF KEYWORD_SET(ver) THEN MESSAGE, 'Writing the primary header to '+FILE+'...', /INFO
FXWRITE, FILE, header

IF KEYWORD_SET(ver) THEN MESSAGE, 'Creating the SPECTRUM extension header...', /INFO
FXBHMAKE, header, npha, 'SPECTRUM', 'name of this binary table extension', /INIT
IF KEYWORD_SET(ver) THEN MESSAGE, 'Adding columns to the SPECTRUM extension header...', /INFO
FXBADDCOL, chancol, header, INTARR(1), 'CHANNEL', 'label for field 1'
FXBADDCOL, countcol, header, LONARR(1), 'COUNTS', 'label for field 2'
FXADDPAR, header, 'TUNIT2', 'count', 'units for field 2'
FXBADDCOL, qualcol, header, INTARR(1), 'QUALITY', 'label for field 3'
IF KEYWORD_SET(ver) THEN MESSAGE, 'Adding keywords to the SPECTRUM extension header...', /INFO
FXADDPAR, header, 'TELESCOP', 'XTE', 'mission/satellite name'
FXADDPAR, header, 'INSTRUME', 'HEXTE', 'instrument'
FXADDPAR, header, 'DETNAM', STRTRIM(Detnam,2), 'Detector name'
FXADDPAR, header, 'FILTER', 'NONE', 'filter information'
FXADDPAR, header, 'CHANTYPE', 'PHA', 'Type of channels (PHA, PI etc.)'
FXADDPAR, header, 'DETCHANS', npha, 'Total number of detector channels'
FXADDPAR, header, 'TLMIN1', 0, 'minimum valid channel'
FXADDPAR, header, 'TLMAX1', Channels(npha-1), 'maximum valid channel'
FXADDPAR, header, 'AREASCAL', 1.0, 'Area scaling factor'
FXADDPAR, header, 'BACKSCAL', 1.0, 'Background scaling factor'
FXADDPAR, header, 'CORRSCAL', 0.0, 'Correction scaling factor'
de = strlowcase(detnam)
if (n_elements(rmfile) eq 0)then respfile = strcompress('hexte_'+de+'.rmf') $ 
else respfile = rmfile
if (n_elements(arfile) eq 0)then ancrfile = strcompress('hexte_'+de+'.arf') $ 
else ancrfile = arfile
if (n_elements(back) eq 0)then $
backfile = strmid(file,0,strpos(file,'.')) + '.bak' $
else backfile = back
FXADDPAR, header, 'RESPFILE',respfile, 'name of response file'
FXADDPAR, header, 'ANCRFILE',ancrfile, 'name of ancillary file'
FXADDPAR, header, 'BACKFILE',backfile, 'name of background file'
FXADDPAR, header, 'CORRFILE', 'none', 'name of correction file'
FXADDPAR, header, 'POISSERR', 'T', $
                  'Poissonian statistical errors to be assumed'
FXADDPAR, header, 'STAT_ERR', 'T', $
                  'No statistical specified'
FXADDPAR, header, 'SYS_ERR', 0, $
                  'no systematic error specified'
FXADDPAR, header, 'GROUPING', 0, 'No grouping specified'
FXADDPAR, header, 'OBJECT', 'none', 'Object observed'
FXADDPAR, header, 'EXPOSURE', FLOAT(Exposure), 'Livetime (sec)'
ngti = N_ELEMENTS(METstarts)
IF (ngti GT 0) THEN BEGIN
   tstart = MIN(METstarts) 
   tstop = MAX(METstops)
   FXADDPAR, header, 'TSTART', tstart, 'Start time'
   FXADDPAR, header, 'TSTOP', tstop, 'Stop time'
ENDIF   
;******************************************************************************   ; (SPECTRUM) New OGIP keywords
;******************************************************************************
FXADDPAR, header, 'HDUCLASS', 'OGIP', 'organization'
FXADDPAR, header, 'HDUCLAS1', 'SPECTRUM', 'PHA dataset (OGIP memo OGIP-92-007)"
;; FXADDPAR, header, 'HDUCLAS2', 'BKG', 'spectrum is background data'
FXADDPAR, header, 'HDUCLAS3', 'COUNT', 'data is stored as counts'
FXADDPAR, header, 'HDUVERS1', '1.1.0', 'version of format (OGIP memo OGIP-92-007a)'
FXADDPAR, header, 'CREATOR', STRTRIM(PROGNAME,2), $
                             'Software that generated this file'
;*****************************************************************************
; Add the comments (if any) to the FITS header
;*****************************************************************************
ncomm = N_ELEMENTS(Comments)
if (ncomm GT 0) THEN $
   FOR i=0, ncomm-1 DO FXADDPAR, header, 'COMMENT', Comments(i), " "
;*****************************************************************************
; Write out the header to the file
;*****************************************************************************
IF KEYWORD_SET(ver) THEN MESSAGE, 'Writing the SPECTRUM extension header to '+STRTRIM(FILE,2)+'...',/INFO
FXBCREATE, unit, file, header
IF KEYWORD_SET(ver) THEN MESSAGE, 'Writing the columns of the SPECTRUM extension', /INFO
FOR i=0, npha-1 DO BEGIN
  FXBWRITE, unit, Channels(i), chancol, i+1
  FXBWRITE, unit, Counts(i), countcol, i+1
  FXBWRITE, unit, quality(i), qualcol, i+1
ENDFOR
FXBFINISH, unit
IF KEYWORD_SET(ver) THEN MESSAGE, 'PHA extension of '+STRTRIM(FILE)+' complete.', /INFO
IF ngti EQ 0 THEN RETURN
;*****************************************************************************
; From now on, assume that we have a GTI extension to write.
;*****************************************************************************
FXBHMAKE, gtiheader, ngti, 'STDGTI', 'name of this binary extension', /INIT
FXBADDCOL, tstart_col, gtiheader, 0.0D0, 'START', 'label for field 1'
FXBADDCOL, tstop_col, gtiheader, 0.0D0, 'STOP', 'label for field 2'
FXADDPAR, gtiheader, 'TUNIT1', 's', 'units of field 1'
FXADDPAR, gtiheader, 'TUNIT2', 's', 'units of field 2'
FXADDPAR, gtiheader, 'HDUCLASS', 'OGIP', 'format conforms to OGIP/GSFC standards'
FXADDPAR, gtiheader, 'HDUCLAS1', 'GTI', 'Extension contains Good Time Intervals'
FXADDPAR, gtiheader, 'HDUCLAS2', 'ALL', 'Extension contains Good Time Intervals'
FXADDPAR, gtiheader, 'INSTRUME', 'HEXTE', 'Instrument used for observation'
FXADDPAR, gtiheader, 'TELESCOP', 'XTE', 'Observatory which generated these data'
FXADDPAR, gtiheader, 'TSTART', tstart, 'Observation start time'
FXADDPAR, gtiheader, 'TSTOP', tstop, 'Observation stop time'
FXADDPAR, gtiheader, 'ONTIME', DOUBLE(TOTAL(METstops - METstarts)), 'time on source'
FXADDPAR, gtiheader, 'TIME-SYS', 'MET', 'Time system in use: Mission Elapsed Time'
FXADDPAR, gtiheader, 'TIMEUNIT', 's', 'Time units in use'
FXBCREATE, unit, file, gtiheader
;*****************************************************************************
; Write the extension
;*****************************************************************************
FOR i=0, ngti-1 DO BEGIN
  FXBWRITE, unit, DOUBLE(METstarts(i)), tstart_col, i+1
  FXBWRITE, unit, DOUBLE(METstops(i)), tstop_col, i+1
ENDFOR
;*****************************************************************************
; That's it
;*****************************************************************************
FXBFINISH, unit
IF KEYWORD_SET(ver) THEN MESSAGE, 'STDGTI extension of '+STRTRIM(FILE)+' complete.', /INFO
RETURN
END
