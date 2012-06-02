PRO plotacs, file,rra,dde
;+
; NAME:
;            plotacs
;
;
; PURPOSE:
;            Prepare an overview-plot of the contents of an RXTE ACS-File
;            (ACS is the Attitude Control System). The program plots
;            the deviation of the pointing-position of the satellite
;            from the nominal source position, the elevation of the
;            source above the horizon, and which of the proportional
;            counters is on.
;
; CATEGORY:
;            RXTE
;
;
; CALLING SEQUENCE:
;            plotacs,file,ra,dec
;
; 
; INPUTS:
;            file: filename of the ACS file (only one file can be
;                  given right now)
;            ra  : RA of the source (2000.0 coordinates, degrees)
;            dec : DEC of the source(2000.0 coordinates, degrees)
;
; OPTIONAL INPUTS:
;            none
;
;	
; KEYWORD PARAMETERS:
;            none
;
;
; OUTPUTS:
;            none
;
;
; OPTIONAL OUTPUTS:
;            none
;
;
; COMMON BLOCKS:
;            none
;
;
; SIDE EFFECTS:
;            none
;
;
; RESTRICTIONS:
;            none
;
;
; PROCEDURE:
;            The function reads the important columns from the ACS
;            file and plots them.
;
;
; EXAMPLE:
;            file='./FP_54a1780-54a3935.xfl'
;            ra=hms2deg(19.,58.,21.72)
;            dec=dms2deg(35.,12.,05.9)
;            plotacs,file,ra,dec
;
;
; MODIFICATION HISTORY:
;            V1.0, 1997/06/24, Joern Wilms (wilms@astro.uni-tuebingen.de)
;-

   filename = file
   
   ;;
   ;; goto XTE_MKF extension 
   ;;
   fxbopen,unit,filename,'XTE_MKF',header
   
   ;;
   ;; Read Necessary Information
   ;;
   fxbread,unit,time,'TIME'    ; Time (in MET)
   fxbread,unit,ra,'POINT_RA'  ; Pointing: RA
   fxbread,unit,dec,'POINT_DEC';           DEC
   fxbread,unit,elv,'ELV'      ; Source Elevation
   fxbread,unit,pcu0,'PCU0_ON' ; 1 if PCU0 is on
   fxbread,unit,pcu1,'PCU1_ON' ; 1 if PCU1 is on
   fxbread,unit,pcu2,'PCU2_ON' ; 1 if PCU2 is on
   fxbread,unit,pcu3,'PCU3_ON' ; 1 if PCU3 is on
   fxbread,unit,pcu4,'PCU4_ON' ; 1 if PCU4 is on
   
   ;;
   ;; ... done with reading
   ;;

   fxbclose,unit
   
   ;;
   ;; Do some Plotting
   ;;
   
   ;; Min. and max. time (so that time-axes are all identical)
   tmin=min(time)
   tmax=max(time)

   
   ;;
   ;; Deviation from nominal position in RA
   ;;
   
   ;; Plot only for times where RA is known
   valid=where(finite(ra) EQ 1)
   tim=time(valid)
   dist=(ra(valid)-rra)*60. ;; Dist in RA (in arcmin)
   
   plot,[tmin,tmax],[-1.7,+1.7],ystyle=1, $
     ytitle=textoidl("\Delta\alpha_{point} (')"), $
     position=[0.1,0.75,0.95,0.95],/ynozero,/nodata,xstyle=1, $
     xtickformat='nolabel'
   oplot,tim,dist
   oplot,[tmin,tmax],[0.,0.]
   
   ;;
   ;; Deviation from nominal position in DEC
   ;;

   valid=where(finite(dec) EQ 1)
   tim=time(valid)
   dist=(dec(valid)-dde)*60.
   
   plot,[tmin,tmax],[-1.7,+1.7], ystyle=1, $
     ytitle=textoidl("\Delta\delta_{point} (')"), $
     position=[0.1,0.55,0.95,0.75],/noerase,/nodata,xstyle=1, $
     xtickformat='nolabel'
   oplot,tim,dist
   oplot,[tmin,tmax],[0.,0.]

   valid=where(finite(elv) EQ 1)
   el=elv(valid)
   ti=time(valid)

   
   ;;
   ;; Elevation (can be greater than 90 deg since Earth is sphere and
   ;; elv is measured from real horizon)
   ;;

   ema=max(el)*1.05
   emi=min(el)
   IF (emi LT 0.) THEN emi=emi*1.05
   IF (emi GE 0.) THEN emi=emi*0.95

   plot,[tmin,tmax],[emi,ema],ytitle=textoidl('Elevation (deg)'), $
     position=[0.1,0.35,0.95,0.55],/noerase,/ynozero,/nodata, $
     xstyle=1,xtickformat='nolabel'

   IF (emi LT 0.) THEN BEGIN 
       oplot,[tmin,tmax],[0.,0.]
   ENDIF 
   oplot,ti,el
   
   ;;
   ;; Plot a line where the individual PCUs are on
   ;;

   plot,[tmin,tmax],[0.,6.],position=[0.1,0.15,0.95,0.35], $
     /noerase,/nodata,xstyle=1,yticks=5,ytickv=[0,1,2,3,4,5,6], $
     ytickname=[' ','PCU0','PCU1','PCU2','PCU3','PCU4'],yticklen=0, $
     xtitle='Time [MET]'

   FOR j=0,4 DO BEGIN 
       CASE j OF
           0: pcu=pcu0
           1: pcu=pcu1
           2: pcu=pcu2
           3: pcu=pcu3
           4: pcu=pcu4
       END 

       gap=where(pcu NE shift(pcu,-1))

       start=0
       FOR i=0,n_elements(gap)-1 DO BEGIN 
           stop=gap(i)
           IF (pcu(start) EQ 1) THEN BEGIN 
               oplot,[time(start),time(stop)],[j+1,j+1]
           ENDIF 
           start=stop+1
       ENDFOR 
   ENDFOR 

END 

