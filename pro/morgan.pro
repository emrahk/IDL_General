pro morgan, X, A, F, pder


rate=76.
F=2+(2.*A(0)*rate*A(1)*A(1)*(sin(!PI*A(1)*X)/(!PI*A(1)*X))^2)
der1=(F-2)/A(0)
der2=(F-2)*2/A(1)+(4.*A(0)*rate/(!PI*!PI*X*X*A(1)))*((!PI*A(1)*X/2)*$
      sin(2*!PI*A(1)*X)-(sin(!PI*A(1)*X))^2)

if N_PARAMS() GE 4 THEN pder=[[der1],[der2]]

end
