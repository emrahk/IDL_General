pro oplotmodel, ldata_x, ldata_dx, ldata_y

;;
;; Print a histogram of the forward folded model with
;; the proper channel boundaries, rather than simply
;; using 'oplot' and having IDL determine where the
;; channels begin and end (wrongly)
;;
;; Call for both PCA and HEXTE data
;;

;;
;; Get the size of the input arrays
;;
t=size(ldata_x)

;;
;; Create variables
;;
temp_x=dblarr(t(1)*2)
temp_y=dblarr(t(1)*2)

;;
;; Calculate the correct histogram edges
;;
for i=0,t(1)-1 do begin
   temp_x(i*2)=ldata_x(i)-ldata_dx(i)
   temp_x(i*2+1)=ldata_x(i)+ldata_dx(i)
   temp_y(i*2)=ldata_y(2,i)
   temp_y(i*2+1)=ldata_y(2,i)
endfor

;;
;; Plot not as a histogram, but as a 'connect the dots'
;; to get the right look
;;
oplot,temp_x,temp_y,psym=0

;;
;; Thant's all folks
;;

return
end
