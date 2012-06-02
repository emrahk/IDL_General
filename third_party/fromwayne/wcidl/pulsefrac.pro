function pulsefrac, flc

a=size(flc)
avgflc=total(flc)/a(1)
mx=max(flc)
mi=min(flc)
ti=total(flc)
ml=mi*a(1)

result=dblarr(4)

result(0)=(mx-mi)/avgflc
result(1)=sqrt(result(0)*result(0)/avgflc + (mx+mi)/(avgflc*avgflc))
result(2)=1.d - ml/ti
result(3)=sqrt(ml*(1+ml/ti)/(ti*ti))

return,result
end

