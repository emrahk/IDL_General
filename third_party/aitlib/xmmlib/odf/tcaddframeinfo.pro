FUNCTION tcaddframeinfo,data,mode,framedatastruct=framedatastruct
   
 ;+
; NAME:            tcaddframeinfo
;
;
;
; PURPOSE:
;		   Add frame information to data struct array
;
;
; CATEGORY:
;                  HK-File Data Analysis
;
;
; CALLING SEQUENCE:
;                  datawithframeinfo=tcaddframeinfo(data,mode,/framedatastruct)
;
; 
; INPUTS:
;                  data  :  data struct array as specified in geteventdata.pro
;                  mode: string with mode of measurement: 'FF', 'TI', 'BU', 'SW',
;                        or 'full', 'timing', 'burst', 'small'  
;                        or integer 1..4
;   
;
; OPTIONAL INPUTS:
;                  none
;   
;
; KEYWORD PARAMETERS:
;                  framedatastruct: data struct contains the element data.frame
;
;
; OUTPUTS:
;                  data struct with frame info in element data.frame
;
;
; OPTIONAL OUTPUTS:
;		   none   
;                  
;
; COMMON BLOCKS:
;                  none
;
;
; SIDE EFFECTS:
;                  all data elements with time values greater than 32700 (most
;                  probably swaps) are removed from array
;
;
; RESTRICTIONS:
;                  none
;                  
;
; PROCEDURE:
;                  
;
;
; EXAMPLE:
;                  
;                  
;
; MODIFICATION HISTORY:
; V1.0 19.09.00 T. Clauss first version
; V1.1 21.09.00 T. Clauss added keyword framedatastruct
;-
   
   
   mode=string(mode)
   
   CASE strtrim(mode,2) OF
       'FF': tframe=(0.07326592d - 0.00000001d)
       'TI': tframe=(0.00590400d - 0.00000001d)
       'BU': tframe=(0.00433728d - 0.00000001d)
       'SW': tframe=(0.00565856d - 0.00000001d)
       'full':   tframe=(0.07326592d - 0.00000001d)
       'timing': tframe=(0.00590400d - 0.00000001d)
       'burst':  tframe=(0.00433728d - 0.00000001d)
       'small':  tframe=(0.00565856d - 0.00000001d)
       '1' : tframe=(0.07326592d - 0.00000001d)
       '2' : tframe=(0.00590400d - 0.00000001d)
       '3' : tframe=(0.00433728d - 0.00000001d)
       '4' : tframe=(0.00565856d - 0.00000001d)
       ELSE: BEGIN
           print,'% TCADDFRAMEINFO: No valid mode given, returning...'
           return,-1
       ENDELSE
   ENDCASE
   
   data=data(where(data.time LE 32700))
   
   IF NOT keyword_set(framedatastruct) THEN BEGIN 
   
       sfdata={sfdata,line:long(0),column:long(0),energy:double(0),sec:double(0),$
               secbruch:double(0),ccd:byte(0),split:long(0),time:double(0),frame:long(0)}
   
       nevents=n_elements(data)
       fdata=replicate(sfdata,nevents)
       
       fdata.line=data.line
       fdata.column=data.column
       fdata.energy=data.energy
       fdata.sec=data.sec
       fdata.secbruch=data.secbruch
       fdata.ccd=data.ccd
       fdata.split=data.split
       fdata.time=data.time
       
   ENDIF ELSE BEGIN
       fdata=data
   ENDELSE 
   
   frame=data.time-shift(data.time,-1)
   frameind=where(frame NE 0)
   numevframes=n_elements(frameind)
   
   fcount=0l
   
   FOR f=0l,numevframes-1 DO BEGIN
       
       IF (f NE 0) THEN BEGIN
           find=indgen(frameind(f)-frameind(f-1))+frameind(f-1)+1  ;; current frame
           time=data(find(0)).time
           dtime=time-ptime
           ptime=time
       ENDIF ELSE BEGIN   ;; first frame
           IF frameind(0) EQ 0 THEN BEGIN 
               find=0
           ENDIF ELSE BEGIN
               find=indgen(frameind(0))
           ENDELSE 
           time=data(find(0)).time
           dtime=0
           ptime=time
       ENDELSE

       nframes=fix(dtime/tframe)  ;; number of frames since last frame
       fcount=fcount+nframes
       
       fdata(find).frame=fcount

   ENDFOR
   
   return,fdata
   
END

