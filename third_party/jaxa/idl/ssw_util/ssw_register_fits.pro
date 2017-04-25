pro ssw_register_fits,infits,outfits, _extra=_extra, $
   read_command=read_command, process_commands=process_commands, $
   image_chunk=image_chunk,   $
   prefix=prefix,  outdir=outdir, $      ; keywords -> mwritefits.pro
   first=first, middle=middle, last=last
;
;+
;   Name: ssw_register_fits
;
;   Purpose: I/O wrapper for ssw_register.pro (a memory only routine)
;
;   Input Parameters:
;      infits - input FITS files (assumed ssw compliant)
;
;   Output Parameters:
;      outfits - file names of output FITS (ie, piped through ssw_register)
;
;   Keyword Parameters:
;      _extra - inherit -> ssw_register.pro, including
;           ref_index, ref_map, /derotate, /correl, roll
;      read_command - optional read_command (def=mreadfits)
;      process_commands - optional process commands (verbatim execute)
;      image_chunk - optional number of images per read/loop 
;                    for memory management control 
;
;      outdir - output directory for FITS generation.
;      first, last, middle - optional reference image for alignment
;         
;
;   Calling Sequence:
;      IDL> ssw_register_fits,infits,outfits,[ssw_register options] , $
;             [,read_command=read_command] [,process_commands=process_commands]
;
;   Calling Example:
;      IDL> ssw_register_fits,<sxifiles>,ref_index=index, $
;              read_command='mreadfits_sxig12,/comp,/reg'	
;
;   History:
;      15-jun-2006 - S.L.Freeland - memory management front end for ssw_reg 
;
;
version=1.0
if n_elements(read_command) eq 0 then read_command='mreadfits' 


if n_elements(image_chunk) eq 0 then image_chunk=1  ; pairwise default
ichnk=image_chunk-1>0

nfiles=n_elements(infits)
;
case 1 of
   keyword_set(first): rss=0
   keyword_set(last): rss=nfiles-1
   keyword_set(middle): rss=nfiles/2
   else: rss=nfiles/2 
endcase



read_command=str_replace(strcompress(read_command,/remove),',index,data','')
   
;
; define reference map for entire cube
estat=execute(read_command+',infits(rss),index,data')
if not data_chk(index,/struct) then begin
   box_message,'read command did not return "index,data", aborting..'
   return
endif
index2map,index,data,refmap   ; align everthing to this one...
rinfo=get_infox(refmap,'id,time')

read_command=read_command+',infits(i:(i+ichnk<(nfiles-1))),index,data'
for i=0,nfiles-1,image_chunk do begin 
   delvarx,index,data,rindex,rdata
   estat=execute(read_command)
   ssw_register,index,data,rindex,rdata,_extra=_extra,ref_map=refmap
   delvarx,index,data
   update_history,rindex,/caller,version=version
   refinf=replicate(rinfo(0),n_elements(rindex))
   update_history,rindex,/caller,'Ref:'+refinf,/mode
   mwritefits,rindex,rdata, outdir=outdir, prefix=prefix
endfor
end
