Pro goes_error_bars, tarray, yuse, bad0, bad1, ebars, error=error

; Procedure by Eric Carzon, Hughes/STX
; Added to Kim Tolbert's GOES Widget Program 
; Calculates error bars on GOES data.
; 2/93, Goddard Solar DAC

; set variables for ebars and ebar values

error = 0

;intensity ranges and corresponding resolutions
i0_range = [0,1.2e-6,1.2e-5,1.2e-4,1.2e-3,10e10]
i1_range = [0,1.2e-7,1.2e-6,1.2e-5,1.2e-4,10e10]
i0_res = [2.3e-9,1.2e-8,1.1e-7,1.17e-6,1.17e-5]
i1_res = [1.3e-10,3.26e-10,1.27e-8,1.3e-7,1.3e-6]

n_elem = n_elements(tarray)
ebars = fltarr(n_elem,2)  ; set ebar to handle 2 channels, only one plots at a
		    	  ;time
for chan = 0,1 do begin
   ;print,'chan:',chan
   y_flux = yuse(*,chan)   ;convert yuse to only one ch. of data
   y_bad = bad0
   if chan eq 1 then y_bad = bad1
   y_bad_ct = n_elements(y_bad)

   if(chan eq 0) then i_range = i0_range else i_range = i1_range
   if(chan eq 0) then i_res = i0_res else i_res = i1_res

   if (y_bad(0) eq -1) then begin

      ; calculate ebars for case where there are no gain changes in data

      ;print,'There are no gain change spikes for this event'
      wh_err1 = where( i_range gt (avg(y_flux) ),wh_err1_ct)
      if(wh_err1_ct le 0) then goto,error_Exit 
      ; print,'wh_err1:',wh_err1
      ; print,'ave of y_flux:',avg(y_flux)
      err1 = i_res(wh_err1(0)-1)
      ebars(*,chan) = replicate(err1,n_elem)
      goto,wr_ebars

   endif else begin

      ; Find # of spikes and position, calculate error bars 

      if (y_bad_ct lt 2) then nm_ct = 0 else $
         nm_y_bad = where( ( ( shift(y_bad,-1) - y_bad) gt 2), nm_ct)
      ;print,'There are ',nm_ct+2,' Gain States in This Plot'

      pos=intarr(nm_ct+3) ;make an array of positions within y_bad
      pos(0) = 0
      if (nm_ct eq 0) then begin
         pos(1) = y_bad(0) 
      endif else begin
         for i=1,nm_ct do pos(i) = y_bad(nm_y_bad(i-1)) 
         pos(nm_ct+1) = y_bad(nm_y_bad(nm_ct-1)+1)
      endelse
      pos(nm_ct+2) = n_elem-1
 
      compare_loop:
      for n=0,nm_ct+1 do begin
         wh_err1 = where(i_range gt (avg(y_flux(pos(n):pos(n+1))) ), wh_err1_ct)
         if(wh_err1_ct le 0) then goto,error_Exit 
         ;  print,'wh_err1:',wh_err1
         ;  print,'ave of y_flux:',avg(y_flux(pos(n):pos(n+1)))
         ebars(pos(n):pos(n+1),chan) = i_res(wh_err1(0)-1)
      endfor
   endelse

   ebars(y_bad,chan) = 0.0	;write 0. to the bad points' ebars

   wr_ebars:
   ebars(0:n_elem-2,chan) = ebars(0:n_elem-2,chan)/$
      (fix(((tarray(1:*)-tarray(*))/3)+.5)*3.064) 
   ebars(n_elem-1,chan) = ebars(n_elem-2,chan)

endfor

;help,ebars
;print,ebars
goto,get_out

error_exit:
error = 1
;print,'Exiting Error_bars.pro with an error!'

get_out:
;print,'Leaving Error_bars, enjoy your stay in E_goesplot'
return
end                    
