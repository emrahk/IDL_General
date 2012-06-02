;+
; XTE_ORIENT.pro - IDL routines for computing attitude information.
;
; Taken from Fortran code provided by Tod Strohmayer and Mike Pelling.
; See also "Spacecraft Attitude Determination and Control", ed. J. R. Wertz
; (Kluwer 1991). This version uses the IDL (column, row) convention
; for indexing matrices, which is opposite to Tod's code and Wertz's
; notation (but it works!).

; To use these programs, make sure that your IDL_PATH environment contains the
; GSFC astronomy library under /disk2/util/idl_public. Then just type ".RUN
; xte_orient", TWICE (to solve forward references in the code). The main use
; of these is to convert quaternions to an attitude matrix (XTEAMAT.PRO), and
; thereafter convert the Crab's RA and Dec to spacecraft Y and Z (components
; of a unit vector). The routines can also be used to calculate the sky
; positions of the clusters +/-1.5 and +/-3.0 degree rocking positions for a
; given source pointing. See the code or Phil Blanco for details. 

; When reading the routine names, read "_" aloud as "from", eg.
; RD_SKY = "RA and Dec from sky (Cartesian) coordinates", and
; SC_ATTSKY = "spacecraft coordinates FROM attitude and sky coodinates".
; and functions can be chained together to create new ones, eg.
; RD_SKY(SKY_ATTSC(...)) = "RA and Dec from attitude and spacecraft coords"
; Examples of use:

; a) To print the RA and Dec look direction at the Y=+1.5 deg position
; when pointing at J2000 RA=100, Dec=50 on UT 1995 Mar 15 at 12:30 pm.

; Use the attitude in sky coordinates:
; IDL> Attitude = ATT_RDOBS(19950316, 12, 30.0, [100.0, 50.0]) 
;  Then: 
; IDL> PRINT, RD_SKY( (SKYSCAXES_ATT(ATT_PITCHYATT(1.5, Attitude)))(*,0) )
;  or:
; IDL> PRINT, RD_SKY(SKY_ATTSC(ATT_PITCHYATT(1.5, Attitude), [1,0,0]))

;Or use the offset spacecraft vector (careful with sign conventions!):
; IDL>  scvec = [COS(!PI*1.5/180), -SIN(!PI*1.5/180), 0.0]
; IDL>  PRINT, RD_SKY(SKY_ATTSC(Attitude, scvec)

; b) Calculate the spacecraft coordinates of the Crab (RA=83.6333, Dec=22.0145)
; IDL> xyz = SC_ATTSKY(Attitude, SKY_RD([83.6333, 22.0145]))
; -
;+
FUNCTION ATT_RDOBS, YYMMDD, Hour, Min, RaDecdeg, Xrolloffdeg
;
; Calculates the attitude matrix for a given observation's RA, Dec
; and date, assuming zero X-axis roll offset from the sun, i.e. the
; spacecraft's Y axis is normal to the sun, i.e. the sun lies
; exactly in the X-Z plane.
;
; Parameters (<=input, >=output, !=modified):
; YYMMDD (<) (LONG) - the UT Date in the format YearMonthDay
; Hour (<) (INT) - UT hour (0-23)
; Min (<) (FLOAT) - UT minutes (0.0-59.999)
; RaDecdeg (<) (FLTARR(2)) - pointing RA and Dec (J2000.0), in degrees
; Xrolloffdeg (<, default 0.0) - X-axis roll offset in degrees

; Calls:
; JULDATE (GSFC) - calculate the (JD-2400000) given Year,Month,Day,Hour.Min
; XYZ (GSFC) - calculate the 1950.0 Cartesian coords of the sun given reduced J.D.
; JPRECESS (GSFC) - precess B1950.0 RA and Dec to J2000.0
;
syntax = "<attitude> = ATT_RDOBS(YYMMDD, Hour, Min, RADec(2), [Xroll(deg)])"
;-
IF N_PARAMS() EQ 0 THEN BEGIN
  PRINT, "Syntax: ", syntax
  RETURN, 0
ENDIF

; Coordinates of the spacecraft X-axis, which looks at the source
X = DOUBLE( SKY_RD( DOUBLE(RaDecdeg) ) )

Day = YYMMDD MOD 100
Month = (YYMMDD / 100) MOD 100
Year = YYMMDD / 10000

