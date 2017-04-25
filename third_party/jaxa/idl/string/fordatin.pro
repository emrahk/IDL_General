function fordatin,file,varname,pu=pu, help=help, last_col=last_col
;+
; ROUTINE:    fordatin
;
; PURPOSE:    read fortran data statements
;
; USEAGE:     result=fordatin(file,varname)
;
; INPUT:
;   file      name of fortran source file containing target
;             data statement (string)
;
;   varname   name of fortran variable initialized in data statement
;             (string)
;
; KEYWORD INPUT:
; pu          the name of the program unit which contains the data
;             initialization.  Specify enough of the leading
;             characters of the program unit name to make it
;             unique. White space and case are ignored.  For example
;
;                    pu='subroutine foo'
;                    pu='      subroutine   foobar'
;                    pu='SUBROUTINE FOOBAR(x1,'
;
;             all match
;
;                    subroutine foobar(x1,x2,x3)    ! a comment
;
; help        print this documentation header
;
; OUTPUT:
;   result    array of initial values of variable VARNAME.
;
; PROCEDURE:  FORDATIN first searches through the fortran source file
;             for a program unit matching PU (if this optional
;             parameter is provided).  Next it looks for a line
;             containing the keywords DATA and the variable name
;             VARNAME. It reads all the following characters until it
;             finds two matching forward slashes (/).  All characters
;             between the matching slashes are scanned and turned into
;             either an integer or float array as appropriate.
;
;
; RESTRICTIONS:
;             this routine is designed to extract the part of the data
;             block following a typical array initialization such as
;
;                 data varname/ 1,2,3,4,5,5
;                &          7,8,9/
;
;             if the data statement looks like
;
;                 data (varname(i),i=1,3) /1,2,3/
;                 data (varname(i),i=4,6) /3,2,4/
;
;             you can read the data as
;
;                 v1=fordatin('file.f','(varname(i),i=1,3)')
;                 v2=fordatin('file.f','(varname(i),i=4,6)')
;                 v=[v1,v2]
;
;             but beware, FORDATIN will read all the numbers between
;             slashes in a multi-variable data statement such as
;
;                 data v1,v2,v3/12,24,25/
;
; EXAMPLE:
;
;; plot temperature profile of TROPICAL standard atmosphere
;
;             z1=fordatin('/home/paul/rtmodel/atms.f','z1')
;             t1=fordatin('/home/paul/rtmodel/atms.f','t1')
;             plot,z1,t1
;
;; plot coalbedo of ice particles as a function of wavelength
;
;             wl=.29*(333.33/.29)^(findgen(400)/399)
;             w=fordatin('/home/paul/rtmodel/cloudpar.f','(ww(i,14),i=1,mxwv)')
;             plot,wl,1.-w,xrange=[0,4]
;
; REVISIONS:
;
;  author:  Paul Ricchiazzi                            jan94
;           Institute for Computational Earth System Science
;           University of California, Santa Barbara
;-
;
default, last_col, 72
if n_params() eq 0 or keyword_set(help) then begin
  xhelp,'fordatin'
  return,0
endif

line=''
get_lun,lun
openr,lun,file

blank="                                                    "

; first look for the program unit which contains the variable initialization


if keyword_set(pu) then begin
  match=strcompress(strlowcase(pu),/remove_all)
  repeat begin
    readf,lun,line
    line=strcompress(strlowcase(line),/remove_all)
  endrep until strpos(line,match) eq 0
endif

; look for the variable initialization

found=0
nslsh=0

body=''

while nslsh lt 2 do begin
  readf,lun,line
  line=strlowcase(line)
  if strpos(line,' ') ne 0 then line=' '      ; delete comment lines
  if not found then begin
    ncvar=strpos(line,varname)
    if ncvar gt 0 then begin
      ncdat=strpos(line,"data")
      predat=""
      if ncdat ge 0 then predat=strmid(line,0,ncdat-1)
      blnk=strmid(blank,0,ncdat-1)
      if ncdat ge 6 and ncvar ge ncdat and predat eq blnk then found=1
    endif
  endif
  if found then begin
    nend=strpos(line,"!")
    if nend lt 0 then nend=last_col
    line=strmid(line,0,nend-1)
    if strpos(line,"c") eq 0 then line=blank
    n1=6
    if nslsh eq 0 then begin
      n1=strpos(line,"/")
      if n1 ge 0 then begin
        nslsh=nslsh+1
        n1=n1+1
      endif
    endif
    if n1 eq 6 then n2=strpos(line,"/") $
               else n2=strpos(strmid(line,n1,last_col-1),"/")+n1
    if n2 ge n1 then begin
      nslsh=nslsh+1
      n2=n2-1
    endif else begin
      n2=last_col-1
    endelse
    body=body+strmid(line,n1,n2-n1+1)
  endif
endwhile

free_lun,lun

body=strcompress(body,/remove_all)

a_float=strpos(body,'.') ge 0 or strpos(body,'e') ge 0
body1=str_sep(body,',')
if a_float then body2=float(body1) else body2=fix(body1)

return,body2

end


