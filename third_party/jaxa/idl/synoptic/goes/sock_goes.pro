pro rd_week_file, input10, input20, data_type, data, orb_pointer, vnum=vnum, $
  indir=indir, nearest=nearest, full_weeks=full_weeks, status=status, qdebug=qdebug, $
  ibyt=ibyt, filename=infil, qstop=qstop, $
        verbose=verbose,nobackup=nobackup,remote=remote,_extra=extra

;+
;NAME:
; rd_week_file
;PURPOSE:
; Read the weekly files which do not have orbit pointers (EVN, FEM,
; NAR, GEV, and GXT)
;CALLING SEQUENCE:
; rd_week_file, roadmap(0),  roadmap(n), 'FEM', fem_data
; rd_week_file, '1-dec-91', '30-dec-91', 'EVN', evn_data
; rd_week_file,      weeks,       years, 'GEV', gev_data
;INPUT:
;     INPUT CAN BE OF TWO FORMS
;
;     (A) Input starting and ending times
; input1  - Starting time in either (i) standard string format,
;     or (ii) a structure with .time and .day fields
;     (the 7 element time vector form is not allowed)
; input2  - Ending time.  If ending time is omitted, the
;     ending time is set to 24 hours after starting time.
;
;     (B) Input can be a vector of week/year number
; input1  - a vector of the week numbers to read
; input2  - a vector of the year of the week to be read
;     if the weeks vector is all within one year, the
;     year parameter can be a scalar.
; data_type - The type of data to read.  Either EVN, FEM, NAR,
;     GEV or GXT
;OUTPUT:
; data  - the data structure containing the data in the files
;     See the structure definition for further information
; orb_pointer - the set of orbit pointers from the files
;OPTIONAL KEYWORD INPUT:
; indir - Input directory of data files.  If not present, use
;     $DIR_GEN_xxx logical directory
; vnum  - The file version number to use.  If not present, a call
;     to WEEKID is made and that latest version is used.
; nearest - If set, then the time span is adjusted a day at a time
;     until it finds some data.  It decrements the starting
;     date by a day and increments the ending date by a day
;     up to 14 days (28 day total span)
; full_weeks - If set, then do not extract the entries that just
;     cover the times covered in the start/end time.  Return
;     all data for weeks covered by the start/end time. This
;     allows a user to have start and end time be the same
;     and still get some data.
;       nobackup - If set, then do not back up a week if the start
;                  time is within 90 minutes of the first day of the week.
;OPTIONAL KEYWORD OUTPUT:
; status  - The read status
;     Some data is available if (status le 0)
;      0 = no error
;      1 = cannot find the file
;      2 = cannot find data in the time period
;     99 = cannot recognize the data_type (prefix)
;     -1 = found data, but had to go outside of the requested
;          period (only true if /NEAREST is used).
; ibyt  - The byte position within the file where the data was extracted
; filename- The name of the file which was read
;RESTRICTIONS:
; Assumes that all files have the same data structure version.
;HISTORY:
; Written 5-Apr-93 by M.Morrison
;  6-Apr-93 (MDM) - Modification to not change the input variable type
;  7-Apr-93 (MDM) - Added /FULL_WEEKS option
; 12-Apr-93 (MDM) - Modification to allow first week to be missing
; 13-Apr-93 (MDM) - Modified to work with the weekly files that have
;       orbit pointers
; 15-Apr-93 (MDM) - Expanded to handle PNT, G6D, G7D
;     - Expanded to handle the new OBS files
;       (OBD, OSF, OSP, OWH)
;     - Removed the "ndatasets-1" restriction, made it
;       "ndatasets" (-1 was a carry over from RD_PNT)
; 16-Apr-93 (MDM) - Some debugging statement
; 19-Apr-93 (MDM) - Expanded to handle NEL files
; 20-Apr-93 (MDM) - Expanded to handle OGB files
; 21-Apr-93 (MDM) - Renamed OGB to GOL
;     - Added ORB_POINTER so that the FIDs can be passed
;       out for the OBS file reads
; 13-May-93 (MDM) - Expanded to handle NTS files
; 14-May-93 (MDM) - Removed the special handling of OBS directory
; 17-May-93 (MDM) - Minor modification
; 20-May-93 (MDM) - Allowed 7-element array external time representation
;       as input.
; 12-Jul-93 (MDM) - Use TEMPORARY function some more
; 16-Apr-93 (MDM) - Expanded to handle ATR and ATT files
; 11-Aug-93 (MDM) - Added IBYT and FILENAME output parameters
;     - Modification so that if the input times match, it
;       will increment the end time by one second because
;       otherwise the /FULL_WEEK option will not work.
;  9-Mar-94 (SLF) - GUF (Ulysees Ephemeris) support
; 29-Aug-94 (MDM) - Added /QSTOP option
;       29-Aug-94 (MDM) - Added /NOBACKUP option to NOT back up a week
;                         when start time is within 90 minutes of the first
;                         day of the week - it is passed to ANYTIM2WEEKS
;       25-Oct-94 (SLF) - allow use of compressed files
;        8-Dec-94 (MDM) - Patch for cases where there is no data but there
;                         is an orbit pointer entry
; 19-Dec-94 (MDM) - Modified to correct a problem caused by the modification
;       to MK_WEEK_FILE which used a different NEWORB_P
;       structure for all weekly files.
; 23-Mar-95 (MDM) - Modified to accept new version of FEM structure
;       29-aug-95 (SLF) - Add GOES averages (g61/g71/g65/g75)
;        1-apr-96 (SLF) -
; 29-Aug-96 (RDB) - Added ORB file (orbital position file)
;       21-Jul-98 (SLF) - GOES 10
; 17-Dec-99 (GLS) - Y2K FIX - Modified test of input1 to accomodate Y2K values
;       18-Jan-2001 (SLF) - made loop counter LONG
; 19-Jun-2001, Paul Hick; fixed two obscure bugs triggered when specifying
;   input times as week/year.
;       22-May-2002, Zarro (L-3Com/GSFC) - made socket compatible
;        4-may-2007 (SLF) - GOES 11+13 support (G1D,G11,G15)
;   19-Feb-2008, Kim. If none of data read is > 0. keep looking for another satellite.
;   05-Mar-2008, Kim.  Fixed previous fix.  Check if goesdig true before checking for 0 data.
;   06-Aug-2008, Kim.  Moved message about remote searching to after check for network available
;        7-dec-2009 (SLF) - through G15
;   19-Jan-2012, Zarro (ADNET) - fixed potential path problem in sock_find   
;-
;

