
pro rpc_upload,file,_ref_extra=extra,err=err

err=''
if is_blank(file) then begin
 err='Invalid input filename.'
 mprint,err
 return
endif

if ~file_test(file,/read) then begin
 err='Invalid input filename.'
 mprint,err
 return
endif

r=rpc()
if obj_valid(r) then r->upload,file,_extra=extra,err=err
obj_destroy,r
return
end
