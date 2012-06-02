;==========================================================================
; Several local procedures used by plotpulse
;==========================================================================

PRO plotpulse_set_margins,box,left,right,bottom,top
;
; Local procedure to calculate useful margins
;
left   = 6*float(!d.x_ch_size)/!d.x_size+1.5*!d.y_ch_size/!d.y_size+box(0)
right  = 2*float(!d.x_ch_size)/!d.x_size+1.0-box(2)
top    = 2*float(!d.y_ch_size)/!d.y_size+1.0-box(3)
bottom = 4*float(!d.y_ch_size)/!d.y_size+box(1)
RETURN
END

;==========================================================================

PRO plotpulse_set_x_axis,xrange,band,noxmarks=noxmarks,xtickvals,xticknames
;
; Local procedure to set nice x-axis tickmarks
;
xtickvals=findgen(ceil(xrange(1)*2+1))*0.5   ;; -> 0.0,0.5,1.0,...
xtickvals=xtickvals(where( xtickvals GE xrange(0) AND xtickvals LE xrange(1)))

IF (keyword_set(noxmarks)) THEN BEGIN
    xticknames=replicate(' ',n_elements(xtickvals))
ENDIF ELSE BEGIN
    xticknames=string(form='(f3.1)',xtickvals-fix(xtickvals-1e-3))
ENDELSE
RETURN
END
;==========================================================================

PRO plotpulse_set_y_axis,y,dy,noerror=noerror,zerolower=zerolower,$
                           noymarks=noymarks,$
                           ymin,ymax,ytickvals,yticknames
;
; Local procedure to set a nice y-axis range and tickmarks
;

IF (keyword_set(noerror)) THEN BEGIN
    miny = min(y)
    maxy = max(y)
ENDIF ELSE BEGIN
    miny = min(y-dy)
    maxy = max(y+dy)
ENDELSE

IF (keyword_set(zerolower)) THEN miny=min([0.0,miny])

;;
;; Check if we have sensible data
;; Set order of magnitude for tickmarks
;;
delta=maxy-miny
IF (delta LE 0) THEN BEGIN
    print,'Warning: max(y) LE min(y), this is not normal',maxy,miny
    ymin=-1.0
    ymax=1.0
    decade=0
    tickstep=1.0
ENDIF ELSE BEGIN 
    decade=floor(alog10(delta))
    tickstep = 10.0^decade
    CASE 1 OF
        ((delta/tickstep) LE 2): tickstep=tickstep/2.0
        ((delta/tickstep) GT 4): tickstep=tickstep*2.0
        ((delta/tickstep) GT 8): tickstep=tickstep*4.0
        ELSE:
    ENDCASE
    ymin=floor(miny/tickstep)*tickstep
    ymax=ceil(1.1*maxy/tickstep)*tickstep
ENDELSE

ytickvals=findgen(10)*tickstep + ymin
ytickvals=ytickvals(where( ytickvals GT ymin AND ytickvals LT ymax ))

;; set tickmark labels
IF (keyword_set(noymarks)) THEN BEGIN
    yticknames=replicate(' ',n_elements(ytickvals))
ENDIF ELSE BEGIN
    IF (tickstep EQ fix(tickstep)) THEN BEGIN
        format = '(i'+string(form='(i1)',fix(alog10(ymax)+1))+')'
    ENDIF ELSE BEGIN
      post = abs(decade) > 1
      pre  = post+3  ; space for . - and leading zero
      format = '(f'+string(form='(i1)',pre)+'.'+string(form='(i1)',post)+')'
    ENDELSE
    yticknames = string(form=format,ytickvals)
ENDELSE
RETURN   
END


;==========================================================================

PRO make_polygons,x,y,dx,dy,poly_x,poly_y
;
; Local procedure to calculate a list of points defining polygons
; (for the "block" style of pulse profile plotting)
;

make_staircase,x,y+dy,dx,xupstair,yupstair
make_staircase,x,y-dy,dx,xlowstair,ylowstair

dim=n_elements(xupstair)

poly_x=fltarr(2*dim)
poly_y=fltarr(2*dim)

poly_x(0:dim-1)=xlowstair
FOR p=0,dim-1 DO poly_x(dim+p)=xupstair(dim-1-p)

poly_y(0:dim-1)=ylowstair
FOR p=0,dim-1 DO poly_y(dim+p)=yupstair(dim-1-p)

RETURN
END


;==========================================================================
; The actual plotpulse procedure
;==========================================================================

