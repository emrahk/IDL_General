pro gfunct, X, A, F, pder
   
    bx=exp(-X/A(1))
    F=A(0) * bx

    if N_PARAMS() GE 3 then $
        pder=[[bx],[-A(0) * X * bx / (A(1))^2]]

print,F
end
