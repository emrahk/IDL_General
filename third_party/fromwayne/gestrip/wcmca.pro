pro wcmca, filename, data=data, flags=flags, spec=spec, nrg=nrg, $
           nstrips=nst, numch=nch, chrange=chrng, erange=erng, $
           lld=lldch, calib=nrgary, $
           plot=plot, peak=peak, energy=energy, savespec=savespec, $
           restore=restore, coinc=coinc, antic=antic, ylog=ylog, $
           pkch=peakch, numcts=pkcnts, width=pkwidth, verbose=verbose, $
           postscript=ps, psname=psflname, title=pltttl, panels=pnlname, $
           small=small, square=square

if (n_params() eq 0) then begin
   print,'USAGE:'
   print,'wcmca,filename,[data=],[flags=],[spec=spec], $'
   print,'   [nstrips=],[numch=],[chrange=],[calib=],[lld=], $'
   print,'   [/plot],[/peak],[/energy]'
   print,' '
   print,'INPUTS:'
   print,'   filename: Name of binary datafile'
   print,' '
   print,'OUTPUTS:'
   print,'   data:  Array of pha channels'
   print,'   flags: Array of coincidence flags'
   print,'   spec:  Array of binned spectra'
   print,' '
   print,'OPTIONAL INPUTS:'
   print,'   nstrips: Number of strips in datafile (default=4)'
   print,'   numch:   Number of PHA channels (default=8192)'
   print,'   chrange: Channel range to consider (default is [0,numch])'
   print,'   erange:  Energy range to consider (default is [0,numch])'
   print,'   calib:   Energy calibration Array (calspace 0-3 default)'
   print,'   lld:     Ignore data below this channel (default=1)'
   print,'            Can be specifed as either a scalar or an array'
   print,' '
   print,'OPTIONAL FLAGS:'
   print,'   /plot:     Generate plots of the strips
   print,'   /peak:     Turn on Peakfinder
   print,'   /energy:   Plot spectra as a function of energy'
   print,'   /savespec: Save the processed data in an IDL save file'
   print,'   /restore:  Restore data from a previous IDL save file'
   print,'   /coinc:    Coincidence mode'
   print,'   /antic:    Anticoincidence mode'
   print,'   /ylog:     Plot logrithmic y-axis
   print,' '
   return
endif

;;
;; Set things up
;;

;; Number of MCA channels
if (keyword_set(nch) eq 0) then nch = 8192
ch=lindgen(nch)

;; Number of Strips
if (keyword_set(nst) eq 0) then nst = 4

;; Channel Range
;;  Can set a unique range for each spectra
if (keyword_set(chrng) eq 0) then begin
   chrng = [0,nch-1]
endif

if (n_elements(chrng) eq 2 and nst gt 1) then begin
   w = chrng
   for i=1,nst-1 do begin
      chrng = [[chrng],[w]]
   endfor
endif

if (n_elements(chrng) lt nst*2) then begin
      print,'FATAL ERROR'
      print,'CHANNEL RANGES IMPROPERLY SET'
      print,'EXITING'
      print,' '
      return
endif

;; Set a software LLD
;;    This is applied BEFORE the histogram is generated
;;    This can be set as either a scalar or as an array
;;
;; Apply default if not set
if (keyword_set(lldch) eq 0) then lldch=replicate(1,nst)
;;
;; If a constant has been specified, the make it into an aray
sz=size(lldch)
if ( sz(0) eq 0 ) then lldch=replicate(lldch,nst)

;; Set the default energy calibration
if (keyword_set(nrgary) eq 0) then begin
   nrgarray=[[-0.86217089,-1.4874672,-0.80257990,-1.0954302], $
             [ 0.17423849, 0.17249550,0.16373508, 0.16001649]]
endif else begin
   nrgarray = nrgary
endelse

;; If the user specifies an energy range then set the energy keyword
if (keyword_set(erng)) then energy=1

;; Coincidence and Anticoincidence Flags
if (keyword_set(coinc) eq 0) then coinc = 0
if (keyword_set(antic) eq 0) then antic = 0

;; Forbid the user from setting both coincidence and anticoincidence
if (keyword_set(coinc) and keyword_set(antic)) then begin
      print,'FATAL ERROR'
      print,'COINC AND ANTIC CANNOT BOTH BE SET'
      print,'EXITING'
      print,' '
      return
endif

;; Logrithmic Vertical Axis?
if (keyword_set(ylog)) then begin
   ylg =1
   ymin = 0.9
endif else begin
   ylg = 0
   ymin = 0
endelse

;; Verbosity
if (keyword_set(verbose) eq 0) then $
   verbose=0


;;
;; Done setting things up
;;


;;
;; Load in the data
;;