; Now calculate the J2000.0 coords of the sun using the GSFC astro library
JULDATE, [Year, Month, Day, Hour, Min], RedJD
XYZ, RedJD, sunx, suny, sunz                        ; 1950.0 Cartesian coords in A.U.
sunvec = [sunx, suny, sunz]
sunvec = sunvec / SQRT(TOTAL(sunvec^2))             ; Normalize 
sunradec = RD_SKY(sunvec)                           ; Convert to RA, Dec
JPRECESS, sunradec(0), sunradec(1), sunraj, sundecj ; Precess to J2000.0

MESSAGE, /INFO, "The Sun is at RA="+STRTRIM(sunraj/15.0,2) $
               +" H, Dec="+STRTRIM(sundecj,2)+" deg on RJD="+STRTRIM(RedJD,2)

sunvec = DOUBLE( SKY_RD([sunraj, sundecj]) )        ; Convert to J2000.0 X,Y,Z

; Spacecraft Y axis points along cross product of sunvector with X-axis
;
Y = CROSSP(X, sunvec)
Y = Y / SQRT(TOTAL(Y^2)) ; normalize

Z = CROSSP(X, Y)
Z = Z / SQRT(TOTAL(Z^2)) ; normalize (shouldn't be necessary as X,Y are orthog)

; Return the spacecraft axes as IDL COLUMNS of the attitude matrix 
; Note that the indexing is opposite to that used
; by Wertz in the Appendix on matrices, though the matrix should
; print out as in Wertz eqn 12-2.

att = REFORM([X,Y,Z], 3, 3)

; Roll around the X axis, if requested
IF N_ELEMENTS(Xrolloffdeg) NE 0 THEN att = ATT_ROLLXATT(Xrolloffdeg, att)
RETURN, att
END

;+
FUNCTION ATT_ROLLXATT, Xrolldeg, Attitude
; Returns an attitude matrix rotated about its X axis by Xrolldeg degrees
syntax = "<attitude> = ATT_ROLLXATT(xroll (deg), attitude(3,3))"
;-
IF N_PARAMS() EQ 0 THEN BEGIN
   PRINT, "Syntax: ", syntax
   RETURN, 0 
ENDIF   

xvec = Attitude(*,0) ; xaxis in sky coordinates
RETURN, ROT_AXISANGLE(xvec, Xrolldeg) # Attitude 
END

;+
FUNCTION ATT_PITCHYATT, Yrolldeg, Attitude
; Returns an attitude matrix rotated about its Y axis by Yrolldeg degrees
syntax = "<attitude> = ATT_PITCHYATT(ypitch (deg), attitude(3,3))"
;-
IF N_PARAMS() EQ 0 THEN BEGIN
   PRINT, "Syntax: ", syntax
   RETURN, 0 
ENDIF   

yvec = Attitude(*,1) ; y-axis in sky coordinates
RETURN, ROT_AXISANGLE(yvec, Yrolldeg) # Attitude
END

;+
FUNCTION ATT_YAWZATT, Zrolldeg, Attitude
; Returns an attitude matrix rotated about its Z axis by Zrolldeg degrees
syntax = "<attitude> = ATT_YAWZATT(zyaw (deg), attitude(3,3))"
;-
IF N_PARAMS() EQ 0 THEN BEGIN
   PRINT, "Syntax: ", syntax
   RETURN, 0 
ENDIF   

zvec = Attitude(*,2) ; z-axis in sky coordinates
RETURN, ROT_AXISANGLE(zvec, Zrolldeg) # Attitude
END

;-
FUNCTION Q_ATT, Att
;
; Computes a quaternion from an attitude matrix.
; From Wertz p. 415.
; Parameters:
; Att (DBLARR(3,3)) - attitude matrix

syntax = "<quat> = Q_ATT(Attitude(3,3))"
;-
IF N_PARAMS() EQ 0 THEN BEGIN
   PRINT, "Syntax: ", syntax
   RETURN, 0 
ENDIF   

quat = DBLARR(4)
WertzAtt = TRANSPOSE(Att)
quat(3) = 0.5 * SQRT(1 + WertzAtt(0,0) + WertzAtt(1,1) + WertzAtt(2,2))
quat(0) = 0.25 / quat(3) * (WertzAtt(1,2) - WertzAtt(2,1))
quat(1) = 0.25 / quat(3) * (WertzAtt(2,0) - WertzAtt(0,2))
quat(2) = 0.25 / quat(3) * (WertzAtt(0,1) - WertzAtt(1,0))

RETURN, quat
END

;
; Summary of Tod Strohmayer's  code:
; ATT_Q - Quaternion to Attitude Matrix (XTEAMAT)

; SKYSCAXES_ATT - Attitude matrix to X,Y,Z inertial coordinates 
; (Cartesian RA,Dec) of the spacecraft's x,y,z axes (I guess
; this is a special case of XTETOIRF, called 3 times with
; {x,y,z} = {1,0,0}, {0,1,0}, then {0,0,1}). (XTEPNT_XYZ).

