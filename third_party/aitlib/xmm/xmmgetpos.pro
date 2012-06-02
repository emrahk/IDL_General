PRO XMMGETPOS, OUT=OUT, REGION=REGION, RA=RA, DEC=DEC, CTS=CTS, RATE=RATE, FLUX=FLUX, LIKE=LIKE, ERR_RADEC=ERR_RADEC, ERR_CTS=ERR_CTS,  ERR_RATE=ERR_RATE, ERR_FLUX=ERR_FLUX
;+
; NAME:
;            xmmgetpos
;
;
; PURPOSE:
;            convert the source positions of XMM SAS sourcelist files 
;            *emllist*.ds into latex table 
;            
;
; CATEGORY:
;            IAAT XMM tools
;
;
; CALLING SEQUENCE:
;            xmmgetpos [, out='latexfile.tex', /flux, /region]
;
;
; INPUTS:
;            XMM SAS sourcelist files *emllist*.ds
;
;
; OPTIONAL INPUTS:
;            OUT : name of output file
;
;
; KEYWORD PARAMETERS:
;            REGION: create a ds9 region file (ascii) including circles
;                     with diameter of 1' around the source positions
;            RA       : sort sources for decreasing RA
;            DEC      : sort sources for decreasing declinations
;            ERR_RADEC: sort sources for decreasing position error circles
;            CTS      : sort sources for decreasing counts
;            ERR_CTS  : sort sources for decreasing count errors
;            RATE     : sort sources for decreasing rates
;            ERR_RATE : sort sources for decreasing rate errors
;            FLUX     : sort sources for decreasing fluxes
;            ERR_FLUX : sort sources for decreasing flux errors
;            LIKE     : sort sources for decreasing likelihoods
;
;
; OUTPUTS:
;            LATEX file named *emllist*.tex containing some parameter 
;            of the sources
;            
; 
;
; OPTIONAL OUTPUTS:
;            ds9 region file (ascii) named *emllist*.txt            
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;            
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;               xmmgetpos [, out='latexfile.tex', /flux, /regions]
;
;
; MODIFICATION HISTORY:
;               Version1.1: initial version
;                           06.09.2001, Martin Stuhlinger
;               Version1.2: enabled sorting parameter and added keyword region.
;                                creates ascii ds9 region files named the same
;                                as the corresponding source list file.
;                           09.01.2002, Martin Stuhlinger
;               Version1.3: if emllists contain different ID_BANDs then print
;                                the summary band (id_band=0).
;                           changed sorting to decreasing order and define
;                                sort parameter as keywords.
;                           create for each emllist different output files.
;                           14.02.2002, Martin Stuhlinger  
;               Version1.4: delete EXPOSURE column because the summary
;                                band keeps no EXPOSURE information
;                           in filenames change "_" into "-"
;                           inserted into LATEX table multicolumn containing
;                                the filename (instead of section in front
;                                of the table)
;                           enable sorting for every column
;                           changed LATEX style "a4kopka" into "a4paper"
;                           19.02.2002, Martin Stuhlinger 
;               Version1.5: enable sorting for source ID number (default now)
;                           Avoid some of the incorrect sources caused
;                           by a bug of XMM SAS source detection emldetect: 
;                           if /region is selected only sources are printed
;                           which have counts > counts_error. 
;-                          25.11.2002, Martin Stuhlinger


;; INPUT: FIND ALL MULTIPLE PSF SOURCE LIST FILES FROM SAS TASK EMLDETECT
multilists=findfile("*emllist*.ds", count=multilistctr)
IF (multilistctr EQ 0) THEN BEGIN
  print,"ERROR: no files *emllist* found"
  RETURN 
ENDIF 

