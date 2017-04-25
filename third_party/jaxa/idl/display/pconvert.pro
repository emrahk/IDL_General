;+
; Project     : SOHO - CDS     
;                   
; Name        : PCONVERT()
;               
; Purpose     : Convert Plot DEVICE, DATA, NORMAL and PIXEL coordinates
;               
; Explanation : Uses the data stored for each Plot Region to calculate
;		to and from different coordinate systems.
;               
; Use         : DEVICE_X = PCONVERT(PLOTREG,COORD)
;    
; Inputs      : PLOTREG : A plot region ID as returned by PSTORE or PFIND
;
;		COORD : The coordinate to be converted. See Restrictions.
;               
; Opt. Inputs : None.
;               
; Outputs     : Return value.
;               
; Opt. Outputs: None.
;               
; Keywords    : Y : 	Set to mark that it's the Y coordinate that is
;			supplied.
;
;		DEVICE/DATA/
;		NORMAL/
;		PIXEL  : Set to indicate the type of the supplied coordinate.
;			Default is DEVICE.
;
;		TO_DEVICE/TO_DATA/
;		TO_NORMAL/
;		TO_PIXEL: Set to indicate the type of coordinate to convert
;			into. Default is DATA.
;		
;		LOWER: In converting PIXEL -> other units, it is normally
;			assumed that the supplied coordinate is the 
;			pixel _number_, i.e., the expected output is the
;			value at the center of the pixel. If you are 
;			supplying 'real' pixel values (with pixel 
;			number 2 lying in the interval <1.0, 2.0>) or if
;			you want the coordinates at the left/lower border of
;			where the pixel is displayed, use this keyword to
;			notify. E.g:
;
;			pconvert(P,0,/pixel,/to_data) yields 0.000
;			but:
;			pconvert(P,0,/pixel,/to_data,/lower) yields -0.500
;			given that the data coordinate system is set up
;			to correspond with pixel index numbers.
;
; Calls       : TRIM()
;
; Common      : WSTORE
;               
; Restrictions: There must exist a data coordinate system for the
;		specified plot region, stored with PSTORE()
;
;		When converting to and from PIXEL values it is assumed
;		that:
;
;		For one-dimensional data, the plot is generated
;		with XRANGE = [MIN(x),MAX(x)],XSTYLE=1, and it is
;		assumed that the pixels are placed at constant intervals.
;
;		For two-dimensional data, the plot is generated with
;		XRANGE = [MIN(x)-XSTEP,MAX(x)+XSTEP],XSTYLE=1, (and
;		vice versa for Y) where XSTEP is the (DATA coordinate) 
;		distance between two consecutive pixels.
;		This is also necessary to get the axis ticks correct
;		on the plot/TV'ed data.
;               
; Side effects: None.
;               
; Category    : Utilities, Graphics
;               
; Prev. Hist. : Combined earlier ppix2dat/ppix2dev .... etc.
;
; Written     : SV Hagfors Haugan, 30-May-1994
;               
; Modified    : SVHH, 1-June-1994 -- Found that IDL sometimes chops a pixel
;			when calculating !X.S/!Y.S - fixed.
;		SVHH, 25-November-1994 -- The above "fix" removed -- better
;			to make sure that IDL is not missing the pixel
;			using e.g., plot,[..],position=pos+0.0001,/dev
;			--  this (hopefully) keeps IDL from miscalculations
;			of !P.clip etc.
;			Included bounds on /TO_PIXEL conversions.
;               Version 2, SVHH, 15 June 1996
;                       Added recognition of logarithmic axis scaling.
;                       
; Version     : 2, 15 June 1996
;-            


