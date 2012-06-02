pro morgan_or,rate,part,fre

Tp=5e-3
func=2+(2.*part*rate*Tp*Tp*(sin(!PI*Tp*fre)/(!PI*Tp*fre))^2)
oplot,fre,func
end