;; LOOP OVER ALL EMLDETECT PSF SOURCELIST FILES
FOR fileloop=0,(multilistctr-1) DO BEGIN

  ;; WRITE NEW EMLLIST TABLE IN A NEW FILE

  ;; DEFINE NAME OF OUTPUT FILE 
  ;; use name of emllist also as file name for LATEX file:
  ;; cut extension '.ds' out of inputfile name: find position of the '.'
  ;; and extract the string from begin up to the character before the '.' 
  inname=STRMID(multilists[fileloop], 0, strsplit(multilists[fileloop],'.')-1)
  ;; exchange in filename character "_" with "-" and add new extension 
  ;; do it in two steps because outname is used in LATEX-section 
  outname=STRJOIN(STRSPLIT(inname[1], '_', /extract), '-')
  texfilename=outname+'.tex'

  ;; if passed use outfilename from procedure call 
  IF (keyword_set(out)) THEN texfilename=out 

  ;; OPEN LATEX OUTPUT FILE 
  get_lun, outtexfile
  openw, outtexfile, texfilename
  printf, outtexfile,  "\documentclass[12pt]{article}"
  printf, outtexfile, "\usepackage{rotating}"
  printf, outtexfile, "\usepackage[a4paper,dvips]{geometry}"
  printf, outtexfile, "\begin{document}"
  printf, outtexfile, ""


  ;; OPEN SOURCE LIST FILES EMLLIST-*.DS
  fxbopen,sourcelistfile, multilists[fileloop],"SRCLIST"

  ;; HOW MANY ID_BANDS ARE CONSIDERED IN THE EMLLIST? 
  fxbread, sourcelistfile, id_band, "id_band"
  amount_id_bands = max(id_band)

  ;; HOW MANY SOURCES HAVE BEEN FOUND?
  fxbread, sourcelistfile, ml_id_src, "ml_id_src"
  amount_sources = max(ml_id_src)

  ;; READ RA+DEC POSITION OF SOURCES, ERRORS, SIGMAS...
  fxbread, sourcelistfile, ras, "ra"
  fxbread, sourcelistfile, decl, "dec"
  fxbread, sourcelistfile, radecl_err, "radec_err"
  fxbread, sourcelistfile, det_ml, "det_ml"
  fxbread, sourcelistfile, scts, "scts"
  fxbread, sourcelistfile, scts_err, "scts_err"
  fxbread, sourcelistfile, rates, "rate"
  fxbread, sourcelistfile, rates_err, "rate_err"
  fxbread, sourcelistfile, fluxes, "flux"
  fxbread, sourcelistfile, fluxes_err, "flux_err"
  ;; including column EXPOSURE: if there are more than one ID_BANDs
  ;; defined the summary band keeps no EXPOSURE information
  ;;  fxbread, sourcelistfile, exp_map, "exp_map"

  ;; CLOSE LOCAL SOURCE LIST FILE EMLLIST-*.ds
  fxbclose, sourcelistfile

  ;; CREATE AN ARRAY WITH ALL SOURCE INFORMATION OF SUMMARY BAND
  ;; and catch the case that there is only one ID-BAND (id_band=1)
  ;; or more ID-BANDs where we want to print the summary band (id_band=0)
  sources = fltarr(amount_sources,11)
  sources[*,0]=ml_id_src[where(id_band eq min(id_band))]
  sources[*,1]=ras[where(id_band eq min(id_band))]
  sources[*,2]=decl[where(id_band eq min(id_band))]
  sources[*,3]=radecl_err[where(id_band eq min(id_band))]
  sources[*,4]=det_ml[where(id_band eq min(id_band))]
  sources[*,5]=scts[where(id_band eq min(id_band))]
  sources[*,6]=scts_err[where(id_band eq min(id_band))]
  sources[*,7]=rates[where(id_band eq min(id_band))]
  sources[*,8]=rates_err[where(id_band eq min(id_band))]
  sources[*,9]=fluxes[where(id_band eq min(id_band))]
  sources[*,10]=fluxes_err[where(id_band eq min(id_band))]
  ;; including column EXPOSURE: if there are more than one ID_BANDs
  ;; defined the summary band keeps no EXPOSURE information
  ;;  sources[*,11]=exp_map[where(id_band eq min(id_band))]

  ;; DEFINE PARAMETER TO SORT THE SOURCES
  ;; default: ra
  order=0
  IF (keyword_set(RA)) THEN  order=1 
  IF (keyword_set(DEC)) THEN  order=2
  IF (keyword_set(ERR_RADEC)) THEN  order=3
  IF (keyword_set(LIKE)) THEN  order=4
  IF (keyword_set(CTS)) THEN  order=5
  IF (keyword_set(ERR_CTS)) THEN  order=6
  IF (keyword_set(RATE)) THEN  order=7
  IF (keyword_set(ERR_RATE)) THEN  order=8
  IF (keyword_set(FLUX)) THEN  order=9
  IF (keyword_set(ERR_FLUX)) THEN  order=10

  ;; SORT ALL SOURCES TO DECREASING PARAMETER 
  ;; exception for source ID number: sort increasing
  IF (order NE 0) THEN BEGIN
     a=reverse(sort(sources[*,order]))
     sources[*,*]=sources[a,*]
  ENDIF

  ;; THIS SORTING ALGORITHM DOES THE SAME AS THE TWO LINES ABOVE.
  ;;copy = fltarr(6)
  ;; IF (amount_sources NE 1) THEN BEGIN
  ;;   FOR sortloop1=0,(amount_sources-2) DO BEGIN
  ;;     FOR sortloop2=0,(amount_sources-2) DO BEGIN
  ;;       ;; if declination source(n+1) < source(n) exchange sources
  ;;       IF (sources[(sortloop2+1),1] LT sources[sortloop2,1]) THEN BEGIN
  ;;         ;; exchange positions of the sources
  ;;         copy=sources[sortloop2+1,*]
  ;;         sources[sortloop2+1,*]=sources[sortloop2,*]
  ;;         sources[sortloop2,*]=copy
  ;;       ENDIF 
  ;;     ENDFOR 
  ;;   ENDFOR 
  ;; ENDIF

  ;; PRINT SOME LATEX-COMMANDS FIRST
  printf, outtexfile, "\begin{center}"
  printf, outtexfile, "\begin{sideways}"
  printf, outtexfile, "\begin{tabular}{|r|c@{$^{\circ}\;$}c@{'$\;$}c@{''}|r@{$^{\circ}\;$}r@{'$\;$}l@{''}|r|r|r|r|c|c|c|c|} \hline"
  printf, outtexfile, "\multicolumn{15}{|c|}{\bf Sources listed inside "+outname+".ds} \\ \hline"
  printf, outtexfile, "No. & \multicolumn{3}{c|}{Rektaszension} & \multicolumn{3}{c|}{Deklination} & Error & Likelihood & Counts & C-Err. & Rate & R-Err. & Flux & F-Err. \\ \hline"

