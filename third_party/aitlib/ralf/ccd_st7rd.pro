PRO CCD_ST7RD, data, FILE=file, ALL=all, SILENT=silent
;
;+
; NAME:
;	CCD_ST7
;
; PURPOSE:   
;	Read ST7 file format.
;
; CATEGORY:
;	Data I/O.
;
; CALLING SEQUENCE:
;	CCD_ST7RD, [ data, FILE=file, ALL=all, SILENT=silent ]
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
;	FILE   : Input file name.
;	ALL    : Read all available data.
;	SILENT : No output on screen.
;
; OUTPUTS:
;	NONE.
;
; OPTIONAL OUTPUT PARAMETERS:
;	DATA : Array with times, amplitudes and errors.
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
file=FINDFILE('*.dat')

if not EXIST(file) then file=PICKFILE(title='Data File', $
                        path='.', $
                        filter='*.dat')


num_f=n_elements(file)
data=dblarr(3,10000)
count=0

t=1.0d0
a=1.0d0
e=1.0d0

for i=0,num_f-1 do begin

   CCD_RASC,file(i),dat,silent=silent
   num=n_elements(dat)
   for k=0,num-1 do begin
 
      ;exclude comments beginning with %
      p=STRPOS(dat(k),'%')
      if p ne -1 then str=STRMID(dat(k),0,p(0)-1) else str=dat(k)
      READS,str,t,a,e
      data(0,k+count)=t
      data(1,k+count)=a
      data(2,k+count)=e
   endfor

   count=count+num
   close,1
endfor

data=data(*,where(data(0,*) ne 0.0))

RETURN
END
