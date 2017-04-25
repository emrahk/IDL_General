;+
; Project     : SOHO - CDS     
;                   
; Name        : PRESTORE
;               
; Purpose     : Restore Plot Region data (!P,!X,!Y,!D, and data X/Y size)
;               
; Explanation : Prestore is used to restore information about plot regions
;		previously saved with PSTORE().
;		The !P/!X/!Y/!D system variables are set to the values
;		they had at the moment of the call to PSTORE().
;
;		The Plot Region is identified by the plot region ID that
;		was returned by PSTORE(), or found by PFIND()
;
; Use         : PRESTORE,P_REG [,DATAX, DATAY, SCRNX, SCRNY, JX, JY]
;    
; Inputs      : P_REG : The plot region ID.
;
; Opt. Inputs : None.
;               
; Outputs     : DATAX/Y : The size of the data in the plot region, as reported
;			to PSTORE().
;
;		SCRNX/Y : The size of the display region on the screen (device units)
;		
;		JX/JY   : !P.CLIP(0) and !P.CLIP(1)
;               
; Opt. Outputs: None.
;               
; Keywords    : PLOT_NUMBER: Set to a named variable to return the plot number
;			that was sent to PSTORE().
;
; Calls       : SETWINDOW, TRIM()
;
; Common      : WSTORE
;               
; Restrictions: None.
;               
; Side effects: None.
;               
; Category    : Utility, Graphics
;               
; Prev. Hist. : None.
;
; Written     : Stein Vidar Hagfors Haugan, May 1994
;               
; Modified    : 
;
; Version     : 1, May 1994
;-            

PRO prestore,qlwid,datax,datay,scrnx,scrny,jx,jy,plot_number=plot_number
  common wstore,D,P,Nn,Xx,Yy,dataxx,datayy
  
  On_Error,2
  
  IF N_elements(qlwid) ne 1 THEN $
	message,'Use: PRESTORE,QLWID [,datax,datay,scrnx,scrny]'
  
  IF qlwid lt 0	or qlwid gt N_elements(d)-1 THEN $
	  message,'QLWID must be <0,...,'+trim(N_elements(d)-1)+'>'
  
  i = qlwid
  
;!D = D(i)
  
  set_plot,D(i).name
  
  IF (D(i).flags and 256) gt 0 THEN BEGIN
      DEVICE,window_state=open_window
      IF D(i).window lt	0 or open_window(D(i).window>0)	eq 0 THEN BEGIN
	  plot_number =	'Closed Window'
	  return
      END
  EndIF
  
  IF (!D.flags and 256)	gt 0 THEN SetWindow,D(i).window
  
  !P = P(i)
  !X = Xx(i)
  !Y = Yy(i)
  datax	= dataxx(i) &  datay = datayy(i)
  scrnx	= !P.clip(2)-!P.clip(0)+1 &  scrny = !P.clip(3)-!P.clip(1)+1
  jx = !P.clip(0) & jy = !P.clip(1)
  plot_number =	Nn(i)
END



