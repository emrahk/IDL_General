;+                                                                 
;
; NAME:		SPECTRA2FITS
;
; PURPOSE:	Create fits binary tables using BATSE and GOES spectra data.
;
; CATEGORY: 	Fits Binary Table Extensions I/O
;
; CALLING SEQUENCE:
;		spectra2fits,time,flux,date_obs,edges=edges, $
;                 livetime=livetime, eflux=eflux,  $
;                 flux_unit=flux_unit, $
;                 direction_cosines=direction_cosines, $
;                 edge_unit=edge_unit,filename=filename, status=status,$
;                 clockcor=clockcor, help=help, com_head=com_head, $ 
;                 com_ext1=com_ext1, com_ext2=com_ext2, com_ext3=com_ext3, $
;		  head_key=head_key, ext1_key=ext1_key, ext2_key=ext2_key, $
;		  ext3_key=ext3_key, y2k=y2k
;
; CALLS:
;       FCHECK,FXHMAKE,FXADDPAR,FXWRITE,FXBHMAKE,FXBADDCOL,FXBCREATE,FXBWRITE,
;       FXBFINISH,ANYTIM,WC_WHERE,FLIPDATE,CONVERT_2_STREAM
;
; INPUTS: 
;	Time: Time in seconds from start observation time.
;	Flux: Flux (any size array)
;	Date_obs: Obs. starting time (format accepted by anytim)
;
; OUTPUTS: 
;	Binary fits tables with default filename 'spectra2fits.fits'
;
; KEYWORDS:
;       EDGES: 		Energy edges (2xn format)
;       LIVETIME: 	Livetime of each interval (in sec)
;       EFLUX: 		Uncertainty on flux
;       FLUX_UNIT: 	Unit of flux (default: counts/sec)
;	DIRECTION_COSINES: Direction cosines for all 8 detectors
;       EDGE_UNIT: 	Unit of edges (default: keV)
;       FILENAME: 	Name for output fits file (def.: spectra2fits.fits) 
;	STATUS: 	Status word (1st column must be time)
;	CLOCKCOR: 	Clock correction (YES, NO or UNKNOWN)
;	HELP: 		If =1, print help text
;	COM_HEAD: 	Comments for primary header
;	COM_EXT1: 	Comments for 1st extension
;	COM_EXT2:	Comments for 2nd extension
;	COM_EXT3: 	Comments for 3rd extension
;	HEAD_KEY: 	Additional keywords for primary header 
;	EXT1_KEY:	Additional keywords for 1st extension 
;	EXT2_KEY: 	Additional keywords for 2nd extension 
;	EXT3_KEY: 	Additional keywords for 3rd extension
;	Y2K:		Keyword for y2k compatibility, i.e. 4 digit years 
;
; RESTRICTIONS:
;	Time and livetime are 1-D arrays, in seconds, from observation 
;	start time.
;	Date_obs is the start date of observation in any format accepted 
;	by anytim.
;	First column of status array must be time.
;	Comments for a given header are in string array format. Example:
;	com_head=['line1','line2','line3']
;	Additional keywords are input as structures. 
;	Comments on individual keywords are written in string array format
;	and then passed on as an element of the structure. Example: 
;	comments=['Comment on instrument','Comment on telescope','']
;	head_key={instrume:'BATSE',telescop:'CGRO',object:'Sun', $
;	comments:comments}
;	
; PROCEDURE: 
;	This routine creates fits binary tables. 
;       The primary header is a basic header. The first extension 
;       contains the energy edges and direction cosines.
;	The second extension contains time, flux, livetime and 
;	eflux. The third extension contains status word and time.
;
; MODIFICATION HISTORY:
;       Written September 1995, by RCJ.
;       Mod. by RCJ 04/97. Adapt routine to more general use. Please
;		note that it's *not* 100% general.
;	Version 3 Amy.Skowronek@gsfc.nasa.gov Added y2k keyword to
;		write years with four digits in FITS header.
;       05-Nov-2012, Kim Tolbert. Commented out the print'Making stream file ...' msg, since it's only 
;          actually making a stream file for VMS machines, and otherwise inspires 'Huh?'
;-
;===========================================================================
;
pro spectra2fits,time,flux,date_obs,edges=edges, $
                 livetime=livetime, eflux=eflux,  $
                 flux_unit=flux_unit, $
                 direction_cosines=direction_cosines, $
                 edge_unit=edge_unit,filename=filename, $
                 status=status, clockcor=clockcor, $
		 help=help, $
;	 Comments. Example:
;	      com_head=['line1','line2','line3']
		 com_head=com_head, com_ext1=com_ext1, com_ext2=com_ext2, $
		 com_ext3=com_ext3, $