;;
;; Since Loading in a datafile can take a long time, the user has
;; The option of reading in previously processed data
;;
if (keyword_set(restore)) then begin
   ;; Find the save file name using the input data file
   ;;

   ;; Save coincidence and anticoincidence spectra separately
   ;;
   accflag = 'all'
   if (keyword_set(coinc)) then accflag='coinc'
   if (keyword_set(antic)) then accflag='antic'

   infile = strsplit(filename,'\....',/extract,/regex)+'.'+accflag+'.idl'

   ;; The above creates an array, so you have to specify the
   ;; First (and only) element in the restore command. IDL sucks.
   if (file_exist(infile(0))) then begin
      restore,infile(0)
   endif else begin
      print,'FATAL ERROR'
      print,'SAVE FILE DOES NOT EXIST'
      print,'EXITING'
      print,' '
      return
   endelse

   ;; If verbosity is set, print out a block of saved spec info
   ;; This should be help ID what the saved spectra actually are
   ;;
   if (keyword_set(verbose)) then begin
      print,' '
      print,'SAVE FILE PARAMETERS'
      print,'   # Strips:   ',strcompress(nst,/remove_all)
      print,'   # Channels: ',strcompress(nch,/remove_all)
      print,'   LLD:        ',strcompress(lldch,/remove_all)
      print,'   Coinc Flag: ',strcompress(coinc,/remove_all)
      print,'   Antic Flag: ',strcompress(antic,/remove_all)
      print,' '
   endif

;; Don't load in from a save file, but instead generate spectra
;; From the raw event data.
endif else begin

   ;;
   ;; Load in the binary datafile
   ;;    data_type=2 specifies 16bit datawords
   ;;    endian='little' since the file was created on a PC
   ;;
   Result = read_binary(filename,data_type=2,endian='little')

   ;;
   ;; Each channel is two sets of 8-bit characters
   ;;    the first two bits are the coincidence flag
   ;;    the last 14 are the signal
   ;; Use the IDL bit shifting routine to separate them
   ;;

   ;; Data
   tdata  = ishft(ishft(result,2),-2)

   ;; Coincidence Flags
   tflags = ishft(result,-14)

   ;;
   ;; Convert the input data into an 2-D array
   ;;

   ;; Get the size of the input data stream
   q=size(result)

   ;; Check to make sure the length of the input data stream is
   ;; A multiple of the number of input strips. If not, exit
   if (q(1)/nst ne (q(1)+nst-1)/nst) then begin
      print,'FATAL ERROR'
      print,'INCOMPLETE FILE'
      print,'EXITING'
      print,' '
      return
   endif else begin
      nevents = q(1)/nst
      if (keyword_set(verbose)) then $
         print,'Number of Events in File: ',nevents
   endelse

   ;;
   ;; Convert the 1-D input array into a nstrips by nchannels array
   ;;
   data=intarr(nst,nevents)
   flags=lonarr(nst,nevents)

   for i=0,nst-1 do begin
      q=lindgen(nevents)*nst + i
      data(i,*)  = tdata(q)
      flags(i,*) = tflags(q)
   endfor

   ;;
   ;; Generate Spectra
   ;;    Use doubles so that we can easily convert to
   ;;    Rates at some future date
   ;; 

   ;; Generate Strip Spectra?
   ;;
   if (keyword_set(coinc) eq 0) then begin

      ;; Set up our variables
      spec=dblarr(nst,nch)

      ;; Create our Strip Histograms
      for i=0,nst-1 do begin

         ;; Set which channels to Accumulate
         ;;    Use the Software LLD here so that we can remove unwanted
         ;;    Triggers for coincidence spectra
         ;;
         if (keyword_set(antic)) then begin
            w=where(flags(i,*) eq 0 and data(i,*) ge lldch(i), count)
         endif else begin
            w=where(data(i,*) ge lldch(i), count)
         endelse

         ;; Histogram the whole thing, and worry about the
         ;; Channel and energy bounds later
         ;;
         if (count ne 0) then begin
            spec(i,*)=histogram(data(i,w),binsize=1,min=0,max=nch-1,/nan)
         endif else begin
            spec(i,*)=0.d
         endelse

         ;; A bit of diagnostics
         ;;
         if (keyword_set(verbose)) then begin
            totcnts=total(spec(i,*))
            print,'Number of Events in Spectrum '+ $
               strcompress(i,/remove_all)+': '+ $
               strcompress(totcnts,/remove_all)
         endif

      endfor

      ;;
      ;; Do energy calibrations
      ;;
      nrg=dblarr(nst,nch)
      if (keyword_set(nrgarray)) then begin
         for i=0,nst-1 do begin
            nrg(i,*)=nrgarray(i,0) + nrgarray(i,1)*ch
         endfor
      endif

      ;; Finished With Strip Spectra
   
   endif else begin
      ;;
      ;; Generate Coincidence Spectra
      ;;

      ;;
      ;; Since we are adding strips with different gains, we need to
      ;;  Convert to energies

      ;; Gain correct strips Before doing anything else
      ;;
      cdata=dblarr(nst,nevents)
      for i=0,nst-1 do begin
         cdata(i,*)=nrgarray(i,0) + nrgarray(i,1)*data(i,*)
      endfor

      ;;
      ;; Calculate the number of possible combinations of strips
      ;;
      ncoinc=factorial(nst)/(factorial(nst-2)*factorial(2))
      ncoinc=long(ncoinc)
     
      ;;
      ;; Set up the spectral variable
      ;;
      spec=dblarr(ncoinc,nch)

      ;;
      ;; Use an ``average'' energy calibration for x-axis
      ;;  This includes adjusting the nrgarray matrix
      ;;
      offst = mean(nrgarray(*,0))
      binsz = mean(nrgarray(*,1))
      nrg=dblarr(ncoinc,nch)

      for i=0,ncoinc-1 do begin
         nrg(i,*)=offst + binsz*ch
         if (i eq 0) then begin
            nrgarray=[offst,binsz]
         endif else begin
            nrgarray=[[nrgarray],[offst,binsz]]
         endelse
      endfor
      nrgarray=transpose(nrgarray)
      

      ;;
      ;; Start Binning Spectra
      ;;  k is the conincidence spectra number
      ;;  i and j are the strips of interest
      ;;  q is a mask to select out only those strips
      ;;
      k=0
      for i=0,nst-2 do begin
         for j=i+1,nst-1 do begin

            ;; Find the data we want
            q=lindgen(nst)
            q=where(q ne i and q ne j)
            w=where(flags(i,*) ge 1 and flags(j,*) ge 1 and $
               flags(q(0),*) eq 0 and flags(q(1),*) eq 0, count )

            ;; Convert our energies back into ``average'' channels
            ;; And create a histogram
            if (count ne 0) then begin
               tdata=long((cdata(i,w)+cdata(j,w)-offst)/binsz +0.5)
               spec(k,*)=histogram(tdata(0,*),binsize=1,min=0,max=nch-1,/nan)
            endif else begin
               spec(k,*)=0.d
            endelse
            k=k+1
         endfor
      endfor

      ;; Now, we bascially have ncoinc strips instead of nst
      ;; Adjust things appropriately
      ;;
      nst = ncoinc
      data = cdata
      ;; Finished(?) with Coincidence Spectra

   endelse