PRO plotpulse,profile,exposure=exposure,$
              first=first,last=last,$
              xrange=xrange,yrange=yrange,box=box,$
              title=title,xtitle=xtitle,ytitle=ytitle,annotations=annot,$
              energy=energy,channels=channels,$
              noerror=noerror,over=over,samepage=samepage,othery=othery,$
              linestyle=linestyle,psym=psym,thickness=thickness,$
              tcharsize=tcharsize,$
              colors=colors,blocks=blocks,zerolower=zerolower,$
              noxmarks=noxmarks,noymarks=noymarks,$
              verbose=verbose

;+
; NAME:
;       plotpulse
;
;
; PURPOSE:
;       Plot a pulse profile in 'pretty' fashion
;
; CATEGORY:
;       Plotting
;
; CALLING SEQUENCE:
;       plotpulse,profile
; 
; INPUTS:
;       profile : PULSEPROFILE structure
;
; OPTIONAL INPUTS:
;       first       : First energy band to plot (If not given: 1)
;       last        : Last energy band to plot (If not given: first+9)
;       xrange      : An array [xmin,xmax] to limit the plot range for X axis
;       yrange      : An array with 2N values (lower,upper) for the yranges
;                     in the N plotted energy bands.
;       box         : An area in NORMAL coordinates within which the whole
;                     plot will be contained.
;       title       : The overall title of the plot (set on top).
;       xtitle      : Title for the X-axis (Default is 'Pulse Phase').
;       ytitle      : Title for the X-axis (Default is 'Counts / s').
;       annotations : An array of N strings with annotations for N energy
;                     bands.
;       colors      : An array with N color table indices for N energy bands.
;       
;
; KEYWORD PARAMETERS:
;       exposure  : LOGICAL - Plot the exposure time below profiles
;       noerror   : LOGICAL - Plot profiles without error bars
;       energy    : LOGICAL - Annotate individual panels with energy range
;                             (may be 0.0-0.0 if this information has not
;                              been filled for the structure)
;       channel   : LOGICAL - Annotate individual panels with range of 
;                             original instrument channels used for this
;                             (if this information is set in structure)
;       over      : LOGICAL - Plot profiles over existing plot (implies
;                             either yrange or othery set).
;       samepage  : LOGICAL - Plot this without going to a new page
;       othery    : LOGICAL - Y-scale of overplotted profile != original scale
;       blocks    : LOGICAL - Plot profile with 'blocks' instead of error-bars
;       zerolower : LOGICAL - Have y-range start at 0.0 or negative
;       verbose   : LOGICAL - Be talkative about processing
;       noymarks  : LOGICAL - Don't write numbers to y-axis
;       noxmarks  : LOGICAL - Don't write numbers to x-axis
;       linestyle   : linestyle as in plotting keyword
;       psym        : plot symbol as in plotting keyword
;       thickness   : line thickness as plotting keyword
;       tcharsize   : relative size of title characters
;
; OUTPUTS:
;       none
;
; OPTIONAL OUTPUTS:
;       none
;
; COMMON BLOCKS:
;       none
;
;
; SIDE EFFECTS:
;       In case of crash, several !p.xxx variables may have been changed.
;
;
; RESTRICTIONS:
;       * Complex procedure
;
; PROCEDURE:
;       just read it
;
; EXAMPLE:
;       TBW
;
;
; MODIFICATION HISTORY:
;       Version 1.0: 1999/11/12 PK
;                    first fully functional version
;       Version 1.1: 1999/11/24 PK
;                    put subprocedures first in code;
;                    renamed subprocedures to plotpulse_***;
;                    corrected documentation
;       Version 1.2: 2000/04/11 PK
;                    corrected several typos
;                    extended x-axis range slightly for nicer plot
;-

proname='plotpulse'

;; check for correct type of input profile

IF (datatype(profile,2) NE 8) THEN BEGIN
    print,proname,' error: Need special Structure as input!'
    RETURN
ENDIF ELSE BEGIN
    tags=tag_names(profile)
    IF (tags(0) NE 'NPROFILES') THEN BEGIN
        print,proname,' error: Input Structure seems to be wrong'
        RETURN
    ENDIF
ENDELSE

;; set some keyword parameters to default
IF (NOT keyword_set(xrange))   THEN $
    xrange=[-1.0/profile.nphasebins,$
            1.0*profile.nprofiles+1.0/profile.nphasebins]
