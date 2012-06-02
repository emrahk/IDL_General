PRO readxtedata,t,c,path=pa,dirs=dirs,obs=obs,occult=occult, $
                saa=saa,good=good,pcu0=pcu0,pcu1=pcu1,pcu2=pcu2,pcu3=pcu3, $
                pcu4=pcu4,verbose=verbose,noback=noback,back=back, $
                gti=gti,electron=electron,earthvle=earthvle,faint=faint, $
                q6=q6,skyvle=skyvle,top=top,exclusive=exclusive, $
                nopcu0=nopcu0,fivepcu=fivepcu,cass=cass,deadcorr=deadcorr, $
                err=err, binning=binning, bary=bary

;+
; NAME:
;             readxtedata
;
;
; PURPOSE:
;             Retrieves for a given PCA RXTE observation lightcurve
;             data. 
;
;
;
; CATEGORY:
;             RXTE data analysis
;
;
; CALLING SEQUENCE:
;             readxtedata,t,c,path=pa,dirs=dirs,obs=obs,occult=occult, $
;                saa=saa,good=good,pcu0=pcu0,pcu1=pcu1,pcu2=pcu2,pcu3=pcu3, $
;                pcu4=pcu4,verbose=verbose,noback=noback,back=back, $
;                gti=gti,electron=electron,earthvle=earthvle,faint=faint, $
;                q6=q6,skyvle=skyvle,top=top,exclusive=exclusive, $
;                nopcu0=nopcu0,fivepcu=fivepcu,cass=cass,deadcorr=deadcorr, $
;                err=err, binning=binning, bary=bary
; 
; INPUTS:
;             path: path to the observation
;             dirs: subdirectories to the individual observing blocks
;             
; OPTIONAL INPUTS:
;             binning: Number how much datapoints are to be summed up
;                      into a single point. 
;
;
;
;      
; KEYWORD PARAMETERS:
;             see above
;   
;             noback: set if no bkg subtraction is to be performed   
;             earthvle: set if EarthVLE background model is to be used
;             faint: set if Faint background model is to be used
;             q6: set if Q6 background model is to be used
;                (default is to test for earthvle,faint,q6)
;             skyvle: set if SkyVLE background model is to be used
;             (default is 0 for noback,earthvle,faint,q6,skyvle)
;
;             exclusive: set to search for data that was extracted
;                with the exclusive keyword to pca_standard being set.
;             top: set to read top-layer data 
;             nopcu0: set to search for data that was extracted
;                ignoring PCU0   
;             fivepcu: plot count-rates wrt to whole PCA, i.e.,
;                normalizing to five PCU; default is to plot the average
;                countrate per PCU
;             bary: Try to use barycenter time column in data. Must be
;                   created with fxbary before into file with postfix _bary.
;
;
; OUTPUTS:
;             t : time array of data in MJD. 
;             c : count array of data
;
; OPTIONAL OUTPUT:
;             err: Estimated error by applying poisson
;                  statistic. Binning/background subtraction will be acknowledged.
;
;
; EXAMPLE:
;      obsid='P10241'
;      dirs=['01.00','01.000']
;      path='/xtearray/cyg/'
;      readxtedata,t,c,path=path+obsid,dirs=dirs...
;
;
;
; MODIFICATION HISTORY:
; CVS Version 1.14, 2003-05-02 TG
;   added screen output if deadtime correction does not work
;
; $Log: readxtedata.pro,v $
; Revision 1.14  2003/05/02 10:08:09  gleiss
; added screen output if deadtime correction does not work
;
; Revision 1.13  2003/04/03 16:15:59  goehler
; added option to read bary center corrected data
;
; Revision 1.12  2003/03/13 11:00:33  goehler
; - added docu
; - added bary keyword for barycenter column reading.
;
; Revision 1.11
; date: 2002/08/15 06:43:53;  author: goehler;  state: Exp;  lines: +29 -1
; added binning input option to set a binning factor,
; added an error output option to retrieve an error estimated from poisson statistics
; (before subtracting the background)
; 
; Revision 1.10
; date: 2001/03/23 00:36:06;  author: katja
; keyword deadcorr has been added, if set, the output lightcurve is
; deadtime corrected
; 
; Revision 1.9
; date: 2001/01/04 15:23:25;  author: katja
; kp,jw changes FINALLY correcting bug in plotting PCU on times
; 
; Revision 1.8
; date: 2000/12/07 21:00:54;  author: kreyken
; Removed bug concerning the sequence of _top and _ign0
; 
; Revision 1.7
; date: 2000/12/06 00:00:30;  author: wcoburn
; WC: fixed bug in the spawn command
; 
; Revision 1.6
; date: 2000/12/04 14:12:32;  author: katja
; the nopcu0 keyword has been added, in order to plot data (with
; correct normalization) that was extracted ignoring PCU0 
; 
; Revision 1.5
; date: 2000/11/15 01:14:10;  author: wheindl
; added cass keyword for obscat path
; 
; Revision 1.4
; date: 2000/10/19 10:08:57;  author: wilms
; improvements concerning reading all different permutations of PCUs
; and in computation of electron ratio 
; 
; Revision 1.3
; date: 1999/10/26 17:19:34;  author: katja
; bug fixes
; 
; Revision 1.2
; date: 1999/10/26 16:50:38;  author: katja
; added skyvle and q6 keywords
; 
; Revision 1.1
; date: 1999/10/14 13:17:20;  author: cvs
; Initial revision
;   
;-


   IF (n_elements(verbose) EQ 0) THEN verbose=0
   
   ;; given the state of the PCA, here are ALL possible combinations
   ;; of PCUs where at least one PCU is still on
   detoff=['','0','1','2','3','4', $
           '01','02','03','04', $
           '12','13','14', $
           '23','24', $
           '34', $
           '012','013','014','023','024','034', $
           '123','124','134', $
           '234', $
           '0123','0124','0134','0234', $
           '1234']
   numpcuon=5-strlen(detoff)
   
   IF (keyword_set(nopcu0)) THEN BEGIN 
       ndx=where(strpos(detoff,'0') EQ -1)
       numpcuon[ndx]=numpcuon[ndx]-1
   ENDIF 
   
   ; ;; take care of normalization, taking into account that
