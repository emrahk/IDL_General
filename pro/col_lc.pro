;pro col_lc.idl


filename='l56_3s_60_120.lc'
fxbopen,unit,filename,1,h
fxbread,unit,time,1
fxbread,unit,r,2
fxbclose,unit
mtime=double(min(time))
t=time-mtime


t_ind=0l
;r_tot=dblarr(32l*128l)
ps=dindgen(2047)
hm=0.

while t_ind LT n_elements(t) do begin

 if ((t_ind+32l*128l-1) GT n_elements(t)) then t_ch=0.0 else t_ch=t(t_ind+32l*128l-1)-t(t_ind)
 print,t_ch
 if ((t_ch eq 31.9921875)) then begin
    ;print,t_ind
    fft_f,t,r(t_ind:t_ind+32l*128l-1),f,p,frange=[0.04,64]
    ps=ps+p
    hm=hm+1
    t_ind=t_ind+32l*128l
    endif 
 if ((t_ch NE 31.9921875) AND (t_ch NE 0.0)) then begin
    t_ind=t_ind+32l*128l
    print,t_ind
    while t(t_ind)-t(t_ind-1) LE 0.01 do t_ind=t_ind-1
    print,'whoops  '
    print,t_ind,t(t_ind)
    ;t_ind=t_ind-1
 endif

 if (t_ch eq 0.0) then begin
     t_ind=t_ind+32l*128l
     print,t_ind,n_elements(t)
 endif

endwhile
p_err=ps
p_err_em=ps
save,f,ps,hm,p_err,p_err_em,filename='avfgp_l563s_60_120idl.dat'

end
