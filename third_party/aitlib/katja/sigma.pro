FUNCTION sigma,arr

n=n_elements(arr)  
avg=total(arr)/n
return,sqrt(total((arr-avg)^2.)/(n-1.))

END 