IF (NOT keyword_set(box))      THEN box=[0.0,0.0,1.0,1.0]
IF (NOT keyword_set(ytitle))   THEN ytitle='counts / s'
IF (NOT keyword_set(xtitle))   THEN xtitle='pulse phase'
IF (NOT keyword_set(title))    THEN title=' '
IF (NOT keyword_set(charsize)) THEN tcharsize=2



;; set first and last band to plot
IF (keyword_set(first)) THEN BEGIN 
    IF (NOT keyword_set(last)) THEN BEGIN
        last = min([first+9,profile.nchannels])
    ENDIF
ENDIF ELSE BEGIN
    IF (NOT keyword_set(last)) THEN BEGIN
        last = min([10,profile.nchannels])
    ENDIF
    first = max([1,last-9])
ENDELSE


;; limit first,last to available plots
IF (first GT profile.nchannels) THEN BEGIN
    print,proname,' error: Can not have first band beyond band ',$
          profile.nchannels
    RETURN
ENDIF
IF (last GT profile.nchannels) THEN BEGIN
    print,proname,' error: Can not have last band beyond band ',$
          profile.nchannels
    RETURN
ENDIF

profiles_to_plot = 1+last-first

;; add 1 if we want to see exposure times also
IF (keyword_set(exposure)) THEN profiles_to_plot = profiles_to_plot+1


charsize= 1.0+(profiles_to_plot/10.0)

;; check out yrange optional input
IF (keyword_set(yrange)) THEN BEGIN
    n_yranges=n_elements(yrange)/2
    IF (n_yranges*2 NE n_elements(yrange)) THEN BEGIN
        print,proname,' error: Need even number of y range values!'
        RETURN
    ENDIF 
    IF (n_yranges LT profiles_to_plot) THEN BEGIN
        print,proname,' warning: Not all plotted bands have a defined range.'
        print,proname,'          The last',profiles_to_plot-n_yranges,$
              ' will be set automatically',form='(2a,i2,a)'
    ENDIF
    IF (keyword_set(verbose)) THEN BEGIN
        print,proname+':',n_yranges,' yrange pairs given',form='(a,i3,a)'
    ENDIF
ENDIF ELSE BEGIN
    n_yranges=0
ENDELSE


IF (!D.NAME EQ 'PS') THEN !P.FONT=0 ELSE !P.FONT=-1

savemulti=!P.MULTI
!P.MULTI=[0,0,profiles_to_plot]

;; set global margins
plotpulse_set_margins,box,leftmargin,rightmargin,bottommargin,topmargin


;; limit plotted points to given x-range
x_select = where((profile.x(*,0) GE xrange(0)) AND $
                 (profile.x(*,0) LE xrange(1)) AND $
                 (profile.dx(*,0) gt 0))
IF x_select(0) EQ -1 then x_select = replicate(1,profile.nphasebins) 


;; set a sensible ticklength
ticklength = 0.01

;; if we overplot several parameters are special
IF (keyword_set(over)) THEN BEGIN
  IF NOT (keyword_set(yrange) AND NOT keyword_set(othery)) THEN BEGIN
    print,proname,$
      '> You *must* give the yrange-array for overplotting!'
    Return
  ENDIF
  current_xstyle=5
  current_ystyle=5
  title=' '
  xtitle=' ' 
  ytitle=' ' 
  over=1
  noerase=1
ENDIF ELSE BEGIN
  over=0
  IF keyword_set(samepage) THEN noerase=1 ELSE noerase = 0
  current_xstyle=1 
  current_ystyle=1
ENDELSE
   

