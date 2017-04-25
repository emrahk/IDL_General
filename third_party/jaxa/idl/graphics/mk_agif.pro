;+
; Project     : SOHO-CDS
;
; Name        : MK_AGIF
;
; Purpose     : Make animated GIF file from series of GIF files
;
; Category    : imaging
;
; Explanation : 
;
; Syntax      : IDL> mk_agif,gifs
;
; Examples    :
;
; Inputs      : GIFS = filename with listing of GIF files
;
; Opt. Inputs : None
;
; Outputs     : None
;
; Opt. Outputs: None
;
; Keywords    : PATH = path to WHIRLGIF program
;
; History     : Written 22 March 1997, D. Zarro, ARC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

pro mk_agif,outfile,gifs,path=path

;-- check inputs 

if datatype(gifs) ne 'STR' then begin
 message,'Syntax: mk_agif,outfile,gifs',/cont
 return
endif

;-- look for WHIRLGIF

if not exist(path) then begin
 path=''
 espawn,'which whirlgif',out
 out=out(0)
 if trim(out) ne '' then not_found=(strpos(out,'not found') gt -1) else not_found=1
endif else begin
 wc=loc_file(concat_dir(path,'whirlgif'),count=count)
 not_found=count eq 0
endelse

if not_found then begin
 out='WHIRLGIF not found'
 message,out,/cont
 return
endif

;-- have write access?

if datatype(outfile) ne 'STR' then outfile='anim.gif'
break_file,outfile,dsk,dir
cd,curr=curr
outdir=trim(dsk+dir)
if outdir eq '' then outdir=curr
if not test_open(outdir,/write) then begin
 message,'Cannot write GIF file to directory: '+outdir,/cont
 return
endif

if (n_elements(gifs) gt 1) then begin
 listfile=concat_dir(getenv('HOME'),'gif.lis_temp')
 openw,unit,listfile,/get_lun
 for i=0,n_elements(gifs)-1 do printf,unit,gifs(i)
 close,unit & free_lun,unit
endif else begin
 listfile=loc_file(gifs,count=count)
 if count eq 0 then  begin
  message,'Cannot locate filename that contains GIF file listing',/cont
  return
 endif
 listfile=listfile(0)
endelse

;-- spawn WHIRLGIF

cmd=concat_dir(path,'whirlgif')+' -o '+outfile+' -i '+listfile
espawn,trim(cmd),out
if trim(out(0)) ne '' then print,out

;-- cleanup

if exist(unit) then rm_file,listfile

return & end

