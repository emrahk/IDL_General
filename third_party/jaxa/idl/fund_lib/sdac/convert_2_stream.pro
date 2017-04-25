;+
; PROJECT:
;	SDAC
; NAME: 
;	CONVERT_2_STREAM
;
; PURPOSE: 
;	This procedure converts fixed-length-record files to stream files.
;
; CATEGORY: 
;	GEN, I/O
;
; CALLING SEQUENCE: 
;	convert_2_stream, filename [,/delete]
;
; CALLS:
;	BREAK_FILE, FCHECK	
;
; INPUTS:
;       filename - name of indexed file to convert to stream
;		   new file has _stream appended to its extension,
;                  unless delete keyword is activated
; KEYWORD INPUTS:
;	rec_length - logical record length.  For fixed-record-length files that have
;	been ftp'd onto a VMS system, pad bytes are placed at the end of the file to
;	fill out the last 512 block record.  if 
; OPTIONAL INPUTS:
;	delete - if set delete the old file
;
; OUTPUTS:
;       none
;
; OPTIONAL OUTPUTS:
;	Outfile - filename to write to if given.
;
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	new file is created in the directory of the old file
;	IF file is already a stream file it will be deleted
; RESTRICTIONS:
;	Only run on VMS machines.
;	File must not be in STREAM format Already 
;	must have permission to create the new file and delete the old
;
; PROCEDURE:
;	none
;
; MODIFICATION HISTORY:
;	ras, 16-apr-95
;	eac, 23-aug-95 ; if delete keyword activated, then 
;                        new filename will be same as old, only 1 ver higher
;	eac, 23-aug-95 ; add +vers to newfile name, so program won't bomb
; 			 on version numbers > 1
;	ras, added more documentation, 7 June 1996
;	Version 5, richard.schwartz@gsfc.nasa.gov, 1-sep-1997, added outfile arg.
;	Version 6, richard.schwartz@gsfc.nasa.gov, 8-oct-1997, check for VMS.
;-

pro convert_2_stream, filename, outfile, delete=delete 

;This is a one time procedure to convert the flare catalog into a stream file
;to be readable on both SDAC (OVMS) and Umbra (OSF)
if os_family() ne 'vms' then return
break_file, filename(0), disk, dir, fnm, ext, vers

delete = keyword_set(delete)
openr, lu,/get, filename, delete=delete
stat = fstat(lu)
reclen = stat.rec_len

if reclen ne 0 then begin
	recs   = ceil(stat.size *1. /reclen)
	data = bytarr( reclen, recs)
	on_ioerror, mustbedone
	readu, lu, data
	mustbedone: on_ioerror,null
	free_lun,lu

        if keyword_set(delete) then $
	newfile = disk + dir + fnm + ext + vers else $
        newfile = disk + dir + fnm + ext+'_stream'+vers
        newfile = fcheck( outfile, newfile)
	openw,/stream, lu,/get, newfile 
	writeu,lu, data
endif ;if reclen is 0 then it is not a fixed-length file
free_lun,lu

end