FUNCTION pconvert,P_reg,C,y=y,lower=lower,$
                  DEVICE=DEVICE,data=data,normal=normal,pixel=pixel,$
                  to_device=to_device,to_data=to_data,$
                  to_normal=to_normal,to_pixel=to_pixel
  
  COMMON wstore,D,P,N,XX,YY,dataxx,datayy
  
  IF N_params()	LT 2 THEN MESSAGE,'Use: result = pconvert(Plot_reg,COORD)'
  
  IF N_elements(P_reg) EQ 0 OR N_elements(P_reg) GT 1 THEN $
     MESSAGE,'Plot_region must be scalar'
  
  i = P_reg                     ; shorthand
  
  IF i LT 0 OR i GE N_elements(D) THEN $
     MESSAGE,'Plot region number must be [0,..,'+trim(N_elements(D)-1)+']'
  
  IF NOT Keyword_SET(Y)	THEN BEGIN
     ddata = dataxx(i)	>1
     odata= datayy(i) >1
     scrn = P(i).clip(2)-P(i).clip(0)
     j	= P(i).clip(0)
     Size = D(i).X_size
     s	= XX(i).s
     type = XX(i).type
  END ELSE BEGIN
     ddata = datayy(i)	>1
     odata= dataxx(i) >1
     scrn = P(i).clip(3)-P(i).clip(1)
     j	= P(i).clip(1)
     Size = D(i).Y_size
     s	= YY(i).s
     type = YY(i).type
  EndELSE

;
; Default input is DEVICE
;
  IF NOT (Keyword_SET(DEVICE) OR Keyword_SET(data) $
          OR Keyword_SET(normal) OR Keyword_SET(pixel))	THEN DEVICE=1
  
;
; Default output is DATA
;
  IF NOT (Keyword_SET(to_device) OR Keyword_SET(to_data) $
          OR Keyword_SET(to_normal) OR Keyword_SET(to_pixel)) THEN to_data=1
;
;
;
  
  IF (Keyword_SET(pixel)) AND odata GT 1  $
     AND NOT Keyword_SET(lower) THEN C	= C + .5d
  
  CASE 1 OF 
     
  KEYWORD_SET(DEVICE):BEGIN
     
     IF Keyword_SET(to_device)	THEN BEGIN
        RETURN,c
     END ELSE IF Keyword_SET(to_data) THEN BEGIN
        IF type THEN RETURN,10.0D^((DOUBLE(C)/Size-s(0))/s(1))
        RETURN,(DOUBLE(c)/SIZE-s(0))/s(1)
     END ELSE IF Keyword_SET(to_normal) THEN BEGIN
        RETURN,DOUBLE(C)/DOUBLE(Size)
     END ELSE IF Keyword_SET(to_pixel)	THEN BEGIN
        RETURN,(((C-J)*DOUBLE(ddata)/scrn) >0) < (ddata-0.0001)
     END
     
     ENDCASE
     
  Keyword_SET(data):BEGIN
     
     IF type THEN c = alog10(c)
     IF Keyword_SET(to_device)	THEN BEGIN
        RETURN,(C*s(1)+s(0))*Size
     END ELSE IF Keyword_SET(to_data) THEN BEGIN
        RETURN,10.0d^C
     END ELSE IF Keyword_SET(to_normal) THEN BEGIN
        RETURN,C*s(1)+s(0)
     END ELSE IF Keyword_SET(to_pixel)	THEN BEGIN
        dev =	(C*s(1)+s(0))*Size
        RETURN,(((dev - j)*ddata/scrn) > 0) < (ddata-0.0001)
     END
     
     ENDCASE
     
  Keyword_SET(normal):BEGIN
     
     IF Keyword_SET(to_device)	THEN BEGIN
        RETURN,C*Size
     END ELSE IF Keyword_SET(to_data) THEN BEGIN
        IF type THEN RETURN,10.0d^(C-s(0))/s(1)
        RETURN,(C-s(0))/s(1)
     END ELSE IF Keyword_SET(to_normal) THEN BEGIN
        RETURN,c
     END ELSE IF Keyword_SET(to_pixel)	THEN BEGIN
        RETURN,(C*Size - j)*ddata/scrn > 0 < (ddata-0.0001)
     END
     
     ENDCASE
     
  Keyword_SET(pixel):BEGIN
     
     IF Keyword_SET(to_device)	THEN BEGIN
        RETURN, J + C*scrn/ddata
     END ELSE IF Keyword_SET(to_data) THEN BEGIN
        IF type THEN RETURN,10.0D^((J+DOUBLE(C)*scrn/ddata)/(Size)-s(0))/s(1)
        RETURN,((J+DOUBLE(C)*scrn/ddata)/(Size)-s(0))/s(1)
     END ELSE IF Keyword_SET(to_normal) THEN BEGIN
        RETURN,(J + C*scrn/ddata)/Size
     END ELSE IF Keyword_SET(to_pixel)	THEN BEGIN
        RETURN,c
     END
     
     ENDCASE
     
  END
  
END



