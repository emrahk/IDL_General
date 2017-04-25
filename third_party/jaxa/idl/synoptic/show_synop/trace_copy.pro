;+
; Project     : HESSI
;
; Name        : TRACE_COPY
;
; Purpose     : copy reformatted and prep'ed TRACE files to
;               HESSI archive. 
;
; Category    : synoptic gbo
;
; Syntax      : IDL> trace_copy,tstart,tend,back=back,_extra=extra
;
; Inputs      : TSTART, TEND = start and end times to consider
;               [def = current day]
;
; Outputs     : processed TRACE FITS files.
;
; Keywords    : BACK = days to look back
;               EXTRA = keywords for TRACE_PREP
;               COUNT = # of files processed
;               TESTARRAY = filter keywords to STRUCT_WHERE
;               CLOBBER = clobber existing files
;               PREFLARE = mins of preflare data to include [def=5]
;               LOW_RES = only process files nearest GOES start/peak/end 
;               POSTFLARE = mins of postflare [def=10]
;               BY_TIME = process all times between TSTART/TEND
;                         [def is process overlapping flare times]
;               GOES = key off GOES events instead of RHESSI
;               THRESHOLD = peak count rate threshold for RHESSI-based
;               selection
;               GRID = same as /BY_TIME, but select files relative to
;                        a time grid [def = hourly]
;
; Restrictions: Unix only
;
; History     : Written 13 May 2001, D. Zarro (EITI/GSFC)
;               Modified 3 Sep 2006, Zarro (ADNET/GSFC) 
;                - added /GRID
;
; Contact     : dzarro@solar.stanford.edu
;-

pro trace_copy,tstart,tend,testarray=testarray, _extra=extra, $
            goes=goes,threshold=threshold,grid=grid,$
            count=count,clobber=clobber,back=back,verbose=verbose,$
            preflare=preflare,low_res=low_res,postflare=postflare,$
            by_time=by_time,debug=debug,previous=previous,reprocess=reprocess


common trace_copy,flare_data

verbose=keyword_set(verbose)
debug=keyword_set(debug)
clobber=keyword_set(clobber) or keyword_set(reprocess)
by_time=keyword_set(by_time) or keyword_set(grid)
low_res=keyword_set(low_res)
by_flare=1-keyword_set(by_time)
count=0

;-- decode directory environments

synop_images=chklog('$SYNOP_DATA/images')
if not test_dir(synop_images) then return

synop_data=chklog('$SYNOP_DATA')

;-- default to current day

dstart=get_def_times(tstart,tend,dend=dend,/utc)
if is_number(previous) then begin
 dstart.mjd=dstart.mjd-previous
 dend.mjd=dend.mjd-previous
endif

;-- determine copy times

if is_number(back) then tback=back > 0 else tback=0
if tback gt 0 then begin
 dstart=dend
 dstart.mjd=dend.mjd-tback-1
endif

dstart=anytim2utc(dstart,/vms)
dend=anytim2utc(dend,/vms)

dprint,'% dstart,dend: ',dstart,', ',dend

if not data_chk(testarray,/string) then $                  
; testarray=['wave_len=171,195,wl,1216,1600','naxis1>=512'] 
 testarray=['wave_len=171,195,1216,1600','naxis1>=512']

;-- flare selection constraints 

if is_number(preflare) then pre=float(preflare) > 0. else pre=30.
if is_number(postflare) then post=float(preflare) > 0. else post=30.
if is_number(threshold) then thresh=float(threshold) else thresh=100.


case 1 of

;-- find overlapping GOES events

 keyword_set(goes): begin

 rd_gev,dstart,dend,gev,status=status,/nearest

;-- find GOES flare start and end times

 if status ne 0 then begin
  message,'No GOES events during specified period',/cont
  return
 endif

 decode_gev,gev,gstart,gend,gpeak,/vms,class=class,/nearest

;--- filter > B flares

 flares=where(stregex(class,'(C|M|X)',/bool),nflares)

 if nflares eq 0 then begin
  message,'No GOES events above B level',/cont
  return
 endif

 gev=gev[flares] & gstart=gstart[flares] & gend=gend[flares]
 gpeak=gpeak[flares] & class=class[flares]

 if verbose then begin
  message,'Found following GOES events - '+arr2str(class,delim=','),/cont
 endif

;-- include preflare and postflare files

 gstart=anytim(gstart,/tai)-pre*60.
 gstart=anytim2utc(gstart,/vms)

;-- if M or X flare, force postflare = 30 minutes

; if is_number(postflare) then post=float(postflare) > 0. else post=10.
; m_or_x=where(stregex(class,'(M|X)',/bool),fcount)
; if fcount gt 0 then post=30.

 gend=anytim(gend,/tai)+post*60.
 gend=anytim2utc(gend,/vms)
 gpeak=anytim2utc(gpeak,/vms)

 cstart=anytim2tai(gstart)
 cend=anytim2tai(gend)
 cpeak=anytim2tai(gpeak)

