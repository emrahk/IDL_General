PRO rxte_zuramo,path,type=type,ord=inpord, $
                maxdim=inpmaxdim,dim=inpdim,newbin=inpnewbin, $
                plotbin=plotbin,histmax=histmax,itemax=itemax, $             
                channels=channels,obsid=obsid,username=username,date=date, $
                color=color,postscript=postscript,chatty=chatty  
;+
; NAME:
;          rxte_zuramo
;
;
; PURPOSE:
;          perform first order linear state space model fits to
;          segmented, evenly spaced, multidimensional xdr lightcurves
;          for all given energy channels; save the Zuramo model
;          parameters for all segments 
;
;   
; FEATURES: 
;         segmented, evenly spaced, multidimensional (i.e., for one
;         or more energy bands) xdr lightcurves (e.g., prepared by the
;         rxte_syncseg.pro routine) are read; the maximum segment
;         length ``maxdim'' of the input lightcurves has to be given
;         in bins; the segment length for the Zuramo analysis ``dim''
;         has to be given in bins and should be obtained by dividing
;         ``maxdim'' by an integer; the lightcurves of length ``dim''
;         can then be rebinned by an integer factor given by
;         ``newbin''; as part of the output filenames ``dim'' (before
;         rebinning), ``newbin'', and the ``channels'' array
;         (containing the energy bands corresponding to each set of
;         the multidimensional input lightcurves) are required inputs;
;         a linear state space model fit of order ``ord'' (up to now:
;         ord=1) is then performed for each rebinned segment; the
;         distributions of the Zuramo fit parameters (dyn, P/tau,
;         WfWNR, VdBeoR, supremum, number of iterations, details see
;         zrmcalc.pro and zuramo.ksh) are determined: the Zuramo model
;         parameters for each segment are saved to an ASCII file (one
;         data + one history file per energy range) and are plotted to
;         a ps file (again one file per energy range, see keywords
;         tagged ``kw1'') by zrmplot.pro; characteristics of the
;         distributions are also saved (one ASCII file for the most
;         probable value, one for the mean, and one for the standard
;         deviation of all Zuramo fit parameters and all energy
;         bands); the input xdr lightcurves must be stored in
;         <path>/light/processed, and the output ASCII Zuramo
;         quantities, the output ps distribution plots, and the output
;         ASCII distribution characteristics are stored in
;         subdirectories of <path>/light/zuramo/<type> (see
;         RESTRICTIONS and SIDE EFFECTS) 
;
;   
; CATEGORY:
;          timing tools
;
;
; CALLING SEQUENCE:
;          rxte_zuramo,path,type=type,ord=inpord, $
;                      maxdim=inpmaxdim,dim=inpdim,newbin=inpnewbin, $
;                      plotbin=plotbin,histmax=histmax,itemax=itemax, $
;                      channels=channels, $
;                      obsid=obsid,username=username,date=date, $
;                      color=color,postscript=postscript,chatty=chatty   
;  
;   
; INPUTS:
;          path               : string containing the path to the
;                               observation directory which must have
;                               a subdirectory called light/processed/
;                               where the prepared lightcurves are
;                               stored in xdr format, named according
;                               to the output of rxte_syncseg.pro routine      
;          type               : string that in the case of Fourier
;                               calculations (rxte_fourier.pro)
;                               indicates whether one (type='high') or
;                               more segment lengths (type='low') are
;                               given, and whether the non-frequency
;                               rebinned Fourier quantities are saved
;                               as well (type='low') or not
;                               (type='high'); here, in the case of
;                               the Zuramo calculations this is only a
;                               directory name and the properties of
;                               type='high' (only one segment length
;                               is allowed) are given automatically     
;          ord                : parameter giving the order of the
;                               linear state space models that are
;                               fitted to the lightcurves;
;                               as for now only the first order is
;                               implementd, thus only ord=1 is
;                               allowed; ord=long(inpord) is used   
;          maxdim             : parameter giving the maximum segment
;                               length of the input lightcurves in
;                               time bins; maxdim is part of the file
;                               name of the multidimensional input
;                               lightcurve; maxdim=long(inpmaxdim) is
;                               used    
;          dim                : parameter giving the segment
;                               length (in bins BEFORE rebinning the
;                               input lightcurve by the factor given
;                               by newbin) for which the Zuramo
;                               quantities are to be calculated; to
;                               ensure that no lightcurve data are
;                               lost, dim should be an integer values
;                               obtained by dividing maxdim by an
;                               integer value; dim=long(inpdim) is
;                               used 
;          newbin             : parameter containing the rebin factor for
;                               all energy bands (no array!); newbin
;                               is part of the output file names;
;                               newbin=long(inpnewbin) is used   
;          channels           : string array containing the channel
;                               ranges (pha channels); plotted on the
;                               overview plots; 
;                               note: contrary to the optional input
;                               ``channels'' in the rxte_fourier.pro
;                               routine,  ``channels'' is an array
;                               here and is not optional because it is
;                               part of the output file names     
;   
;          
;          note: further input parameters for the fitting of the 
;                linear state space Models are defined in the ksh
;                script zuramo.ksh that is called by zrmcalc.pro    
;   
;   
; OPTIONAL INPUTS:
;          see KEYWORD PARAMETERS   
;
;
; KEYWORD PARAMETERS:
;          and OPTIONAL INPUTS:   
;   
;       -- for the plot routines, for each energy band one
;          overview plot (showing the distributions of several Zuramo
;          quantities for all segments) is produced (kw1) 
;              plotbin        : array giving the size of the bins
;                               that are used to plot the distribution
;                               histograms of the Zuramo parameters
;                               (in the following order: 
;                               dyn, tau [in units of the lightcurve
;                               time array, i.e., in sec], WfWNR,
;                               VdBeoR, supremum, number of
;                               iterations); for each of the six
;                               Zuramo parameters with the exception
;                               of tau, the entry in plotbin has
;                               to be given in the same units as
;                               delivered by the LSSM fit routine; 
;                               default: 
;                               plotbin=[1D-2,2D-2,5D-2,5D-2,5D-3,5D1]
;              histmax        : array giving the maximum value
;                               (minimum value = 0) that are used to
;                               determine the distribution histograms
;                               of the Zuramo parameters (not
;                               necessarily the range that is
;                               plotted); order and units, see plotbin;   
;                               default:
;                               histmax=[1D0,5D0,1D0,1D0,1D-1,2D3]   
;              itemax         : define the maximum number of
;                               iterations of the LSSM model fit that
;                               is performed; if for a given lightcurve
;                               segment the number of iterations is
;                               reaching itemax, the corresponding fit
;                               results are removed from the sample; 
;                               default: itemax=2000L
;              obsid          : string giving the name of the observation;
;                               plotted on the overview plots;
;                               default: 'Keyword obsid has not been set
;                                        (rxte_zuramo)'  
;              username       : string giving the name of the user; 
;                               plotted on the overview plots;   
;                               default: 'Keyword username has not been set
;                                        (rxte_zuramo)'  
;              date           : string giving the production date of
;                               the Fourier quantities; plotted on the
;                               overview plots; 
;                               default: 'Keyword date has not been set
;                                        (rxte_zuramo)'
;              color          : decide which color (of color table 39) is
;                               used for each of the three plots;
;                               default: color=[50,50,50]: blue   
;              postscript     : decide whether ps or eps plots are
;                               produced; 
;                               default: postscript=1: ps plots are
;                                        produced   
;       -- for the screen output
;              chatty         : controls screen output; 
;                               default: screen output;  
;                               to turn off screen output, set
;                               chatty=0       
;   
;   
; OUTPUTS:
;          none, but: see side effects    
;   
;   
; OPTIONAL OUTPUTS:
;          none   
;
;
; COMMON BLOCKS:
;          none
;
;
; SIDE EFFECTS:
;          the resulting Zuramo quantities and the corresponding
;          history files are written to subdirectories of the
;          <path>/light/zuramo/ directory
;   
;          in xdr format under the following file names (the .history
;          files are ASCII): 
;   
;          <path>/light/zuramo/<type>/onelength/: 
;          (no merging of different segment lengths as for the Fourier
;          quantities is performed here (light/zuramo/<type>/merged
;          does not exist), only results for type='high', i.e., for
;          one segment length are saved)    
;                  <dim>_<newbin>_<channels[*]>.history
;                  (e.g., 0008192_04_0-10.history)
;                  <dim>_<newbin>_<channels[*]>.par1
;                  (e.g., 0008192_04_0-10.par1)  
;
;          and as ps plots under the following file names (the .txt
;          files are ASCII): 
;
;          <path>/light/zuramo/<type>/plots/:  
;                  <dim>_<newbin>_<channels[*]>.ps
;                  (e.g., 0008192_04_0-10.ps)
;                  <dim>_<newbin>_max.txt
;                  <dim>_<newbin>_mean.txt
;                  <dim>_<newbin>_sig.txt   
;
;
;  for a description of the Zuramo quantities labeled by these file
;  names, see subroutines of rxte_zuramo.pro or the ASCII file
;  readme.txt    
;   
;
; RESTRICTIONS: 
;          the input lightcurves must have been produced
;          according to rxte_syncseg.pro: they have to be segmented,
;          evenly spaced and multidimensional, it must be possible to
;          read them with xdrlc_r.pro and they must be stored in a
;          directory named <path>/light/processed/; the subdirectories
;          <path>/light/zuramo/<type>/onelength, and
;          <path>/light/zuramo/<type>/plots must exist for saving the
;          results; to ensure that all lightcurve data are used dim
;          should be an integer value obtained by dividing maxdim by
;          an integer value
;
;
; PROCEDURES USED:
;          zrmcalc.pro, zrmplot.pro
;
;
; EXAMPLE: 
;          rxte_zuramo,'01.all',type='high',ord=1, $
;                      channels=['0-10','11-13','14-19'], $   
;                      maxdim=8192L,dim=8192L,newbin=4,/chatty   
;   
;
; for an example of the rest of the keywords see default values    
;
;
; MODIFICATION HISTORY:
;          Version 1.1, 1998       Katja Pottschmidt
;                       1999/10/14 Katja Pottschmidt,
;                                  cvs version control enabled      
;          Version 1.2, 2000/11/07 Katja Pottschmidt,   
;                                  IDL header added,
;                                  keyword default values defined/changed   
;          Version 1.3, 2000/11/07 Katja Pottschmidt,   
;                                  IDL header and keywords:
;                                  minor corrections   
;          Version 1.4, 2000/12/12 Katja Pottschmidt,   
;                                  ``path'' does not contain ``light''
;                                  anymore 
;   
;-
   
   
;; set default values
IF (n_elements(plotbin) EQ 0) THEN plotbin=[1D-2,2D-2,5D-2,5D-2,5D-3,5D1] 
IF (n_elements(histmax) EQ 0) THEN histmax=[1D0,5D0,1D0,1D0,1D-1,2D3] 
IF (n_elements(itemax) EQ 0) THEN itemax=[2000L]    
IF (n_elements(obsid) EQ 0) THEN BEGIN 
    obsid='Keyword obsid has not been set (rxte_zuramo)'
