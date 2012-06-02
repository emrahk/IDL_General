PRO gtifilt,data,gti,debug=debu
    ;; 
    ;; filter the data for goodtimes on data.time, the good-times
    ;; are kept in the array gti, where gti[0,*] is the starting
    ;; time of the gti interval, and gti[1,*] the stop time.
    ;;

    ;;
    ;; $Log: gtifilt.pro,v $
    ;; Revision 1.1  2003/04/23 12:54:20  wilms
    ;; initial version, still without docheader...
    ;;
    ;;

    gtinum=n_elements(gti[0,*])

    ndx=where(data.time GE gti[0,0],num)
    IF (num GT 0) THEN BEGIN 
        data=temporary(data[ndx])
    ENDIF ELSE BEGIN 
        message,'Selection did not result in any data'
    ENDELSE 

    IF (gtinum GT 1) THEN BEGIN 
        FOR i=1,gtinum-1 DO BEGIN 
            ndx=where(data.time LT gti[1,i-1] OR data.time GE gti[0,i],num)
            IF (num GT 0) THEN BEGIN 
                data=temporary(data[ndx])
            ENDIF ELSE BEGIN 
                message,'Selection did not result in any data'
            ENDELSE
        ENDFOR
    ENDIF 
    ndx=where(data.time LT gti[1,gtinum-1],num)

    IF (num GT 0) THEN BEGIN 
        data=temporary(data[ndx])
    ENDIF ELSE BEGIN 
        message,'selection did not result in any data'
    ENDELSE
END 
