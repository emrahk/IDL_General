pro vcr2, X,A,F
    
    I_pr=0.001556
    ;A(0)=Rds,A(1)=M/L
    G=6.67e-8
    kpc=3.086e21
    ;in terms of kpc
    Rdg=2.78
    Kg(*)=beseli(X(*)/(2.*Rdg),0)*beselk0(X(*)/(2.*Rdg))$
    -beseli(X(*)/(2.*Rdg),1)*beselk1(X(*)/(2.*Rdg))
    print,Kg
    vcg(*)=sqrt(!PI*I_pr*G*X(*)^2*Kg(*)/Rdg)
    vcgr(*)=vcg(*)*sqrt(kpc)/1.e5
    ;vcgr in km/sec
    print,'vcgr',vcgr
   
    Ks(*)=beseli(X(*)/(2.*A(0)),0)*beselk0(X(*)/(2.*A(0)))$
    -beseli(X(*)/(2.*A(0)),1)*beselk1(X(*)/(2.*A(0)))
    vcs(*)=sqrt(!PI*G*I_pr*X(*)^2*A(1)*Ks(*)/A(0))
    vcsr(*)=vcs(*)*sqrt(kpc)/1.e5

    F(*)=sqrt(vcgr(*)^2+vcsr(*)^2)

    print,F
   


end        
