1) Summary

This directory contains tools to produce evenly spaced lightcurve segments
from unevenly spaced raw data (in FITS format), tools to strictly
synchronize simultaneous lightcurves for multiple energy bands, different
lightcurve analysis procedures (most notably: calculation of several
Fourier statistics, fitting of first order linear state space models) most
of which require evenly spaced lightcurves, and, finally, tools to read and
write the results in xdr format and plot ps figures for a quick look at the
results.

All the procedures are IDL routines except for one ksh script (zuramo.ksh)
to call the fit routine for linear state space models. The LSSM fitting
itself is a Fortran code which is not to be found in this directory.

Most of the procedures were written to be independent of the instrument
that provided the lightcurve data - with the exception of the deadtime
correction in determining the noise component of Fourier quantities, and
some higher level procedures for the automated analysis of RXTE monitoring
lightcurves (see next paragraph).

The deadtime correction of the Leahy normalized noise in the power spectra
can either be performed using instrument independent formulae (Zhang,
Jahoda, Swank, et al., 1995, Ap. J. 449, 930) or specialized ones for the
RXTE/PCA instrument (Jernigan, Klein, and Arons, 2000, Ap. J. 530, 875) or
the RXTE/HEXTE instrument (Kalemci, 2000, priv. comm.). In order to switch
off the deadtime correction use the Zhang correction with a deadtime of 0.




2) Automated analysis of RXTE/PCA lightcurves

There are procedures that were especially written to perform an automated
timing analysis of many high time-resolution RXTE/PCA lightcurves in
multiple energy bands (the initial application of almost all the tools was
to RXTE monitoring obervations of the bright HMXB and BHC Cygnus X-1
performed in 1998 to 2000). All the stages of the automated analysis also
work for the analysis of RXTE/HEXTE data (note that to accomplish this,
different deadtime correction tools and background determination tools have
to be used for PCA and HEXTE). The following three procedures correspond to
the three main stages of the automated analysis:

rxte_syncseg.pro : prepare the lightcurves (e.g., find segments without
                   gaps, rebin, time-synchronize energy channels, cut into
                   equally long segments for different segment lengths),
                   save results as xdr files, requires that the original
                   FITS lighcurves are stored in a directory named
                   <path>/light/raw/ and that they are named according to
                   the output of the IAAT extraction scripts (e.g.,
                   FS37_978fa90-9790888__excl_8_160-214.lc for the PCA, and
                   FS_04.00-a_src_6_15-30.lc or FS_04.00-a_bkg_6_15-30.lc
                   for HEXTE), 
                   requires that a directory
                   <path>/light/processed/ exists for the resulting
                   multidimensional xdr lightcurves, see *), 
                   HEXTE source and background lightcurves have to be
                   synchronized separately,
                   for PCA lightcurves, if the deadtime information exists
                   in the <path>/light/raw/ directory, subroutines generate
                   pcadead-files in the <path>/light/processed/ directory
                   for the final lcs 
  
rxte_fourier.pro : calculate Fourier quantities and their uncertainties and
                   noise corrections from the prepared lightcurves, rebin
                   the frequencies, save results as multidimensional xdr
                   files and as overview ps plots, requires that the xdr
                   lighcurves are stored in a directory named
                   <path>/light/processed/ and that they are named
                   according to the rxte_syncseg.pro output (e.g.,
                   0131072_seg.xdrlc), 
                   requires that the directories
                   <path>/light/fourier/<type>/onelength/,
                   <path>/light/fourier/<type>/merged/ and
                   <path>/light/fourier/<type>/plots/ exist for saving the
                   results, see **), 
                   the PCA as well as the HEXTE power spectra can be
                   background corrected in case that the Miyamoto
                   normalization is applied (PCA: ``full'' standard2f spectra  
                   must exist in the extraction path, HEXTE: synchronized
                   background file(s) must exist in the
                   <path>/light/processed/ directory),
                   the PCA as well as the HEXTE power spectra noise can be
                   deadtime corrected (PCA: the .pcadead files containing
                   the housekeeping data must exist in the
                   <path>/light/processed/ dirextory, HEXTE: the
                   ``*_FH53_a.gz'' or ``*_FH59_b.gz'' file containing the
                   housekeeping data and the ``*_good_hexte.gti'' file must
                   exist in the <path>/house/ directory) 

        
