;;
;; Short routine to find and plot peaks in the data
;;
pro wcpeakfind, x, y, rng, params=a, nterms=nt, plot=plot, charsize=csize, $
   verbose=verbose

;; Number of terms used in the fitting 
;;    See the GAUSSFIT routine in the IDL documentation
if (keyword_set(nt) eq 0) then nt=6

;; Fit the Peaks
w=where(x ge rng(0) and x le rng(1))
result=gaussfit(x(w),y(w),a,nterms=nt)

;; Does the user want to plot this information?
;;
if (keyword_set(plot)) then begin  
   oplot,x(w),result,psym=0

   ;; Set the character size
   if (keyword_set(csize) eq 0) then csize=1

   ;; Calculate the number of counts in the peak
   ;; And save it as the normalization
   a(0) = sqrt(2.d*!DPI)*a(0)*a(2)

   ;; Round off to an integral number of counts
   ;;
   a(0) = ulong64(a(0)+0.5)


   ;; Put the information on the plot
   ;; (the !C performs a carriage return in the output text)
   text=  'Cent: '+strcompress(a(1),/remove_all)+ $
        '!CFWHM: '+strcompress(string(a(2)*2.354),/remove_all);;+ $
        ;;'!CPeak: '+strcompress(a(0),/remove_all)
   xyouts,a(1)+2*a(2),(0.9)*max(y(w)),text,charsize=csize
   
   ;; Send the fits to STDOUT
   ;;
   if (keyword_set(verbose)) then begin
      print,'Cent: '+strcompress(a(1),/remove_all)
      print,'FWHM: '+strcompress(string(a(2)*2.354),/remove_all)
      print,'Peak: '+strcompress(a(0),/remove_all)
      print,' '
   endif

   ;; And that about does it
   ;;

endif

return
end
