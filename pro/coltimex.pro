pro coltimex, obsid, eafile=fileea
  
; This program collects information so that rxte shell program can run
; the correct routines
;
; INPUTS
;
; obsid:full obsid
;
; OPTIONAL INPUTS
;
; eafile: a file that holds the correct ea and channel range information
;
; OUTPUTS
;
; NONE (a file with relevant info for shell programs)
;
; USES
;
; NONE
;
; USED BY
;
; alldo (bash shell)
;
; created by Emrah Kalemci, november 2014
;
;

obspl=strsplit(obsid,'-',/extract)
IF NOT keyword_set(fileea) THEN fileea=obspl[0]+'_eainfo.txt'

; find the total good time and pcu combination
;

gtifils=file_search(obspl[2]+'.'+obspl[3]+'/filter','good*.gti',count=nfil)


IF nfil eq 1 THEN indx=0 ELSE BEGIN
      totexpo=fltarr(nfil)

      FOR i=0, nfil-1 DO BEGIN
         ogtfx=strsplit(gtifils[i],'/',/extract)
         ogtf=ogtfx[2]
         detoffx=strsplit(ogtf,'_',/extract)
         detsoff=strpos(detoffx[1],'off') ; number of pcus off
         starts=loadcol(gtifils[i],'START')
         stops=loadcol(gtifils[i],'STOP')
         expo=0.
         FOR j=0, N_ELEMENTS(starts)-1 DO expo=expo+stops[j]-starts[j]
         totexpo[i]=expo*(5-detsoff)
         print,totexpo[i]
      ENDFOR
      
      indx=where(totexpo eq max(totexpo))
ENDELSE
   
ogtfx=strsplit(gtifils[indx],'/',/extract)
ogtf=ogtfx[2]
detoffx=strsplit(ogtf,'_',/extract)
detflag=''

IF detsoff eq -1 THEN detflag='-all' ELSE BEGIN
    FOR k=0, detsoff-1 DO detflag=detflag+'-'+strmid(detoffx[1],k,1)+'off '
 ENDELSE

readcol,'../'+fileea,ea,minc,maxc, FORMAT = 'A, A, A'

ao=strmid(obspl[0],0,1)
openw,1,'allextiming'

printf,1,'#!/bin/ksh'
printf,1,'eaextract=eaextract'
printf,1,'obspath=/Users/emrahkalemci/RXTE/DATA_AN/RAW/AO'+ao+'/P'+obspl[0]+'/'
FOR i=0, n_elements(ea)-1 DO BEGIN
   printf,1, '${eaextract} '+obsid+' ${obspath} '+obspl[2]+'.'+obspl[3]+'t -dt=8 -exclusive -ea='+ea+' '+detflag+minc+' '+maxc+' > '+obspl[2]+'.'+obspl[3]+'t_ea'+ea+'.log'
ENDFOR

close,1

spawn,'chmod u+x allextiming

END

