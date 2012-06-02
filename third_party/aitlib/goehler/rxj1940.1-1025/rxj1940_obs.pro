; observations of rxj 1940.1-1025
; in 2001
; 22.1.2002, eg
;------------------------------------------------------------

; observation structure:
OBS={obs_struct, obs_str:'', obs_start:0.D0, obs_end: 0.D0 }

; number of observations:
OBS_NUM = 9
OBSERVATIONS=REPLICATE(OBS,OBS_NUM);


;; observations-entries, time in MJD:
OBSERVATIONS[0] = {obs_struct, "Optical, SSO 40'':", $
                    5.201368423600e+04,  5.201682427100e+04 }

OBSERVATIONS[1] = {obs_struct, "Optical, CAHA:", $
                   52108.375550-0.5,             $
                   52117.520816-0.5 } ; convert to mjd



JULDATE,[2001,10,4,11,34],stime
JULDATE,[2001,10,12,12,35],etime
OBSERVATIONS[2] = {obs_struct, "Optical, SSO 40'':", $
                    stime-0.5,  $ ; convert to mjd
                    etime-0.5}


OBSERVATIONS[3] = {obs_struct, "X-Ray, RXTE:", $
                     52014.831476 , 52018.635921}

OBSERVATIONS[4] = {obs_struct, "X-Ray, RXTE:", $
                      52114.057032,52116.975921}

OBSERVATIONS[5] = {obs_struct, "X-Ray, RXTE:", $
                       52190.990180, 52191.356291}


OBSERVATIONS[6] = {obs_struct, "X-Ray, XMM:", $
                       52191.036659, 52191.330918}

JULDATE,[2001,10,8,22,23],stime
OBSERVATIONS[7] = {obs_struct, "X-Ray, XMM:", $
                       stime-0.5, stime-0.5 + 7602./86400.}


OBSERVATIONS[8] = {obs_struct, "Optical, Hobart (Warren/Greenhill):", $
                       52025.65801, 52025.80214}



; time in MJD -> JD - 2400000
FOR i=0,OBS_NUM-1 DO BEGIN


    print, OBSERVATIONS[I].OBS_STR

    ;; print start time in MJD:
    TIME = OBSERVATIONS[I].OBS_START
    DAYCNV, time+2400000.D0, yr,mn,day,hr
    date= string(yr,format='(I4)') + "/" + string(mn,format='(I2.2)') $
           + "/" + string(day,format='(I2.2)')                        $
           + "  " + string(floor(hr)      ,format='(I2.2)') + ":"     $    
           + string(hr*60 MOD 60   ,format='(I2.2)') + ":"            $
           + string(hr *3600 MOD 60,format='(I2.2)')
    PRINT, "START: ", TIME, " MJD  (", $
      date,")", $
      format="(A,F16.6,A,A,A)"
;HELIO_JD(TIME+ 0.5, 19.666, -10.423611)

    ;; print end time:
    TIME = OBSERVATIONS[I].OBS_END
    DAYCNV, time+2400000.D0, yr,mn,day,hr
    date= string(yr,format='(I4)') + "/" + string(mn,format='(I2.2)') $
           + "/" + string(day,format='(I2.2)')                        $
           + "  " + string(floor(hr)      ,format='(I2.2)') + ":"     $    
           + string(hr*60 MOD 60   ,format='(I2.2)') + ":"            $
           + string(hr *3600 MOD 60,format='(I2.2)')
    PRINT, "END:   ", TIME, " MJD  (", $
      date,")" , $
      format="(A,F16.6,A,A,A)"
;HELIO_JD(TIME + 0.5, 19.666, -10.423611)
ENDFOR

END
