pro wemean,ar,are,mean,error

;we=1./double(are)^2
;mean=total(we*ar)/total(we)
;error=1./sqrt(total(we))
qq=total(ar/are^2)
ee=total(1./are^2)
mean=qq/ee
error=sqrt(1./ee)

end
