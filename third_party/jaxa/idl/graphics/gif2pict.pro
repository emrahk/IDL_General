;+
; Project     :	SDAC
;
; Name        :	GIF2PICT
;
; Purpose     :	copy GIF image to PICT format
;
; Explanation :	
;
; Use         :	GIF2PICT,IFILE,OFILE
;              
; Inputs      :	IFILE = GIF file name
;               OFILE = PICT file name [def is to rename ext of IFILE to .PICT)
;
; Opt. Inputs : None.
;
; Outputs     :	None.
;
; Opt. Outputs:	None.
;
; Keywords    :	LIST = list of input files to convert (overridden by IFILE)
;               FRAME = write output PICT files as FRAMEi.*
;               OUT_DIR = output directory for PICT files [def = sames as GIF]
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Category    :	Graphics
;
; Prev. Hist. :	None.
;
; Written     :	Dominic Zarro (ARC)
;
; Version     :	Version 1.0, 1 January 1997
;-
 
pro gif2pict,ifile,ofile,list=list,frame=frame,out_dir=out_dir

list_entered=datatype(list) eq 'STR'
file_entered=datatype(ifile) eq 'STR'
if (not list_entered) and (not file_entered) then begin
 message,'Syntax: gif2pict,ifile,ofile,[list=list]',/cont
 return
endif

;-- filename entered ? (ignore list)

if file_entered then begin
 ifile=loc_file(ifile,count=count)
 if count eq 0 then begin
  message,'Cannot locate: '+ifile,/cont
  return
 endif
 list_entered=0
endif

;-- list of files entered?

if list_entered then begin
 ilist=loc_file(list,count=count)
 if count eq 0 then begin
  message,'Cannot locate: '+ifile,/cont
  return
 endif
 ifile=rd_ascii(list)
endif

nfiles=n_elements(ifile)
use_frame=keyword_set(frame)

for i=0,nfiles-1 do begin
 if valid_gif(ifile(i)) then begin
  if datatype(ofile) ne 'STR' then tofile=ifile(i) else tofile=ofile(i)
  break_file,tofile,dsk,dir,name,ext
  if datatype(out_dir) ne 'STR' then out_dir=trim(dsk+dir)
  ok=test_open(out_dir,/write)
  if ok then begin
   if use_frame then name='frame'+trim(string(i))
   if tofile eq ifile(i) then ext='.pict'
   tofile=concat_dir(out_dir,name+ext)
   read_gif,ifile(i),image,r,g,b
   message,'writing '+tofile,/cont
   write_pict,tofile,image,r,g,b
  endif else message,'Cannot output PICT file to: '+out_dir,/cont 
 endif else message,'Input file not in GIF format',/cont
endfor

return & end
