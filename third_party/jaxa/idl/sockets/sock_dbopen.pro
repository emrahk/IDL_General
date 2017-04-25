
;-- load socketized DB routines

@sock_dbfind_sort.pro
@sock_dbrd.pro
@sock_dbext_dbf.pro
@sock_dbext_ind.pro
;----------------------------------------------------------------

pro sock_dbopen,name,_ref_extra=extra,err=err

err=''

if is_blank(name) then return

url=getenv('ZDBASE')
h=url_parse(url)
host=h.host
path=h.path
if is_blank(host) or is_blank(path) then begin
 err='ZDBASE URL not defined.'
 return
endif

db_ext=['dbh','dbf','dbx']
dbs=name+'.'+db_ext
urls=host+'/'+path+'/'+dbs

;
;------------------------------------------------------------------------
;
; data base common block
;
common db_com,QDB,QITEMS,QDBREC

offset=0                ;byte offset in dbrd record for data base
tot_items=0             ;total number of items all opened data bases
update=0

sflag=is_url(getenv('ZDBASE'))
if sflag then sass=obj_new('sock_assoc')

    dbno=0
    db=bytarr(120)
    if sflag then begin
     sass->set,file=urls[0],data=db
     db=sass->read(0)
    endif else readu,unit,db

    external = db[119] eq 1     ;Is external data rep. being used?
    newdb = db[118] eq 1        ; New db format allowing longwords
    totbytes = newdb ? long(db,105,1) :  fix(db,82,1)
    totbytes = totbytes[0]      ;Make sure is scalar
     nitems=fix(db,80,1) & nitems=nitems[0] ;number of items or fields in file

    if external then begin
     byteorder, totbytes, /NTOHS  &  db[82] = byte(totbytes,0,2)
     byteorder, nitems,/NTOHS   &  db[80] = byte(nitems,0,2)
    endif
    
    items=bytarr(200,nitems)
    if sflag then begin
     sass->set,file=urls[0],data=items,offset=120
     items=sass->read(0)
    endif else readu,unit,items

    if external then begin
        tmp = fix(items[20:27,*],0,4,nitems)
        byteorder,tmp, /ntohs
        items[20,0] = byte(tmp,0,8,nitems)
;
        tmp = fix(items[98:99,*],0,1,nitems)
        byteorder,tmp,/NTOHS
        items[98,0] = byte(tmp,0,2,nitems)
;
        tmp = fix(items[171:178,*],0,4,nitems)
        byteorder,tmp,/NTOHS
        items[171,0] = byte(tmp,0,8,nitems)
	
	if newdb then begin
        tmp = long(items[183:186,*],0,2,nitems)
        byteorder,tmp,/NTOHL
        items[183,0] = byte(tmp,0,8,nitems)
	endif
    endif

;
; add computed information to items ---------------------------
;
    sbyte = newdb ?  long(items[183:186,*],0,nitems)+offset : $ 
                     fix(items[24:25,*],0,nitems)+offset 

    for i=0,nitems-1 do begin
        if newdb then items[187,i]= byte(sbyte[i],0,4)  else $
	              items[171,i] = byte(sbyte[i],0,2)
	            ;starting byte in DBRD record
        items[173,i]=byte(dbno,0,2)     ;data base number
        items[177,i]=byte(i,0,2)        ;item number
    endfor
    offset=offset+totbytes

    head=lonarr(2)
    if sflag then begin
     sass->set,file=urls[1],data=head,offset=0
     head=sass->read(0)
    endif else readu,unitdbf,head

    if external then byteorder, head, /NTOHL
    ;db[96]=unitdbf                      ;unit number of .dbf file
    db[84]=byte(head[0],0,4)            ;number of entries
    db[92]=byte(head[1],0,4)            ;last seqnum used
    db[88]=byte(tot_items,0,2)          ;starting item number for this db
    tot_items=tot_items+nitems          ;new total number of items
    db[90]=byte(tot_items-1,0,2)        ;last item number for this db
    db[104]=update                      ;opened for update
;
; open index file if necessary -----------------------------
;

    index=where(items[28,*] gt 0,nindex)        ;indexed items
    if nindex gt 0 then begin           ;need to open index file.
     
    endif
;
; add to common block ---------------------
;
    if dbno eq 0 then begin
        qdb=db
        qitems=items
    endif else begin
        old=qdb
        qdb=bytarr(120,dbno+1)
        qdb[0,0] = old
        qdb[0,dbno] = db
        old=qitems
        qitems=bytarr(200,tot_items)
        qitems[0,0] = old
        qitems[0,tot_items-nitems] = items
     endelse

if sflag then obj_destroy,sass
return
end
