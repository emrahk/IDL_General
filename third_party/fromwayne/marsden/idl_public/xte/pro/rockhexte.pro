PRO ROCKHEXTE, UTdate, RAdeg, Decdeg, angledeg, Xrolldeg
;
syntax = "ROCKHEXTE, UTdate, RA(deg), Dec(deg), angle(deg), [roll(deg)]"
;-
IF N_PARAMS() EQ 0 THEN BEGIN
   PRINT, "Syntax: ", syntax
   RETURN
ENDIF

IF N_ELEMENTS(Xrolldeg) EQ 0 THEN Xrolldeg = 0.0

rockdeg = FLOAT(ABS(angledeg))
rockstr = STRING(rockdeg, FORMAT="(F4.2)")
; Compute attitude matrix
Attitude = ATT_RDOBS(UTdate, 12, 0.0, [RAdeg, Decdeg], Xrolldeg)
posformat = "(F8.4)"

PRINT, "Pointing axis: ", STRING( $ 
        RD_SKY(SKY_ATTSC(Attitude, [1, 0, 0])), $
        FORMAT=posformat )

PRINT, rockstr+" degrees +Y", STRING( $
       RD_SKY(SKY_ATTSC(ATT_PITCHYATT(rockdeg, Attitude), [1,0,0])), $ 
       FORMAT=posformat )
PRINT, rockstr+" degrees -Y", STRING( $
       RD_SKY(SKY_ATTSC(ATT_PITCHYATT(-rockdeg, Attitude), [1,0,0])), $
       FORMAT=posformat )
PRINT, rockstr+" degrees +Z", STRING( $ 
       RD_SKY(SKY_ATTSC(ATT_YAWZATT(rockdeg, Attitude), [1,0,0])), $ 
       FORMAT=posformat )
PRINT, rockstr+" degrees -Z", STRING( $
       RD_SKY(SKY_ATTSC(ATT_YAWZATT(-rockdeg, Attitude), [1,0,0])), $
       FORMAT=posformat )

RETURN
END
