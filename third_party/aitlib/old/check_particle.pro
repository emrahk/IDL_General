PRO check_particle,name,result
;+
; NAME:
;       check_particle
;
;
; PURPOSE:
;       check the particle detectors and find out which datapoints are
;       ok and which are not
;
;
; CATEGORY:
;       
;
;
; CALLING SEQUENCE:
;       check_particle,filename,result
;
; 
; INPUTS:
;       filename : name of the FITS file containing particle detector
;                  information 
;
;
; OUTPUTS:
;       result : the processed particle columns
;
;
; PROCEDURE:
;       Right and left veto counter are added and divided by Counter
;       Q6VxVpXeCntPcu0. If the result is smaller than 0.1, everything
;       is fine
;
;
; EXAMPLE:
;       check_particle,'test.lc'
;
;
; MODIFICATION HISTORY:
;       written 1996 by Ingo Kreykenbohm, AIT
;-

tab = readfits(name,h,/exten)

l = float(tbget(h,tab,'VpX1LCntPcu0'))
r = float(tbget(h,tab,'VpX1RCntPcu0'))
q = float(tbget(h,tab,'Q6VxVpXeCntPcu0'))

result = (l+r)/q

a = where(result LE 0.1) ; Kriterium fuer ok ist a >= 0.1

IF (a(0) EQ -1) THEN BEGIN 
print,'Alle Datenpunkt ok.' 
END ELSE BEGIN 
    print,'Folgende Datenpunkt sind nicht in Ordnung :'
    print,a
END 
END 