; SKY_ATTSC - Spacecraft x,y,z and attitude matrix to X,Y,Z (XTETOIRF)

; SKY_ATTSC, /INVERT -
; X,Y,Z (Cartesian RA, Dec) and attitude matrix to Spacecraft x,y,z (XTETOIRF)

; Example calls:
 
; Convert source RA & Dec into unit vector in inertial coord.
;  coor = RDTOSKY(RA, Dec)
; Compute the spacecraft attitude from the quaternions
;  att = ATT_Q(quat)
; Compute the source position in the spacecraft coord.
;  SKY_ATTSC, att, coor, sccoor

;+
FUNCTION ATT_Q, quat
; *******************************************************************************
; SUBROUTINE:
;     xtemat
;
; DESCRIPTION:
;     Constructs the 3x3 attitude matrix from a given quaternion. See Wertz
;     (Spacecraft Attitude Determination and Control) for more on quaternions
;     and attitude matrix.
;
; Parameters::
;     quat(4)      - quaternions
; Return value:
;     att(3,3)     - attitude matrix
;
; AUTHOR:
;     Tod Strohmayer
;
syntax = "<att(3,3)> = ATT_Q(quat(4))"
;-
IF N_PARAMS() EQ 0 OR N_ELEMENTS(quat) NE 4 THEN BEGIN
  PRINT, "Syntax: ", syntax
  RETURN, 0
ENDIF
;
; ****************************************************************************

Att = DBLARR(3,3)
q1 = quat(0) & q2 = quat(1) & q3 = quat(2) & q4 = quat(3)

