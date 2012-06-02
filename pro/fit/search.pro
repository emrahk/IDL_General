pro search,fs,fe,f,p,pe

i=0
while f(i) lt fs do i=i+1
j=0
while f(j) lt fe do j=j+1

fin=f(i:j)
pin=p(i:j)
pein=pe(i:j)

level=0.0119
ind=-1.353

ploterror,fin,pin,pein,/xlog,/ylog,/nohat,yrange=[min(pin)/10.,max(pin)*10.],/ystyle
oplot,fin,level*fin^(ind)
STOP


;pavg=avg(pin)
d = (pin-level*fin^(ind))/pein
qp = where(d gt 2.0)

STOP
IF total(qp) ne -1 THEN BEGIN
        print, 'Possible features at ', fin(qp)

        ; try fitting a Lorentzian + power law at each point
        FOR i=0, n_elements(qp)-1 DO BEGIN
          ; make guess based on frequency of high point
          frange = 50.0*(fin(1)-fin(0))
          nu0 = fin(qp(i))-5*frange & nu1 = fin(qp(i))+frange
          q = where(fin ge nu0 and fin le nu1)
          pavg = avg(pin(q))

a1=[0.012,-1.35]
a2=[0.001,3,fin(qp(i))]

STOP
fit_pl_1l,pin(q),pein(q),fin(q),a1,a2,res,guess

;chisq = total( ((pin(q)-yfit)/pein(q))^2 )
          ;chisq0 = total( ((pin(q)-pavg)/pein(q))^2 )
nq = n_elements(q)
          ;fr = (chisq/float(nq-4))/(chisq0/float(nq-1))
          ;ftest = f_pdf(fr, nq-4, nq-1)
          ;print, '  F-test = ', ftest
 
         STOP

print,res
ENDFOR

ENDIF

END