;        The next keywords have to be structures. Example:
;	      comments=['Comment on instrument','Comment on telescope','']
;             head_key={instrume:'BATSE',telescop:'CGRO',object:'Sun', $
;			comments:comments}
                 head_key=head_key, ext1_key=ext1_key, $
                 ext2_key=ext2_key, ext3_key=ext3_key,y2k=y2k
On_error,2
y2k=keyword_set(y2k)

if n_params() lt 2 then begin 
   text=['',+$
   'SPECTRA2FITS: IDL>spectra2fits, time, flux, date_obs, edges=edges,',+ $
   'livetime=livetime, eflux=eflux, flux_unit=flux_unit, status=status,',+ $
   'direction_cosines=direction_cosines, edge_unit=edge_unit, filename=filename' ,+ $
   'help=help, com_head=com_head, com_ext1=com_ext1, com_ext2=com_ext2,' ,+ $
   'com_ext3, head_key=head_key, ext1_key=ext1_key, ext2_key=ext2_key',+$
   'ext3_key=ext3_key',+'y2k=y2k',+$
   '']
   for i=0,n_elements(text)-1 do print,text(i)
   if keyword_set(help) then begin
      text=["",+$
      "Time and livetime are 1-D arrays, in seconds, from observation start time.",+$
      "",+$
      "Date_obs is the start date of observation in any format accepted by anytim",+$
      "",+$
      "The default unit for edges and flux are 'keV' and 'counts /s', respectively",+$
      "",+$
      "Comments for a given header are in string array format. Example:",+$
      "com_head=['line1','line2','line3']",+$
      "",+$
      "Additional keywords are input as structures. ",+$
      "Comments on individual keywords are written in string array format",+$
      "and then passed on as an element of the structure. Example: ",+$
      "comments=['Comment on instrument','Comment on telescope','']",+$
      "head_key={instrume:'BATSE',telescop:'CGRO',object:'Sun', $",+$
      "comments:comments}",+$
      ""]
      for i=0,n_elements(text)-1 do print,text(i)
   endif
goto,getout
endif
;
;
text='Number of comments should be the same as the number of keywords!'
if keyword_set(head_key) then begin
   head_name=strupcase(tag_names(head_key)) 
   if n_elements(head_name)-1 ne n_elements(head_key.comments) then message,text
endif else head_name=''
if keyword_set(ext1_key) then begin
   ext1_name=tag_names(ext1_key) 
   if n_elements(ext1_name)-1 ne n_elements(ext1_key.comments) then message,text
endif else ext1_name=''
if keyword_set(ext2_key) then begin
   ext2_name=tag_names(ext2_key) 
   if n_elements(ext2_name)-1 ne n_elements(ext2_key.comments) then message,text
endif else ext2_name='' 
if keyword_set(ext3_key) then begin
   ext3_name=tag_names(ext3_key) 
   if n_elements(ext3_name)-1 ne n_elements(ext3_key.comments) then message,text
endif else ext3_name=''
;
edge_unit=fcheck(edge_unit,'keV')
flux_unit=fcheck(flux_unit,'counts /s')
mjdref=anytim('1-jan-1979',/mjd)
time=anytim(time,/sec)    ; any type of time input (acceptable by anytim) 
                          ; array becomes a double array of seconds
dt_obs=anytim(date_obs,/ex) ;hh,mm,ss,msec,dd,mm,yy
timezero=anytim(date_obs,/mjd)   
if not keyword_set(filename) then begin
   res=wc_where(head_name,'TELESCOP')
   if res(0) ne -1 then filename=head_key.(res(0))(0) else begin
     filename='spectra2fits.fits'
     goto,keep_going
   endelse
   res=wc_where(head_name,'INSTRUME')
   if res(0) ne -1 then begin
      filename=filename+'_'+head_key.(res(0))(0)
      dt=dt_obs(6)+dt_obs(5)+dt_obs(4)+dt_obs(0)+dt_obs(1)        ;yymmddhhmm
      filename=filename+'_'+strtrim(dt,2)+'.fits'
   endif else filename='spectra2fits.fits'
endif
keep_going:
;
;
;  Write primary header
;
;
fxhmake,head,/date,/extend,/init
if keyword_set(head_key) then $
   for i=0,n_elements(head_name)-2 do $  ; -2 because last elem. is comments
      fxaddpar,head,head_name(i), head_key.(i), head_key.comments(i)
fxaddpar,head,'DATE-OBS',flipdate(anytim(date_obs,hxrbs=1-y2k,ecs=y2k,/date)),$
		'date of first obs.(DD/MM/YYYY)'
fxaddpar,head,'TIME-OBS',anytim(date_obs,/hxrbs,/time),$
		'UT time of first obs.(HH:MM:SS.XXX)'
fxaddpar,head,'DATE-END',flipdate(anytim(anytim(date_obs,/sec)+time(n_elements(time)-1),$
		hxrbs=1-y2k,ecs=y2k,/date)), 'date of last obs.(DD/MM/YYYY)'
