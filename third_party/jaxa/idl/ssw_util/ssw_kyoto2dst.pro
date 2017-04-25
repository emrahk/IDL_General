function ssw_kyoto2dst, kyotostuff
;+
;
;  Name: ssw_kyoto2dst
; 
;  Purpose: convert monthy kyoto dst WWW pages -> ssw/utplot vector
;
;    
;  Input Parameters:
;      kyotostuff - url of desired page (month) -or- sock_list of the url
;
;  Output:
;    function returns utplot-ready vector for page (one month of kyoto)
;    vector of {mjd:0l, time:0L, dst:0.0}
;
;  Calling Example:
;     (usually invoked by wrapper ssw_getdst.pro)
;
;     EX: read kyoto provisional dst for October 2003
;     dst=ssw_kyoto2dst(http://swdcdb.kugi.kyoto-u.ac.jp/dstdir/dst1/p/dstprov20;                                0310.html'
;  History:
;    27-Feb-2004  - S.L.Freeland - broke url->struct logic from ssw_getdst
;    20-mar-2004 -  S.L.Freeland - remove fill data records (9999)
;
;  Restrictions:
;     url input assumes IDL V >= 5.4 due to use of sockets
;
;-
case 1 of
   n_params() eq 0: begin 
      box_message,'Need Kyoto url -or- listing from same'
      return,-1
   endcase
   n_elements(kyotostuff) eq 1: begin
      kurl=strtrim(kyotostuff(0),2)
      if strpos(strlowcase(kurl),'http') ne 0 then begin 
         box_message,'Need full kyoto url...'
         return,-1
      endif
      sock_list,kurl,kyolist
   endcase
   else: kyolist=kyotostuff
endcase

if n_elements(kyolist) lt 30 then begin 
   box_message,'Warning - problem with WWW listing or no such url'
   return,-1
endif
 
kyolist=strupcase(strtrim(kyolist,2))
ss0=where(strpos(kyolist,'DAY') eq 0)
minit='1-'+str_replace(strcompress(kyolist(ss0-3)),' ','-')
ssl=where(strpos(kyolist,'</CODE>') eq 0)
kyolist=strarrcompress(kyolist(ss0+1:ssl-1))
kyolist=strpad(kyolist,max(strlen(kyolist)))
format='(8i4,1x,8i4,1x,8i4)'
days=strmid(kyolist,0,2)
dstdata=strmids(kyolist,3,strlen(kyolist))
dst=intarr(n_elements(days)*24)
reads,dstdata,dst,format=format
lastday=str2number(strmid(last_nelem(days),0,2))
mgrid=timegrid(minit,nsamp=24.*lastday,/hour,out='utc_int')
mretval=add_tag(mgrid,0.0,'dst')
mretval.dst=dst
goodss=where(mretval.dst lt 9999,gcnt)
if gcnt gt 0 then mretval=mretval(goodss) else begin 
   box_message,'No good data for time range...'
   mretval=-1
endelse
return,mretval
end       
    