if (n_elements(input10) ne 0) then input1 = input10
if (n_elements(input20) ne 0) then input2 = input20
if (n_elements(indir) eq 0) then indir = '$DIR_GEN_' + strupcase(data_type)

goesdig=is_member(data_type,['G61','G71','G65','G75','G81','G85','G91','G95',$
   'G01','G05','G11','G15','G21','G25','G31','G35','G41','G45','G51','G55'],/ignore_case)

;
siz = size(input1)    ;MDM added 20-May-93
typ = siz( siz[0] + 1)
verbose=keyword_set(verbose)
; Convert from 7 elem ext rep if necessary:
; Y2K FIX - Expand test to include Y2K years (lt 54):
if ((typ lt 7) and (typ ne 0)) then $
  if ((max(input1) gt 54) or (n_elements(input1) eq 7)) then begin
    input1 = anytim2ints(input1)
    input2 = anytim2ints(input2)
end


siz = size(input1)
typ = siz[siz[0] + 1]
if ((typ eq 7) or (typ eq 8)) then begin  ;entered a start/end time
    if (n_elements(input2) eq 0) then begin ;undefined
  day_arr1 = anytim2ex(input1)
  ex2int, day_arr1, time, day
  int2ex, time, day+1, day_arr2                ;just end 24 hours later
  input2 = fmt_tim(day_arr2)
    end
