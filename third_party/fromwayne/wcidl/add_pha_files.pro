pro add_pha_files, infile, outfile

f=''
cnt=0

openr,unit,infile,/get_lun
while (eof(unit) ne 1) do begin
   readf,unit,f
   cnt=cnt+1
endwhile
free_lun,unit

f=strarr(cnt)
openr,unit,infile,/get_lun
readf,unit,f
free_lun,unit

add_pha,f,outfile,ad=1

return
end
