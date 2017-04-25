function secchi_time2files, time0, time1, level=level, $
   lz=lz, pb=pb, rt=rt,$
   pattern=pattern, euvi=euvi, cor1=cor1,cor2=cor2,hi1=hi1,hi2=hi2,$
   ahead=ahead,behind=behind, urls=urls, parent=parent,  $
   dtype=dtype, debug=debug, beacon=beacon,topurls=topurls, $
   l1q=l1q, check_fits=check_fits, bad_fits=bad_fits, quiet=quiet, $
   ssc=ssc, lmsal=lmsal, urlparent=urlparent
;
;+
;   Name: secchi_time2files
;
;   Purpose: return secchi files for user time/timerange 
;
;   Input Paramters:
;      time0 - time or start time of range
;      time1 - stop time of range
;
;   Keyword Parameters:
;      level - processing level - default= Zero aka 0
;      pb - switch - if set, playback data is considered
;      rt - switch - if set, real time data is considered
;      lz - switch - if set, 'lz' path (??)
;      pattern - optional file pattern - default = *fts
;      euvi, cor1, cor2, hi1, hi2 - mutually exclusive instrument - def = euvi
;      a,b - probably obvious - default = /a
;      dtype - "type" of data returned, def='img' - tbd... 
;      parent - top level directory - if not supplied, use '$SSW_SECCHI_DATA'
;               (url parent of secchi data tree server ok)
;      urls - if set, return urls, not nfs filenames
;      ssc - source=Stereo Science Center (implies /urls) ; default urls
;      lmsal - source=lmsal (implies /urls)
;      beacon - if set, files/urls are BEACON tree, not $secchi
;      topurls=topurls - if set, return parent urls (default=FITS files)
;      l1q - if set, use associated $SSWDB distributed Level1Q
;      check_fits - if set, then verify each file is valid FITS (only return valid)
;      bad_fits - only defined if /check_fits set; list of invalid FITS (generally null)
;               
;
;   Calling Sequence:
;      IDL> secfiles=secchi_time2files(t0,t1 [,level=#] $
;                      [,/a] -or [,/b] [,/rt] -or- [,/pb] $
;                      [,/corN] -or- [,/hiN] -or- [,/euvi]
;
;   Calling Examples:
;      IDL> euvi=secchi_time2files('4-dec-2006','5-dec-2006',/pb) ; def=euvi/a - fits
;      IDL> cor1=secchi_time2files('4-dec-2006','5-dec-2006',/rt,/b,/cor1) 
;      IDL> cor2=secchi_time2files('
;
;   History:
;      4-dec-2006 - S.L.Freeland - celebrate SECCHI first light
;                                  in the mold of xxx_time2files.pro suite 
;     27-feb-2007 - S.L.Freeland - add /LZ switch (tlm? = {rt -or- pb -or- lz}
;      5-mar-2007
;     12-mar-2007 - S.L.Freeland - changed parameter passed to 
;                                  ssw_time2filelist.pro (much faster....)
;     21-jan-2008 - S.L.Freeland - expand /URLS to any $secchi server;
;                                  change default type from /PB to /LZ
;     26-jan-2008 - S.L.Freeland - tweak for ssc vs lmsal server config
;                                  add /lmsal ; SSC is default if /URLS set
;     16-jul-2009 - S.L.Freeland - handle href & HREF... 
;                                  default nfs from pb -> lz
;
;   Method:
;     set up call to 'ssw_time2filelist' based on user time+keywords
;     (which calls 'ssw_time2paths')
;
;  Restrictions:
;     dtype and pattern not yet explored; assume FITS images are desired for today 
;-
quiet=keyword_set(quiet) 
loud=1-quiet
debug=keyword_set(debug)
secchidata=get_logenv('secchi') ; secchi standard
eparent=get_logenv('SSW_SECCHI_DATA') ; possible synonym/backward compat
beacon=keyword_set(beacon)
l1q=keyword_set(l1q)
ssc=keyword_set(ssc)
lmsal=keyword_set(lmsal)
urls=keyword_set(urls) or ssc or lmsal

case 1 of 
   data_chk(parent,/string):  ; user supplied vi keyword
   l1q: parent=concat_dir('$SSWDB','/stereo/secchi/data/beacon/')
   keyword_set(urls): begin
      secchi_server=get_logenv('secchi_server')
      case 1 of 
        data_chk(urlparent,/string): parent=urlparent ; user supplied
        beacon: parent='http://stereo-ssc.nascom.nasa.gov/data/beacon/
        ssc: parent='http://stereo-ssc.nascom.nasa.gov/data/ins_data/secchi'
        secchi_server ne '': parent=secchi_server ; via env. $secchi_server
        lmsal: parent='http://www.lmsal.com/solarsoft/stereo/secchi/data/'
        else: begin 
           parent='http://stereo-ssc.nascom.nasa.gov/data/ins_data/secchi'
           ssc=1 ; 
        endcase
      endcase
     
   endcase
   file_exist(eparent): parent=eparent ; via environmental override
   file_exist(secchidata): parent=secchidata ; 
   else: parent='/service/stereo4/data/secchi/' ; local gsfc 
endcase

if n_elements(level) eq 0 then level=0
slevel='L'+strtrim(level,2) ; processing level subdirectory hook

case 1 of   ; set telemetry type string/subdirectory
   ssc: ttype='' ; SSC slightly different top level organization
   keyword_set(rt): ttype='rt'
   keyword_set(pb): ttype='pb'
   keyword_set(lz): ttype='lz'
   else: ttype='lz' ; ttype=(['pb','lz'])(keyword_set(urls))  ;  
endcase
 
sat=(['a','b'])(keyword_set(behind))  ; satellite select, default='a'
satab=(['/ahead/','/behind/'])(sat eq 'b')

if n_elements(dtype) eq 0 then dtype='img'
if n_elements(pattern) eq 0 then pattern='*.fts'
case 1 of 
   keyword_set(cor1): inst='cor1'
   keyword_set(cor2): inst='cor2'
   keyword_set(hi1): inst='hi1'
   keyword_set(hi2): inst='hi2'
   else: inst='euvi'
endcase

delim=([get_delim(),'/'])(urls)
topparent=arr2str(strarrcompress([parent,ttype,slevel,sat,dtype,inst]),delim)

case 1 of
   keyword_set(urls): begin
      if beacon then begin 
         topparent=parent+satab+'secchi/'+arr2str([dtype,inst],'/')+'/'
         subdirs=ssw_time2paths(parent=topparent,time0,time1,/flat) + '/'
         sock_list,subdirs(0),urllist
         urllist=web_dechunk(urllist)
         for i=1,n_elements(subdirs)-1 do begin 
            sock_list,subdirs(i),newlist
            urllist=[temporary(urllist),web_dechunk(newlist)]
         endfor
         fitss=where(strpos(urllist,'.fts">') ne -1,ffcnt)
         if ffcnt eq 0 then begin
            box_message,['No files found in >>',subdirs]
            return,''
         endif
         ffiles=urllist(fitss)
         hpat=(['HREF="','href="'])(strpos(ffiles(0),'href') ne -1)
         fits=strextract(ffiles,hpat,'.fts"')+'.fts'
         urls=topparent+strmid(fits,0,8)+'/'+fits 
         if debug then stop,'urls'
         if keyword_set(topurls) then retval=subdirs else $
              retval=urls 
         if keyword_set(pattern) then begin 
            ss=where(strmatch(retval,pattern))
            if ss(0) ne -1 then retval=retval(ss) else retval='' 
         endif
      endif else begin 
         t0=anytim(time0,/ecs) 
         t1=([anytim(time1,/ecs),reltime(time1,min=-.01)]) $
              (anytim(time1) eq anytim(time1,/date_only))
         suburls=ssw_time2paths(t0,t1,parent=topparent,/flat)+'/'
         urllist=''
         for i=0,n_elements(suburls)-1 do begin 
            if loud then print,'Listing>> '+ suburls(i)
            sock_list,suburls(i),ulist
            ulist=web_dechunk(ulist)  
            ss=where(strpos(ulist,'.fts') ne -1,sscnt)
            if sscnt gt 0 then begin 
               ffiles=ulist(ss)
               hpat=(['HREF="','href="'])(strpos(ffiles(0),'href') ne -1)
               files=strextract(ulist(ss),hpat,'">')
               urllist=[temporary(urllist),suburls(i)+files]
            endif else box_message,'No files in ' + suburls(i)
         endfor
         retval=urllist(0) ; init->null
         if n_elements(urllist) gt 1 then $
            retval=ssw_time2filelist(time0,time1,in_files=urllist(1:*),/flat,debug=debug) 
         if keyword_set(pattern) then begin 
            ss=where(strmatch(retval,pattern))
            if ss(0) ne -1 then retval=retval(ss) else retval='' 
         endif
      endelse
   endcase
   else: begin 
       retval=ssw_time2filelist(time0,time1,pattern=pattern,parent=topparent,/flat,debug=debug)
       nret=n_elements(retval)*(retval(0) ne '')
       if keyword_set(check_fits) and nret gt 0 then begin 
          bad_fits=''
          box_message,'Verifying valid FITS...'
          ifs=intarr(nret)
          for i=0,nret-1 do ifs(i)=is_fits(retval(i))
          badss=where(ifs eq 0,badcnt)
          case 1 of
             badcnt eq 0: box_message,'all files are valid FITS'
             badcnt eq nret: begin
                box_message,'All '+strtrim(badcnt,2)+ ' files are not valid FITS!!...'
                bad_fits=retval
                retval=''
             endcase 
             else: begin 
                bad_fits=retval(badss)
                retval=retval(where(ifs))
             endcase
         endcase
       endif
   endcase
endcase
if debug then stop,'retval,topparent'

return,retval
end