;    anytim2weeks, input1, input2, weeks, years, nobackup=nobackup
    temp=week_loop(input1,input2,weekstr=weekstr)
    weeks=temp.week
    years=temp.year
    if (int2secarr(input1, input2) eq 0) then input2 = anytim2ints(input2, off=1) ;input the same time ==> want an orbit
    qtim_check = 1
    qtimes = 1
end else begin
    weeks = input1
    years = input2
    qtim_check = 0
    qtimes = 0
end
if (keyword_set(full_weeks)) then qtim_check = 0
;
status = 0
data = 0b
orb_pointer = 0b
neworb_p = 0b
input1_save = input1
input2_save = input2
itry = 0
;
qdone = 0
while ~qdone do begin
    qfirst = 1
    if (strupcase(data_type) eq 'GBE') then weeks = 1   ;only one file
    if (strupcase(data_type) eq 'NEL') then weeks = 1   ;only one file
    for iweek = 0L, n_elements(weeks)-1L do begin
  case strupcase(data_type) of
      'GBE': begin
      infil = file_list('$DIR_GEN_GBE', 'gbe000000.0000')
      infil = infil[0]
      wid = ' '
       end
      'NEL': begin
      infil = file_list('$DIR_GEN_NEL', 'nel000000.0000')
      infil = infil[0]
      wid = ' '
       end
      else: begin
      if (n_elements(years) eq 1) then yr=years else yr=years[iweek]
      wid = string(fix(yr mod 100), '_', fix(weeks[iweek]), format='(i2.2,a,i2.2)')
      infil = weekid(wid, prefix=strlowcase(data_type),indir=indir, vnum=vnum,verbose=verbose,remote=remote,_extra=extra)
      end
  endcase
  if (keyword_set(qdebug)) then print, wid, ' = ', infil
  if (infil eq '') then begin
      status = 1
      if verbose then message, 'No input file for week ' + wid + ' found in: ' + indir, /info
  end else begin
            chk=file_search(infil,count=count)
            if (count eq 0) then begin
             temp_dir=goes_temp_dir()
             if ~is_dir(temp_dir) then begin
              mk_dir,temp_dir
              chmod,temp_dir,/a_write
             endif
             server=goes_server(network=network,_extra=extra)
             break_file,infil,dsk,dir,name,ext
             if network then begin
              spos1=strpos(infil,'/')
              spos2=strpos(infil,'\')
              if (spos1 eq 0) or (spos2 eq 0) then infil=strmid(infil,1,strlen(infil))
              sfile=infil
              if verbose then message,'Downloading '+sfile,/info
              sock_copy,sfile,out=temp_dir,verbose=verbose,_extra=extra,/use_network,/no_check
             endif
             infil=concat_dir(temp_dir,name+ext)
             chk=file_search(infil,count=count)
             if count eq 0 then begin
              infil=''
              return
             endif
            endif
            compfiles=wc_where(infil,'*.Z',compcnt)
            if compcnt gt 0 then begin
               savename=infil[compfiles]
               if verbose then message,/info,"Decompressing files..."
               for k=0,compcnt-1 do begin
                inname=infil[compfiles[k]]
                outname=find_compressed(inname,err=err,limit=10)
                if err eq '' then infil[compfiles[k]]=outname
               endfor
      endif

      openr, lun, infil, /get_lun, /block
      if verbose then message,'Reading Yohkoh weekly file '+infil,/info
      ;

      rd_pointer, infil, pointer
      rd_fheader, infil, fheader, ndset
      ;
      if (qfirst) then begin
    case strupcase(data_type) of
        'EVN': evn_struct, evn_summary=data_ref
        'FEM': begin
        case pointer.data_version of
                0: fem_old_struct, fem_9001_data=data_ref
          '9002'x: fem_old_struct, fem_9002_data=data_ref
          '9004'x: fem_struct, fem_data=data_ref
        endcase
          end
        'GEV': gbo_struct, gev_data=data_ref
        'GXT': gbo_struct, gxr_data=data_ref
        'NAR': gbo_struct, nar_data=data_ref

        'G6D': gbo_struct, gxd_data=data_ref
        'G7D': gbo_struct, gxd_data=data_ref
        'G8D': gbo_struct, gxd_data=data_ref
        'G9D': gbo_struct, gxd_data=data_ref
                    'G0D': gbo_struct, gxd_data=data_ref
                    'G1D': gbo_struct, gxd_data=data_ref
                    'G2D': gbo_struct, gxd_data=data_ref
                    'G3D': gbo_struct, gxd_data=data_ref
                    'G4D': gbo_struct, gxd_data=data_ref
                    'G5D': gbo_struct, gxd_data=data_ref
        'GBE': gbo_struct, batse_event=data_ref
        'GBL': gbo_struct, batse_lcur=data_ref

        'PNT': pnt_struct, pnt_data=data_ref
        'ATR': att_struct, atr_summary=data_ref
        'ATT': att_struct, att_summary=data_ref

        'OSF': obs_struct, obs_sxt=data_ref
        'OSP': obs_struct, obs_sxt=data_ref
        'OBD': obs_struct, obs_bcs_obs=data_ref
        'OWH': obs_struct, obs_wbshxt=data_ref

        'NEL': gbo_struct, nob_event=data_ref
        'NTS': gbo_struct, nob_timser=data_ref

        'GOL': gbo_struct, gbo_obs=data_ref

        'GUF': gbo_struct, uly_fem=data_ref
        'SXG': sxt_struct, sxg_sxtgoes=data_ref

        'ORB': orb_struct, orb_rec=data_ref

        else: if goesdig then gbo_struct, gxd_data=data_ref else begin
        status = 99
        print, 'RD_WEEK_FILE: Cannot recognize data_type: ', data_type
        return
        endelse
    endcase
      end
      if (pointer.opt_section gt 0) then begin  ;MDM modified 19-Dec-94
    rd_neworb_p, infil, neworb_p
    ss_temp = where(tag_names(neworb_p) eq 'ST$FILEID')
    if (ss_temp[0] eq -1) then begin
        obs_struct, obs2_neworbit=orbit0_ref        ;19-Dec-94 MDM modified to used "obs2" orbit
                ;record for all weely files

        neworb_p = str_copy_tags(orbit0_ref, neworb_p)    ;convert the structure type
        fid_temp = byte( ex2fid( anytim2ex(neworb_p) ) )
        neworb_p.st$fileid[0:10,*] = fid_temp
    end
      end

      if ((pointer.opt_section gt 0) and (qtimes)) then begin ;orbital pointer information available
    norb = n_elements(neworb_p)

    ist = sel_timrange(neworb_p, input1, st_before1st=st_before1st)
                ist = ist[0]    ;patch because of 8-Dec-94 work on ATT/ATR file creation
    ien = sel_timrange(neworb_p, input2, en_afterlast=en_afterlast, /after)
                ien = ien[0]    ;patch because of 8-Dec-94 work on ATT/ATR file creation

    if (st_before1st) then st_dset = neworb_p(0).stEntry else st_dset = neworb_p(ist).stEntry
    ;;if (en_afterlast) then en_dset = fheader.ndatasets-1   else en_dset = neworb_p(ien).stEntry
    ;;en_dset = en_dset < (fheader.ndatasets-1)
    if (en_afterlast) then en_dset = fheader.ndatasets   else en_dset = neworb_p(ien).stEntry
    en_dset = en_dset < (fheader.ndatasets)

    if (keyword_set(qdebug)) then print, 'RD_WEEK_FILE: ist,ien,st_dset,en_dset', ist,ien,st_dset,en_dset

    st_dset = st_dset < en_dset
    ndset = (en_dset-st_dset + 1)

    data0 = replicate(data_ref, ndset)
    ibyt = pointer.data_section + (st_dset-1)*get_nbytes(data0[0])
      end else begin
          data0 = replicate(data_ref, ndset > 1)
          ibyt = pointer.data_section
      end
      rdwrt, 'R', lun, ibyt, 0, data0
      ;
      case strupcase(data_type) of
    'FEM': begin
          ss = where(data0.night ne 0)  ;only get data where it exists
          data0 = data0[ss]
           end
    else:
      endcase
      ;
      if (keyword_set(qstop)) then stop
      if (qfirst) then begin
    orb_pointer = neworb_p
    data = temporary(data0)
    qfirst = 0
      end else begin
;   orb_pointer = [orb_pointer, neworb_p]
;   data = [data, temporary(data0)]
    orb_pointer = [temporary(orb_pointer), neworb_p]
    data = [temporary(data), temporary(data0)]
      end
      ;
      free_lun, lun
   ;       if compcnt gt 0 then begin
   ;           message,/info,"RE-compressing files..."
   ;           file_compress,infil(compfiles)
   ;           infil[compfiles]=savename
   ;        endif
  end
    end
    ;
    qdone = 1

    if (qtim_check) then begin
  if (get_nbytes(data[0]) gt 4) then begin
      x1 = int2secarr(data, input1)
      x2 = int2secarr(data, input2)
      ss = where((x1 ge 0) and (x2 le 0))
      if ss[0] eq -1 then $
        if verbose then message,'Error reading file ' + infil + ' No data or data is all zero. Will keep searching...', /info
  end else begin  ;there was no data read - the file did not exist
      ss = -1
  end
  if (ss[0] eq -1) then begin
      if (keyword_set(nearest)) then begin
    itry = itry + 1
    input1 = anytim2ints(input1_save, off=-1*itry*24.*60.*60.)
    input2 = anytim2ints(input2_save, off=   itry*24.*60.*60.)
    anytim2weeks, input1, input2, weeks, years
    if (keyword_set(qdebug)) then message, 'No data in time span requested.  Expanding to search ' + $
            gt_day(input1,/str) + ' to ' + gt_day(input2,/str), /info
    qdone = 0
    if (itry ge 15) then qdone = 1
      end else begin
    qdone = 1
    data = 0b
    if (status eq 0) then status = 2  ;dont change status if set by "no file found" error
      end
  end else begin
      data = data[ss]
      if goesdig then begin
         if max([data.lo, data.hi]) eq 0. then begin
           if verbose then message, 'Data in file ' + infil + ' is all zero. Will keep searching...', /info
           qdone=0
           status=2
         endif else begin
           qdone = 1
           status = 0
           if verbose then message,'Data successfully read from file ' + infil, /info
         endelse
      endif else begin
         qdone = 1
         state = 0
      endelse
  end
    end
end
;
if (keyword_set(qstop)) then stop
if ((itry ne 0) and (status eq 0)) then status = -1
end

function weekid, fileid, all=all,count=count,			$
   		 xbd=xbd, xad=xad, pnt=pnt, fem=fem, obs=obs,	$
		 ver=ver, gt_pre=gt_pre, indir=indir, 		$
		 gt_distpre=gt_distpre, prefix=prefix, vnum=vnum,$
                 verbose=verbose,remote=remote,_extra=extra
;+
;   Name: weekid
;
;   Purpose: return expanded file ids for weekly files in common area
;	     (provide single point maint for weekly prefix definitions)
;
;   Input Parameters:
;	fileid = xxxyy_wwn (string) - standard weekly file name
; 		 if xxx is included, only that prefix is checked
;   Output:
;	function returns string scaler or array
;	default is latest version only (scaler)
;
;   Optional Keyword Parameters:
;	all - if set, all prefixes are checked
;	xbd,xad,pnt,fem,obs - prefixes to check (mutally exclusive)
;	indir	- if set, look at that directory instead of the
;		  "standard" directory.
;	gt_pre - if set, returns weekid prefixes only
;	gt_distpre - if set, returns weekid prefixes for distributed
;		     (tar sets) only
;       vnum - version number (limit search to only these versions)
;
;   Output Parameters:
;	ver - highest existing version (integer) - 00 if no such file
;
;   Modification History:
;	Written: slf, 19-feb-92
;		 slf,  8-mar-92 	added gt_pre for single pt maint
;		 mdm, 20-May-92		Added "indir" option
;		 mdm,  9-Jun-92		Removed unix specific "/" code
;					Used wildcard "*.*" instead of "*"
;	         slf, 22-Jun-92		Added nar,evn,gev
;		 slf, 20-Oct-92		Added gxt
;		 slf, 24-Nov-92		Added ssl, sot
;		 slf,  6-apr-93		Added prefix and vnum keywords
;                slf, 19-aug-93         replaced recursive segment
;-
;
; handle vnum (input version number)

verbose=keyword_set(verbose)
svnum=size(vnum)
case 1 of
   svnum[svnum[0]+1] eq 0: sver='*'			; all versions
   svnum[svnum[0]+1] eq 7: sver=vnum			; string, use as is
   else: sver=string(fix(vnum),format='(i2.2)')		; number passed
endcase

if n_elements(fileid) eq 0 then fileid='*'	;default wild card
; set up filenames
distpre= $		; distributed (as tar sets)
   ['xbd','xad','fem','nar','evn','gev','gxt','sot','ssl']
preweek=[distpre, 'obs', 'pnt']

if keyword_set(gt_pre) then return, preweek	; just prefixes
if keyword_set(gt_distpre) then return, distpre

if keyword_set(prefix) then preweek=prefix else begin
   fidchk=where(strmid(fileid,0,3) eq preweek)
   if fidchk[0] gt 0 then begin
      prefix=preweek[fidchk]			; full filename
      fileid=strmid(fileid,3,1000)		; use same logic
   endif
endelse
;
						; allow prefix passed in

comdir = '$DIR_GEN_' + strupcase(preweek)	; commond directories
if (keyword_set(indir)) then comdir = indir	; MDM added 20-May-92

; slf, 6-apr - allow version searches
weekfiles=preweek + fileid + '*.' + sver	; add wild card for search

genfiles= concat_dir(comdir, weekfiles)		; path + file
;
; check keywords

; slf, 19-aug - removed recursive segment since calling recursivly.
;for i=0,n_elements(preweek)-1 do begin
;   exestr="if keyword_set(" + preweek[i] +") then prefix=" + $;
;	"'" + preweek(i) + "'"
;   exestat=execute(exestr)
;endfor

if ~keyword_set(prefix) then begin
   case 1 of
      keyword_set(xad): prefix='xad'
      keyword_set(xbd): prefix='xbd'
      keyword_set(fem): prefix='fem'
      keyword_set(nar): prefix='nar'
      keyword_set(evn): prefix='evn'
      keyword_set(gev): prefix='gev'
      keyword_set(gxt): prefix='gxt'
      keyword_set(sot): prefix='sot'
      keyword_set(ssl): prefix='ssl'
      keyword_set(obs): prefix='obs'
      keyword_set(pnt): prefix='pnt'
      else: begin
         message,/info,'no prefix defined, returning...'
         return,''
      endcase
   endcase
endif
;
index=where(prefix[0] eq preweek)		; which file

;-- use HTTP sockets to remotely list files

gfiles=genfiles(index[0])

count=0
remote=keyword_set(remote)
if is_dir(comdir) and ~remote then gen=file_search(gfiles,count=count)
if (count eq 0) or remote then begin
 server=goes_server(network=network,path=path,_extra=extra,verbose=verbose)
 break_file,gfiles,dsk,dir,name,ext
 if network then begin
  path=path+'/'+strlowcase(preweek)+'/'
  gen=sock_find(server,name+ext,path=path,protocol=1.0,count=count,/use_network)
 endif else gen=loc_file(name+ext,path=goes_temp_dir(),count=count)
endif

;count=n_elements(gen)
if count eq 0 then return,''
if (count eq 1) and gen[0] eq '' then return,''
latest=gen[count-1]			; take latest
break_file,latest,log,path,file,ext,version	;
ver=fix(str_replace(ext,'.'))			; version as integer
;
retval = latest					; default is latest
if keyword_set(all) then retval=gen		; all
return, retval
end

;---------------------------------------------------------------------------------------------------------

pro sock_goes

return & end
