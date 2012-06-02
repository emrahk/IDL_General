PRO plothardness,files,path=path,channels=channels,comp_channel=comp_channel, $
                 annotate=annotate,error=error,lightcurve=lightcurve, $
                 nocolor=nocolor,grid=grid,plot_channel=plot_channel, $
                 col_data=col_data,col_err=col_err,over=over,fadd=fadd
;+
; NAME:
;       PLOTHARDNESS
;
;
; PURPOSE:
;       calculate and plot hardness ratios
;
;
; CATEGORY:
;       spectrum
;
;
; CALLING SEQUENCE:
;       plothardness,files,path=path,channels=channels,comp_channel=comp,
;       /annotate,/error,/lightcurve,/nocolor,/grid,plot_channel=pc,
;       col_data=col1,col_err=col2,/over,fadd=fadd
;
; 
; INPUTS:
;       files    : the files to be processed
;       channels : array consisting of channelpairs
;       comp     : that entry from the array above to which all pairs
;                  are compared 
;       
;
;
; OPTIONAL INPUTS:
;       pc   : the channel to be plotted. If omitted, al channels are plotted.
;       col1 : color of data
;       col2 : color of error
;       fadd : number of files to be added. If omitted all files are
;              processed alone
;
;	
; KEYWORD PARAMETERS:
;       /annotate   : print some information
;       /error      : calculate and plot errorbars
;       /lightcurve : plot a lightcurve consisting of all files
;       /nocolor    : do not plot hardness ratios.
;       /grid       : plot a grid
;       /over       : use an existing window
;       
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;       a hardness ratio (or color) is calculated by dividing a
;       certain energy range through another one. This is done for all
;       input files and the resulting colors are plotted.
;
;
; EXAMPLE:
;       files=['vela_2_0pwa.pha','vela_2_1pwa.pha','vela_2_2pwa.pha', $
;       'vela_2_3pwa.pha','vela_2_4pwa.pha','vela_2_5pwa.pha', $
;       'vela_2_6pwa.pha','vela_2_7pwa.pha','vela_2_8pwa.pha', $
;       'vela_2_9pwa.pha','vela_2_10pwa.pha','vela_2_11pwa.pha', $
;       'vela_2_12pwa.pha','vela_2_13pwa.pha','vela_2_14pwa.pha', $
;       'vela_2_15pwa.pha','vela_2_16pwa.pha','vela_2_17pwa.pha', $
;       'vela_2_18pwa.pha','vela_2_19pwa.pha'] 
;
;       ch=[[12,30],[31,47],[48,60],[61,100],[101,200]]
;       cc = 2
;       fadd = [0,2]
;       plothardness,files,path=pfad,channels=ch,comp_channel=cc, $
;         col_data=farbe,/error,/annotate,/nocolor,/lightcurve
;
;
;
;
; MODIFICATION HISTORY:
;       written 1996 by Ingo Kreykenbohm, AIT
;-

;; files :        contains the list of pha files
;; path :         the path to the files. If no path is given, it is assumed
;;                that the files contain the complete path
;; channels :     contains a lsit of channelpairs
;; comp_channel : the number of the channel to which the others are
;;                compared
;; plot_channel : which channel shall be plotted. If none, all are
;;                plotted
;; fadd :         how many files should be added together. If none is
;;                given, each file is processed alone 
;; /annotate :    if given, some documentation is printed in the plot
;; /error :       plot errorbars
;; /lightcurve :  if given, lightcurves from the above selected
;;                channels are plotted
;; /nocolor :     no colorcurve is plotted - demands /lightcurve to do
;;                anything
;; /grid    :     plots a vertical grid 
;; /over :        use an existing window (overplotting)
;; coldata :      the resulting colors are returned


;; check if all necessary parameters are given
 

IF (keyword_set(nocolor) AND (NOT keyword_set(lightcurve))) THEN BEGIN
    print,'Nothing to plot.'
END

IF (n_elements(files) EQ 0) THEN BEGIN
    print,'Error : No input files'
    return
END

IF (n_elements(fadd) EQ 0) THEN BEGIN
    fadd = 1
END 

nfil=n_elements(files)

IF (n_elements(comp_channel) EQ 0) THEN BEGIN
    print,'Warning : No Compare Channel specified. Assuming first channel.'
    comp_channel = 0
END
IF (n_elements(plot_channel) EQ 0) THEN BEGIN
    pcmin = 0
    pcmax = n_elements(channels(0,*)) - 1
END ELSE BEGIN
    pcmin = plot_channel
    pcmax = plot_channel
END
IF (n_elements(channels) EQ 0) THEN BEGIN
    print,'Error : no channels specified.'
    return
END
IF ((n_elements(channels) LT 2) AND (NOT keyword_set(nocolor))) THEN BEGIN
    print,'Error : Need at lest 2 channels to compute a color'
    return
END
IF (((n_elements(channels) LT comp_channel) OR (n_elements(channels) LT 0)) $
    AND (NOT keyword_set(nocolor))) THEN BEGIN
    print,'Error : compare channel does not exist.'
    return
END

IF (n_elements(path) EQ 0) THEN path = ''

;; initializing variables

;IF (keyword_set(back)) THEN BEGIN
;    back_files = strmid(files,0,strlen(files)-3)
;END 

nbins=n_elements(channels(0,*))
bins=fltarr(nfil,nbins)
abins = fltarr(nfil-fadd+1,nbins)
binerr= fltarr(nfil,nbins)
abinerr = fltarr(nfil-fadd+1,nbins)

