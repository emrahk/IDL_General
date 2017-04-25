;-- Unit test for VSO_PREP 

pro vso_prep_test,file,_ref_extra=extra

if is_blank(file) then begin
 pr_syntax,'vso_prep_test,file'
 return
endif

cd,current=curr
if ~write_dir(curr) then begin
 message,'Needs write access to current directory.',/cont
 return
endif

qsave=!quiet
!quiet=1
message,!stime,/cont
help,/st,!version

message,'Running Test 1 with URL file - '+file,/cont

file_delete,'test1.fits',/quiet
vso_prep,file,ofile='test1.fits',_extra=extra,oprep=o1,err=err,status=status

if valid_fits('test1.fits') and status then begin
 message,'Test 1 succeeded.',/cont
 if obj_valid(o1) then o1->plotman
endif else begin
 message,'Test 1 failed.',/cont
 java_debug
endelse

print,'_______________________________________________________________'
print,''

local=file_basename(file)
message,'Running Test 2 with local file - '+local,/cont
file_delete,'test2.fits',/quiet

chk=loc_file(local,count=count)
if count eq 0 then begin
 sock_copy,file,local=dlocal,err=err
 if is_blank(err) then chk=loc_file(dlocal,count=count)
 if count gt 0 then local=dlocal 
endif

if count eq 0 then begin
 message,'Local file '+local+' not found',/cont
 message,'Test 2 failed.',/cont
 return
endif

if ~valid_fits(local) then begin
 message,'Local file '+local+' not a valid FITS file',/cont
 message,'Test 2 failed.',/cont
 return
endif

vso_prep,local,ofile='test2.fits',_extra=extra,oprep=o2,status=status

if valid_fits('test2.fits') and status then begin
 message,'Test 2 succeeded.',/cont
 if obj_valid(o2) then o2->plotman
endif else begin
 message,'Test 2 failed.',/cont
 java_debug 
endelse

!quiet=qsave

return & end