ENDIF 
IF (n_elements(username) EQ 0) THEN BEGIN 
    username='Keyword username has not been set (rxte_zuramo)' 
ENDIF     
IF (n_elements(date) EQ 0) THEN BEGIN
    date='Keyword date has not been set (rxte_zuramo)'
ENDIF              
IF (n_elements(color) EQ 0) THEN color=[50,50,50]    
IF (n_elements(postscript) EQ 0) THEN postscript=1   
IF (n_elements(chatty) EQ 0) THEN chatty=1

          
;; helpful parameters
ord         = long(inpord)
maxdim      = long(inpmaxdim)   
dim         = long(inpdim)
newbin      = long(inpnewbin)
ndim        = n_elements(dim)
nch         = n_elements(channels)

segname     = path+'/light/processed/'+ $
              string(format='(I7.7)',maxdim)+'_seg.xdrlc'
zrmroot     = path+'/light/zuramo/'+type

plotquans   = ['DYN','TAU [sec]','WNR','VDR','SUP','ITE']
nplot       = n_elements(plotquan)


;; read synchronized, segmented lightcurve
;; calculate Zuramo quantities + write to file
bt=dblarr(ndim)
nt=lonarr(ndim)
FOR i=0,ndim-1 DO BEGIN
    FOR chan=0,nch-1 DO BEGIN 
        ;; read synchronized, segmented lightcurve for one channel range
        xdrlc_r,segname,time,rate,select=chan+1,history=lchistory,chatty=chatty
        ;; output path for Zuramo quantities 
        zrmpath=zrmroot+'/onelength/'+string(format='(I7.7)',dim(i))
        zrmpath=zrmpath+'_'+string(format='(I2.2)',newbin)
        ;; calculate Zuramo quantities + write to file
        zrmcalc,time,rate,zrmpath, $
          dseg=dim(i),factor=newbin,ord=ord, $
          energy=channels(chan),obsid=obsid,username=username,date=date, $ 
          history=lchistory,chatty=chatty         
    ENDFOR 
    nt(i)=n_elements(time)
    bt(i)=(time(1)-time(0))*newbin 
