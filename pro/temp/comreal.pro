pro comreal

rddata,'se22x657z190t.dat',9,aryc1,nskip=3
rddata,'se22x657z160t.dat',9,aryc2,nskip=3
rddata,'se22x657z130t.dat',9,aryc3,nskip=3
rddata,'se22x657z90t.dat',9,aryc4,nskip=3
rddata,'se22x657z190t.dat',9,arya1,nskip=3
rddata,'se22x657z160t.dat',9,arya2,nskip=3
rddata,'se22x657z130t.dat',9,arya3,nskip=3
rddata,'se22x657z90t.dat',9,arya4,nskip=3

!P.MULTI=[0,1,2]

plot,aryc1(1,*),aryc1(8,*),psym=1
oplot,aryc2(1,*),aryc2(8,*),psym=4
oplot,aryc3(1,*),aryc3(8,*),psym=5
oplot,aryc4(1,*),aryc4(8,*),psym=6

plot,arya1(1,*),arya1(4,*),psym=1
oplot,arya2(1,*),arya2(4,*),psym=4
oplot,arya3(1,*),arya3(4,*),psym=5
oplot,arya4(1,*),arya4(4,*),psym=6

end