exposure=0.
c = fltarr(256)
FOR i=0,nfil-1 DO BEGIN
    p=0
    readpha,counts,counterr,rate,back,path+files(i),exposure=exposure,poisson=p
    IF (p EQ 1) THEN counterr = sqrt(counts)
    FOR j=0,nbins-1 DO BEGIN 
        a=channels(0,j)
        b=channels(1,j)
        bins(i,j)=total(counts(a:b))/exposure
        IF (keyword_set(error)) THEN binerr(i,j)=sqrt(bins(i,j)/exposure)
    ENDFOR 
ENDFOR 

a=indgen(fadd)
FOR i=0,nfil-fadd DO BEGIN
    FOR j=0,nbins-1 DO BEGIN
        abins(i,j) = total(bins(i+a,j))
        abinerr(i,j) = sqrt(total(binerr(i+a,j)^2))
    END
END
bins = abins
binerr = abinerr

loadct,39

pha=indgen(nfil)

;; plot lightcurve
IF (keyword_set(lightcurve)) THEN BEGIN
    plot,[0,nfil-1],[0,max(bins)],/nodata
    FOR i=0,nbins-1 DO BEGIN 
        oplot,pha,bins(*,i)
        IF (keyword_set(error)) THEN BEGIN
            FOR j=0,nfil-1 DO BEGIN
                oplot,[pha(j),pha(j)],[bins(j,i)-binerr(j),bins(j,i)+binerr(j)]
            ENDFOR
        END
    ENDFOR 
END

;; if lightcurve and color is demanded, wait for a keystroke
IF (keyword_set(lightcurve) AND (NOT keyword_set(nocolor))) THEN BEGIN
    print,'Press any key to continue'
    taste = get_kbrd(1)
END

;; plot colors
IF (NOT keyword_set(nocolor)) THEN BEGIN
    IF (NOT keyword_set(over)) THEN begin
        ;; if doc wanted, create a plot and a small doc window
        IF (keyword_set(annotate)) THEN BEGIN 
            !p.multi=[0,1,2]
            plot,[0,nfil-1],[-1.,+1.],position=[0.05,0.2,0.95,0.95],/nodata
        ENDIF ELSE BEGIN
            plot,[0,nfil-1],[-1.,+1.],position=[0.05,0.05,0.95,0.95],/nodata
        ENDELSE
    end
    c1 = comp_channel
    ls = 0.0
    FOR c0 = pcmin, pcmax DO BEGIN
        IF (NOT(c0 EQ c1)) THEN BEGIN
            c=(bins(*,c0)-bins(*,c1))/(bins(*,c0)+bins(*,c1))
            coldata=c
            oplot,pha,c,linestyle = ls
            ls = ls + 1.
            ;; calculate error and plot it
            IF (keyword_set(error)) THEN BEGIN
                FOR i=0,nfil-fadd DO BEGIN
                    df=sqrt((2.*bins(i,c1)/(bins(i,c0)+bins(i,c1))^2* $
                             binerr(i,c0))^2 +  $
                            (2.*bins(i,c0)/(bins(i,c0)+bins(i,c1))^2* $
                             binerr(i,c1))^2)
                    oplot,[i,i],[c(i)-df,c(i)+df]
                ENDFOR
            END
        END
    ENDFOR
    ;; plot a grid
    IF (keyword_set(grid)) THEN BEGIN
        FOR j=1,19 DO BEGIN
            oplot,[0,nfil],[j/10.-1.,j/10.-1.],linestyle=1
        ENDFOR
    END

    ;; print/plot documentation
    IF (keyword_set(annotate)) THEN BEGIN
        plot,[0,nfil-1.],[0.,1.],position=[0.05,0.05,0.95,0.19],/nodata, $
          xstyle=4,ystyle=4 ; do not plot any axis
        xyouts,0.,0.6,'Compare :        -'
        xyouts,1.3,0.6,channels(0,c1)
        xyouts,2.7,0.6,channels(1,c1)
        ls = 0
        FOR j = pcmin,pcmax DO BEGIN
            IF (not(j EQ c1)) THEN BEGIN
                oplot,[1.5+4*ls,5.1+4*ls],[0.05,0.05],linestyle = ls
                xyouts,2.3+4*ls-1,0.15,channels(0,j)
                xyouts,3.3+4*ls,0.15,'- '
                xyouts,2.7+4*ls,0.15,channels(1,j)
                ls = ls + 1
            END
        ENDFOR

    END
        
END ELSE BEGIN 
    c1 = comp_channel
    ls = 0.0
    FOR c0 = pcmin, pcmax DO BEGIN
        IF (NOT(c0 EQ c1)) THEN BEGIN
            c=(bins(*,c0)-bins(*,c1))/(bins(*,c0)+bins(*,c1))
            coldata=c
            ;; calculate error 
            IF (keyword_set(error)) THEN BEGIN
                FOR i=0,nfil-fadd DO BEGIN
                    df=sqrt((2.*bins(i,c1)/(bins(i,c0)+bins(i,c1))^2* $
                             binerr(i,c0))^2 +  $
                            (2.*bins(i,c0)/(bins(i,c0)+bins(i,c1))^2* $
                             binerr(i,c1))^2)
                ENDFOR
            END
        END
    ENDFOR
END     

;; that's all folks !

END
