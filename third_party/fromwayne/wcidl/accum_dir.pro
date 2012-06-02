PRO accum_dir, dfile=dfile, thk=thk, nopha=nopha, nolc=nolc, dlist=dlist
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  accum_dir.pro
;
;  Accumulate spectra and light curves according to the .liv? files in
;  a set of directories.
;
;  Uses runaccum to do the work.  Assumes the filenames are based on
;  the obsids.
;
;   dfile    string    file which holds list of directories
;   thk      string    post saa skip time.  labels .liv file
;                      (e.g. *.hk32.liv1  --> thk = hk32)
;   nopha    int       set this to skip making the pha files 
;   nolc     int       set this to skip making the lc files
;
;;;;;;;;;;;;;;;;;;;;;;;;;;
;
   IF (n_params() GT 0) THEN BEGIN
       print,''
       print,'Usage: accum_dir, dfile=dfile, thk=thk'
       print,'   dfile    string    file which holds list OF directories'
       print,'   thk      string    post saa skip time.  labels .liv file'
       print,''
       return 
   ENDIF
;
;  first read in the list of directories from the file, dlist.
;  This must exist in the current working directory.
;
IF (NOT keyword_set(dfile))  THEN dfile='dirlist.txt'
IF (NOT keyword_set(thk))  THEN thk='hk32'
IF (keyword_set(nopha)) THEN print, 'Warning: Not accumulating spectra!'
IF (keyword_set(nolc)) THEN print, 'Warning: Not accumulating light curves!'
;
;
if not (keyword_set(dlist)) then begin
   cmd = 'cat ' + dfile
   spawn, cmd, dlist
endif
print, dlist
ndirs = size(dlist)
ndirs = ndirs(1)
;
;  now loop through the directories and build spectra and light curves
;  for each observation.
;
spawn, 'pwd', cwd
ebands = [15,32,64,128,250]

FOR i = 0, ndirs-1 DO BEGIN
    print, dlist(i)
    cd, dlist(i)
    outfile = "h"+strmid(dlist(i),9,10) ;; throw out prop# and targ# from obsid
    IF NOT (keyword_set(nopha)) THEN $
      runaccum,dlist(i)+'.'+thk,ofile=outfile, /cor, /fits
    IF NOT (keyword_set(nolc)) THEN $
      runaccum,dlist(i)+'.'+thk,ofile=outfile+'_lc',$
      /cor, tres=16, ebins=ebands, mode='m'
    cd, cwd(0)
ENDFOR 

END

