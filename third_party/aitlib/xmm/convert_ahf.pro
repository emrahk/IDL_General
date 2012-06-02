PRO convert_ahf,ascii, fits,preq=preq

;+
; NAME: 
;           convert_ahf
;        
;
;
; PURPOSE: 
;           read in ascii XMM attitude history file, 
;           write out fits file
;        
;
;
; CATEGORY: 
;           IAAT XMM tools
;
;
; CALLING SEQUENCE: 
;           convert_ahf, ascii, fits
;
;
;
; INPUTS: 
;        ascii - File name of ascii input file, string. 
;                File must obey structure of XMM attitude history file.
;                Refer XMM-MOC-ICD-0006-OAD.
;
;
; OPTIONAL INPUTS:
;        preq - Pointing request identifier (integer) of records which
;               only should be written into the fits file. 
;               This option may be used to select a single pointing 
;               sequence from the entire attitude history file
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;               fits - fits output file name, string.
;                      Fits file contains data as read in from ascii 
;                      input file
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;                 Reading in from LUN 2 which must not be used for
;                 other purposes. (yeah, for convenience and stupid
;                 time sparing reasons). 
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:                                        
;           convert_ahf, 'new_ahf.txt', 'AttHK.ds'
;
;
;
; MODIFICATION HISTORY:
;           Created: 2001/04/09, Eckart Goehler
;
;-




t1="        "
t2="        "
t3="        "
sw_ver_num="          "
space="              "

PREQID=  "              "
TYPEID=  " "
SOURCEID=" "
ATTSEQNO=0
SLEWTIME="                    "
PTTIME=  "                    "
VALTIME= "                    "
VALDUR=0.0
OTFTHRES=0.0
VIEWRA=  "           "
VIEWDECL="           "
ASTPOS=0.0
ROLLANG=0.0
GSREFNO= "            "
GSRA=    "           "
GSDEC=   "           "
ASPANGLE=0.0
ACFLAG=BYTE(0)
APDAMP=  "     "
DIFFVRA= "           "
DIFFVDEC="           "
DIFFPOS= "           "



; internal:
ROW=0       ; number of rows
J=1         ; row counter
RECORDS = 0 ; total record counter 



; start reading to get row number:
openr, 2, ascii

; read header:
readf,2, t1,          $ ;start time
         t2,          $ ;end time
         t3,          $ ;valid time
         rev_num,     $ ;revolution number     
         rec_num,     $ ;number of records
         ver_num,     $ ;version number
         sw_ver_num,  $ ;s/w version number
         space,       $ ;space for comments
         format='(A20,1X,A20,1X,A20,1X,I4.4,1X,I6,1X,I4.4,1X,A5,1X,A150)'


; read file in once to get number of rows in fits file:
REPEAT BEGIN 
readf,2,        $
      PREQID,   $
      TYPEID,   $
      SOURCEID, $
      ATTSEQNO, $
      SLEWTIME, $
      PTTIME,   $
      VALTIME,  $
      VALDUR,   $
      OTFTHRES, $
      VIEWRA,   $
      VIEWDECL, $
      ASTPOS,   $
      ROLLANG,  $
      GSREFNO,  $
      GSRA,     $
      GSDEC,    $
      ASPANGLE, $
      ACFLAG,   $
      APDAMP,   $
      DIFFVRA,  $
      DIFFVDEC, $
      DIFFPOS,  $
                $
      format='(A14,1X, A1,1X,  A1,1X,  I3,1X,A20,1X,A20,1X,A20,1X,F9.2,1X,F5.1,1X,A11,1X,A11,1X,F11.6,1X,F10.6,1X,A12,1X,A11,1X,A11,1X,F5.1,1X,I1,1X,A5,1X,A11,1X,A11,1X,A11,1X)'

; increase row number if pointing request id matches or none required
IF  (n_elements(preq) EQ 0)  THEN     ROW = ROW + 1 ELSE $
IF (PREQID EQ preq)  THEN  ROW = ROW + 1

; count total records:
RECORDS = RECORDS+1

ENDREP UNTIL EOF(2)

close,2 

;--------------------------------------------------------------------------
; actually read in and generate fits file:
;--------------------------------------------------------------------------

; start reading:
openr, 2, ascii