;;
;; Now the actual action starts.
;; For each energy band we do the following steps:
;; - setup x-axis tick values and labels (mostly identical for all bands,
;;   but having this here makes plotting the last easier)
;; - setup y-axis tick values and labels
;; - plot an empty frame
;; - depending on keyword settings, overplot the profile for this band
;;   either as a "staircase", individual data points or "blocks"
;;
FOR band=first,last DO BEGIN

    ;; set up x-axis, only label ticks for last band plotted
    IF (keyword_set(noxmarks)) THEN BEGIN
        noxm=1
    ENDIF ELSE BEGIN
        noxm=(band LT last OR keyword_set(exposure))
    ENDELSE
    plotpulse_set_x_axis,xrange,band,noxmarks=noxm,xtick_values,xtick_names

    ;; these 4 definitions make the following code more readable
    x=profile.x(x_select,band-1)
    dx=profile.dx(x_select,band-1)
    y=profile.y(x_select,band-1)
    dy=profile.dy(x_select,band-1)

    ;; set up y-axis
    plotpulse_set_y_axis,y,dy,ymin,ymax,ytick_values,ytick_names,$
               noerror=noerror,zerolower=zerolower,noymarks=noymarks
               
    ;; if we have a defined y-range for this band, set ymin & ymax
    ;; to that regardless of what the procedure calculated
    IF (keyword_set(yrange) AND n_yranges GT (band-first)) THEN BEGIN
        ymin=yrange(2*(band-first))
        ymax=yrange(2*(band-first)+1)
    ENDIF ELSE BEGIN
        IF (n_yranges LE 0) THEN BEGIN
            yrange=[ymin,ymax]
            n_yranges = 1
        ENDIF ELSE BEGIN
            yrange=[yrange,ymin,ymax]
            n_yranges = n_yranges+1
        ENDELSE
    ENDELSE

    ;; calculate box for this band
    lower_bound=bottommargin + $
                ( (1.0-topmargin-bottommargin) * $
                  (profiles_to_plot-1-band+first) $
                  / profiles_to_plot )
    upper_bound=bottommargin + $
                ( (1.0-topmargin-bottommargin) * $
                  (profiles_to_plot-band+first) $
                  / profiles_to_plot )
    local_box = [leftmargin,lower_bound,1.0-rightmargin,upper_bound]

    ;; plot empty frame with all settings as calculated before
    plot,[0,1],[0,1],/nodata,$
         xrange=xrange,xstyle=current_xstyle,$
         yrange=[ymin,ymax],ystyle=current_ystyle,$
         xticks=n_elements(xtick_values)-1,xminor=5,$
         xticklen=ticklength*profiles_to_plot,$
         xtickv=xtick_values,xtickname=xtick_names,$
         yticks=n_elements(ytick_values)-1,yminor=2,$
         yticklen=ticklength,$
         ytickv=ytick_values,ytickname=ytick_names,$
         thick=thickness,charsize=charsize,$
         position=local_box,noerase=noerase

    ;; if we have a different y-axis, annotate the right-hand axis
    IF (keyword_set(othery)) THEN BEGIN
        axis,/yaxis,yticks=2,yminor=1,ytickv=ytick_values,$
             yrange=[ymin,ymax],ystyle=1,charsize=sqrt(profiles_to_plot)
    ENDIF

    ;; set up plot color
    IF (NOT keyword_set(colors)) THEN BEGIN
        color = !P.COLOR 
    ENDIF ELSE BEGIN
        color = colors(band-first)
    ENDELSE

    ;; overplot the profile for this band
    ;; either as individual data points, a "staircase"  or "blocks"
    IF (keyword_set(psym)) THEN BEGIN
        oplot,x,y,$
              psym=psym,color=color
    ENDIF ELSE IF (keyword_set(blocks)) THEN BEGIN
        make_polygons,x,y,dx,dy,poly_x,poly_y
        polyfill,poly_x,poly_y,color=color
    ENDIF ELSE BEGIN
        make_staircase,x,y,dx,xstair,ystair
        oplot,xstair,ystair,linestyle=linestyle,thick=thickness,color=color
    ENDELSE
        
    ;; plot error bars (if not told to not do so)
    IF (NOT keyword_set(noerror)) THEN BEGIN
        jwoploterr,x,y,dy,dx=dx,ymin=ymin,ymax=ymax,$
                     linestyle=linestyle,color=color,thick=thickness
    ENDIF

    ;; annotate the individual panel
    annosize = 1.5-(profiles_to_plot/10.0)
    anno_x = 1.0-rightmargin-(annosize*!d.x_ch_size)/!d.x_size
    anno_y = upper_bound - (2*annosize*!d.y_ch_size)/!d.y_size
    IF (n_elements(annotations) GE band-first+1) THEN BEGIN
        annostring = annotations(band-first)
    ENDIF ELSE IF (keyword_set(channels)) THEN BEGIN
        annostring=string(form='("Channel ",i3," - ",i3)',$
                          profile.chbounds(0,band-1),$
                          profile.chbounds(1,band-1))
    ENDIF ELSE IF (keyword_set(energy)) THEN BEGIN
        annostring=string(form='(f6.2," - ",f6.2," keV")',$
                          profile.ebounds(0,band-1),$
                          profile.ebounds(1,band-1))
    ENDIF ELSE BEGIN
        annostring=''
    ENDELSE      

    xyouts,anno_x,anno_y,/normal,annostring,charsize=annosize,align=1

ENDFOR

