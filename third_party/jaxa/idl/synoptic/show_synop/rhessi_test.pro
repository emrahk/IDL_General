
pro rhessi_test,_ref_extra=extra

message,'Prepping RHESSI image...',/cont
prepped_hsi_file='RHESSI_prep_test.fits'
vso_prep,inst='rhessi',ofile=prepped_hsi_file,status=status,_extra=extra,err=err,$
  oprep=o,im_time_interval=['21-apr-2002 01:15', '21-apr-2002 01:16'],image_alg='clean'

if is_string(err) then message,err,/cont
if ~exist(status) then return
if status then begin
 message,'Prepped RHESSI image written to '+prepped_hsi_file,/cont
 if obj_valid(o) then o->plotman
endif else begin
 message,'Prepping RHESSI image failed.',/cont
 java_debug
endelse

return
end


