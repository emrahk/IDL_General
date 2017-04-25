;+
; NAME:
;	te_scale
; PURPOSE:
;	Will take x, an NxN image of temperatures, or EM's, or
;	anything, and tv it with a scale on the side, into a file 
;	called filen0. And also take y another NxN image and 
;	overplot it with a contour plot
; CALLING SEQUENCE:
;	te_scale,x,y=y,filen0=filen0,title=title,label=label,
;                lpix=lpix,color=color,range=range,win=win,
;                levels=levels,nlevels=nlevels,boxq=boxq,boxl=boxl
;                reverse=reverse, noscale=noscale, charsize=charsize
;                con_color=con_color,stop_and_look=stop_and_look,
;                noreverse=noreverse
; INPUT:
;	x= an array, with the bad points set to ABS(x)=0.0
; OPTIONAL KEYWORD INPUT:
;	y= an array, with the bad points set to ABS(y)=0.0
;	filen0= a filename.
;	label= a label for the scale
;	title= a title for the image
;	lpix= pixel size in km's
;       color= color postscript
;       range= range of values to use
;       win= a window to use
;       levels= levels for the contour plot
;       nlevels= number of levels for contour plot, default is 17
;       boxq= box coordinates for boxes to be drawn
;;;;;;;;boxl= labels for boxes
;       con_color= a color value for the contours, from 0 to 255
;                  the default is whatever is normally used
;       stop_and_look= if set, stops before returning.
;       reverse = reverse the color scale, this is the default for
;                 ps plots, when filen0 is set
;       noreverse= don't reverse, even if filen0 is set
; HISTORY:
;	Written May '92 by J McTiernan
;       Chnaged units, 12-jul-94, jmm
;-
PRO Te_scale, x, y=y, filen0=filen0, title=title, label=label, $
              lpix=lpix, color=color, range=range, win=win, $
              levels=levels, nlevels=nlevels, boxq=boxq, boxl=boxl, $
              reverse=reverse, noscale=noscale, charsize=charsize, $
              con_color=con_color, stop_and_look=stop_and_look, $
              noreverse=noreverse
   
   x1 = x
;get max and min
   IF(KEYWORD_SET(range)) THEN BEGIN
      xmx = range(1)
      xmn = range(0)
   ENDIF ELSE BEGIN
      z = where(abs(x) GT 0.0)
      IF(z(0) NE -1) THEN BEGIN 
         xmx = max(x(z))
         xmn = min(x(z))
      ENDIF ELSE BEGIN
         xmx = 1.0
         xmn = 0.0
      ENDELSE
      
      IF((xmx GT 3000.0) OR (xmn LT -3000.0)) THEN BEGIN
         xmx = float(long(xmx+1))
         xmn = float(long(xmn))
      ENDIF ELSE BEGIN
         IF(abs(xmx) GT 1.0) THEN BEGIN
            xmx = 0.1*fix(xmx*10.0+1.0) ;round up
            xmn = 0.1*fix(xmn*10.0) ;round down
         ENDIF
      ENDELSE
   ENDELSE

;get color scale
   xsmn = 0.0
   xsmx = 255.0
   
   n = N_ELEMENTS(x(0, *))         ;n=64 isn't neede anymore
;   print, 'n=', n
   n1 = n-1
   dxs = (xsmx-xsmn)/n1
   xs = dxs*findgen(n)
   
;now scale x from 0 to 255
   dx = xmx-xmn
   s1 = where(x LT xmn)
   IF(s1(0) NE -1) THEN x(s1) = xmn
   s2 = where(x GT xmx)
   IF(s2(0) NE -1) THEN x(s2) = xmx
   IF(dx NE 0.0) THEN xr = (x-xmn)*255.0/dx ELSE xr = fltarr(n, n)
;insert scale into xr
   IF(n GT 64) THEN BEGIN
      ss0 = n-(n/64)
      FOR j = ss0, n-1 DO xr(j, *) = xs
   ENDIF ELSE xr(n-1, *) = xs

   xpl = byte(xr)
;get labels
   dxl = (xmx-xmn)/(n-1)
   xvl = xmn+dxl*findgen(n)
   xlb = strcompress(xvl)
   
;open output file
   IF(KEYWORD_SET(reverse) OR KEYWORD_SET(filen0)) THEN $
     IF(NOT KEYWORD_SET(noreverse)) THEN xpl = 255b-xpl ;reverse for ps plots

   IF(KEYWORD_SET(filen0)) THEN BEGIN
      set_plot, 'ps'
      IF(KEYWORD_SET(color)) THEN cl = 1 ELSE cl = 0
      device, /landscape, filename = filen0, color = cl
   ENDIF
   IF(N_ELEMENTS(win) GT 0) THEN window, fix(win(0))
   IF(KEYWORD_SET(y)) THEN BEGIN
      ypl = y
      zy = where(ypl NE 0.0)
      IF(zy(0) NE -1) THEN ypl = ypl > min(ypl(zy))
   ENDIF ELSE ypl = fltarr(n, n)
   IF(KEYWORD_SET(levels)) THEN ylvls = levels ELSE ylvls = 0
   IF(KEYWORD_SET(nlevels)) THEN nylvls = nlevels ELSE nylvls = 0
;contours on a square plot
   image_c17, xpl, b = ypl, /aspect, nlevels = nylvls, levels = ylvls, color=con_color
   
;use data coordinates for the labels, since you now have a plot window
   fifty_5 = fix(7.0*n/8.0)
   sixty_5 = fix(8.3*n/8.0)
   sixty_4 = n
   IF(KEYWORD_SET(charsize)) THEN chsz = charsize ELSE chsz = 0
   IF(NOT KEYWORD_SET(noscale)) THEN BEGIN
      scale1 = n/16
      xyouts, sixty_4, 0, xlb(0), charsize = chsz, /data
      FOR j = scale1-1, n-1, scale1 DO xyouts, sixty_4, j, xlb(j), charsize = chsz, /data
   ENDIF
;add boxes if you want to
   IF(KEYWORD_SET(boxq)) THEN BEGIN
      ipix = N_ELEMENTS(xpl(*, 0)) & jpix = N_ELEMENTS(xpl(0, *))
      box1_draw, boxq, ipix, jpix, label = boxl
   ENDIF
;and annotate the plot
   IF(KEYWORD_SET(title)) THEN BEGIN
      titleq = [0, sixty_5]
      xyouts, titleq(0), titleq(1), title, /data
   ENDIF
   IF(KEYWORD_SET(label)) THEN BEGIN
      labelq = [fifty_5, sixty_5]
      xyouts, labelq(0), labelq(1), label, /data
   ENDIF
   IF(KEYWORD_SET(lpix)) THEN BEGIN
      topc = [0, fifty_5] 
      sclbl = strmid(string(fix(lpix)), 4, 5)
      xyouts, topc(0), topc(1), ' scale='+sclbl+' km/pixel', /data
   ENDIF	
   IF(KEYWORD_SET(filen0)) THEN BEGIN
      device, /close
      set_plot, 'x'
   ENDIF
   
   x = x1
   IF(KEYWORD_SET(stop_and_look)) THEN stop
   RETURN
END
