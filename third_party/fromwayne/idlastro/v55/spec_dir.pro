function spec_dir,filename,extension
;+
; NAME:
;     SPEC_DIR
; PURPOSE:
;     Complete a file specification by appending the default disk or directory
;
; CALLING SEQUENCE:                      
;     File_spec = SPEC_DIR( filename, [ extension ] )
; INPUT:
;     filename - character string giving partial specification of a file
;               name.  Examples for different operating systems include the
;                       following:
;               Unix: 'pro/test.dat', '$IDL_HOME/test','~/subpro'
;               MacOS: ':Programs:test'
;               Windows: '\pro\test.dat','d:\pro\test'
;
; OPTIONAL INPUT:
;     exten - string giving a default file name extension to be used if
;             filename does not contain one.  Do not include the period.
;
; OUTPUT:
;     File_spec - Complete file specification using default disk or 
;               directory when necessary.  
;
; EXAMPLE:
;      IDL> a = spec_dir('test','dat')
;
;      is equivalent to the commands
;      IDL> cd, current=cdir
;      IDL> a = cdir + delim + 'test.dat'
;
;      where delim is the OS-dependent separator 
; METHOD:
;      SPEC_DIR() decomposes the file name using FDECOMP, and appends the 
;      default directory (obtained from the CD command) if necessary.   
;
;      SPEC_DIR() does not check whether the constructed file name actually
;      exists.
; PROCEDURES CALLED:
;      EXPAND_TILDE(), FDECOMP
; REVISION HISTORY:
;      Written W. Landsman         STX         July, 1987
;      Added Unix compatibility, W.  Landsman, STX   August 1991
;      Added Windows and Macintosh compatibility   W. Landsman  September, 1995
;      Work for relative Unix directory            W. Landsman  May, 1997
;      Expand Unix tilde if necessary              W. Landsman  September 1997
;      Converted to IDL V5.0   W. Landsman   September 1997
;      Fix VMS call to TRNLOG()  W. Landsman       September 2000
;-
 On_error,2                                     ;Return to user

 unix = !VERSION.OS_FAMILY EQ 'unix'
 filname = filename
 if unix then if strpos(filname,'~') GE 0 then filname = expand_tilde(filname) 
 fdecomp,filname,disk,dir,name,ext             ;Decompose filename

 if (ext EQ '') and ( N_params() GT 1) then $   ;Use supplied default extension?
                    ext = extension

 environ = (unix) and (strmid(dir,0,1) EQ '$')

 if not environ then begin
 if (unix) and (strmid(dir,0,1) NE '/')  then begin
     cd,current=curdir
     dir = curdir + '/' + dir
 endif

 if (dir EQ '') and (!VERSION.OS NE "vms") and (not environ) then begin

    cd,current=dir
    if name NE '' then begin
        case !VERSION.OS_FAMILY of 
        'windows': dir = dir + '\'    ;Get current default directory
        'MacOS': 
         else: dir = dir + '/'
        endcase
    endif
 
 endif else begin

   if ( disk EQ '' ) or ( dir EQ '' ) then begin
     cd,current=defdir                          ;Get current default directory
     fdecomp,defdir,curdisk,curdir
     if disk EQ '' then disk = curdisk 
  endif
    

    if dir eq '' then dir = curdir 

 endif
 
 endelse
 endif

 if ext ne '' then ext = '.'+ext

  return,dir+name+ext           ;Unix

end
