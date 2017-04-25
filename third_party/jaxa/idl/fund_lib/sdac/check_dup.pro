;+
; NAME:
;	CHECK_DUP
; PUROSE:
;	Check for duplicate file names and print list on screen.
;	Written for VMS only.
; CALLING SEQUENCE:
;	CHECK_DUP [,DIR=DIR, SEARCH=SEARCH, /YOHKOH_SDAC, FILE=FILE]
; SAMPLE CALL:
;	check_dup
;	check_dup, search='utplot.pro'
;	check_dup, /y, /f
;	check_dup, dir='user_disk0:[sdac...]'
; KEYWORD ARGUMENTS:
;	DIR - directory specification to search. Default is 
;	the current path.
;	SEARCH - file name or wildcard specification to search for. 
;		Default is '*.pro'.
;	YOHKOH_SDAC - if set, will notify you only if one of the files
;		is in yohkoh tree (ys:[...]) and the other file isn't.
;	FILE - If set, send listing to output file called DUP.DAT.  Or
;		specify FILE='filename.ext'.
; MODIFICATION HISTORY:
;	Written AKT 93/1/29
;	Mod. AKT 93/11/5.  Default to search is !path.  Added /yohkoh_sdac
;	  keyword - will only look for duplicates across yohkoh/sdac boundary.
;	  And added search and output file keywords and options.
;-
;--------------------------------------------------------------

pro check_dup, dir=dir, search=search, yohkoh_sdac=yohkoh_sdac, file=file


if not(keyword_set(search)) then search = '*.pro'

if keyword_set(dir) then f=findfile(dir + search, count=numf) else begin
   dirs = get_lib()
   ndirs = n_elements(dirs)
   if ndirs eq 0 then begin
      print,'No directories in path.'
      goto, getout
   endif
   f = ' '
   for i=0,ndirs-1 do begin
      files = findfile(dirs(i)+search, count=count)
      if count gt 0 then f = [f,files]
   endfor
   numf = n_elements(f) - 1
   if numf gt 0 then f = f(1:*)
endelse

if numf eq 0 then begin
   print,'No ', search, ' files found. !!!'
   goto, getout
endif

print, 'Number of files on all directories = ', numf
if numf eq 1 then goto,getout

; open output file if user wants listing sent to a file.
if keyword_set(file) then begin

   if (size(file))(1) eq 7 then outfile = file else outfile = 'dups.dat'
   openw, lun, outfile, /get_lun
endif else lun = -1

; sort filename (without directory part) into alphabetical order
; and save.
br = strpos (f, ']')
sc = strpos (f, ';')
name = strarr(numf)
for i = 0,numf-1 do name(i) = strmid(f(i), br(i)+1, sc(i)-br(i))
s = sort(name)
f = f(s)
name = name(s)

; now name and f have partial and full file names in alph. order

; convert to bytes and subtract adjacent names.  Multiply this difference
; array by a (1,n) array of ones to add up each row.  Then find which
; rows added up to 0.  These will be the rows corresponding to file names
; that are the same.
b = byte(name)
d = b(*,1:*) - b(*,*)
t = replicate(1,1,(size(d))(1)) # d
q = where (t eq 0, kq)   ; q has indices of files that have duplicates

printf, lun, ' '
printf, lun, 'Duplicate files: '
printf, lun, ' '

count_dups = 0
if kq gt 0 then begin
   ; i will step through the q(i)'s, last will record index of last 
   ; duplicate found.  If there are more than 2 duplicates, then the next
   ; q(i) may still be referring to same file. If q(i) is < last, we
   ; know we can skip q(i).
   i = -1      
   last = 0    
   nextone:
   i = i + 1
   if i eq kq then goto, done  ; done
   if q(i) lt last then goto, nextone   
   qdups = where(strpos(f(q(i):(q(i)+10)<(numf-1)), name(q(i))) ne -1, kdups)
   dups = f(q(i) + qdups)
   br = strpos(dups,']')
   ; if yohkoh_sdac keyword set, then only list files if some have YS:, and 
   ; some don't (i.e. some are in yohkoh tree and some aren't).  Otherwise,
   ; just print all the duplicates.
   if keyword_set(yohkoh_sdac) then begin
      yfiles = 0 & sfiles = 0
      for j = 0,kdups-1 do begin
         y = where (strpos(strmid(dups(j),0,br(j)), 'YS:') ne -1, ky)
         if ky then yfiles = 1 else sfiles = 1
      endfor
      if yfiles and sfiles then begin   ; have some files from each tree
         count_dups = count_dups + 1
         for j = 0, kdups-1 do printf, lun, dups(j)
         printf, lun, ' '
      endif
   endif else begin
      count_dups = count_dups + 1
      for j=0,kdups-1 do printf, lun, dups(j)
      printf, lun, ' '
   endelse
   last = q(i) + kdups
   goto, nextone
endif 

done:
print, 'Number of files found in more than one directory: ', count_dups
if lun ne -1 then begin
   printf, lun ,'Number of files found in more than one directory: ',count_dups
   free_lun, lun
   print, 'Listing saved in file ', outfile
endif

getout:
return & end
