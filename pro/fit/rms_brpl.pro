pro rms_brpl,l,fb,i,rm

rm1=l*fb
c=l*fb^(-i)
int=rm1-(c*fb^(i+1))/(i+1)
rm=sqrt(int)

end
