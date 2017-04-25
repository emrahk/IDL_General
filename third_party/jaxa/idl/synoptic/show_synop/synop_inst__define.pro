;+
; Project     : VSO
;
; Name        : SYNOP_INST__DEFINE
;
; Purpose     : Wrapper object to hold instrument-specific data
;               for SHOW_SYNOP object
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('synop_db')
;
; History     : Written 1-Jan-09, D. Zarro (ADNET)
;               Modified, 15-March-10, Zarro (ADNET)
;                - added check for valid class
;               Modifiied 26-February-13, Zarro (ADNET)
;               - removed EIT and TRACE prep options
;               Modified 28-Feb-2013, Kim Tolbert
;               - added SDO/AIA cutouts option
;               Modified 24-Jul-2013, Zarro (ADNET)
;               - added EIT to READ_AGAIN list
;               - added MESSENGER data 
;               Modified 21-Oct-2013, Zarro (ADNET)
;               - added EOVSA
;               Modified 13-Aug-2014, Kim Tolbert
;               - added HMI to get_class instruments
;               1-Jan-2015, Zarro (ADNET)
;               - added GOES/SXI
;               14-Jul-2015, Kim Tolbert
;               - added SMM/HXRBS (note - in acro and class list, has
;                 to precede hxrs)
;               11-Feb-2016, Zarro (ADNET)
;               - added LASCO and SOT
;
; Contact     : dzarro@solar.stanford.edu
;-

;-----------------------------------------------------------------------------

function synop_inst::list_sites,abbr

names=[ 'Big Bear Solar Observatory (BBSO) | bbso',$
        'Callisto Radio Observations | callisto',$
        'Expanded Owens Valley Solar Array (EOVSA)| eovsa',$
        'FERMI GBM | fermi_gbm', $
        'GOES/SXI  | sxi',$
        'Hinode/EIS | eis',$
        'Hinode/SOT | sot',$
        'Hinode/XRT | xrt2',$
        'Kanzelhohe Solar Observatory | kanz',$
        'Meudon Observatory | meudon',$
        'MESSENGER | messenger',$
        'Nancay Radio Observatory | nancay',$
        'Nobeyama Radioheliograph | nobeyama',$
        'Phoenix ETH Zurich | ethz',$
        'SDO/AIA cutouts | aia_cutout', $        
        'SDO/EVE | eve',$
        'SDO/HMI | hmi',$
        'SMM/HXRBS | smm_hxrbs',$
        'SOHO/EIT | eit',$
        'SOHO/LASCO | lasco',$
;        'SOHO/EIT (prepped) | eit2',$
        'SOHO/MDI (Continuum) | mdi_c',$
        'SOHO/MDI (Magnetogram) | mdi',$
        'Solar X-ray Spectrometer (SOXS) | soxs',$
        'STEREO/SECCHI-COR1 | cor1',$
        'STEREO/SECCHI-COR2 | cor2',$
        'STEREO/SECCHI-EUVI | euvi',$
        'TRACE | trace']
;        'TRACE (prepped) | trace2']

c=stregex(names,'(.+)\|(.+)',/ext,/sub)
sites=trim(reform(c[1,*]))
abbr=trim(reform(c[2,*]))

return,sites
end

;-------------------------------------------------------------------------------
function synop_inst::get_class,file,verbose=verbose

if is_blank(file) then return,'fits'

acro=['SXI','xrs','(^hmi|_aia_blos|_aia_cont)','(^aia|_AIA_[0-9])','^(EVL|EVS)','\.les','^glg','^(prepped_)?eis','^mdi','^cont','^fdmg','^(prepped_)?xrt','^kanz','^eit','^(prepped_)?efr',$
      '^(prepped_)?efz','^trac','^(prepped_)?tri','^hxrbs',$
      '^mg1','^bbso','^kpno','^rstn','^phnx','^hxr','^(prepped_)?[^ ]+(euA\.|euB\.)',$
      '^ovsa','^osra','\.xrs|\.hsi)','^(ifa|ifb|ifz|ifs)','^(na|nb)','^(mh|mt)','^BLEN',$
      '^(prepped_)?[^ ]+(c1A\.|c1B\.)','^(prepped_)?[^ ]+(c2A\.|c2B\.)','^eovsa']

class=['sxi','messenger','hmi','aia','eve','soxs','fermi_gbm','eis','mdi','mdi','mdi','xrt2','kanz','eit','eit','eit',$
       'trace','trace','smm_hxrbs',$
       'spirit','bbso','kpno','rstn','ethz','hxrs','euvi',$
       'ovsa_ltc','osra','synop_spex','nobeyama','nancay','meudon','callisto','cor1','cor2','eovsa']

fclass=''
bfile=file_break(file)
for i=0,n_elements(acro)-1 do begin
 if stregex(bfile,acro[i],/bool,/fold) then begin
  fclass=class[i]
  message,'guessing '+strupcase(fclass),/info
  break
endif
endfor

;-- check if map class is defined

if is_blank(fclass) then begin
 dclass=get_map_class(file,/quiet)
 if is_string(class) then fclass=dclass
endif

if is_blank(fclass) then fclass='fits'

return,strupcase(fclass)
end

;-------------------------------------------------------------------------
;-- check if file is candidate for prepping

function synop_inst::do_prep,file,read_again=read_again

read_again=0b
if is_blank(file) then return,0b
bfile=file_basename(file)
if stregex(bfile,'^prepped',/fold,/bool) then begin
 read_again=1b
 return,0b
endif
chk=stregex(bfile,'(^eis|^efz|^efr|^tri|^xrt|eua\.|eub\.|c1a\.|c2a\.|c1b\.|c2b\.)',/bool,/fold)
read_again=stregex(bfile,'^tri|^efz|^efr',/bool,/fold)
return,chk
end

;------------------------------------------------------------------------------

pro synop_inst__define,void                 

void={synop_inst,null_synop_inst:''}

return & end