; read header:
readf,2, t1,          $ ;start time
         t2,          $ ;end time
         t3,          $ ;valid time
         rev_num,     $ ;revolution number     
         rec_num,     $ ;number of records
         ver_num,     $ ;version number
         sw_ver_num,  $ ;s/w version number
         space,       $ ;space for comments
         format='(A20,1X,A20,1X,A20,1X,I4.4,1X,I6,1X,I4.4,1X,A5,1X,A150)'

; create primary fits file: 
FXHMAKE, HEADER,/INITIALIZE,/EXTEND,/DATE ; make empty header

; add relevant parameters (from XMM ICD: XMM-SOC-ICD-0004-SDD)
FXADDPAR, HEADER,'CREATOR ', 'CONVERT-AHF (IDL) 1.0','fits generation tool' 
FXADDPAR, HEADER,'TELESCOP ', 'XMM','observatory' 
FXADDPAR, HEADER,'INSTRUME ', 'SC', 'instrument is spacecraft'
FXADDPAR, HEADER,'DATATYPE ', 'ATTHIS.EL', 'File type'
;FXADDPAR, HEADER,'OBS_ID ', , 'observation ID'
FXADDPAR, HEADER,'DATE-OBS ', t1, 'observation start',format='A20'
FXADDPAR, HEADER,'DATE-END ', t2, 'observation end',format='A20'
;FXADDPAR, HEADER,'GEN-DATE ', t3, 'attitude file generation (new keyword)'

; Write out: 
FXWRITE, fits, HEADER


; make fits header with number of rows as defined above:
FXBHMAKE, HEADER, ROW, 'SCATS1 ',/INITIALIZE,/EXTVER,/EXTLEVEL


; make columns: 
FXBADDCOL,INDEX,HEADER, VALTIME, 'VALTIME ', $
                        'time from which data in this record are valid', $
                        TUNIT='yyyy-mm-ddThh:mm:ss'
FXBADDCOL,INDEX,HEADER, VALDUR, 'VALDUR ', $
                        'duration for which data in this record are valid', $
                        TUNIT='SECOND '
FXBADDCOL,INDEX,HEADER, OTFTHRES, 'OTFTHRES ', $
                        'on-target flag threshold in arc-sec', $
                        TUNIT='ARCSEC '
FXBADDCOL,INDEX,HEADER, VIEWRA, 'VIEWRA ', $
                        'right ascension in viewing direction', $
                        TUNIT='HH:MM:SS.SS '
FXBADDCOL,INDEX,HEADER, VIEWDECL, 'VIEWDECL ', $
                        'declination of viewing direction', $
                        TUNIT='DD:MM:SS.S '
FXBADDCOL,INDEX,HEADER, ASTPOS, 'ASTPOS ', $
                        'astronomical position angle in degrees', $
                        TUNIT='DEGREE '
FXBADDCOL,INDEX,HEADER, ROLLANG, 'ROLLANG ', $
                        'roll angle', $
                        TUNIT='DEGREE '
FXBADDCOL,INDEX,HEADER, GSREFNO, 'GSREFNO ', $
                        'guide star reference number in catalogue', $
                        TUNIT='    '
FXBADDCOL,INDEX,HEADER, GSRA, 'GSRA ', $
                        'guide star right ascension', $
                        TUNIT='HH:MM:SS.SS '
FXBADDCOL,INDEX,HEADER, GSDEC, 'GSDEC ', $
                        'guide star declination', $
                        TUNIT='DD:MM:SS.S '
FXBADDCOL,INDEX,HEADER, ASPANGLE, 'ASPANGLE ', $
                        'solar aspect angle', $
                        TUNIT='DEGREE '
FXBADDCOL,INDEX,HEADER, ACFLAG, ' ACFLAG', $
                        'attitude contingency flag', $
                        TUNIT='   '
FXBADDCOL,INDEX,HEADER, APDAMP, 'APDAMP ', $
                        'observable APD amplitude', $
                        TUNIT='ARCSEC '
FXBADDCOL,INDEX,HEADER, DIFFVRA, 'DIFFVRA ', $
                         'difference between reconstituted and commanded viewing direction right ascension', $
                         TUNIT='DEGREE '
FXBADDCOL,INDEX,HEADER, DIFFVDEC, 'DIFFVDEC ', $
                         'difference between reconstituted and commanded viewing direction declination', $
                         TUNIT='DEGREE '
