pro vcr, X,A,F
    
    So=60.*2.0*0.001/(3.1^2)
    I_pr=[.0108,.005,.0014,0.,0.,0.,0.,0.,0.,0.,0.]
    ;Rds=Rds,A(1)=M/L
    G=6.67e-8
    kpc=3.086e21
    ;in terms of kpc
    Rdg=2.
    Kg=fltarr(11)
    Ks=fltarr(11)
    vcs=fltarr(11)
    for i=0,10 do $
Kg(i)=beseli(X(i)/(2.*Rdg),0)*beselk0(X(i)/(2.*Rdg))-beseli(X(i)/(2.*Rdg),1)*$
             beselk1(X(i)/(2.*Rdg))
    print,Kg
    vcg=sqrt(!PI*So*G*X^2*Kg/Rdg)
    vcgr=vcg*sqrt(kpc)/1.e5
    ;vcgr in km/sec
    print,'vcgr',vcgr
    Rds=0.5
    for i=0,10 do $
Ks(i)=beseli(X(i)/(2.*Rds),0)*beselk0(X(i)/(2.*Rds))-beseli(X(i)/(2.*Rds),1)$
             *beselk1(X(i)/(2.*Rds))
    
    for i=0,10 do vcs(i)=sqrt(!PI*G*I_pr(i)*X(i)^2*A(0)*Ks(i)/Rds)
    print,vcs
    vcsr=vcs*sqrt(kpc)/1.e5

    ;F=vcgr+vcsr
    F=sqrt((vcgr)^2+(vcsr)^2)
    print,F
     
    vrot=[2.0,14.0,28.0,34.,40.,44.0,46.0,47.5,50.0,48.0,45.0]
    set_plot,'ps'
    plot,X,vrot,psym=2
    oplot,X,F,psym=1
    device,/close
end        