fxaddpar,head,'TIME-END',anytim(anytim(date_obs,/sec)+time(n_elements(time)-1),$
		/hxrbs,/time),'UT time of last obs.(HH:MM:SS.XXX)'
if keyword_set(com_head) then $
   for i=0,n_elements(com_head)-1 do $
      fxaddpar,head,'COMMENT',com_head(i)
;
fxwrite,filename,head
;
;
;  Write first extension     Contains energy edges and direction cosines
;
;
fxbhmake,ext1,1      
if keyword_set(ext1_key) then $
   for i=0,n_elements(ext1_name)-2 do $
      fxaddpar,ext1,ext1_name(i), ext1_key.(i), ext1_key.comments(i)
if keyword_set(edges) then $
   fxbaddcol,eecol,ext1,edges,'Edges',tunit=edge_unit   
if keyword_set(direction_cosines) then $
   fxbaddcol,coscol,ext1,direction_cosines,'Direction_cosines'     
if keyword_set(com_ext1) then $
   for i=0,n_elements(com_ext1)-1 do $
      fxaddpar,ext1,'COMMENT',com_ext1(i)
fxbcreate,unit,filename,ext1
if keyword_set(edges) then $
   fxbwrite,unit,edges,eecol,1    
if keyword_set(direction_cosines) then $
   fxbwrite,unit,direction_cosines,coscol,1
fxbfinish,unit
;
;
;  Write second extension    Contains time, flux, livetime, eflux 
;
;
fxbhmake,ext2,1  ;fxbhmake,header,nrows[,extname[,comment]]
fxaddpar,ext2,'MJDREF', mjdref.(0),'MJD for reference file'
fxaddpar,ext2,'TIMESYS', 'MJD', 'The time system is MJD'
fxaddpar,ext2,'TIMEUNIT', 's', 'Unit for TSTART and TSTOP'
; TIMEZERO keyword can be overwritten. Simply enter your TIMEZERO
; in ext2_key.
fxaddpar,ext2,'TIMEZERO', timezero.(0), 'Time zero off-set'
fxaddpar,ext2,'TSTART', time(0), 'Observation start time'
fxaddpar,ext2,'TSTOP', time(n_elements(time)-1), 'Observation stop time'
if keyword_set(clockcor) then begin
   if strupcase(clockcor) ne 'YES' or strupcase(clockcor) ne 'NO' or $
	strupcase(clockcor) ne 'UNKNOWN' then $
	message,'CLOCKCOR keyword should be YES, NO, or UNKNOWN'
   fxaddpar,ext2,'CLOCKCOR',clockcor,'If time is corrected to UT'
endif
if keyword_set(ext2_key) then $
   for i=0,n_elements(ext2_name)-2 do $
      fxaddpar,ext2,ext2_name(i), ext2_key.(i), ext2_key.comments(i)
fxbaddcol,tcol,ext2,time,'Time',tunit='s'
fxbaddcol,ccol,ext2,flux,'Flux',tunit=flux_unit
if keyword_set(livetime) then $
   fxbaddcol,lcol,ext2,livetime,'Livetime',tunit='s'
if keyword_set(eflux) then $
   fxbaddcol,eccol,ext2,eflux,'Eflux',tunit=flux_unit
if keyword_set(com_ext2) then $
   for i=0,n_elements(com_ext2)-1 do fxaddpar,ext2,'COMMENT',com_ext2(i)
fxbcreate,unit,filename,ext2
fxbwrite,unit,time,tcol,1
fxbwrite,unit,flux,ccol,1 
if keyword_set(livetime) then $
   fxbwrite,unit,livetime,lcol,1
if keyword_set(eflux) then $
   fxbwrite,unit,eflux,eccol,1
fxbfinish,unit
;
;  Write third extension     Contains status word
;
if keyword_set(status) then begin
   fxbhmake,ext3,1
   if keyword_set(ext3_key) then $
      for i=0,n_elements(ext3_name)-2 do $
         fxaddpar,ext3,ext3_name(i), ext3_key.(i), ext3_key.comments(i)
   fxbaddcol,tcol,ext3,reform(status(0,*)),'Time',tunit='s'
   fxbaddcol,scol,ext3,float(status(1:*,*)),'Status'
   if keyword_set(com_ext3) then $
      for i=0,n_elements(com_ext3)-1 do fxaddpar,ext3,'COMMENT',com_ext3(i)
   fxbcreate,unit,filename,ext3
   fxbwrite,unit,status(0,*),tcol,1
   fxbwrite,unit,float(status(1:*,*)),scol,1    
   fxbfinish,unit
endif
;
;print,'Making stream file ...'
convert_2_stream,filename,/delete
getout:
end
