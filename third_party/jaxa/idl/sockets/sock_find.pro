;+
; Project     : HESSI
;
; Name        : SOCK_FIND
;
; Purpose     : socket version of FINDFILE
;
; Category    : utility system sockets
;
; Syntax      : IDL> files=sock_find(server,file,path=path)
;                   
; Inputs      : server = remote WWW server name
;               FILE = remote file name or pattern to search 
;
; Outputs     : Matched results
;
; Keywords    : COUNT = # of matches
;               PATH = remote path to search
;               ERR   = string error message
;
; Example     : IDL> a=sock_find('smmdac.nascom.nasa.gov','*.fts',$
;                                 path='/synop_data/bbso')
;               or
;
;               IDL> a=sock_find('smmdac.nascom.nasa.gov/synop_data/bbso/*.fts')
;
; History     : 27-Dec-2001,  D.M. Zarro (EITI/GSFC) - Written
;                3-Feb-2007, Zarro (ADNET/GSFC) - Modified
;                 - return full URL path
;                 - made no-cache the default
;               27-Feb-2009, Zarro (ADNET) 
;                 - restored caching for faster repeat searching of
;                   same directory
;                 - improved regular expression to handle wild card
;                   searches
;               17-Jan-2010, Zarro (ADNET)
;                 - modified to return "http://" in output
;               22-Oct-2010, Zarro (ADNET)
;                 - modified to extract multiple files listed per line
;               22-July-2011, Zarro (ADNET)
;                 - change sock_list to call sock_list2, which has better
;                   proxy support
;               16-Jan-2012, Zarro (ADNET)
;                 - added _extra to sock_list to pass HTTP
;                   keywords 
;               5-Feb-2013, Zarro (ADNET)
;                 - avoid str_replace call if path not in listing
;               25-Feb-2013, Zarro (ADNET)
;                 - made USE_NETWORK = 1 the default so that 
;                  IDL network object is called, which handles
;                  chunked-encoding better.
;               10-Jul-2013, Zarro (ADNET)
;                 - fixed potential bug when search file not entered
;                   (now defaults to *).
;               7-Nov-2013, Zarro (ADNET)
;                 - call SOCK_LIST directly, which uses IDL network
;                   object.
;               15-Sep-2014, Zarro (ADNET)
;                 - reinforced test for dangling backlash on path.
;               17-Feb-2015, Zarro (ADNET)
;                 - removed spurious links
;               6-Mar-2015, Zarro (ADNET)
;                 - separated HREF parsing code into PARSE_LINKS
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function sock_find,server,file,path=path,count=count,err=err,$
                   _ref_extra=extra,old_way=old_way

;--- start with error checking

err=''
count=0
dfile='' 
dpath=''

if is_blank(server) then begin
 err='Missing remote server name.'
 mprint,err
 return,''
endif

;-- check if server includes full URL 

dserver=server
durl=url_parse(dserver)
dscheme=durl.scheme
if is_string(durl.host) then dserver=durl.host
if is_string(durl.path) then begin
 dpath=strtrim(durl.path,2)
 if ~is_string(file) && ~stregex(dpath,'/$',/bool) then begin
  dfile=file_basename(dpath)
  dpath=file_dirname(dpath)
 endif
 if dpath eq '.' then dpath=''
endif

if is_string(path) then dpath=path
if is_string(file) then dfile=file

;-- impose defaults

if is_blank(dfile) then dfile='*'
if is_blank(dpath) then dpath='/'
 
;-- escape any metacharacters

dpath=str_replace(dpath,'\','/')

;-- remove duplicate delimiters

vpath=str2arr(dpath,delim='/')
ok=where(trim(vpath) ne '',vcount) 
if vcount eq 0 then dpath='/' else dpath='/'+arr2str(vpath[ok],delim='/')+'/'

url=dscheme+'://'+dserver+dpath
dprint,'% Searching '+url
dprint,'% Path ',dpath
dprint,'% File ',dfile
dfile=trim(dfile)

if keyword_set(old_way) then sock_cat,url,hrefs,err=err,_extra=extra,/no_check,old_way=old_way else $
 sock_list,url,hrefs,err=err,_extra=extra
if is_string(err) then return,''

links=parse_links(hrefs,dfile,dpath,count=count)
if count eq 0 then return,''

if ~stregex(url,'http:',/bool) then url='http://'+url
return,url+links

end