;;
;; Plot exposure time per bin if requested to do so
;;
IF (keyword_set(exposure)) THEN BEGIN

    ;; set up x-axis
    plotpulse_set_x_axis,xrange,band,noxmarks=noxmarks,xtick_values,xtick_names

    ;; these 4 definitions make the following code more readable
    x=profile.x(x_select,0)
    dx=profile.dx(x_select,0)
    y=profile.exposure(x_select)
    dy=replicate(0.0,n_elements(x_select))

    ;; set up y-axis
    plotpulse_set_y_axis,y,dy,ymin,ymax,ytick_values,ytick_names,$
               noerror=noerror,zerolower=zerolower,noymarks=noymarks
               
    ;; if we have a defined y-range for this set ymin & ymax
    ;; to that regardless of what the procedure calculated
    IF (keyword_set(yrange) AND n_yranges GT (band-first)) THEN BEGIN
        ymin=yrange(2*(band-first))
        ymax=yrange(2*(band-first)+1)
    ENDIF ELSE BEGIN
        IF (n_yranges LE 0) THEN BEGIN
            yrange=[ymin,ymax]
            n_yranges = 1
        ENDIF ELSE BEGIN
            yrange=[yrange,ymin,ymax]
            n_yranges = n_yranges+1
        ENDELSE
    ENDELSE

    ;; calculate box for this band
    lower_bound=bottommargin
    upper_bound=bottommargin + $
                ( (1.0-topmargin-bottommargin) $
                  / profiles_to_plot )
    local_box = [leftmargin,lower_bound,1.0-rightmargin,upper_bound]

    ;; plot empty frame with all settings as calculated before
    plot,[0,1],[0,1],/nodata,$
         xrange=xrange,xstyle=current_xstyle,$
         yrange=[ymin,ymax],ystyle=current_ystyle,$
         xticks=n_elements(xtick_values)-1,xminor=5,$
         xticklen=ticklength*profiles_to_plot,$
         xtickv=xtick_values,xtickname=xtick_names,$
         yticks=n_elements(ytick_values)-1,yminor=2,$
         yticklen=ticklength,$
         ytickv=ytick_values,ytickname=ytick_names,$
         thick=thickness,charsize=charsize,$
         position=local_box,noerase=noerase

    ;; if we have a different y-axis, annotate the right-hand axis
    IF (keyword_set(othery)) THEN BEGIN
        axis,/yaxis,yticks=2,yminor=1,ytickv=ytick_values,$
             yrange=[ymin,ymax],ystyle=1
    ENDIF

    ;; set up plot color
    IF (NOT keyword_set(colors)) THEN BEGIN
        color = !P.COLOR 
    ENDIF ELSE BEGIN
        color = colors(profiles_to_plot-1)
    ENDELSE

    ;; overplot the exposure time
    ;; either as individual data points, a "staircase"  or "blocks"
    IF (keyword_set(psym)) THEN BEGIN
        oplot,x,y,$
              psym=psym,color=color
    ENDIF ELSE IF (keyword_set(blocks)) THEN BEGIN
        make_polygons,x,y,dx,dy,poly_x,poly_y
        polyfill,poly_x,poly_y,color=color
    ENDIF ELSE BEGIN
        make_staircase,x,y,dx,xstair,ystair
        oplot,xstair,ystair,linestyle=linestyle,thick=thickness,color=color
    ENDELSE

    annosize = 1.5-(profiles_to_plot/10.0)
    anno_x = 1.0-rightmargin-(annosize*!d.x_ch_size)/!d.x_size
    anno_y = upper_bound - (2*annosize*!d.y_ch_size)/!d.y_size
    IF (n_elements(annotations) EQ profiles_to_plot) THEN BEGIN
        annostring = annotations(profiles_to_plot-1)
    ENDIF ELSE BEGIN
        annostring='Exposure time per phasebin'
    ENDELSE

    xyouts,anno_x,anno_y,/normal,annostring,charsize=annosize,align=1

ENDIF 

;;
;; Write titles
;;

midx=0.5*(1+leftmargin-rightmargin)
topy=box(3)-topmargin+tcharsize*(0.5*!d.y_ch_size)/!d.y_size
boty=box(1)+bottommargin-tcharsize*(1.5*!d.y_ch_size)/!d.y_size
midy=0.5*(box(3)-topmargin+box(1)+bottommargin)
leftx=box(0)+leftmargin-(5.0*!d.x_ch_size)/!d.x_size

xyouts,/normal,midx,topy,title,align=0.5
xyouts,/normal,midx,boty,xtitle,align=0.5
xyouts,/normal,leftx,midy,$
       orientation=90,align=0.5,ytitle


RETURN
END