ENDFOR


;; create ps-plot of Zuramo quantities for all channel ranges
;; save important distribution parameters
FOR i=0,ndim-1 DO BEGIN
    nus=long(nt(i)/dim(i))    
    ;; initialize important distribution parameters
    ;; most probable value of distribution for all Zuramo quantities
    mostdyn=0D0
    mosttau=0D0
    mostwnr=0D0
    mostvdr=0D0
    mostsup=0D0
    mostite=0D0
    ;; mean value of distribution for all Zuramo quantities
    meandyn=0D0
    meantau=0D0
    meanwnr=0D0
    meanvdr=0D0
    meansup=0D0
    meanite=0D0
    ;; standard deviation of distribution for all Zuramo quantities
    sigdyn=0D0
    sigtau=0D0
    sigwnr=0D0
    sigvdr=0D0
    sigsup=0D0
    sigite=0D0    
    
    ;; prepare and create ps-plot
    ;; calculate important distribution parameters 
    ;; for each channel range
    FOR chan=0,nch-1 DO BEGIN         
        ;; input path for Zuramo quantities
        zrmpath=zrmroot+'/onelength/'+string(format='(I7.7)',dim(i))
        zrmpath=zrmpath+'_'+string(format='(I2.2)',newbin)
        zrmpath=zrmpath+'_'+channels(chan)
        zrmpath=zrmpath+'.par'+string(format='(I1.1)',ord)
        ;; output path for the plots
        plotname=zrmroot+'/plots/'+string(format='(I7.7)',dim(i))
        plotname=plotname+'_'+string(format='(I2.2)',newbin)
        plotname=plotname+'_'+channels(chan)
        plotord='order '+string(format='(I1.1)',ord)
        ;; create ps-plot + output of important distribution parameters
        zrmplot,zrmpath,plotname, $
          mostquan=mostquan,meanquan=meanquan,sigquan=sigquan, $
          nseg=nus,bt=bt(i),quantities=plotquans, $
          plotbin=plotbin,histmax=histmax,itemax=itemax, $
          label=[plotord,obsid,username,date,channels(chan)], $
          color=color,postscript=postscript,chatty=chatty
        ;; collect important distribution parameters for all channel ranges
        ;; most probable value
        mostdyn=temporary([mostdyn,mostquan(0)])
        mosttau=temporary([mosttau,mostquan(1)])
        mostwnr=temporary([mostwnr,mostquan(2)])
        mostvdr=temporary([mostvdr,mostquan(3)])
        mostsup=temporary([mostsup,mostquan(4)])
        mostite=temporary([mostite,mostquan(5)])
        ;; mean value
        meandyn=temporary([meandyn,meanquan(0)])
        meantau=temporary([meantau,meanquan(1)])
        meanwnr=temporary([meanwnr,meanquan(2)])
        meanvdr=temporary([meanvdr,meanquan(3)])
        meansup=temporary([meansup,meanquan(4)])
        meanite=temporary([meanite,meanquan(5)])
        ;; standard deviation
        sigdyn=temporary([sigdyn,sigquan(0)])
        sigtau=temporary([sigtau,sigquan(1)])
        sigwnr=temporary([sigwnr,sigquan(2)])
        sigvdr=temporary([sigvdr,sigquan(3)])
        sigsup=temporary([sigsup,sigquan(4)])
        sigite=temporary([sigite,sigquan(5)])
    ENDFOR
    
    ;; write important distribution parameters to one file for all
    ;; channel ranges
    ;; most probable value
    maxevol=zrmroot+'/plots/'+string(format='(I7.7)',dim(i))
    maxevol=maxevol+'_'+string(format='(I2.2)',newbin)
    maxevol=maxevol+'_max.txt'
    openw,unit,maxevol,/get_lun
    printf,unit,plotquans(0)
    printf,unit,mostdyn(1:nch)
    printf,unit,plotquans(1)
    printf,unit,mosttau(1:nch)
    printf,unit,plotquans(2)
    printf,unit,mostwnr(1:nch)
    printf,unit,plotquans(3)
    printf,unit,mostvdr(1:nch)
    printf,unit,plotquans(4)
    printf,unit,mostsup(1:nch)
    printf,unit,plotquans(5)
    printf,unit,mostite(1:nch)
    free_lun,unit
    ;; mean value
    meanevol=zrmroot+'/plots/'+string(format='(I7.7)',dim(i))
    meanevol=meanevol+'_'+string(format='(I2.2)',newbin)
    meanevol=meanevol+'_mean.txt'
    openw,unit,meanevol,/get_lun
    printf,unit,plotquans(0)
    printf,unit,meandyn(1:nch)
    printf,unit,plotquans(1)
    printf,unit,meantau(1:nch)
    printf,unit,plotquans(2)
    printf,unit,meanwnr(1:nch)
    printf,unit,plotquans(3)
    printf,unit,meanvdr(1:nch)
    printf,unit,plotquans(4)
    printf,unit,meansup(1:nch)
    printf,unit,plotquans(5)
    printf,unit,meanite(1:nch)
    free_lun,unit
    ;; standard deviation
    sigevol=zrmroot+'/plots/'+string(format='(I7.7)',dim(i))
    sigevol=sigevol+'_'+string(format='(I2.2)',newbin)
    sigevol=sigevol+'_sig.txt'
    openw,unit,sigevol,/get_lun
    printf,unit,plotquans(0)
    printf,unit,sigdyn(1:nch)
    printf,unit,plotquans(1)
    printf,unit,sigtau(1:nch)
    printf,unit,plotquans(2)
    printf,unit,sigwnr(1:nch)
    printf,unit,plotquans(3)
    printf,unit,sigvdr(1:nch)
    printf,unit,plotquans(4)
    printf,unit,sigsup(1:nch)
    printf,unit,plotquans(5)
    printf,unit,sigite(1:nch)
    free_lun,unit    
ENDFOR


END 