endelse

;;
;; Done loading in the data
;;

;; 
;; Generate a processed IDL save file
;;
if (keyword_set(savespec)) then begin

   ;; Generate the IDL save file name from the input datafile name
   ;;
   ;; Which dataset do we want?
   accflag = 'all'
   if (keyword_set(coinc)) then accflag='coinc'
   if (keyword_set(antic)) then accflag='antic'
   ;; Create IDL save file name
   outfl = strsplit(filename,'\....',/extract,/regex)+'.'+accflag+'.idl'

   ;; Save all of the information that went into creating the
   ;; Processed spectra
   save,nch,nst,lldch,coinc,antic, $
      ch,nrg,nrgarray,spec,filename=outfl(0)

   ;; If verbosity is set, print out a block of saved spec info
   ;;
   if (keyword_set(verbose)) then begin
      print,' '
      print,'SAVE FILE PARAMETERS'
      print,'   # Strips:   ',strcompress(nst,/remove_all)
      print,'   # Channels: ',strcompress(nch,/remove_all)
      print,'   LLD:        ',strcompress(lldch,/remove_all)
      print,'   Coinc Flag: ',strcompress(coinc,/remove_all)
      print,'   Antic Flag: ',strcompress(antic,/remove_all)
      print,' '
   endif
endif

;;
;; Done saving spectra
;;