rxte_zuramo.pro :  perform LSSM fitting of first order models to the
                   prepared lightcurves, save results as ASCII files
                   (separate files for each energy band) and overview ps
                   plots, requires that the xdr lighcurves are stored in a
                   directory named <path>/light/processed/ and that they are
                   named according to the rxte_syncseg.pro output (e.g.,
                   0131072_seg.xdrlc), requires that the directories
                   <path>/light/zuramo/<type>/onelength/ and
                   <path>/light/zuramo/<type>/plots/ exist for saving the
                   results, see ***),
                   this analysis method has not been extended to HEXTE
                   data sofar (should work for HEXTE in principle, though) 

Almost all remaining procedures are used by the above procedures.




3) I/O in xdr format:

Of the remaining subroutines the following are for reading and writing the xdr
files:

xdrlc_r.pro        : read multidimensional lightcurve, keywords (history
		     and others) in format		   
xdrlc_w.pro	   : write multidimensional lightcurve, keywords (history
		     and others) in xdr format  
(xdrlc.format	   : ASCII file explaining the exact IDL formats used for
		     the lightcurve arrays and the keyword parameters,
		     i.e., written and read by xdrlc_w.pro and
		     xdrlc_r.pro.)    

xdrfu_r1.pro	   : read multidimensional Fourier quantity (each set
		     calculated from one energy band), keywords
		     (history and others) in xdr format  
xdrfu_r2.pro	   : read multidimensional Fourier quantity (each set
		     calculated from two energy bands), keywords
		     (history and others) in xdr format 
xdrfu_w1.pro       : write multidimensional Fourier quantity (each set
		     calculated from one energy band), keywords
		     (history and others) in xdr format  
xdrfu_w2.pro       : write multidimensional Fourier quantity (each set
		     calculated from two energy bands), keywords
		     (history and others) in xdr format 
(xdrfu.format      : ASCII file explaining the exact IDL formats used for
		     the Fourier quantity arrays and the keyword
		     parameters, i.e., written and read by xdrfu_w[1,2].pro
		     and xdrfu_r[1,2].pro.)   

(history.bsp       : ASCII example of a history keyword written by xdrfu_w1.pro
		     or xdrfu_w2.pro, containing Fourier quantities
		     calculated using rxte_syncseg.pro and rxte_fourier.pro) 




4) Instrument and file format independent timing tools

The mostly instrument independent tools to process and/or analyze
lightcurves, Fourier quantities, and LSSM models are mostly (!, not the
``outer layer'') working with input in form of IDL arrays and keywords and
are thus independent of file formats. The following procedures are
available:


a) Processing of lightcurves (and PCA deadtime info)
   (procedures used by rxte_syncseg.pro):

lcmerge.pro : merge several RXTE/PCA FITS lightcurves of a given energy band,
              rebin, find gaps; a history string, the gap array, and the
              merged lightcurve are written to an xdr file; uses  
              
              timerebin.pro : rebin a lightcurve array by an integer
                              factor, find gaps; uses 
                              
                              timegap.pro : find gaps in a time array,
                                            determine gap and segment
                                            lengths   

lcsync.pro  : read quasi-simultaneous xdr lightcurves and
              time-synchronize them, write one multidimensional xdr
              lightcurve

lcseg.pro   : read multidimensional xdr lightcurve and cut it into segments
              of given dimension taking gaps into account, write segmented
              multidimensional xdr lightcurve; uses
       
              timeseg.pro   :  cut a time array into segments of a given
                               dimension taking gaps into account by
                               returning the ``good'' indices

                              timegap.pro:  see above 

important: outside of the gaps the lightcurves have to be evenly spaced

pcadeadmerge.pro : process the deadtime files (ASCII) that have been
                   created during the extraction of several PCA high
                   resolution lightcurves in the same energy band that are
                   now to be merged (see lcmerge.pro), the correct deadtime
                   information for the merged lightcurve is calculated from
                   the individual deadtime files and written to a merged
                   .pcadead output file (ASCII); uses
                  
                   readvle.pro  : read the ASCII file containing the PCA deadtime
                                  information; the read quantities (averaged
                                  over the corresponding observation
                                  segment) are: the number of PCUs, the
                                  exposure, the
                                  Xenon/Propane/coincident/total/vle count
                                  rates PER PCU, and the PCA deadime setting 
                   writevle.pro : write the ASCII file containing the PCA deadtime
                                  information; the written quantities (averaged
                                  over the corresponding observation
                                  segment) are: the number of PCUs, the
                                  exposure, the
                                  Xenon/Propane/coincident/total/vle count
                                  rates PER PCU, and the PCA deadime setting

