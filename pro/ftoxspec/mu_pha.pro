PRO MU_PHA,POWER,POWER_ERR,PHANAME,RMFNAME
;+
; NAME: 
;      MU_PHA
; PURPOSE: 
;      Produces a PHA file from a PDS
; EXPLANATION:
;      This procedure is used by MU_XSPEC to produce a FITS PHA file
;      containing a PDS. It should not be used interactively.
;
; CALLING SEQUENCE: 
;       MU_PHA,POWER,POWER_ERR,PHANAME,RMFNAME
; INPUTS:
;       POWER    = Array with powers (watch out, power per bin!)
;       POWER_ERR= Array with power errors
;       PHANAME  = String containing the pha filename
;       RMFNAME  = String containing the rmf filename (for the pha header)
;
; OUTPUTS:
;       The PHANAME.pha file is produced.
;
; KEYWORDS:
;       NONE
;
; EXAMPLE:
;       NONE
;
; COMMON BLOCKS: 
;       None 
; ROUTINES USED: 
;       FX* routines from the astron IDL library
; NOTES:
;       NONE
; MODIFICATION HISTORY: 
;       T. Belloni  20 Aug 2001  implementation: original from T. Yaqoob
;       T. Belloni   9 Nov 2001  removal of remnant arf filename
;-
;--------------------------------------------------------------------------

;ncol   = 6l
ncol   = 3l

nrow   = long(n_elements(POWER))
channel  = fix(findgen(nrow) + 1)
quality  = intarr(nrow)
sys_err  = fltarr(nrow)
grouping = intarr(nrow) + 1

;create primary header

fxhmake,hdr,/extend,/date
fxaddpar,hdr,'TELESCOPE','XTE'
fxaddpar,hdr,'INSTRUME','PCA'
fxaddpar,hdr,'CONTENT','SPECTRUM'
fxaddpar,hdr,'PHAVERSN','1992a'

fxwrite,phaname,hdr

;create the extension header

fxbhmake,hdr,nrow,'SPECTRUM','name of this binary table extension'
fxaddpar,hdr,'TELESCOPE','XTE'
fxaddpar,hdr,'INSTRUME','PCA'
fxaddpar,hdr,'FILTER','NONE'
fxaddpar,hdr,'EXPOSURE',double(1.0)
fxaddpar,hdr,'AREASCAL',double(1.0)
fxaddpar,hdr,'BACKSCAL',double(1.0)
fxaddpar,hdr,'CORRSCAL',double(1.0)
fxaddpar,hdr,'BACKFILE','NONE'
fxaddpar,hdr,'CORRFILE','NONE'
fxaddpar,hdr,'RESPFILE',RMFNAME
fxaddpar,hdr,'POISSERR','F'
fxaddpar,hdr,'CHANTYPE','PHA'
fxaddpar,hdr,'DETCHANS',fix(nrow)
fxaddpar,hdr,'SYS_ERR',0
fxaddpar,hdr,'QUALITY',0
fxaddpar,hdr,'GROUPING',0

fxaddpar,hdr,'HDUCLASS','OGIP'
fxaddpar,hdr,'HDUCLAS1','SPECTRUM'
fxaddpar,hdr,'HDUVERS','1.1.0'


;now create the columns
fxbaddcol,col1,hdr,CHANNEL(0),'CHANNEL',tunit='       '
fxbaddcol,col2,hdr,POWER(0),'COUNTS',tunit='counts   '
fxbaddcol,col3,hdr,POWER_ERR(0),'STAT_ERR ',tunit='counts   '

nh = WHERE(STRMID(HDR,0,8) EQ 'END     ', nend)
hdr=hdr(0:nh(0)-1)
print,'hdr: ',(size(hdr))(1)
s=strarr(3)
s(0)='TELESCOP= ''XTE     ''           / mission/satellite name'
s(1)='INSTRUME= ''PCA     ''           / instrument/detector name'
s(2)='END                                                         '

print,'hdr: ',(size(hdr))(1)

;Open a new binary table at the end of a FITS file.

fxbcreate,unit,phaname,hdr

;write  the data

NORM=1.

FOR I=1L,NROW DO BEGIN
  FXBWRITE,UNIT,CHANNEL(I-1),COL1,I
  FXBWRITE,UNIT,POWER(I-1),COL2,I
  FXBWRITE,UNIT,POWER_ERR(I-1),COL3,I
ENDFOR
FXBFINISH,UNIT
END
