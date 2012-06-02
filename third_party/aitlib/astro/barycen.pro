function barycen, date, ra, dec, B1950 = B1950, TIME_DIFF = time_diff, $
                  ephemfile=ephemfile, orbit=orbit
;+
; NAME:
;      BARYCEN
;      
; PURPOSE:
;      Convert geocentric (reduced) Julian date to helio bary centric Julian
;      date
;      
; EXPLANATION:
;      This procedure correct for the extra light travel time between the Earth 
;      and the bary center of the Sun.
;
; CALLING SEQUENCE:
;       bary_time = BARYCEN( date, ra, dec, /B1950, /TIME_DIFF)
;
; INPUTS
;       date - reduced Julian date (= JD - 2400000), scalar or vector, MUST
;               be double precision.
;
;               The date describes an event at the geocentric time. 
;
;               The format of date can be a vector which is recommended for
;               computing several dates because ephemeris file will be
;               accessed only once.
;               
;      ra,dec - scalars giving right ascension and declination of the
;               observed object in DEGREES
;               Equinox is J2000 unless the /B1950 keyword is set.
;
;               The object direction is needed to take into account
;               the time delay due light travelling from center to
;               earth to the common solar bary center. 
;
; OUTPUTS:
;       bary_time - solar bary centric reduced Julian date.
;                   If /TIME_DIFF is set, then BARYCEN() instead
;                   returns the time difference in seconds of
;                   barycentric-geocentric Julian date. 
;
; OPTIONAL INPUT:
;   ephemfile - (string) The file which contains JPL ephemeris
;               information. It must have the JPLEPHREAD specific
;               format. Public available are
;               - JPLEPH.200 - JPL-DE200 which is the older but well
;                               known ephemeris data file.
;               - JPLEPH.405 - JPL-DE405 is more recent and precise.
;               
;               It is possible to build one's own ephemeris
;               file. Refer JPLEPHREAD procedure.
;
;               This file is not needed if the pinfo and pdata input
;               variables are set. 
;
;               If this file is not given BARYCEN looks for the
;               environment variable "ASTRO_DATA" describing a
;               directory which must contain the file "JPLEPH.405". 
;               If the ephemeris file is not found an error is raised.
;
;  orbit      - 2-dim array of double containing the orbit position
;               information in respect of the geocenter. The position
;               must be given for all dates given with the DATE
;               input. Position must be given in FK5 coordintates (or
;               ICRF if using JPLEPH.405) in units of km.
;               Dimensions must be: array(3,n_elements(date)).
;
;               If orbit is not given the correction will be performed
;               at the center of the earth.
;
;               Note: as mentioned by the different authors the use of
;               the input date to define the orbit (and earth) vector
;               uses an circular argumentation; but the error due to
;               the small contribution of this correction is small. 
;
; DESCRIPTION:
;                Main steps of the correction are taken from
;                C. Marquardts description in
;                http://lheawww.gsfc.nasa.gov/users/craigm/bary/
;                which gives a good overview of the relevant aspects.
;                BARYCEN does not perform a dispersion time
;                correction.
;
;                The procedure first reads the jpl ephemeris file
;                taking the part which is needed for all dates to
;                convert. Then the coordinates of the earth for all
;                dates are computed within the FK5 (or ICRF when using
;                DE405 ephemerides which is mostly the same like FK5)
;                coordinate system, origin located at the solar system
;                bary center.
;                Additionally a unit vector is derived from the RA/DEC
;                position which is converted also to the FK5
;                coordinate system (J2000 equinox).
;                Finally the projection of this vector at the
;                coordinates of the earth yield the distance the light
;                must travel; ivided by the speed of light this gives the
;                time delay we are looking for.
;
;                We should mention that JPL DE200 ephemeris are
;                defined for the FK5 (J2000) coordinate system while
;                the DE405 is defined for the ICRS coordinate
;                system. They are defined close together but not
;                exact.
;                For the algorithm we always use FK5 coordinates
;                (i.e. computing all in J2000 and not e.g. in the
;                Hipparcos IRCS J1991.25 system). The difference lies
;                in the region of ~50-80mas.
;
;                Care must be taken when using the orbit input because
;                errors in the orbit position directly influence the
;                correction in a non-neglectable manner.
;
;                Internally all computations are performed in units of
;                km and seconds.
;                 
; OPTIONAL INPUT KEYWORDS:
;       /B1950 - if set, then input coordinates are assumed to be in equinox 
;                B1950 coordinates.
;                Default is the J2000 equinox.
;                
;       /TIME_DIFF - if set, then HELIO_JD() returns the time difference
;                (helio bary centric JD - geocentric JD ) in seconds. 
;
; EXAMPLE:
;       What is the barycentric Julian date of an observation of V402 Cygni
;       (J2000: RA = 20 9 7.8, Dec = 37 09 07) taken June 15, 1973 at 11:40 UT?
;
;       IDL> juldate, [1973,6,15,11,40], jd      ;Get geocentric Julian date
;       IDL> hjd = barycen( jd, ten(20,9,7.8)*15., ten(37,9,7) )  
;                                                            
;       ==> hjd =  41848.988072569
;
; REMARKS:
;       Reading of orbit files could be performed with the fits
;       accessing function READORBIT().
;
;       !!! Care must be taken for the units of the result of the
;       !!! readorbit procedure. Satellite orbit files usually contain
;       !!! the spacecraft position in meters while here we are
;       !!! using kilometers!.
;
;
; PROCEDURES CALLED:
;       jplephread, jplephinterp,
;       jprecess, tdb2tdt
;
; TESTS:
;       Processed RXTE lightcurves of GX301 (thank you, Ingo) with
;       barycen and checked result against fxbary product.
;       Maximal difference was proven to be in the range of
;       1.2572855e-06 sec while the averaged difference was
;       9.5243109e-08 sec. (17-09-2002, E. Goehler)
;
; REVISION HISTORY:
;       $Log: barycen.pro,v $
;       Revision 1.4  2003/04/29 09:34:48  goehler
;       added warning concerning units in km when using the readorbit() function
;
;       Revision 1.3  2002/09/17 12:49:17  goehler
;       Fix of wrong used JPLEPHINTERP function in respect of velocities.
;       Tests yielded difference to fxbary in the range of less than 1usec.
;
;       Revision 1.2  2002/09/13 16:14:43  goehler
;       preliminary tests give good results (~10msec) for geocentric case. Use of
;       orbit files still bad.
;
;       Revision 1.1  2002/09/12 14:13:58  goehler
;       first version,
;       !!! still not tested !!!
;
;-

