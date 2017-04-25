

function ssw_contrib_info, jobfile, pcnt, pros=pros
;+
;   Name: ssw_contrib_info
;
;   Purpose: return info from ssw_contrib 'jobfile' in structure
;
;   Input Parameters:
;      jobfile - ascii ssw_contrib 'job' file (contrib summary)
;
;   Output Parameters:
;      pcnt - number of *.pro files included (may be zero...)
;
;   Keyword Parameters:
;      pros - (OUTPUT) list of *.pro files  [ strarr(pcnt) ]  
;  
;   History:
;    ~1-Jan-1998 - S.L.Freeland - original
;   21-Sep-1999 - S.L.Freeland - match updated 'job' format
;
;   Calling Seqeunce:
;      jobinfo=ssw_contrib_info(jobfile [pcnt, pros=pros ])
;  
;   Method:
;     call rd_tfile/strpair2struct/str2arr/gt_tagval
;
;   Calling Example
;                              |INPUT   |OUT  |OUT
;   IDL> help,ssw_contrib_info(jobfile, pcnt, pros=pros),/str  ; << CALL
;   ** Structure MS_307224832001, 9 tags, length=72:           
;   FROM            STRING    ' freeland@sxt1.lmsal.com'
;   MASTERIP        STRING    ' diapason.lmsal.com'
;   MASTER          STRING    ' trace'
;   MASTERPATH      STRING    ' /tsw'
;   JOBPATH         STRING    ' /pub/incoming/ssw/freeland'
;   JOBNAME         STRING    ' ssw_contrib.freeland.990921.110359'
;   TARFILE         STRING    ' ssw_contrib.freeland.990921.110359.tar'
;   SSWPATH         STRING    ' idl/util'
;   FILESTRANSFERED STRING    ' one.pro two.pro three.pro'
;
;   IDL> more,pros           ; *.pros returned in keyword <PROS>
;      one.pro
;      two.pro
;      three.pro
;			   
;-

if not data_chk(jobfile,/string) then begin
   box_message,'Need ssw_contrib jobfiles as input'
   return,''
endif  

if n_elements(jobfile) gt 1 then begin
   box_message,'Sorry, only one job at a time..., returning'
   return, ''
endif   

nexist=where(1-file_exist(jobfile),necnt)

if necnt gt 0 then begin
   box_message,['Jobfile ' + jobfile(0) + ' does not exist, returing..']
   return,''
endif

; ------- read ascii job and convert-> structure -------------
jobdata=strcompress(rd_tfile(jobfile(0),nocom='-',/compre))
retval=strpair2struct(jobdata,':')
; ------------------------------------------------------------

; ------ include optional count/names of *.pro files ---------
pros=str2arr(strlowcase(gt_tagval(retval,'filestransfered',missing='')),' ')
prosss=where(strpos(pros,'.pro') ne -1,pcnt)
if pcnt gt 0 then pros=pros(prosss) else pros=''
; --------------------------------------------------------

return,retval
end
