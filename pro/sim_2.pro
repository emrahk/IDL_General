x_rn=randomu(s,n_elements(r))
r_cor=fltarr(n_elements(r))
av=avg(r)
for i=0,n_elements(r)-1 do begin
if (x_rn(i)*r(i)/av) gt (1.-0.000954439) then r_cor(i)=1024.
if (((x_rn(i)*r(i)/av) lt (1.-0.000954439)) and ((x_rn(i)*r(i)/av) gt (1.-0.0427255))) then r_cor(i)=512.
if (x_rn(i)*r(i)/av) lt (1.-0.0427255) then r_cor(i)=0.
endfor
end
