;+
; Project     : SOHO - CDS
;
; Name        : XDIFF
;
; Purpose     : Show differences between program versions
;
; Explanation : When altering IDL software I often find it convenient to be
;               able to pinpoint the changes that have been made, in order to
;               ascertain that no unintended alterations were made, and in
;               order to write up a modification notice in the documentation.
;
;               Given the name of an IDL .pro file, this program locates the
;               first occurence of the program in the path, including the
;               current directory. This file is assumed to be the new,
;               "development" copy. Then the second occurrence of the program
;               in the path is located (assumed to be the old version), and
;               the two are processed by spawning the diff command in Unix, and
;               the perl program diffnew.pl in Windows.  The defaults are
;               to make no distinction between upper and lower case, and
;               to ignore white space differences.
;
;               The output from diff is processed and the files are padded as
;               to display them side by side by XTEXT, with marks inside
;               '<' and '>' for lines that have been changed. The notation
;               is:
;
;               <c> Line changed
;               <+> Line was added (blank line inserted in display)
;               <-> Line was deleted (i.e., added in the *other* copy).
;               | | Line was unchanged.
;
;               If more than one "old" copy are present, it is possible to
;               tell XDIFF to skip one or more versions when locating the old
;               copy, by setting the SKIP keyword to the number of versions to
;               skip.
;
;               You can compare two different programs as well, by supplying a
;               two-element string array as the program name. This is useful
;               for comparing "isomorphic" routines.
;
;               I normally use a suicidally small font when programming, so
;               I've included a check whether it's me working or someone else
;               when setting the font. It's also possible to use the FONT
;               keyword to change the display font.
;
; Use         : XDIFF,'<program-name>' [,flags]
;
; Inputs      : '<program-name>' the name of the program to compare with older
;               versions.
;
;               If program_name is a two-element array, the two different
;               programs are compared (always the first found copies).
;
; Opt. Inputs : FLAGS : The diff flags to be used. Defaults to "-iw", which
;                       ignores case changes and white space, which is quite
;                       convenient when comparing programs.  Note: You can not
;                       specify both the flags argument AND the icase / iwhitespace
;                       keywords.  If you specify the icase and/or iwhitespace keywords,
;                       the diff flags will be set accordingly. There is no diff flag
;                       for ignoring comments or blank lines, so use keywords for
;                       those options.
;
; Outputs     : None.
;
; Opt. Outputs: None.
;
; Keywords    : SKIP : Number of (old) versions in the path to skip.
;             : IBLANKLINE : If set, ignore blank lines. (default is 0)
;             : ICOMMENT : If set, ignore comment lines. (default is 0)
;             : IWHITESPACE : If set, ignore whitespaces.(default is 1)
;             : ICASE : If set, ignore case differences. (default is 1)
;             : FONT : The font to use for the text display.
;             : CONTEXT : Just show changed lines, with a window of this many lines
;               before and after
;             : MAXCHARS : Limit output line length to maxchars for each file
;             Note:  setting the flags argument is incompatible with
;               setting the icase and/or iwhitespace keywords.
;
; Examples:
;             xdiff,'testpro'
;             xdiff,'testpro', 'i'
;             xdiff,['testpro','testpro2'], /icomment, iwhitespace=0
;             xdiff,'testpro', context=2, maxchars=40
;
; Calls       : BREAK_FILE, DEFAULT, DETABIFY(), FIND_WITH_DEF(), RD_ASCII(),
;               XTEXT
;
; Common      : None.
;
; Restrictions: Unix and Windows specific.
;
; Side effects: None.
;
; Category    : Utility
;
; Prev. Hist. : Yes, I know about dxdiff, but I cannot control the diff flags
;               used in it, and I don't like the visual appearance.
;
; Written     : Stein Vidar Hagfors Haugan, UiO, 17 June 1996
;
; Modified    : Version 2, SVHH, 18 June 1996
;               Added comparison of two differently named files.
;               Version 3, SVHH, 16 October 1996
;               Fixed a bug in XDIFF_ADD that crashed in marginal
;               cases.
;               Version 4, 30-Aug-02, mimster@stars.gsfc.nasa.gov, kim.tolbert@gsfc.nasa.gov
;                 Compatibility for Windows
;                 Added icase, iwhitespace, iblankline, and icomment keywords
;                 Also added an indication of how many differences were found to the
;                   widget title (actually counts the number of groups of changes, so
;                   a group of consecutive +'s, e.g., counts as one change)
;                 Also changed |c| to <c> (also |+|, |-|) to make changes stand out more
;                 Also, on unix, if flags is empty, don't use it in spawn command
;                 Also added context and maxchars keywords.
;               Version 5, 8-Aug-2005, Kim Tolbert.  Doesn't work on Windows in IDL 6.2
;                 because of call to file_stat. Not sure why, but file_info
;                 works (file_info was introduced in 5.5)
;               17-Aug-2009, Kim Tolbert.  xtext doesn't free its info structure if it's called from
;                 another routine. So in call to xtext, use unseen keyword, which returns info, and free it.
;
; Version     : 4, 30 August 2002
;-



PRO xdiff_parse4,str,sep,n1,n2,n3,n4

  sep = str_sep(str,sep)

  s12 = str_sep(sep(0),',')

  n1 = LONG(s12(0))
  n2 = LONG(s12(N_ELEMENTS(s12)-1))

  s34 = str_sep(sep(1),',')
  n3 = LONG(s34(0))
  n4 = LONG(s34(N_ELEMENTS(s34)-1))

END


FUNCTION xdiff_rempath,path,file

  break_file,file,disk,dir,filnam,ext
  foundpath = disk+dir

  IF foundpath EQ '' THEN RETURN,path

  cpath = str_sep(path,':')

  ;; Chop / at end
  foundpath = STRMID(foundpath,0,STRLEN(foundpath)-1)

  goodix = WHERE(STRPOS(cpath,foundpath) EQ -1,count)
  IF count EQ -1 THEN BEGIN
     PRINT,"What's wrong with your !path"
     RETURN,path
  END
  ;; Gather new path
  cpath = cpath(goodix)
  npath = cpath(0)
  FOR i = 1,N_ELEMENTS(cpath)-1 DO npath =  npath + ':'+ cpath(i)
  RETURN,npath
END


PRO xdiff_add,to,from,n1,n2,n3,n4,toadded,fromadded
  ON_ERROR,0
  n1 = n1 + toadded
  n2 = n2 + toadded
  n3 = n3 + fromadded
  n4 = n4 + fromadded
  add = n4-n3+1
  toadded = toadded+add

  IF N_elements(to) EQ 0 THEN to = REPLICATE('<+>',add) $
  ELSE IF n1 EQ 0 THEN to = [REPLICATE('<+>',add),to(n1:*)] $
  ELSE IF n1 EQ N_elements(to) THEN to = [to,REPLICATE('<+>',add)] $
  ELSE to = [to(0:n1-1),REPLICATE('<+>',add),to(n1:*)]
  from(n3-1:n4-1) = '<->' + from(n3-1:n4-1)
END


PRO xdiff,file, flags, skip=skip, font=font, $
  icomment=icomment, iblankline=iblankline, icase=icase, iwhitespace=iwhitespace, $
  context=context, maxchars=maxchars

  ON_ERROR,0

  flagsarg = exist(flags)

  if flagsarg and (exist(icase) or exist(iwhitespace)) then begin
    print,'Please use either the flags argument, or the icase and iwhitespace keywords, not both.'
    return
  endif

  default,flags,"-iw"
  default,icase,1
  default,iwhitespace,1
  default,icomment,0
  default,iblankline,0
  default,font,''
  default,skip,0
  default,maxchars,200

  ; user may have entered flags variable or keyword variables, so make them equivalent
  ; for case and whitespace.
  if flagsarg then begin
    if strpos(flags,'i') eq -1 then icase = 0
    if strpos(flags,'w') eq -1 then iwhitespace = 0
  endif else begin
    if not icase then remchar,flags,'i'
    if not iwhitespace then remchar,flags,'w'
    if flags eq '-' then flags = ''
  endelse

  parcheck,file,1,typ(/str),[0,1],'FILE'
  parcheck,flags,2,typ(/str),0,'FLAGS'

  flags = str_sep(flags,' ')


  IF N_ELEMENTS(file) GT 2 THEN BEGIN
     PRINT,"Can only compare 2 files at a time"
     RETURN
  END

  ;; Find the current one (first in path)

  curf = find_with_def(file(0),!Path,'.pro')

  IF curf EQ '' THEN BEGIN
     PRINT,"File not found:" + file(0)
     RETURN
  END

  IF N_ELEMENTS(file) EQ 1 THEN BEGIN
     path = xdiff_rempath(!path,curf)
     nextf = find_with_def(file,path,'.pro',/nocurrent)

     WHILE skip GT 0 DO BEGIN
        path = xdiff_rempath(path,nextf)
        nextf = find_with_def(file,path,'.pro',/nocurrent)
        skip = skip-1
     END
  END ELSE BEGIN
     nextf = find_with_def(file(1),!path,'.pro')
     IF nextf EQ '' THEN BEGIN
        PRINT,"File not found:"+file(1)
        RETURN
     END
  END

  IF nextf(0) EQ '' THEN BEGIN
     PRINT,"Only one copy found"
     RETURN
  END

  n_real=nextf
  c_real=curf

  break_file, nextf, disk_logn, direcn, filenamn, extn
  break_file, curf, disk_logc, direcc, filenamc, extc

  n_temp = concat_dir(get_temp_dir(), filenamn+extn+'_1')
  c_temp = concat_dir(get_temp_dir(), filenamc+extc+'_2')

  made_temp = 0

  ;ignore comments
  IF KEYWORD_SET(icomment) THEN BEGIN
    del_comment_lines, nextf, n_temp, err1
    del_comment_lines, curf, c_temp, err2
    IF err1 or err2 THEN RETURN
    made_temp = 1
    nextf = n_temp
    curf = c_temp
  ENDIF

  ;ignore blanklines
  IF KEYWORD_SET(iblankline) THEN BEGIN
    del_blank_lines, nextf, n_temp, err1
    del_blank_lines, curf, c_temp, err2
    IF err1 or err2 THEN RETURN
    made_temp = 1
    nextf = n_temp
    curf = c_temp
  ENDIF

  org = detabify(rd_ascii(nextf))
  cur = detabify(rd_ascii(curf))

  ;unix
  IF os_family() EQ 'unix' THEN begin
    if trim(flags) eq '' then spawn,/noshell,["diff",nextf,curf],result else $
      spawn,/noshell,["diff",flags,nextf,curf],result
  endif

  ;windows
  IF os_family() EQ 'Windows' THEN BEGIN
    err=0

    IF KEYWORD_SET(icase) or KEYWORD_SET(iwhitespace) THEN BEGIN
      remove_w_c, nextf, n_temp, w=keyword_set(iwhitespace), c=keyword_set(icase), err1
      remove_w_c, curf, c_temp, w=keyword_set(iwhitespace), c=keyword_set(icase), err2
      IF err1 or err2 THEN RETURN
      made_temp = 1
      nextf = n_temp
      curf = c_temp
    ENDIF

    ; user might have used relative path, and we're about to change directory, so
    ; get absolute path
    ; In Version 6.2, calling file_stat somehow screws things up, but file_info works,
    ; but file_info was only introduced in version 5.5
    f = since_version('5.5') ? file_info(nextf) : file_stat(nextf, /fstat_all)
    nextf = f.name
    f = since_version('5.5') ? file_info(curf) : file_stat(curf, /fstat_all)
    curf = f.name

    ; to run the perl program diffnew.pl we MUST be in the $SSW/gen/perl directory
    temp_dir=curdir()
    cd, chklog('SSW') + '\gen\perl'
    spawn, /hide, ['diffnew.pl ', nextf, curf], result
    cd, temp_dir

  ENDIF

  IF result(0) EQ '' THEN BEGIN
     PRINT,"No differences found between files:"
     PRINT,n_real
     PRINT,c_real
     GOTO, cleanup
  END

  stato = intarr(N_ELEMENTS(org))
  statc = intarr(N_ELEMENTS(cur))

  oadded = 0
  cadded = 0

  i = 0
  nres = N_ELEMENTS(result)

  WHILE i LT nres DO BEGIN


     ccom = result(i)
     IF STRPOS(ccom,"a") NE -1 THEN BEGIN
        xdiff_parse4,ccom,'a',n1,n2,n3,n4
        xdiff_add,org,cur,n1,n2,n3,n4,oadded,cadded
     END ELSE IF STRPOS(ccom,"d") NE -1 THEN BEGIN
        xdiff_parse4,ccom,'d',n1,n2,n3,n4
        xdiff_add,cur,org,n3,n4,n1,n2,cadded,oadded
     END ELSE IF STRPOS(ccom,"c") NE -1 THEN BEGIN
        xdiff_parse4,ccom,'c',n1,n2,n3,n4
        nn1 = n1 + oadded
        nn2 = n2 + oadded
        nn3 = n3 + cadded
        nn4 = n4 + cadded
        ochange = n2-n1
        cchange = n4-n3
        delta = cchange - ochange
        both = ochange < cchange
        org(nn1-1:nn1+both-1) = '<c>' + org(nn1-1:nn1+both-1)
        cur(nn3-1:nn3+both-1) =  '<c>' + cur(nn3-1:nn3+both-1)
        IF delta GT 0 THEN BEGIN
           xdiff_add,org,cur,n1+both,n1+both,n3+both+1,n4,oadded,cadded
           ;org=[org(0:n2-1),REPLICATE('|+|',delta),org(n2:*)]
           ;oadded = oadded + delta
           ;cur(n3+both:n4-1) = '|x|' + cur(n3+both:n4-1)
        END
        IF delta LT 0 THEN BEGIN
           xdiff_add,cur,org,n3+both,n3+both,n1+both+1,n2,cadded,oadded
           ;cur=[cur(0:n4-1),REPLICATE('|-|',-delta),cur(n4:*)]
           ;cadded = cadded - delta
           ;org(n1+both:n2-1) = '|+|' + org(n1+both:n2-1)
        END
     END

     i = i+1

     WHILE STRPOS("<->",STRMID(result(i),0,1)) NE -1 AND i LT nres-1 DO $
        i = i+1

     IF STRPOS("<->",STRMID(result(i),0,1)) NE -1 THEN i = i+1
  END

  ix = WHERE(STRMID(org,0,1) NE '<',count)
  IF count GT 0 THEN org(ix) = '| |'+org(ix)

  ix = WHERE(STRMID(cur,0,1) NE '<',count)
  IF count GT 0 THEN cur(ix) = '| |'+cur(ix)

  org = byte(org)
  ix = WHERE(org EQ 0b,count)
  IF count GT 0 THEN org(ix) = 32b


  cur = byte(cur)
  ix = WHERE(cur EQ 0b,count)
  IF count GT 0 THEN cur(ix) = 32b

  if (size(cur))(1) gt maxchars then cur = cur(0:maxchars-1, *)
  if (size(org))(1) gt maxchars then org = org(0:maxchars-1, *)
  xsize = (SIZE(cur))(1) + (SIZE(org))(1)

  IF getenv("USER") EQ 'steinhh' THEN  font =  $
     '-schumacher-clean-medium-r-normal-*-8-*-*-*-*-50-iso8859-1'

IF os_family() EQ 'Windows' THEN BEGIN
	DEVICE, GET_FONTNAMES=dfnames, SET_FONT='6x13'
	IF dfnames(0) EQ '6x13' THEN font = '6x13' ELSE font='fixedsys'
ENDIF

; figure out number of groups of changes for original and current, and include
; number in xtext title
; first change anything that's not a blank in column 1 to a # to make it easier
org_sym = org(1,*)
cur_sym = cur(1,*)
q = where (org_sym ne 32b) & org_sym(q) = 35b
q = where (cur_sym ne 32b) & cur_sym(q) = 35b

find_changes, org_sym, indo, sto
find_changes, cur_sym, indc, stc
q = where (sto ne 32b, counto)
q = where (stc ne 32b, countc)
counto = ' (' + strtrim(counto,2) + ')'
countc = ' (' + strtrim(countc,2) + ')'

; if user wanted to just show the changed lines with a window around them, find the
; indices of the changed lines, expand them by window, and separate each section
; with a  blank line, a line of '-------' followed by another blank.
if exist(context) then begin
   ; if first change is a blank, don't use it (not a real change)
   if sto[0] eq 32b then indo = indo[1:*]
   ; if remaining number of
   ; elements of indo is not even, then last change must have been at end of array,
   ; so add another element that is last index.  (need even, so we can pair up start/end)
   if (n_elements(indo) mod 2) ne 0 then indo = [indo, n_elements(org(0,*))]
   z = reform(indo,2,(n_elements(indo))/2.)
   z[0,*] = (z[0,*] - context) > 0
   z[1,*] = (z[1,*] + context - 1) < (n_elements(org(0,*))-1)
   ; after expanding by context, might overlap - get ranges without overlaps.
   z = find_contig_ranges(z)
   leno = (size(org))(1)
   lenc = (size(cur))(1)
   sep = '---------------'
   for i=0,n_elements(z(0,*))-1 do begin
      sub_org = append_arr(sub_org, [string(org(*,z(0,i):z(1,i))), '', strpad(sep,leno,/after), ''])
      sub_cur = append_arr(sub_cur, [string(cur(*,z(0,i):z(1,i))), '', strpad(sep,lenc,/after), ''])
   endfor
   xtext,sub_org+' '+sub_cur,xsize=xsize,font=font,$
     title = n_real + counto + '     ==>    ' + c_real + countc, unseen=unseen
endif else begin
   xtext,STRING(org)+' '+STRING(cur),xsize=xsize,font=font,$
     title = n_real + counto + '     ==>    ' + c_real + countc, unseen=unseen
endelse

cleanup:
; remove temporary files
if made_temp then begin
  free_var, unseen  ; free pointer to info structure from xtext widget
  rm_file, n_temp
  rm_file, c_temp
endif

END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'xdiff.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