;; return to caller:
; ON_ERROR,2

 ;; ------------------------------------------------------------
 ;; SETUP
 ;; ------------------------------------------------------------

 If N_params() LT 3 then $
   message, "Invalid number of parameters"


 ;; All computation are done in FK5 (J2000) coordinates.
 ;; if B1950 given -> convert it, otherwise keep coordinates:
 if keyword_set(B1950) then jprecess,ra,dec,ra1,dec1 else begin
     ra1 = ra
     dec1 = dec
 endelse

 ;; conversion factor of radians to degree:
 radeg = 180.0d/!DPI   

 ;; convert coordinates to radians:
 ra1 = ra1/radeg
 dec1 = dec1/radeg


 ;; get minimum/maximum date + 1day margin
 mindate = min(date)-1.D0
 maxdate = max(date)+1.D0

 ;; ------------------------------------------------------------
 ;; READ EPHEMERIS DATA 
 ;; ------------------------------------------------------------

 ;;  look for ephemeris file in $ASTRO_DATA
 IF n_elements(ephemfile) EQ 0 then begin     
     ephemfile = find_with_def('JPLEPH.405','ASTRO_DATA')
 ENDIF 
     
 ;; none found
 IF NOT file_exist(ephemfile) THEN $
   message,"Error: JPL Ephemeris file "+ephemfile+" not found"

 ;; read data:
 JPLEPHREAD,ephemfile,pinfo,pdata,[mindate,maxdate]+2400000.D0, $
   status=status, errmsg=errmsg

 ;; successfull?
 IF status EQ 0 THEN message,"Ephemeris file reading failed: "+errmsg



 ;; ------------------------------------------------------------
 ;; COMPUTE COORDINATES OF CENTER EARTH + VELOCITY OF EARTH
 ;; ------------------------------------------------------------

 ;; get FK5 coordinates (x,y,z) of earth in respect of  solar bary center, in
 ;; reduced julian date (tbase reflects this),
 ;; and we also need the speed of earth for einstein orbit correction
 JPLEPHINTERP,pinfo,pdata,date,x_earth,y_earth,z_earth,     $
   vx_earth, vy_earth,vz_earth,/earth,                      $
   posunits="KM", tbase=2400000.D0,velunits='KM/S',/velocity
   


 ;; ------------------------------------------------------------
 ;; COMPUTE COORDINATES OF CENTER SUN (for shapiro correction)
 ;; ------------------------------------------------------------

 ;; get FK5 coordinates (x,y,z) of earth in respect of  solar bary center, in
 ;; reduced julian date (tbase reflects this):
 JPLEPHINTERP,pinfo,pdata,date,x_sun,y_sun,z_sun,/sun,$
   posunits="KM", tbase=2400000.D0

 ;; ------------------------------------------------------------
 ;; COMPUTE COORDINATES OF OBSERVATORY (if not center of earth)
 ;; ------------------------------------------------------------


 x_obs = x_earth
 y_obs = y_earth
 z_obs = z_earth


 ;; use orbit information if given:
 IF n_elements(orbit) NE 0 THEN BEGIN 
     x_obs = x_obs + orbit[0,*]
     y_obs = y_obs + orbit[1,*]
     z_obs = z_obs + orbit[2,*]
 ENDIF 


 ;; ------------------------------------------------------------
 ;; COMPUTE GEOMETRIC CORRECTION
 ;; ------------------------------------------------------------
 ;; This is the barycentric correction due to the travelling of light
 ;; from earth to the solar bary center. We must project the
 ;; observatory position to the object direction to get the time
 ;; difference (because this difference immediately depends on the
 ;; object position in respect of the earth-bary center connection).

 ;; components of the object coordinate unit vector:
 x_obj = cos(dec1)*cos(ra1)
 y_obj = cos(dec1)*sin(ra1)
 z_obj = sin(dec1)

 

 ;; scalar product of stellar object vector,earth vector, divided by c
 ;; in units of km/sec ( c is given in m/sec)
 geo_corr = (x_obs * x_obj + y_obs * y_obj + z_obs * z_obj ) / pinfo.c * 1000.d0



 ;; ------------------------------------------------------------
 ;; COMPUTE EINSTEIN CORRECTION
 ;; ------------------------------------------------------------
 ;; The correction must be applied to take into account both the speed
 ;; of the observatory in respect of the inertial bary center and also
 ;; the influence of the gravitational potential of the sun/planetary
 ;; masses.
 ;; Both effects are treated according the numerical description from
 ;; Fairhead & Bretagnon (1990) in respect of the geo center.
 ;; Additional corrections must be applied for an observatory with an
 ;; orbit, using the speed of the earth. 


 einstein_corr = TDB2TDT(date, $             ; correction to center of earth (the name of
                         tbase=2400000.D0)   ; the procedure is missleading: we
                                             ; actually correct from terestrial to
                                             ; bary centric time)

 ;; take orbit into account if given with
 ;; corr = (r_sat*vearth)/c^2
 IF n_elements(orbit) NE 0 THEN BEGIN 
     
     orb_corr= (vx_earth * orbit[0,*] + vy_earth * orbit[1,*] + vz_earth * orbit[2,*]) $
       / ((pinfo.c / 1000.D0)^2)

     einstein_corr = einstein_corr + orb_corr
 ENDIF 

 ;; ------------------------------------------------------------
 ;; COMPUTE SHAPIRO CORRECTION
 ;; ------------------------------------------------------------

 
 ;; distance of sun to observatory:
 sun_dist = sqrt((x_sun-x_obs)^2+(y_sun-y_obs)^2 + (z_sun-z_obs)^2)

 ;; cosine of unit vector sun->obs and unit vector obs -> object:
 costh = ((x_obs-x_sun)*x_obj+(y_obs-y_sun)*y_obj + (z_obs-z_sun)*z_obj)/sun_dist
 
 
 ;; apply shapiro correction. Sign in accordance with axbary.
 ;; refer  I.I. Shapiro, Phys. Rev. Lett. 13, 789 (1964)).
 shapiro_corr =  2 *pinfo.msol * alog(1+costh)


 ;; ------------------------------------------------------------
 ;; SUMMARIZE CORRECTIONS
 ;; ------------------------------------------------------------

 time = geo_corr + einstein_corr+ shapiro_corr

 if keyword_set(TIME_DIFF) then return, time else $           
       return, double(date) + time/86400.0d

 end

