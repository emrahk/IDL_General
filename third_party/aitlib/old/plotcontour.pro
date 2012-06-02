
PRO plotcontour,par1,par2,chi,colnum=colnum,confidence=confidence, $
   confcol=confcol,confdelta=confdelta
;+
; NAME:
;       plotcontour
;
;
; PURPOSE:
;       plot a confidence contour from the chi^2 values produced by
;       XSPEC while calculating a contour
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;       plotcontour,par1,par2,chi,colnum=colnum,confidence=level,
;       confcol=confcol,confdelta=confdelta
;
; 
; INPUTS:
;       par1 : an array containing the values of parameter 1
;       par2 : an array containing the values of parameter 2
;       chi  : an array containing the values of chi^2 
;
;
; OPTIONAL INPUTS:
;       colnum : the maximum number of colors to use (important if
;       another application like netscape or pgplot is running so not
;       all colors are available)
;       level : at which level the contour should be plottet :
;       chi_min+level. If omitted no contour is plotted
;       confcol : the color in which the contour should be plotted
;       confdelta : plotcontour detects the contour by looking for
;       appropriate chi values : chi_min+level +- delta. If the
;       if the default does not work, you can change confdelta manually
;  
;
;	
; RESTRICTIONS:
;       not very thoroughly tested. plotcontour is known to produce
;       strange results sometimes.
;
;
; PROCEDURE:
;       the chisquare and the parameters are read and plotted
;
;
; EXAMPLE:
;       create a log file within XSPEC just before entering the
;       steppar command. Read this log file with readcontour
;       plotcontour,par1,par2,chi,colnum=100,level=30.,confdelta=2.
;
;
; MODIFICATION HISTORY:
;       written 1996 by Ingo Kreykenbohm
;-


IF (n_elements(colnum) EQ 0) THEN colnum = 230
IF (n_elements(confcol) EQ 0) THEN confcol = 0
IF (n_elements(confdelta) EQ 0) THEN confdelta = 1.

test = sort(par2)
;par1 = par1(test)
;par2 = par2(test)
;stop
;; detect the stepping ranges
bereich1 = [min(par1),max(par1)]
bereich2 = [min(par2),max(par2)]
pbereich1 = [min(par1)*.90,max(par1)*1.1]
pbereich2 = [min(par2)*.90,max(par2)*1.1]

;; determine the number of steps and the stepwidth
steps1 = par1(1)-par1(0)
idx = where(par2 NE par2(0))
steps2 = par2(idx(0)) - par2(0)

stepn1 = fix((bereich1(1)-bereich1(0))/steps1)
stepn2 = fix((bereich2(1)-bereich2(0))/steps2)

;; save chi for sigma ranges
purchi = chi

;; detect chi minimum
chimin = min(chi)

;; to distribute the colors properly, determine the chi range
chi = chi - chimin
chimax = max(chi)
chi = chi / chimax *4.
chi = 1. - chi
col = fix(chi * colnum)

loadct,39

;; create an empty plot window with appropriate axes
plot,bereich1,bereich2,/nodata,xstyle = 1,ystyle = 1

;; calculate the "resolution" of the contour and 
;; define appropriate rectangles as new plotting symbol
xs = 640. / stepn1/4.
ys = fix(480. / stepn2/3.)
stepn1=stepn1+1
x=[1,xs+2,xs+2,1,1]
y=[ys,ys,0,0,0]
usersym,x,y,/fill

;; select the squares whose chi matches the requested confidence
IF (n_elements(confidence) NE 0) THEN BEGIN 
    s = confidence
    ds = confdelta
    idx = where((purchi LT chimin+s+ds) AND (purchi GT chimin+s-ds))
END ELSE BEGIN 
    idx = -1
END 
cc = 0
conf = fltarr(n_elements(chi),2)
mc = 1

;; do the plot
FOR i=stepn1,n_elements(chi)-1-(stepn1*2) DO BEGIN
    c = col(i)
    i2 = where(idx EQ i)
    oplot,[par1(i),par1(i)],[par2(i),par2(i)],psym=8,color=c
    IF i2(0) NE -1 THEN BEGIN 
        cc = cc + 1
        conf(cc,0) = par1(i)
        conf(cc,1) = par2(i)
    ENDIF 
ENDFOR

;; define a cross as plotting symbol, which matches the above defined
;; rectangles. 

xl = 0.25 * xs
xr = 0.75 * xs
xm = 0.50 * xs
yu = 0.25 * ys
yo = 0.75 * ys
ym = 0.50 * ys
x = [xl,xr,xm,xm,xm,xm,xl]
y = [ym,ym,ym,yo,yu,ym,ym]
usersym,x,y

;; plot the requested confidence range 

IF (n_elements(confidence) NE 0) THEN BEGIN
    oplot,[conf(1:cc,0),conf(1:cc,0)], [conf(1:cc,1),conf(1:cc,1)], $
    psym=8, color=confcol
ENDIF 
END 


