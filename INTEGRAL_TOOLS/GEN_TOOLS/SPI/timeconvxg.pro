pro timeconvxg,nums

;this program is good enough for now, but needs an update 
;later when there is time. Best is to get a multiplying factor
;and a constant for every month and rearrange the program

time1=nums(1)*4096.d
time2=(nums(2)/16.d)+(nums(3)/(65536.d*16.d))

tijd=(time1/86400.d)+(time2/86400.d)
fr=tijd-floor(tijd)
print,fr

tijd=double((time1/86400.d)+(time2/86400.d))*1.0000005248d
fr=tijd-floor(tijd)
print,fr
tijdf=fr+.0700485d
tijd=floor(tijd)+tijdf+1020.d

;fr=double(time2-floor(time2))
;tijsf=fr+0.44865d
;print,time1,time2,floor(time2),tijsf
;tijs=floor(time2)+tijsf+88134055.d
;tijs=double(tijs+time1)

;tijs=tijd*86400.d
tijs=(time1+time2)*1.0000005248d
tijs=tijs+88134052.1883d

print,format='(A6,1D0.0,A4)','IJS=',tijs,' (s)'
print,format='(A6,1D0.0,A4)','IJD=',tijd,' (d)'
print,format='(A6,1D0.0,A4)','MJD=',tijd+51544.,' (d)'
print,'warning, the time resolution is good to ms level'
end
