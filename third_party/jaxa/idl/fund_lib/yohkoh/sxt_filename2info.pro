function sxt_filename2info, filenames, debug=debug, refresh=refresh
;
;   Name: sxt_filename2index
;
;   Input Parameters:
;      filenames - input filenames (per JRLemen Yohkoh Legacy document)
;
;   Output Parameters:
;      function returns structure summary, one per input filename
;
;  History:
;      4-October-2004 - S.L.Freeland       
;     15-feb-2005 - S.L.Freeland - dusted off proto code and made it work...
;                   Made it independent of yohkoh SSW branch 
;     20-aug-2005 - Aki Takeda - fixed overflow in reading boolean flags.   
;
;-
common sxt_filename2info_blk,infostr
 
if not data_chk(filenames,/string) then begin 
   box_message,'Expect input filenames..., returning'
   return,-1
endif
debug=keyword_set(debug)

;  check input file names (Legacy urls ok)
fnames=ssw_strsplit(filenames,'/',/last,/tail)
ssbad=where(strlen(fnames) ne 34,bcnt)
if bcnt gt 0 then begin 
   box_message,['At least one illegal filname input, returning..',filenames(ssbad)]
  return,-1
endif

refresh=keyword_set(refresh) or n_elements(infostr) eq 0

if refresh then $
   infostr={Uncertainty_Data:0,Dark_Corrected:0,Leak_Corrected:0,$
         Synthetic_Leak:0, Second_Order_leak:0, Despiked:0, Destreaked:0,$ 
         Two_image_composite:0,Three_image_composite:0,Coaligned:0,$
         Assembled:0,Vignette:0,Descattered:0,$
         Normalized:0,Exposure_normalized:0,$
         Filter_normalized:0, Safe_log10:0, Data_type:'', $
         FilterA:'',FilterB:'',Exposure_Mode:'',Resolution:''}

nfiles=n_elements(fnames)
retval=replicate(infostr,nfiles)

procflags=strmids(fnames,25,5)    ; 'XXXXX' hex
parr=lonarr(nfiles)
reads,procflags,parr,format='(z5)'
for bb=0,15 do $                     ; for each boolean flag
   retval.(bb)=(parr and 2L^bb) ne 0 ; fill corresponding boolean tag
                                     ; (2 --> 2L, 20-aug-2005, AkT)

dtlist=['Byte','Integer','Real']
retval.data_type=dtlist(parr/(2.^17) and '3'x)

instflags=strmid(fnames,21,3)        ;YYY hex
instarr=lonarr(nfiles)
reads,instflags,instarr,format='(z3)'
falist=['????','Open','NaBan','Quart','Diffu','WdBan','NuDen']
fblist=['????','Open','Al.1','AlMg','Be119','Al12','Mg3']
reslist=['Full','Half','Qrtr']
explist=['Norm','Dark','Calb']

fax=instarr and '7'x
fbx=instarr/(2^4) and '7'x
resx=instarr/(2^8) and '3'x 
expmx=instarr/(2^10) and '3'x

retval.filtera=falist(fax)
retval.filterb=fblist(fbx)
retval.resolution=reslist(resx)
retval.exposure_mode=explist(expmx)

if debug then stop
return,retval
end
