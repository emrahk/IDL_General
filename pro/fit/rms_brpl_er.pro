pro rms_brpl_er,l,fb,i,dl,df,di,rm,rme

rm1=l*fb
c=l*fb^(-i)
int=rm1-(c*fb^(i+1))/(i+1)
rm=sqrt(int)

rme=(fb*(i/(i+1))*0.5/rm)*dl+(l*(i/(i+1))*0.5/rm)*df+$
(l*fb*(i+1)^(-2)*0.5/rm)*di

end