;; including column EXPOSURE: if there are more than one ID_BANDs
;; defined the summary band keeps no EXPOSURE information
;;  printf, outtexfile, "\begin{tabular}{|r|c@{$^{\circ}\;$}c@{'$\;$}c@{''}|r@{$^{\circ}\;$}r@{'$\;$}l@{''}|r|r|r|r|c|c|c|c|r|} \hline"
;;  printf, outtexfile, "\multicolumn{16}{|c|}{\bf Sources listed inside "+outname+".ds} \\ \hline"
;;  printf, outtexfile, "No. & \multicolumn{3}{c|}{Rektaszension} & \multicolumn{3}{c|}{Deklination} & Error & Likelihood & Counts & C-Err. & Rate & R-Err. & Flux & F-Err. & Exposure \\ \hline"

  ;; PRINT SOURCE PARAMETERS AS LATEX TABLE LINES
  FOR I=0,(amount_sources-1) DO BEGIN

    ;; CONVERT RA AND DEC FROM DECIMAL TO SEXIGESIMAL
    radec, sources[i,1], sources[i,2], ihr, imin, xsec, ideg, imn, xsc

    printf, outtexfile, sources[i,0]," & ", ihr," & ", imin," & ", xsec," & ", ideg," & ", imn," & ", xsc," & ",sources[i,3]," & ",sources[i,4]," & ",sources[i,5]," & ",sources[i,6]," & ",sources[i,7]," & ",sources[i,8]," & ",sources[i,9]," & ",sources[i,10]," \\ \hline", format='(F4.0,A3,I3,A3,I2,A3,F5.2,A3,I4,A3,I2,A3,F5.2,A3,F5.2,A3,F9.1,A3,F9.2,A3,F7.3,A3,1E9.3,A3,1E8.2,A3,1E8.2,A3,1E8.2,A10)'