pcadeadsync.pro  : a) copy a deadtime file (ASCII) corresponding to one of the
                   merged PCA high resolution lightcurves (see
                   pcadeadmerge.pro and lcmerge.pro) to a file (ASCII) with
                   a name corresponding to the synchronized
                   multidimensional lightcurve created from the lightcurves
                   in different energy bands (see lcsync.pro) 
                   OR
                   b) copy a deadtime file (ASCII) corresponding to the 
                   synchronized multidimensional lightcurve (see a) and
                   lcsync.pro) to a file (ASCII) with a name corresponding
                   to the segmented multidimensional lightcurve created
                   from the synchronized lightcurve (see lcsync.pro); uses  
                  
                   readvle.pro  : see pcadeadmerge.pro
                   writevle.pro : see pcadeadmerge.pro 


b) Calculating and saving of Fourier quantities 
   (procedures used by rxte_fourier.pro): 

readvle.pro  : a desription of this routine is given above (see
               pcadeadmerge.pro), here the PCA vle count rate and the PCA
               deadtime setting are read, these quantities are needed for
               the PCA deadtime correction 

readxuld.pro : read the xuld rates and the good time from the
               housekeeping file corresponding to the HEXTE cluster that is
               to be analyzed (at the moment deadtime correction is
               possible for cluster A only) and from the HEXTE .gti file,
               these quantities are needed for the HEXTE deadtime
               correction; uses

               loadcol.pro    : XXXX
               fits_get.pro   : XXXX
           
               XXXX try to change readxuld according to readvle, i.e., read
               deadtime info not from the original housekeeping files but
               from ASCII files that have to be produced during the
               extraction process of the lightcurves (especially: use
               ``gtifilter'' to get correct good times for the HEXTE
               deadtime information)  
 
ebandrate.pro: read the average count rate (here: for PCA background model
	       data) in a given energy band from a FITS spectrum (here:
	       from the ``full'' standard2f spectra), this procedure is not
	       necessary for HEXTE data since high resolution background
	       lightcurves exist in that case, 
               the average background is needed for correcting the
	       normalization of the power spectra in case that the Miyamoto
	       normalization is applied  

foucalc.pro  : calculate and save (xdr format) multidimensional Fourier quantities,
               their uncertainties, and noise corrections from segmented,
               evenly spaced, multidimensional lightcurve arrays; uses 
 
               fastftrans.pro   : XXXX
               fourierfreq.pro  : XXXX
	       psdcorr.pro      : XXXX
               psdcorr_pca.pro  : XXXX; uses
                                  pcadeadpsd.pro : XXXX  
	       psdcorr_hexte.pro: XXXX; uses
                                  hexdeadpsd.pro : XXXX
               psdnorm.pro      : XXXX
               colacal.pro      : XXXX
               rmscal.pro       : XXXX
               freqrebin.pro    : XXXX
              
foumerge.pro : read, merge and save multidimensional Fourier quanities (xdr
               format) that were obtained from the same original
               lightcurves but for different lightcurve segment lengths,
               produce merged history (saved as an extra ASCII file),
               the upper frequency boundary up to which data from each
               segment length are included has to be given, the lower
               frequency boundary is given by 1./(segment length)      

fouplot.pro  : read and plot a multidimensional Fourier quanity (xdr
               format), one overview plot (ps or eps format) is produced,
               showing individual plot windows for each dataset of the
               multidimensional quantity, uncertainties and noise
               components can be overplotted and several keywords
               controling the ``layout'' may be given  
 

b2) Calculating of Fourier quantities 
    (procedures not used by rxte_fourier.pro):  

psd.pro            : calculate the Fourier frequency array and the average
                     power spectral density array for segments with
                     dimension dseg of one evenly binned lightcurve (given
                     by a time array and a count rate array); return the
                     frequency array and the average power spectral density
                     array (in Schlittgen, Leahy or Miyamoto (default)
                     normalization)  

scargle_cross.pro  : compute the cross-correlation of two unevenly sampled data
                     sets, via Lomb-Scargle periodograms


c) Determining and saving of LSSM fit parameters 
   (procedures used by rxte_zuramo.pro):

zrmcalc.pro        : XXXX; uses
                     zuramo.ksh         : XXXX

zrmplot.pro        : XXXX


d) Others

mean.pro           : XXXX
sigma.pro          : XXXX


*) Output files produced by rxte_syncseg.pro:

the resulting multidimensional xdr lightcurves are written to the
<path>/light/processed/ directory under the following file names 
(``_bkg'' is added to the filenames when hexte=1 and bkg=1 has been set,
 ``_bkg_p'' is added to the filenames when hexte=1 and back_p=1 has been set,
 ``_bkg_m'' is added to the filenames when hexte=1 and back_m=1 has been set):

     sync(_bkg(_p/m)).xdrlc         : synchronized multidimensional lightcurve
     <dim[*]>_seg(_bkg(_p/m)).xdrlc : synchronized multidimensional lightcurve,
                                      segmented into evenly spaced pieces of
                                      dimension <dim[*]>