FXBADDCOL,INDEX,HEADER, DIFFPOS, 'DIFFPOS ', $
                         'difference between reconstituted and commanded position angle', $
                         TUNIT='DEGREES '
FXBADDCOL,INDEX,HEADER, PREQID, 'PREQID ', $
                        'pointing request identifier', $
                        TUNIT='    '
FXBADDCOL,INDEX,HEADER, TYPEID, 'TYPEID', $
                        'pointing type identifier for the data', $
                        TUNIT='    '
FXBADDCOL,INDEX,HEADER, SOURCEID, 'SOURCEID ', $
                        'source identifier for the data in this record', $
                        TUNIT='     '                
FXBADDCOL,INDEX,HEADER, ATTSEQNO, 'ATTSEQNO ', $
                        'attitude sequence number', $
                        TUNIT='    '
FXBADDCOL,INDEX,HEADER, SLEWTIME, 'SLEWTIME ', $
                        'start time of the slew to the pointing-request', $
                        TUNIT='yyyy-mm-ddThh:mm:ss'
FXBADDCOL,INDEX,HEADER, PTTIME, 'PTTIME ', $
                        'start time of stable pointing period', $
                        TUNIT='yyyy-mm-ddThh:mm:ss'



; write out header, get LUN:
FXBCREATE,FITS_LUN, fits, HEADER


; read records:
FOR i=1, RECORDS DO BEGIN
readf,2,        $
      PREQID,   $
      TYPEID,   $
      SOURCEID, $
      ATTSEQNO, $
      SLEWTIME, $
      PTTIME,   $
      VALTIME,  $
      VALDUR,   $
      OTFTHRES, $
      VIEWRA,   $
      VIEWDECL, $
      ASTPOS,   $
      ROLLANG,  $
      GSREFNO,  $
      GSRA,     $
      GSDEC,    $
      ASPANGLE, $
      ACFLAG,   $
      APDAMP,   $
      DIFFVRA,  $
      DIFFVDEC, $
      DIFFPOS,  $
                $
      format='(A14,1X, A1,1X,  A1,1X,  I3,1X,A20,1X,A20,1X,A20,1X,F9.2,1X,F5.1,1X,A11,1X,A11,1X,F11.6,1X,F10.6,1X,A12,1X,A11,1X,A11,1X,F5.1,1X,I1,1X,A5,1X,A11,1X,A11,1X,A11,1X)'

; write out record if pointing request id matches or none required


write_out = 0 
IF  (n_elements(preq) EQ 0)  THEN write_out = 1      ELSE $
IF (PREQID EQ preq)  THEN  write_out = 1

IF write_out EQ 1 THEN BEGIN 
FXBWRITE, FITS_LUN, [VALTIME], 1,J
FXBWRITE, FITS_LUN, VALDUR,  2,J
FXBWRITE, FITS_LUN, OTFTHRES,3 ,J
FXBWRITE, FITS_LUN, VIEWRA,  4,J
FXBWRITE, FITS_LUN, VIEWDECL,5 ,J
FXBWRITE, FITS_LUN, ASTPOS,  6,J
FXBWRITE, FITS_LUN, ROLLANG, 7,J
FXBWRITE, FITS_LUN, GSREFNO, 8,J
FXBWRITE, FITS_LUN, GSRA,    9,J
FXBWRITE, FITS_LUN, GSDEC,   10,J
FXBWRITE, FITS_LUN, ASPANGLE,11 ,J
FXBWRITE, FITS_LUN, ACFLAG,  12,J
FXBWRITE, FITS_LUN, APDAMP,  13,J
FXBWRITE, FITS_LUN, DIFFVRA, 14 ,J
FXBWRITE, FITS_LUN, DIFFVDEC, 15,J
FXBWRITE, FITS_LUN, DIFFPOS, 16,J
FXBWRITE, FITS_LUN, PREQID,  17,J
FXBWRITE, FITS_LUN, TYPEID,  18,J
FXBWRITE, FITS_LUN, SOURCEID, 19,J
FXBWRITE, FITS_LUN, ATTSEQNO, 20,J
FXBWRITE, FITS_LUN, SLEWTIME, 21,J
FXBWRITE, FITS_LUN, PTTIME,   22,J
J = J +1  ; next row
ENDIF 

ENDFOR


; close fits file:
FXBFINISH,FITS_LUN

; close input file:
close, 2
END