;;
;; If requested, plot the resulting spectra
;;
if (keyword_set(plot)) then begin

   ;;
   ;; Standard Positioning Variables
   ;;
   xoff=0.12
   xsiz=(0.99-xoff)
   xlab=1.25*xoff
   yoff=0.05
   ysiz=(0.95-yoff)/nst

   ;;
   ;; Because IDL sucks   
   ;;
   pmulti = !p.multi
   !p.multi=[0,1,nst]
   csize=2
   idlsucks=replicate(' ',30)

   ;;
   ;; Create a postscript plot?
   ;;
   if (keyword_set(ps)) then begin
      set_plot,'PS'
      if (keyword_set(psflname) eq 0) then psflname='wcmcaplot.ps'
      ;;
      ;; Default postscript file size
      device,filename=psflname,/portrait,/inches, $
         xsize=6.5,ysize=9.,xoff=1.0,yoff=1.0
      xsz=6.5

      ;;
      ;; Make a smaller plot?
      ;;
      if (keyword_set(small)) then begin
         device,/inches,xsize=3.5,ysize=5.5
	 csize=csize/2.
	 xsz=3.5
      endif

      ;;
      ;; Make a square plot?
      ;;
      if (keyword_set(square)) then begin
         device,/inches,xsize=xsz,ysize=xsz
      endif

   endif

   ;;
   ;; Set the x-axes
   ;;
   if (keyword_set(energy)) then begin
      xord = nrg
      xttl = 'Energy'

      ;; If the Energy Range isn't specified, then convert the channel
      ;;    Range into energy for each strip, and take the max and min
      ;;    As the overall energy range
      ;;
      if (keyword_set(erng) eq 0) then begin
         erng = nrgarray(0,0)*[1,1] + nrgarray(0,1)*chrng(*,0)
         for i=1,nst-1 do begin
            erng=[[erng],nrgarray(i,0)*[1,1] + nrgarray(i,1)*chrng(*,i)]
         endfor
      endif
      xrng=[min(erng),max(erng)]

      pkrng = erng
      if (nst gt 1) then begin
         for i=1,nst-1 do begin
            pkrng = [[erng],[pkrng]]
         endfor
      endif

   endif else begin
      xord = [ch]
      for i=1,nst-1 do begin
         xord = [[xord],[ch]]
      endfor
      xord = transpose(xord)
      xttl = 'Channel'
      xrng = [min(chrng),max(chrng)]
      pkrng = chrng
   endelse


   ;;
   ;; Plot the fist nst-1 Spectra
   ;;
   for i=0,nst-2 do begin

      if (i eq 0 and keyword_set(pltttl)) then begin
         ttl=pltttl
      endif else begin
         ttl=''
      endelse

      if (keyword_set(pnlname)) then begin
         specnm = pnlname(i)
      endif else begin
         specnm = 'Spec '+ strcompress(i,/remove_all)
      endelse
      
      plot,xord(i,*),spec(i,*),psym=10,charsize=csize, $
         xstyle=1,xtickname=idlsucks,xrange=xrng,ylog=ylg, $
         min_value=ymin,ystyle=0,ytitle='Counts',title=ttl, $
         position=[xoff,yoff+(nst-i-1)*ysiz,xoff+xsiz,yoff+(nst-i)*ysiz]
      xyouts,xlab,yoff+(nst-i-0.25)*ysiz,specnm,/normal,charsize=csize/2.

      if (keyword_set(peak)) then begin
         wcpeakfind,xord(i,*),spec(i,*),pkrng(*,i),params=a,/plot, $
            charsize=csize/2.d,verbose=verbose
         if (i eq 0) then begin
            pkcnts=[a(0)]
            peakch=[a(1)]
            pkwidth=[a(2)]
         endif else begin
            pkcnts=[pkcnts,a(0)]
            peakch=[peakch,a(1)]
            pkwidth=[pkwidth,a(2)]
         endelse
      endif
   endfor

   ;;
   ;; Plot the bottom spectra, along with the x-axis labels
   ;;
   i=nst-1
   if (keyword_set(pnlname)) then begin
      specnm = pnlname(i)
   endif else begin
      specnm = 'Spec '+ strcompress(i,/remove_all)
   endelse
   plot,xord(i,*),spec(i,*),psym=10,charsize=csize, $
      xstyle=1,xtitle=xttl,xrange=xrng, $
      ystyle=0,ytitle='Counts',ylog=ylg,min_value=ymin, $
      position=[xoff,yoff+(nst-i-1)*ysiz,xoff+xsiz,yoff+(nst-i)*ysiz]
   xyouts,xlab,yoff+(nst-i-0.25)*ysiz,specnm,/normal,charsize=csize/2.
   if (keyword_set(peak)) then begin
      wcpeakfind,xord(i,*),spec(i,*),pkrng(*,i),params=a,/plot, $
         charsize=csize/2.d,verbose=verbose
      pkcnts=[pkcnts,a(0)]
      peakch=[peakch,a(1)]
      pkwidth=[pkwidth,a(2)]
   endif

   ;;
   ;; Close our plot and execute gv to view it
   ;;
   if (keyword_set(ps)) then begin
      device,/close
      set_plot,'X'
      spawn,['gv',psflname],/noshell
   endif

   ;;
   ;; Because IDL still sucks
   ;;
   !p.multi=pmulti


endif

;;
;; Done plotting spectra
;;


return
end

