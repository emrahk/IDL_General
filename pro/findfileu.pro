function findfileu,dirs,filter,only=only


if NOT keyword_set(only) then only = 0
 
num_dir=n_elements(dirs)

if only then begin
  if num_dir eq 1 then return,findfile(dirs+filter) else begin
    files=findfile(dirs[0]+filter) 
    for i=1,num_dir-1 do files=[files,findfile(dirs[i]+filter)]
    return,files
 endelse
endif else begin
 dir=dirs[0]
 openw,1,'findallfilesgeneral.csh'
 printf,1,'#!/bin/csh'
 printf,1,'set mdir = "'+dir+'"'
 printf,1,'set files = `find ${mdir} -name "'+filter+'" -print`'
 printf,1,'echo $files > found_files.txt'
 close,1

spawn, 'chmod u+x findallfilesgeneral.csh'
spawn, './findallfilesgeneral.csh'

  ;now read those files

allf=strarr(1)
openr,1,'found_files.txt'
readf,1,allf
close,1

spawn, 'rm findallfilesgeneral.csh'
spawn, 'rm found_files.txt'

;now find individual files
 tot_length=strlen(allf(0))  ;one to include white space

if tot_length lt 3 then print,'no files found!' else begin
  s=strpos(allf(0),' ')+1
  if s eq 0 then files=allf else begin
    pos=0
    size=s-1
    files=strmid(allf(0),pos,size)
    pos=size+1
    s = strpos(allf(0),' ',pos)+1
    while s ne 0 do begin
      size=s-pos-1
      files=[files,strmid(allf(0),pos,size)]
      pos=pos+size+1
      s = strpos(allf(0),' ',pos)+1
  endwhile
  files=[files,strmid(allf(0),pos,tot_length-pos)]
 endelse
endelse

 for i=1,num_dir-1 do begin
 dir=dirs[i]
 openw,1,'findallfilesgeneral.csh'
 printf,1,'#!/bin/csh'
 printf,1,'set mdir = "'+dir+'"'
 printf,1,'set files = `find ${mdir} -name "'+filter+'" -print`'
 printf,1,'echo $files > found_files.txt'
 close,1

spawn, 'chmod u+x findallfilesgeneral.csh'
spawn, './findallfilesgeneral.csh'

  ;now read those files

allf=strarr(1)
openr,1,'found_files.txt'
readf,1,allf
close,1

spawn, 'rm findallfilesgeneral.csh'
spawn, 'rm found_files.txt'

;now find individual files
 tot_length=strlen(allf(0))  ;one to include white space

if tot_length lt 3 then print,'no files found!' else begin
  s=strpos(allf(0),' ')+1
  if s eq 0 then files=[files,allf] else begin
    pos=0
    size=s-1
    files=[files,strmid(allf(0),pos,size)]
    pos=size+1
    s = strpos(allf(0),' ',pos)+1
    while s ne 0 do begin
      size=s-pos-1
      files=[files,strmid(allf(0),pos,size)]
      pos=pos+size+1
      s = strpos(allf(0),' ',pos)+1
  endwhile
  files=[files,strmid(allf(0),pos,tot_length-pos)]
endelse

;return,files

endelse

endfor
return,files
endelse

end