;; including column EXPOSURE: if there are more than one ID_BANDs
;; defined the summary band keeps no EXPOSURE information
;;    printf, outtexfile, source[i,0]," & ", ihr," & ", imin," & ", xsec," & ", ideg," & ", imn," & ", xsc," & ",sources[i,3]," & ",sources[i,4]," & ",sources[i,5]," & ",sources[i,6]," & ",sources[i,7]," & ",sources[i,8]," & ",sources[i,9]," & ",sources[i,10]," & ",sources[i,11],"\\ \hline", format='(F4.0,A3,I3,A3,I2,A3,F5.2,A3,I4,A3,I2,A3,F5.2,A3,F5.2,A3,F9.1,A3,F9.2,A3,F7.3,A3,1E9.3,A3,1E8.2,A3,1E8.2,A3,1E8.2,A3,F8.1,A10)'

    ;; GENERATE A PAGE BREAK IF THE TABLE BECOMES TOO LARGE
    IF (((I MOD 28) EQ 0) AND (I NE 0) AND (I NE amount_sources-1)) THEN BEGIN
      printf, outtexfile, "\end{tabular}"
      printf, outtexfile, "\end{sideways}"
      printf, outtexfile, "\end{center}"
      printf, outtexfile, "\newpage"
      printf, outtexfile, ""
      printf, outtexfile, "\begin{center}"
      printf, outtexfile, "\begin{sideways}"
      printf, outtexfile, "\begin{tabular}{|r|c@{$^{\circ}\;$}c@{'$\;$}c@{''}|r@{$^{\circ}\;$}r@{'$\;$}l@{''}|r|r|r|r|c|c|c|c|} \hline"
  printf, outtexfile, "\multicolumn{15}{|c|}{\bf Sources listed inside "+outname+".ds} \\ \hline"
      printf, outtexfile, "No. & \multicolumn{3}{c|}{Rektaszension} & \multicolumn{3}{c|}{Deklination} & Error & Likelihood & Counts & C-Err. & Rate & R-Err. & Flux & F-Err. \\ \hline"

;; including column EXPOSURE: if there are more than one ID_BANDs
;; defined the summary band keeps no EXPOSURE information
;;      printf, outtexfile, "\begin{tabular}{|r|c@{$^{\circ}\;$}c@{'$\;$}c@{''}|r@{$^{\circ}\;$}r@{'$\;$}l@{''}|r|r|r|r|c|c|c|c|r|} \hline"
;;  printf, outtexfile, "\multicolumn{16}{|c|}{\bf Sources listed inside "+outname+".ds} \\ \hline"
;;      printf, outtexfile, "No. & \multicolumn{3}{c|}{Rektaszension} & \multicolumn{3}{c|}{Deklination} & Error & Likelihood & Counts & C-Err. & Rate & R-Err. & Flux & F-Err. & Exposure \\ \hline"
    ENDIF 

  ENDFOR

  ;; CLOSE TABLE FOR CURRENT EMLLIST  
  printf, outtexfile, "\end{tabular}"
  printf, outtexfile, "\end{sideways}"
  printf, outtexfile, "\end{center}"
  printf, outtexfile, ""

  ;; CLOSE LATEX DOCUMENT
  printf, outtexfile, "\end{document}"
  close, outtexfile
  free_lun, outtexfile


  ;;
  ;; WRITE DS9 REGION FILE FOR THIS EMLLIST
  ;;
  IF (keyword_set(REGION)) THEN BEGIN 

     ; cut extension '.ds' out of inputfile name: find position of the '.'
     ; and extract the string from begin up to the character before the '.' 
     outname=STRMID(multilists[fileloop], 0, strsplit(multilists[fileloop],'.')-1)

     ;; open latex output file 
     get_lun, outregionfile
     openw, outregionfile, outname[1]+'.txt'

     ;; write file header 
     printf, outregionfile, "# Region file format: DS9 version 3.0"
     printf, outregionfile, 'global color=white font="helvetica 10 normal" edit=1 move=1 delete=1 include=1 fixed=0'

     ;; print source positions as table lines
     FOR I=0,(amount_sources-1) DO BEGIN
       IF (sources[i,5] GT sources[i,6]) THEN BEGIN
          printf, outregionfile, "fk5;circle(",sources[i,1],",",sources[i,2],",0.008333) # color=cyan"
        ENDIF  
     ENDFOR 

     ;; close region file for this eventlist
     close, outregionfile
     free_lun, outregionfile

   ENDIF   ;; write ds9 region file


 ENDFOR   ;;fileloop


END 

