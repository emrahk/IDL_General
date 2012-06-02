;+
; NAME:
;                   readorbit
;
;
; PURPOSE:
;                   Read mission orbit file and compute ephemerides for
;                   given times.
;
;
; CATEGORY:
;                   barycenter correction, fits
;
;
; CALLING SEQUENCE:
;                   orbit = readorbit(filename, date,exten=exten)
;
;
;
; INPUTS:
;                   filename - The orbit file name. An orbit fits file must
;                              contain the following
;                              - TSTART, TSTOP
;                              - TIMEDEL or DELTAT
;                              - MJDREFI, MJDREFF - reference times in
;                                                    MJD
;                              - The columns X, Y, Z and VX, VY, VZ of
;                                the spacecraft in FK5 coordinates in
;                                respect of the geo center, values
;                                given in m and m/sec.
;                                
;                              It is possible to enter more than orbit
;                              file by setting file name as an array
;                              of strings. If the date is not covered
;                              by the orbit files an error message is
;                              raised. 
;
;                  date      - a list of dates for which the orbit
;                              should be computed. The date must be
;                              given in reduced julian date (= JD -
;                              2400000). 
;
; OPTIONAL INPUTS:
;                  exten     - The extension to use in the orbit
;                              file. Default is 1. 
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;                  READORBIT returns a 2-dim array containing the
;                  spacecraft positions for each date input. The
;                  position is given in meter within the FK5 reference
;                  frame.
;                  Each point maps to the input date given in reduced
;                  Julian date. 
;
;
; OPTIONAL OUTPUTS:
;
;
; SIDE EFFECTS:
;                   None. 
;
;
; RESTRICTIONS:
;                   This procedure needs a lot of memory because we
;                   read all orbit information before starting any
;                   processing.
;                   But: in case of several orbit files only the
;                   matching part will be read. 
;
;
;
; PROCEDURE:
;                   This function may be used to compute the orbit
;                   input for the barycen command.
;
;                   The function first reads the entries of an orbit
;                   file, checks the range, looks for appropriate
;                   intervals for each date and interpolates the
;                   position.
;                   If several orbit files are used all covered part
;                   of the data will be interpolated and afterwards
;                   checked wether all data points are covered.
;
; EXAMPLE:
;                   Typical lightcurve processing would look like:
;                    > readlc, time,rate,"test.lc", /mjd
;                    > time_rjd = time+0.5D ; convert to reduced
;                                           ; julian date                            
;                    > orbit = readorbit("xte_orbit",      $ ; convert
;                                        time_rjd)/1000.D0   ; into km (!)
;                    > time_bary = $
;                       barycen(time_rjd,ra,dec,orbit=orbit)
;                    -> perform bary center correction with given
;                       orbit file. 
;
;
;
; MODIFICATION HISTORY:
;                   $Log: readorbit.pro,v $
;                   Revision 1.2  2003/04/29 09:34:09  goehler
;                   updated missleading description concerning the example using m/km units
;
;                   Revision 1.1  2002/09/17 12:38:33  goehler
;                   Initial but tested version (in conjunction with barycen)
;
;
;-


FUNCTION readorbit,filename, date, exten=exten


    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------
    
    ;; define default extension -> first extension
    IF n_elements(exten) EQ 0 THEN exten = 1

    ;; mjd - date in MJD instead reduced julian date
    mjd = date - 0.5D


    ;; array describing the coverage of the date in respect of the
    ;; orbit files
    coverage = bytarr(n_elements(mjd))

    ;; resulting orbit information:
    orbit = dblarr(3,n_elements(mjd))


    ;; ------------------------------------------------------------
    ;; READ ORBIT DATA 
    ;; ------------------------------------------------------------
    
    ;; for each file: read orbit:
    FOR i=0,n_elements(filename)-1 DO BEGIN 

        ;; read header information:
        orbheader=headfits(filename[i], exten=exten)


        ;; extract reference time (mjd):
        tref = (double(fxpar(orbheader, "TIMEZERO")) +$
                double(fxpar(orbheader, "MJDREFF"))) + $ 
                double(fxpar(orbheader, "MJDREFI"))

        ;; extract tstart,tstop, deltat:
        tstart = double(fxpar(orbheader, "TSTART"))
        tstop = double(fxpar(orbheader, "TSTOP"))



        ;; compute tstart/tstop in mjd:
        tstart = tstart/86400.D0 + tref
        tstop = tstop/86400.D0 + tref

        ;; get time delta:
        deltat = double(fxpar(orbheader, "DELTAT"))

        ;; parameter not found -> look for timedel:
        IF !ERR EQ -1 THEN deltat = double(fxpar(orbheader, "TIMEDEL"))


        ; which part of data ist covered with the orbits:
        coverindex = where(mjd GT tstart AND mjd LT tstop)

        ;; nothing covered -> next orbit file 
        IF coverindex[0] EQ -1 THEN CONTINUE

        ;; set covering:
        coverage[coverindex] = 1


        ;; ------------------------------------------------------------
        ;; GET ORBIT INFORMATION
        ;; ------------------------------------------------------------


        ;; read position/velocity of space craft:
        ftab_ext,filename[i], "Time,X,Y,Z,VX,VY,VZ",$
          time, xorb, yorb,zorb,vxorb,vyorb,vzorb, exten=exten

        ;; convert time to MJD:
        time = time/86400.D0 + tref


        ;; ------------------------------------------------------------
        ;; INTERPOLATE 
        ;; ------------------------------------------------------------
        

        ;; perform quadratic interpolation on covered data points:
        orbit[0,coverindex] = interpol(xorb,time,mjd[coverindex],/quadratic)
        orbit[1,coverindex] = interpol(yorb,time,mjd[coverindex],/quadratic)
        orbit[2,coverindex] = interpol(zorb,time,mjd[coverindex],/quadratic)


    ENDFOR 



    ;; ------------------------------------------------------------
    ;; CHECK RANGE 
    ;; ------------------------------------------------------------

    ;; some cover elements not set -> not all datapoints defined
    IF (where(coverage EQ 0))[0] NE -1 THEN BEGIN 
        index=where(coverage EQ 0) 
        print, "Not covered: from ",min(date[index])," to " ,max(date[index])
      message, "Error - date not covered by orbit file(s)." 
  ENDIF 


    ;; ------------------------------------------------------------
    ;; THAT'S IT
    ;; ------------------------------------------------------------

    return, orbit
END 

