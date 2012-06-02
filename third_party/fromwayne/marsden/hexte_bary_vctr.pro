function hexte_bary_vctr,ijd,frc,rea,rca,rcs,etut,vce
;*************************************************************************
; This subroutine calculates the vector from the spacecraft to the
; solar system barycenter.
; Variables are:
;   ijd...................Julian day number 
;   frc...................Fraction of day of observation [-.5,.5]
;   REA...................Vector from earth center to spacecraft in m
;   RCA...................Vector from solar system barycenter to
;				   spacecraft in light-seconds
;   ETUT...................TDB-UTC in seconds
;    rca...................SSbary-s/c vector
;    rce...................SSbary-earth vector
;    rcs...................SSbary-Sun vector
;    vce...................d(RCE)/dt
; Set some local variables and parameters
;*************************************************************************
c = 2.99792458d+8
;***********************************************************************
; Call ephem_hexte
;***********************************************************************
status = ephem_hexte(ijd,frc,rce,rcs,etut,vce)
if( not status) then begin
   error = -status/2			
   case error of
      1: print,'HEXTE_BARY_VCTR: EPHEM reports Read Error'
      2: print,'HEXTE_BARY_VCTR EPHEM reports Ephemeris is too short'
      3: print,'HEXTE_BARY_VCTR: EPHEM reports event date outside',$
        	' range of ephemeris'
      else: print,'HEXTE_BARY_VCTR EPHEM reports unknown error: ',$
            error
   endcase
endif
;***********************************************************************
; Compute RCA and convert it to light-seconds
;***********************************************************************
rca = rce + rea/c
;***********************************************************************
; Normal return and end.
;***********************************************************************
return,1
end

