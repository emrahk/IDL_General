;+
; Project     : SOHO - CDS     
;                   
; Name        : SHOW_FITS_HDR
;               
; Purpose     : Display a CDS FITS file header.
;               
; Explanation : Reads header from a CDS FITS file and copies to the screen
;               and/or hardcopy
;               
; Use         : IDL> show_fits_hdr,filename [,parameter,header=header,$
;                                                       extension=extension,$
;                                                       /hardcopy,/keep,
;                                                       /outfile,/quiet]
;    
; Inputs      : filename - name of FITS file to read, can be an array as
;                          returned by eg. FINDFILE.
;               
; Opt. Inputs : parameter - if given then show only that parameter, can be 
;                           a string array of parameter names.
;
;               outfile   - file(s) to which to send output. If given, must
;                           same dimension as input filenames
;               
; Outputs     : Listing is sent to screen and/or hardcopy file.
;               
; Opt. Outputs: header    - returns a string array with the header contents
;               
; Keywords    : HARDCOPY - listing is sent to printer
;               KEEP     - listing is sent to disk file and not deleted.
;                          Default name is filename.hdr in home directory 
;                          unless output file is specified.
;               QUIET    - output to screen is suppressed.
;               EXTEN    - specify the FITS extension to read
;
; Calls       : headfits, print_str
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : FITS
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 6-Jul-95
;               
; Modified    : 
;
; Version     : Version 1, 6-Jul-95
;-            
pro show_fits_hdr, file, parameter, header=header, outfile=outfile, $
                                    hardcopy=hardcopy, $
                                    keep=keep, extension=extension,$
                                    quiet=quiet

;
;  check sufficient parameters
;
if n_params() eq 0 then begin
   print,'Use: IDL> show_fits_hdr,filename [,parameter, + keywords]
   return
endif

;
;  numbers of files and parameters
;
nf = n_elements(file)
np = n_elements(parameter)
no = n_elements(outfile)
if no gt 0 and (no ne nf) then begin
   print,'Error: number of input and output files must be the same.'
   return
endif

;
;  to terminal?
;
if keyword_set(quiet) then to_screen = 0 else to_screen = 1
if to_screen then openw, screen, filepath(/terminal), /more, /get_lun
vms=(!version.os eq 'VMS')

;
;  loop in case of multiple files
;
for i = 0,nf-1 do begin
   if file_exist(file(i)) then begin

;
;  create filename for hardcopy (fileroot.hdr unless specified)
;
      break_file,file(i),disk,dir,f,ext
      if no eq 0 then begin
         hfile = disk+dir+f+'.hdr'
      endif else begin
         hfile = outfile(i)
      endelse

;
;  send to home directory if no directory specified
;
      if dir eq '' then begin
         if vms then home='sys$login' else home=getenv('HOME')
         hfile=concat_dir(home,hfile)
      endif

;
;  read the FITS header
;
      if not keyword_set(extension) then extension = 0
      head = headfits(file(i),exten=extension)

;
;  were any specific parameters wanted?
;
      if n_elements(parameter) gt 0 then begin
         parms = strarr(n_elements(head))
         for k=0,n_elements(parms)-1 do begin
            parms(k) = strtrim(str_pick(head(k),'','='),2)
         endfor
         nparm = 0
         for k=0,n_elements(parameter)-1 do begin
            j = where(parms eq parameter(k))
            if j(0) ge 0 then nparm = [nparm,j]
         endfor
         nparm = nparm(rem_dup(nparm))
         head = head(nparm(1:n_elements(nparm)-1))
      endif
;
;  store return variable
;     
      header = head
         
      head = [' ','********************','Header for FITS file '+file(i),$
              '********************',head]
   
;
;  display as required
;
      if to_screen then print_str,head
      if keyword_set(keep) then keep = 1 else keep = 0
      if keyword_set(hardcopy) then hardcopy = 1 else hardcopy = 0

      if (no gt 0) or keep then begin
         print_str,head,file=hfile,/quiet,/keep,hardcopy=hardcopy 
      endif else begin
         print_str,head,/quiet,hardcopy=hardcopy 
         if file_exist(hfile) then status = delete_file(hfile,/noconfirm) 
      endelse
   endif else begin
      print,'Input file ',file(i),' does not exist'
   endelse

endfor

;
;  close screen
;
if to_screen then free_lun, screen

end
