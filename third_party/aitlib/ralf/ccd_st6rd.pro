PRO CCD_ST6RD, data, FILE=file, ALL=all
;
;+
; NAME:
;	CCD_ST6RD
;
; PURPOSE:   
;	Read ST6 file format.
;
; CATEGORY:
;	Data I/O.
;
; CALLING SEQUENCE:
;	CCD_ST6RD, [ data, FILE=file, ALL=all ]
;
; INPUTS:
;	NONE.
;
; OPTIONAL INPUTS:
;	NONE.
;
; KEYWORDS:
;	NONE.
;
; OPTIONAL KEYWORDS:
;	FILE : Input file name.
;	ALL  : read all available data.
;
; OUTPUTS:
;	NONE.
;
; OPTIONAL OUTPUT PARAMETERS:
;	NONE.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;	NONE.
;	
; RESTRICTIONS:
;	NONE.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - written Nov. 96
;-


on_error,2                      ;Return to caller if an error occurs

if EXIST(all) then $
file=FINDFILE('AIT321$DKA400:[GECKELER.RXJ_1940.ST6]RXJ_*.dat')

if not EXIST(file) then file=PICKFILE(title='ST6 Data File', $
                        path='AIT321$DKA400:[GECKELER.RXJ_1940.ST6]', $
                        filter='RXJ_*.dat')


num_f=n_elements(file)
data=dblarr(2,10000)
bcc=1.0d0
t0=1.0d0
dummy=''
count=0

for i=0,num_f-1 do begin
   openr,unit,file(i),/get_lun
   readf,unit,dummy
   readf,unit,t0
   readf,unit,bcc
   readf,unit,col,row
   readf,unit,dummy
   dat=dblarr(col,row)
   readf,unit,dat
   data(0,count:count+row-1)=t0+bcc/24.0d0/60.0d0+dat(0,*)/24.0d0/60.0d0
   data(1,count:count+row-1)=dat(1,*)
   count=count+row
   free_lun,unit
endfor

data=data(*,where(data(0,*) ne 0.0))

RETURN
END
