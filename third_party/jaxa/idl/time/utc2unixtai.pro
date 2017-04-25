function utc2unixtai, utctime
;+
; $Id: utc2unixtai.pro,v 1.1 2006/12/11 22:00:23 nathan Exp $
;
; Project   : STEREO SECCHI
;                   
; Name      : utc2unixtai
;               
; Purpose   : convert UTC time to "Unix time" (unsegmented seconds since 1/1/1970)
;               
; Explanation: 
;               
; Use       : IDL> tai = utc2unixtai(anytim2utc('2006-12-02 12:23:00'))
;    
; Inputs    : utctime	Time in UTC (structure) format
;               
; Outputs   : double precision number of seconds
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
; $Log: utc2unixtai.pro,v $
; Revision 1.1  2006/12/11 22:00:23  nathan
; *** empty log message ***
;
;-            
tai= UTC2TAI( utctime,/nocorrect) - 378691200d
return,tai
end