for PCA lightcurves, if deadtime information files (ASCII) are present in
the <path>/light/raw directory, the final deadtime information files
(ASCII) are comuted and written to the <path>/light/processed/ directory
under the following file names:

    sync.pcadead         : deadtime info corresponding to sync.xdrlc    
    <dim[*]>_seg.pcadead : deadtime info corresponding to <dim[*]>_seg.xdrlc 


**) Output files produced by rxte_fourier.pro:

the resulting multidimensional Fourier quantities and the corresponding
history files are written to subdirectories of the <path>/light/fourier/
directory (``_corr'' is added to the filenames of normalized psd quantities
when the miyamoto/hexte_bkg or the miyamoto/pca_bkg keyword combination has
been set)


in xdr format under the following file names 
(the .history and .txt files are ASCII):
   
    <path>/light/fourier/<type>/onelength/: 
    (for type='high' only the ``*_rebin_*'' files are saved)

    <dim[*]>_cof.xdrfu                    : coherence function, noise subtracted
    <dim[*]>_errcof.xdrfu		  : uncertainty of coherence function
    <dim[*]>_errlag.xdrfu		  : uncertainty of lag spectrum  
    <dim[*]>_errnormpsd(_corr).xdrfu	  : uncertainty of normalized,
                                            not noise subtracted power spectrum  
    <dim[*]>_errpsd.xdrfu		  : uncertainty of unnormalized,
                                            not noise subtracted power spectrum 
    <dim[*]>_foinormpsd(_corr).xdrfu      : effective noise level
					    of normalized power spectrum 
    <dim[*]>_imagcpd.xdrfu		  : imaginary part of cross power density
    <dim[*]>_lag.xdrfu			  : lag spectrum, not noise subtracted
    <dim[*]>_noicpd.xdrfu		  : noise of cross power density
    <dim[*]>_noinormpsd(_corr).xdrfu      : noise of normalized power spectrum 
    <dim[*]>_noipsd.xdrfu		  : noise of unnormalized power spectrum 
    <dim[*]>_normpsd(_corr).xdrfu         : normalized, not noise subtracted power spectrum 
    <dim[*]>_psd.xdrfu			  : unnormalized, not noise subtracted power spectrum 
    <dim[*]>_rawcof.xdrfu		  : coherence function, not noise subtracted	   
    <dim[*]>_realcpd.xdrfu		  : real part of cross power density
    <dim[*]>_rms(_corr).txt		  : root mean square of normalized,
                                            noise subtracted power spectrum
    <dim[*]>_signormpsd(_corr).xdrfu	  : normalized, noise subtracted power spectrum
    <dim[*]>_sigpsd.xdrfu		  : unnormalized, noise subtracted power spectrum

    <dim[*]>_rebin_cof.xdrfu		  : see above, frequency rebinned
    <dim[*]>_rebin_errcof.xdrfu		  : see above, frequency rebinned
    <dim[*]>_rebin_errlag.xdrfu		  : see above, frequency rebinned   
    <dim[*]>_rebin_errnormpsd(_corr).xdrfu: see above, frequency rebinned
    <dim[*]>_rebin_errpsd.xdrfu		  : see above, frequency rebinned
    <dim[*]>_rebin_foinormpsd(_corr).xdrfu: see above, frequency rebinned
    <dim[*]>_rebin_imagcpd.xdrfu	  : see above, frequency rebinned
    <dim[*]>_rebin_lag.xdrfu		  : see above, frequency rebinned
    <dim[*]>_rebin_noicpd.xdrfu		  : see above, frequency rebinned
    <dim[*]>_rebin_noinormpsd(_corr).xdrfu: see above, frequency rebinned
    <dim[*]>_rebin_noipsd.xdrfu		  : see above, frequency rebinned
    <dim[*]>_rebin_normpsd(_corr).xdrfu	  : see above, frequency rebinned
    <dim[*]>_rebin_psd.xdrfu		  : see above, frequency rebinned
    <dim[*]>_rebin_rawcof.xdrfu		  : see above, frequency rebinned
    <dim[*]>_rebin_realcpd.xdrfu	  : see above, frequency rebinned
    <dim[*]>_rebin_rms(_corr).txt         : see above, frequency rebinned
    <dim[*]>_rebin_signormpsd(_corr).xdrfu: see above, frequency rebinned
    <dim[*]>_rebin_sigpsd.xdrfu	          : see above, frequency rebinned          

    <path>/light/fourier/<type>/merged/:

    merge_rebin_cof.history               : history file
    merge_rebin_cof.xdrfu		  : see above, frequency rebinned and merged
    merge_rebin_errcof.history		  : history file
    merge_rebin_errcof.xdrfu		  : see above, frequency rebinned and merged
    merge_rebin_errlag.history		  : history file
    merge_rebin_errlag.xdrfu		  : see above, frequency rebinned and merged
    merge_rebin_errnormpsd(_corr).history : history file
    merge_rebin_errnormpsd(_corr).xdrfu	  : see above, frequency rebinned and merged
    merge_rebin_foinormpsd(_corr).history : history file
    merge_rebin_foinormpsd(_corr).xdrfu   : see above, frequency rebinned and merged
    merge_rebin_lag.history		  : history file
    merge_rebin_lag.xdrfu		  : see above, frequency rebinned and merged
    merge_rebin_noinormpsd(_corr).history : history file 
    merge_rebin_noinormpsd(_corr).xdrfu   : see above, frequency rebinned and merged
    merge_rebin_signormpsd(_corr).history : history file
    merge_rebin_signormpsd(_corr).xdrfu   : see above, frequency rebinned and merged
   