end

by_time: begin
 gstart=dstart
 gend=dend
end

;-- select by RHESSI event

else: begin
 if not is_struct(flare_data) then flare_data=hsi_read_flarelist()
 gstart=anytim(flare_data.start_time,/tai)
 gend=anytim(flare_data.end_time,/tai)
 gpeak=anytim(flare_data.peak_time,/tai)

 check=where_times(gstart,tstart=dstart,tend=dend,count=count)
 if count eq 0 then begin
  message,'No matching RHESSI flares during specified period',/cont
  return
 endif
 gstart=gstart[check] & gend=gend[check] & gpeak=gpeak[check]
 check=where(flare_data[check].peak_countrate ge thresh,count)
 if count eq 0 then begin
  message,'No RHESSI flares above '+trim(thresh)+' count rate threshold',/cont
  return
 endif

 gstart=gstart[check]-pre*60.
 gend=gend[check]+post*60

 gstart=anytim2utc(gstart,/vms)
 gend=anytim2utc(gend,/vms)
 gpeak=anytim2utc(gpeak,/vms)

 cstart=anytim2tai(gstart)
 cend=anytim2tai(gend)
 cpeak=anytim2tai(gpeak)

end
endcase

nflares=n_elements(gstart)
for k=nflares-1,0L,-1L do begin

 if verbose and by_flare then begin
  if keyword_set(goes) then begin
   message,'Searching for TRACE images near GOES '+class[k]+' flare at '+gpeak[k],/cont
  endif else message,'Searching for TRACE images near RHESSI event at '+gstart[k],/cont
 endif

 trace_cat,gstart[k],gend[k],tcat
 
 ss=struct_where(tcat,test=TESTARRAY,scount,/quiet)  
 if scount eq 0 then begin
  message,'No matching TRACE files found',/cont
  goto,skip
 endif
 tcat=tcat[ss]
 nfiles=n_elements(tcat)

;-- create a time grid and pick files nearest each grid point

 if keyword_set(grid) then begin
  tgrid=timegrid(gstart,gend,/hours,/tai,_extra=extra)
  if verbose then message,'Gridding...',/cont
  etimes=anytim(tcat,/tai)
  near=where_near(etimes,tgrid,count=gcount)
  if gcount eq 0 then return
  tcat=tcat[near]
  nfiles=n_elements(tcat)
 endif

 if low_res and by_flare then begin
  ctime=anytim(tcat,/tai)
  d1=abs(ctime-cstart[k])
  c1=where( d1 eq min(d1))
  d2=abs(ctime-cend[k])
  c2=where( d2 eq min(d2))
  d3=abs(ctime-cpeak[k])
  c3=where( d3 eq min(d3))
  ss=get_uniq([c1,c2,c3])
  tcat=tcat[ss]
  nfiles=n_elements(tcat)
 endif

 if verbose then begin
  message,'Found '+trim(nfiles)+' corresponding TRACE files',/cont
 endif

 for i=nfiles-1,0L,-1L do begin

;-- read raw data

  if debug then print,'% TCAT: ',anytim(tcat[i],/vms)

  error=0
  catch,error
  if error ne 0 then begin
   message,err_state(),/cont
   catch,/cancel
   continue 
  endif

;-- check file names

  outfile=trace_struct2filename(tcat[i],/soho,/seconds,/incwave)
  if verbose then message,'Checking '+outfile,/cont  

  chk=stregex(outfile,'[0-9]{6}_',/ext,/sub)
  ymd=strmid(chk,0,6)
  outdir=concat_dir(synop_images,ymd)
  mk_sub_dir,synop_images,ymd
  outname=concat_dir(outdir,outfile)
  coutname=outname+'.gz'

;-- prep raw data and write new data files only, unless clobber is set

  prep=1b
  if not clobber then begin
   chk=loc_file(coutname,count=cfind)
   chk=loc_file(outname,count=ofind)
   prep=(cfind eq 0) and (ofind eq 0)
  endif
 
  if prep then begin
   count=count+1
   trace_cat2data,tcat[i],index,data,loud=verbose
   if not is_struct(index) then continue  
   trace_prep,index,data,pindex,pdata,/wave2point,/norm,/float,$
               _extra=extra

;-- write FITS file

   if verbose then message,'Writing to '+outname,/cont
   pindex.origin=''
   pindex.telescop=''
   write_trace,pindex,pdata,outdir=outdir,loud=verbose,/soho,/seconds
  endif

  chk=loc_file(outname,count=ofind)
  zip=ofind gt 0
  if zip then zip_files=append_arr(zip_files,outname)

 endfor

skip:

endfor

;-- gzip files
 
if is_string(zip_files) then begin
 chmod,zipfiles,/g_read,/g_write
 if verbose then message,'Compressing files..',/cont
 espawn,'gzip -f '+zip_files,/unique
endif

message,'Processed '+trim(count)+' files',/cont
;if count gt 0 then synop_link,'trac',dstart,dend,cadence=60

return
end

