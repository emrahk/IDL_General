PRO divspectrum,counts1,counts2,c_err1,c_err2,channels=ch, $
                 xmin=xmin,xmax=xmax,result=result,over=over,color=color
;+
; NAME:
;       divspectrum
;
;
; PURPOSE:
;       divide two spectra
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;       divspectrum,counts1,counts2,error1,error2,channels=channels,
;       xmin=xmin,xmax=xmax,result=result,color=color,/over
;
; 
; INPUTS:
;       counts1 : counts of spectrum 1
;       counts2 : counts of spectrum 2
;       error1  : error of spectrum 1
;       error2  : error of spectrum 2
;
;
; OPTIONAL INPUTS:
;       channels  : channel to energy conversion table
;       xmin,xmax : the plotting range
;       color     : the color of the plot
;
;	
; KEYWORD PARAMETERS:
;       /over : use an existing window
;
;
; OPTIONAL OUTPUTS:
;       result : the ratio
;
;
; PROCEDURE:
;       the two spectra are divided and the result is plotted in
;       folded with the energy conversion table.
;
;
; EXAMPLE:
;       divspectrum,counts1,counts2,error1,error2,xmin=20,xmax=60,color=200
;
;
; MODIFICATION HISTORY:
;       written 1996 by Ingo Kreykenbohm
;-



;; if no plotranges are given, use maximum and minimum values

IF (n_elements(xmin) EQ 0) THEN xmin = 0
IF (n_elements(xmax) EQ 0) THEN xmax = n_elements(counts1)-1

;; initialize some variables
IF (n_elements(ch) LT 1) THEN ch = indgen(n_elements(counts1)) 

c1 = fltarr(n_elements(counts1))
c2 = fltarr(n_elements(counts2))
c_e1 = c1
c_e2 = c2
;; transform the integer count array in a float array
c1(*) = counts1(*)
c2(*) = counts2(*)
c_e1(*) = c_err1(*)
c_e2(*) = c_err2(*)

;; find all those counts which are zero and set them to a tiny none
;; zero value to prevent a division by zero error
idx = where(c2 EQ 0)
IF (idx(0) NE -1) THEN c2(idx) = 1e-10

;; divide the two spectra
d = c1/c2

;; calculate the error (error propagation !)
d_err = sqrt(((1/2)*c_e1)^2+(c1/(c2^2)*c_e2)^2)

;; plot the data points
IF (NOT keyword_set(over)) THEN BEGIN
    plot,ch(xmin:xmax),d(xmin:xmax),/nodata
END 
oplot,ch(xmin:xmax),d(xmin:xmax),psym=10,color=color

;; plot the errorbars
FOR i = xmin,xmax DO BEGIN
    oplot,[ch(i),ch(i)],[d(i)-d_err(i),d(i)+d_err(i)],color=color
ENDFOR 

result = d
END 
