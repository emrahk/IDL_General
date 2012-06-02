pro plot_bg_asc,file

;  ***********************************************************************
;  Plot a set of 4 backgrounds given a .asc file saved from get_accum or xs
;  ***********************************************************************


FIRST = 25     ;position within string (0,1,2,...) where livetime starts

!p.multi=[0,2,2]
!x.style=1
!y.style=1

if (n_params() eq 0) then begin
  print,'USAGE:  plot_bg_asc,''filename'' '
  return
endif

openr,1,file

;Read off 5 lines and throw them away
s=strarr(1)
for i=0,4 do readf,1,s

a_counts=fltarr(3,4,256)
a_livetime=fltarr(3,4)
temp=fltarr(256)
for i=0,2 do begin    ;one loop for each cluster position
  readf,1,s             ;throw away the first line of text
  print,s
  for j=0,3 do begin    ;one loop for each detector
    readf,1,s             ;get the line w/livetime info and parse it
    print,s
    last = strpos(s,'SEC')
    length = last(0) - FIRST - 1
    ltimestr = strmid(s,FIRST,length)
    a_livetime(i,j)=float(ltimestr)
    readf,1,temp
    a_counts(i,j,*) = temp
  endfor
endfor

;Add the data and plot it
rate = fltarr(4,256)
for i=0,3 do $
  rate(i,*) = (a_counts(0,i,*)+a_counts(1,i,*)+a_counts(2,i,*)) /    $
                  (a_livetime(0,i)+a_livetime(1,i)+a_livetime(2,i))

x=indgen(256)
for i=0,3 do begin 
  plot,x,rate(i,*),psym=10,yrange=[0.0,0.14], $
     xtitle='channel',ytitle='cts/sec', $
     title='Detector '+strtrim(string(i+1),2)+' total background'
endfor

close,1
return
end