;    ;; PCU0 might be ignored 
;    name0=['','1','2','3','4', $
;           '12','13','14', $
;           '23','24', $
;           '34', $
;           '123','124','134', $
;           '234', $
;           '1234'] 
;    FOR i=0,n_elements(detoff)-1 DO BEGIN
;        zeroon=0
;        FOR j=0,n_elements(name0)-1 DO BEGIN 
;            IF (detoff[i] EQ name0[j]) THEN zeroon=1
;        ENDFOR
;        IF (zeroon EQ 1) AND (keyword_set(nopcu0)) THEN BEGIN
;            numpcuon[i]=numpcuon[i]-1
;        ENDIF ELSE BEGIN
;            numpcuon[i]=numpcuon[i]
;        ENDELSE 
;    ENDFOR   
     
   ;; conversion of measured countrate to 1PCU
   factor=1./numpcuon
   IF (keyword_set(fivepcu)) THEN factor=factor*5
   IF n_elements(binning) EQ 0 THEN binning=1.D0
   
   ;; prepare filename
   detoff='_'+detoff+'off'
   detoff[0]='' 
   
   topins=''
   IF (keyword_set(top)) THEN topins='_top'
   
   exclins=''
   IF (keyword_set(exclusive)) THEN exclins='_excl'
   
   ignore=''
   IF (keyword_set(nopcu0)) THEN ignore='_ign0'

   baryins=''
   IF (keyword_set(bary)) THEN baryins='_bary'
   
   file='/standard2f'+detoff+exclins+ignore+topins+$
     '/standard2f'+detoff+exclins+ignore+topins+baryins+'.lc'

   print,pa
   print,dirs
    
   deadfi='/pcadead/RemainingCnt.lc'   
  
   backsky='/pcabackest/standard2f_back_SkyVLE'+$
     topins+'_good'+detoff+exclins+ignore+baryins+'.lc'
   backearth='/pcabackest/standard2f_back_EarthVLE'+$
     topins+'_good'+detoff+exclins+ignore+baryins+'.lc'
   backfaint='/pcabackest/standard2f_back_Faint'+$
     topins+'_good'+detoff+exclins+ignore+baryins+'.lc'
   backq6='/pcabackest/standard2f_back_Q6'+$
     topins+'_good'+detoff+exclins+ignore+baryins+'.lc'
   
   gtifi='/filter/good'+detoff+exclins+ignore+'.gti'
   

   path=pa+'/'
   
   ;;
   ;; Read light-curves, backs and subtract
   ;;
   nobs=n_elements(dirs)
   obs=fltarr(2,nobs)
   obs(0,*)=1E20
   obs(1,*)=-1E20
   kk=0
   t=[0.]
   c=[0.]
   err=[0.] ; error array

   FOR i=0,nobs-1 DO BEGIN 
       FOR j=0,n_elements(file)-1 DO BEGIN 
           IF (file_exist(path+dirs(i)+file(j))) THEN BEGIN 
               IF (NOT keyword_set(back)) THEN BEGIN 
                   IF (keyword_set(verbose)) THEN BEGIN 
                            print,'READING '+path+dirs(i)+file(j)
                   ENDIF 
                   readlc,tt,cc,path+dirs(i)+file(j),/mjd,bary=bary
               ENDIF
               IF (keyword_set(deadcorr)) THEN BEGIN 
                   IF (file_exist(path+dirs(i)+deadfi)) THEN BEGIN
                     pcadeadlc,tt,cc,path+dirs(i),/mjd
                   ENDIF ELSE BEGIN
                     print,'READXTEDATA: deadtime correction failed: "/pcadead/RemainingCnt.lc" does not exist'
                   ENDELSE  
               ENDIF  
               IF NOT (keyword_set(noback)) THEN BEGIN 
                   backfi=''
                   
                   IF keyword_set(faint) THEN BEGIN 
                       IF (file_exist(path+dirs[i]+backfaint[j])) THEN BEGIN 
                           backfi=backfaint[j]
                       ENDIF ELSE BEGIN
                           message,'background lightcurve "Faint" does not exist'
                       ENDELSE 
                   ENDIF
                   
                   IF keyword_set(q6) THEN BEGIN 
                       IF (file_exist(path+dirs[i]+backq6[j])) THEN BEGIN 
                           backfi=backq6[j]
                       ENDIF ELSE BEGIN
                           message,'background lightcurve "Q6" does not exist'
                       ENDELSE   
                   ENDIF
                   
                   IF keyword_set(skyvle) THEN BEGIN 
                       IF (file_exist(path+dirs[i]+backsky[j])) THEN BEGIN 
                           backfi=backsky[j]
                       ENDIF ELSE BEGIN
                           message,'background lightcurve "SkyVLE" does not exist'
                       ENDELSE    
                   ENDIF
                   
                   IF keyword_set(earthvle) THEN BEGIN 
                       IF (file_exist(path+dirs[i]+backearth[j])) THEN BEGIN 
                           backfi=backearth[j]
                       ENDIF ELSE BEGIN
                           message,'background lightcurve "EarthVLE" does not exist'
                       ENDELSE 
                   ENDIF
                   
                   IF ((backfi EQ '') AND (file_exist(path+dirs[i]+backsky[j]))) THEN BEGIN 
                       backfi=backsky[j]
                       print,'no background lightcurve has been specified,'
                       print,'using "SkyVLE"'
                   ENDIF 
                   
                   
                   IF (backfi EQ '') THEN BEGIN 
                       message,'background not found'
                   ENDIF 
                   
                   IF (keyword_set(verbose)) THEN BEGIN 
                       print,'READING '+path+dirs(i)+backfi
                   END 
                   readlc,tb,cb,path+dirs(i)+backfi,/mjd,bary=bary
                   IF (keyword_set(back)) THEN BEGIN 
                       tt=tb
                       cc=cb
                   END ELSE BEGIN 
                       cc=backsub(tt,cc,tb,cb)
                   END 
               ENDIF 

               ;; determine error: (eg, 7.1.2001)
               IF (keyword_set(verbose)) THEN BEGIN 
                   print,'ERROR DETERMINATION: READING '+path+dirs(i)+file(j)
               ENDIF 
               
               readlc,t_err,c_err,path+dirs(i)+file(j),/mjd,bary=bary
               ee=sqrt(c_err/double(binning)) * factor[j]


               cc=cc*factor[j]

               IF n_elements(binning) NE 0 THEN BEGIN
                   ;; rebin data:
                   ;; skip data at end of read set not fitting into binning:
                   cc=cc[0:n_elements(cc)-1-n_elements(cc) MOD binning]
                   tt=tt[0:n_elements(tt)-1-n_elements(tt) MOD binning]
                   ee=ee[0:n_elements(ee)-1-n_elements(ee) MOD BINNING]

                   tt=tt[where(indgen(n_elements(tt)) MOD BINNING EQ 0)]
                   cc=rebin(cc,n_elements(cc) / BINNING)
               ENDIF 
               ;;
               ;; begin and end of the observation
               ;;
               obs(0,i)=min([obs(0,i),min(tt)])
               obs(1,i)=max([obs(1,i),max(tt)])
               ;;
               ;; append to data-stream
               ;;
               IF (t(0) EQ 0.) THEN BEGIN 
                   t=tt
                   c=cc
                   err=ee
               END  ELSE BEGIN 
                   t=[t,tt]
                   c=[c,cc]
                   err=[err,ee]
               END 
           END 
       END 
   END 
   ;;
   ;; Put in sorted order
   ;;
   ndx=sort(t)
   t=t(ndx)
   c=c(ndx)
   err=err(ndx)
   
   IF (n_elements(t) LE 1) THEN BEGIN 
       message,'No files found'
   END 
   
   ;;
   ;; Read timeline to get occultation-times, saa-times,...
   ;;
   obscats=intarr(nobs*5)
   ii=0
   FOR i=0,nobs-1 DO BEGIN 
       firstday=long(obs(0,i)-50083.)+730-1
       lastday=long(obs(1,i)-50083.)+730+1

       FOR ddd=firstday,lastday DO BEGIN 
           obscats(ii)=ddd
           ii=ii+1
       END 
   ENDFOR 
   ;; produce unique list of timelines
   obscats=obscats(sort(obscats(0:ii-1)))
   obscats=string(format='(5HOCday,I4.4)', $
                    obscats(uniq(obscats)))
   readobscat,obscats,saa=saa,good=good,occult=occult, $
              /mjd,verbose=verbose,cass=cass
   
   ;;
   ;; Read GTI-Files used for preparing the spectra
   ;;
   FOR i=0,n_elements(dirs)-1 DO BEGIN 
       FOR j=0,n_elements(gtifi)-1 DO BEGIN 
           gtfi=path+dirs(i)+gtifi(j)
           IF (file_exist(gtfi)) THEN BEGIN 
               IF (keyword_set(verbose)) THEN BEGIN 
                   print,'READING '+gtfi
               ENDIF 
               readgti,sta,sto,gtfi,/mjd
               IF (n_elements(start) EQ 0) THEN BEGIN 
                   start=sta
                   stop=sto
               END ELSE BEGIN 
                   start=[start,sta]
                   stop=[stop,sto]
               END 
           END 
       END 
   END 
   ndx=sort(start)
   start=start(ndx)
   stop=stop(ndx)
   gti=dblarr(2,n_elements(start))
   gti(0,*)=start
   gti(1,*)=stop
   
   ;;
   ;; Find times when the PCU were on
   ;; 

   ;; ... find filter-files
   filter=strarr(n_elements(dirs))
   FOR i=0,n_elements(dirs)-1 DO BEGIN 
       spawn,'ls '+path+dirs(i)+'/filter/*xfl',result,/sh
       filter(i)=result
   END 

   ;; ... read filter-files, get pcu-times and electron ratios
   readxfl,filter,pcu0,pcu1,pcu2,pcu3,pcu4,electron,/mjd,nopcu0=nopcu0
END 
