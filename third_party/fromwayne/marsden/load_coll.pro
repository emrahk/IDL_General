pro load_coll,resp=resp,x=xx,y=yy,$
              ra=raa,dec=decc
;*********************************************
; Program loads the angular response of the 
; Hexte collimators into a common block.
; Requires a data file coll.dat
; (array courtesy of P. Blanco).
; Variables are:
;  response........Fractional area array
;       x,y........Spatial axes (degrees)
;    ra,dec........RA/DEC of source (degrees)
; First establish the common blocks:
;*********************************************
common response,response,x,y,ra,dec
;*********************************************
; Open the response template file and do 
; an unformatted read.
;*********************************************
if (ks(response) eq 0)then begin
   resp = fltarr(300,300)
   xx = dblarr(300)
   on_ioerror,dumb
   get_lun,unit
   openr,unit,'coll.dat'
   readu,unit,xx
   readu,unit,resp
   x = xx & yy = x & y = x
   response = resp 
   if (n_elements(raa) ne 0)then begin
      ra = raa 
      dec = decc
   endif else begin
      ra = 0.
      dec = 0.
   endelse
endif else begin
   resp = response
   xx = x
   yy = y
endelse
;*********************************************
; That's all ffolks
;*********************************************
return
;*********************************************
; That's all ffolks II
;*********************************************
dumb:
free_lun,unit 
print,'COLLIMATOR FILE COLL.DAT NOT FOUND!!!'
return
end


