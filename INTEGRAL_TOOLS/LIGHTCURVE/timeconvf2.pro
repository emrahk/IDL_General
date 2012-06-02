function timeconvf2,nums,cost=cost

if keyword_set(cst) then print,oha
if (NOT keyword_set(cost)) then cost=88134052.1883d

;this program is good enough for now, but needs an update 
;later when there is time. Best is to get a multiplying factor
;and a constant for every month and rearrange the program


time1=nums(1)*4096.d
time2=(nums(2)/16.d)+(nums(3)/(65536.d*16.d))

tijd=(time1/86400.d)+(time2/86400.d)
fr=tijd-floor(tijd)

tijd=double((time1/86400.d)+(time2/86400.d))*1.0000005248d
fr=tijd-floor(tijd)

tijdf=fr+.0700485d
tijd=floor(tijd)+tijdf+1020.d

tijs=(time1+time2)*1.0000005248d
tijs=tijs+cost
;print,cost
return,tijs
end
