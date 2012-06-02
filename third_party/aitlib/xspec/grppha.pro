PRO grppha,spec,group,quality,back=back,mincnt=mincnt
   
   
   nch=n_elements(spec)
   
   ;; Array containing the rebinning factors
   ;; same syntax as grppha: 
   ;;   1 denotes the start of a new channel
   ;;  -1 is the continuation of the rebinned channel
   group=intarr(nch)
   
   ;; Array containing the quality of the channel
   ;;   0 denotes a good channel
   ;;   2 denotes a channel marked bad by the rebinning procedure
   ;;
   quality=intarr(nch)
   
   ;; rebin to a minimum number of counts in a bin
   IF (n_elements(mincnt) NE 0) THEN BEGIN 
       ;; if a background spectrum is also given, then the rebinning is
       ;; performed on the background subtracted spectrum
       sptmp=double(spec)
       IF (n_elements(back) NE 0) THEN sptmp=sptmp-back

       sum=sptmp[0] ;; number of photons in current bin (excl bin ch)
       group[0]=1   ;; 1st bin starts here
       startchan=0  ;; starting channel of current bin
       ch=1         ;; next channel to inspect
       WHILE ch LT nch DO BEGIN 
           ;; if sum up to here >= min --> start new bin in ch
           ;; if not: continue current bin
           IF sum GE mincnt THEN BEGIN 
               group[ch]=1  ;; start new bin
               sum=0D0      ;; nothing in here yet
               startchan=ch ;; remember starting bin
           END ELSE BEGIN 
               group[ch]=-1 ;; continue current bin
           END 
           
           sum=sum+sptmp[ch]
           ch=ch+1
       END 
       
       ;; if last bin does not fill it up --> mark last
       ;; channels bad
       IF (sum LT mincnt) THEN BEGIN 
           quality[startchan:nch-1]=2
       END 
       
       return
       
   END 
   

   
   message,'This should never happen'
   
END 
