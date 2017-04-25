function unixtai2utc, pkttime
;+
; $Id: unixtai2utc.pro,v 1.1 2006/12/11 22:00:22 nathan Exp $
;
; Project   : STEREO SECCHI
;                   
; Name      : utc2unixtai
;               
; Purpose   : convert "Unix time" (unsegmented seconds since 1/1/1970) to UTC CDS structure
;               
; Explanation: 
;               
; Use       : IDL> utc = unixtai2utc(tai)
;    
; Inputs    : tai   DOUBLE seconds
;               
; Outputs   : UTC CDS time structure
;
; Keywords  : 
;
; Calls from LASCO : 
;
; Common    : 
;               
; Restrictions: 
;               
; Side effects: 
;               
; Category    : time
;               
; Prev. Hist. : None.
;
; Written     : Nathan Rich, NRL/I2, Sep 2004
;               
; $Log: unixtai2utc.pro,v $
; Revision 1.1  2006/12/11 22:00:22  nathan
; *** empty log message ***
;
;-            
utc= TAI2UTC( pkttime + 378691200d0, /NOCORRECT)
return,utc

end