and as ps plots under the following file names:

    <path>/light/fourier/<type>/plots/:    
    (for type='high' the ``*_norebin_*'' files are not saved)   

    <dim[*]>_cof_norebin.ps               : plots of the resulting coherence functions,
					    all energy band combinations,
                                            noise corrected,
                                            full Fourier frequency resolution
                                            (only for type='low' and one segment length)
    <dim[*]>_lag_norebin.ps		  : plots of the resulting lag spectra,
					    all energy band combinations,
                                            not noise corrected,
                                            full Fourier frequency resolution
                                            (only for type='low' and one segment length)
    <dim[*]>_signormpsd(_corr)_norebin.ps : plots of the resulting power spectra,
					    all energy bands,
					    noise corrected,
                                            normalized,
                                            ``_corr'': background corrected,
                                            full Fourier frequency resolution
                                            (only for type='low' and one segment length) 
    cof.ps				  : plots of the resulting coherence functions,
					    all energy band combinations,
                                            noise corrected,
                                            rebinned and merged 
					    (for type='high' only one segment
					    length is ``merged'') 
    lag.ps				  : plots of the resulting lag spectra,
					    all energy band combinations,
                                            not noise corrected,
                                            rebinned and merged 
					    (for type='high' only one segment
					    length is ``merged'')
    signormpsd(_corr).ps                  : plots of the resulting power spectra,
					    all energy bands,
                                            noise corrected,
                                            normalized
                                            ``_corr'': background corrected,
                                            rebinned and merged 
					    (for type='high' only one segment
					    length is ``merged'')


***) Output files produced by rxte_zuramo.pro:

the resulting Zuramo quantities and the corresponding
history files are written to subdirectories of the <path>/light/zuramo/
directory (for each energy range separately)

in ASCII format under the following file names:

    <path>/light/zuramo/<type>/onelength/: 
    (no merging of different segment lengths as for the Fourier quantities is
    performed here (<path>/light/zuramo/<type>/merged does not exist), generally
    only results for type='high', i.e., for one segment length are saved)

    <dim>_<newbin>_<channels[*]>.history  : history file
    (e.g., 0008192_04_0-10.history)
    <dim>_<newbin>_<channels[*]>.par1     : relevant LSSM[AR1] fit parameters 
    (e.g., 0008192_04_0-10.par1)            (dyn, P/tau, WfWNR, VdBeoR, 
                                            supremum, number of iterations) 
                                            for all lightcurve segments
                                            of a given original segment length <dim>,
                                            rebinned by a given factor <newbin>,
                                            in a given energy band <channels[*]>             

and as ps plots under the following file names (the .txt files are ASCII):

    <path>/light/zuramo/<type>/plots/:   

    <dim>_<newbin>_<channels[*]>.ps       : plots showing the distributions of
    (e.g., 0008192_04_0-10.ps)              all LSSM[AR1] fit parameters listed in 
                                            <dim>_<newbin>_<channels[*]>.par1
    <dim>_<newbin>_max.txt                : maximum values of all the 
                                            distributions plotted in 
                                            <dim>_<newbin>_<channels[*]>.ps
    <dim>_<newbin>_mean.txt               : mean values of all the 
                                            distributions plotted in 
                                            <dim>_<newbin>_<channels[*]>.ps
    <dim>_<newbin>_sig.txt                : standard deviations  of all the 
                                            distributions plotted in 
                                            <dim>_<newbin>_<channels[*]>.ps