; Calculate the (columns, rows) as shown in Wertz p. 414
; (Note that the indexing is the transpose of Tod's XTEAMAT 
; and Wertz's - sorry!)
Att(*,0) = [q1^2-q2^2-q3^2+q4^2, 2*(q1*q2+q3*q4), 2*(q1*q3-q2*q4)]
Att(*,1) = [2*(q1*q2-q3*q4), -q1^2+q2^2-q3^2+q4^2, 2*(q2*q3+q1*q4)]
Att(*,2) = [2*(q1*q3+q2*q4), 2*(q2*q3-q1*q4), -q1^2-q2^2+q3^2+q4^2]
RETURN, Att
END

;+
FUNCTION SKYSCAXES_ATT, att
; SUBROUTINE:
;     SKYSCAXES_ATT
;
; DESCRIPTION:
;     computes from the attitude matrix the cartesian (inertial)
;     coordinates of each of the three spacecraft axes.
;
; Parameters:
;     att(3,3)    - attitude matrix
; Return value:
;     coor(3,3)   - output x,y,z intertial coordinates of s/c axes
; AUTHOR:
;     Tod Strohmayer
;
; MODIFICATION HISTORY:
;
; NOTES:
;     coor contains the x,y,z three spacecraft axes. 
;     coor(0,*) = X axis, for 2nd index, 0 = x, 1 = y, 2 = z
;     coor(1,*) = Y axis      "
;     coor(2,*) = Z axis      "
;     (x,y,z) is a unit vector

syntax = "<coor(3,3)> = SKYSCAXES_ATT(att(3,3))"
;-
IF N_PARAMS() EQ 0 THEN BEGIN
  PRINT,  "Usage: " + syntax
  RETURN, 0
ENDIF  
;     
coor = att ; this is trivial due to the earlier definition of the row/column
           ; convention for the attitude matrix.
RETURN, coor
END
      
;+
FUNCTION SKY_ATTSC, att, coorin, INVERT=invert
; SUBROUTINE:
;     SKY_ATTSC,
;
; DESCRIPTION:
;     Uses the attitude matrix from ATT_Q to transform a unit vector
;      in XTE spacecraft coordinates to inertial coordinates (Cartesian
;      RA, Dec), or vice versa.
;     
; Parameters:
;     att(3,3)     - attitude matrix
;     coorin(3)    - input coordinates
; Keywords:
;     invert not set =   coorin treated as s/c coord & coorout as inertial
;     invert set     =   coorin treated as intertial coord & coorout as s/c
; Return value:
;     coorout(3)   - output coordinates
;
; AUTHOR:
;     Tod Strohmayer
;
; MODIFICATION HISTORY:
;
; NOTES:
;
; "Inertial coordinates" are just RA and Dec expressed as a unit vector
; in Cartesian The conversion is (with RA and Dec in degrees):
; 
;      coor(0) = cos(pi*dec/180.) * cos(pi*ra/180.)
;      coor(1) = cos(pi*dec/180.) * sin(pi*ra/180.)
;      coor(2) = sin(pi*dec/180.)

syntax = "<coorout(3)> = SKY_ATTSC(att(3,3), coorin(3), [/INVERT])"
;-

IF N_PARAMS() EQ 0 OR N_ELEMENTS(coorin) NE 3 THEN BEGIN
  PRINT,  "Syntax: ", syntax
  RETURN, 0
ENDIF  
;     

;  Do Transformation or inverse using att from ATT_Q

IF KEYWORD_SET(invert) THEN coorout = TRANSPOSE(att) # coorin $
ELSE coorout = att # coorin

RETURN, coorout
END
; Shadow the INVERT keyword with a reverse function name, SC_ATTSKY:
FUNCTION SC_ATTSKY, att, coorin
syntax = "<coorout(3)> = SC_ATTSKY(att(3,3), coorin(3))"
;-
IF N_PARAMS() EQ 0 OR N_ELEMENTS(coorin) NE 3 THEN BEGIN
  PRINT,  "Syntax: ", syntax
  RETURN, 0
ENDIF  
;     
coorout = TRANSPOSE(att) # coorin
RETURN, coorout
END

;+
FUNCTION SKY_RD, RADecdeg
;
; Returns Cartesian coordinates corresponding to RaDecdeg = [RA, Dec]
; Input parameters:
; RADecdeg (DBLARR(2)) - input RA and Dec as a vector
;
syntax = "<[x,y,z]> = SKY_RD([RA, Dec])"
;-
IF N_PARAMS() EQ 0 THEN BEGIN
  PRINT, "Syntax: ", syntax
  RETURN, 0
ENDIF

vec = DBLARR(3)
vec(0) = COS(!PI*RADecdeg(1)/180.) * COS(!PI*RaDecdeg(0)/180.)
vec(1) = COS(!PI*RADecdeg(1)/180.) * SIN(!PI*RaDecdeg(0)/180.)
vec(2) = SIN(!PI*RADecdeg(1)/180.)
RETURN, vec
END

;+
FUNCTION RD_SKY, Xyzvec
;
; Returns a vector containing [RA, Dec] corresponding to Cartesian vector Xyzvec
; Input parameters:
; Xyzvec (DBLARR(3)) - input [x, y, z] coordinates
;
syntax = "<[RA, Dec]> = RD_SKY([x, y, z])"
;-
IF N_PARAMS() EQ 0 THEN BEGIN
  PRINT, "Syntax: ", syntax
  RETURN, 0
ENDIF

Decdeg = 90.0 - 180./!PI * ACOS(Xyzvec(2))
IF (Xyzvec(0) EQ 0.0 and Xyzvec(1) EQ 0.0) THEN Radeg = 0.0 $
ELSE BEGIN
  Radeg = 180./!PI * ATAN(Xyzvec(1), Xyzvec(0)) 
  IF (Radeg LT 0.0) THEN Radeg = Radeg + 360.0
ENDELSE  
RETURN, [Radeg,Decdeg]
END

;+
FUNCTION ROT_AXISANGLE, Evec, Phideg
; Return a matrix for a rotation around some axis 
; Evec by Phideg degrees. See Wertz p. 413.
;
syntax = "<matrix> = ROT_AXISANGLE(vector(3), angle(deg))"
;-
IF N_PARAMS() EQ 0 THEN BEGIN
  PRINT, "Syntax: ", syntax
  RETURN, 0
ENDIF

c = COS(Phideg *!PI/180.) & s = SIN(Phideg *!PI/180.)

norm = SQRT(TOTAL(Evec^2))
e1 = Evec(0) / norm & e2 = Evec(1) / norm & e3 = Evec(2) / norm

mat = DBLARR(3,3)
mat(*,0) = [c+e1^2*(1-c),     e1*e2*(1-c)+e3*s, e1*e3*(1-c)-e2*s]
mat(*,1) = [e1*e2*(1-c)-e3*s, c+e2^2*(1-c),     e2*e3*(1-c)+e1*s]
mat(*,2) = [e1*e3*(1-c)+e2*s, e2*e3*(1-c)-e1*s, c+e2^2*(1-c)    ]

RETURN, mat
END

