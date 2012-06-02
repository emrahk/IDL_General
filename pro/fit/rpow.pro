PRO rpow, filebase
  rebin = 8 ; best to rebin by a power of 2

  outlun = 18 & close, outlun
  openw, outlun, outputfilename

  errmsg = ''
  npowspec = 1
  no_more = 0
  REPEAT BEGIN

;      n = n_elements(freq)+1
;      f = rebin([freq, 2.0], n/rebin)
;      p = rebin([powspec, 2.0], n/rebin)
;      e = sqrt(rebin([err^2, 4.0], n/rebin)/float(rebin))

      n2 = n_elements(f)
      f = f(0:n2-2)
      p = p(0:n2-2)
      e = e(0:n2-2)


      ploterr, f, p, e

      ; find points which lie above the average
      g = where(f gt 500.0)
      pavg = avg(p(g))
      d = (p-pavg)/e
      qp = where(d gt 3.0)

      IF total(qp) ne -1 THEN BEGIN
        print, 'Possible features at ', f(qp)

        ; try fitting a Lorentzian + constant at each point
        FOR i=0, n_elements(qp)-1 DO BEGIN
          ; make guess based on frequency of high point
          frange = 10.0*(f(1)-f(0))
          nu0 = f(qp(i))-frange & nu1 = f(qp(i))+frange
          q = where(f ge nu0 and f le nu1)
          pavg = avg(p(q))


          nq = n_elements(q)
          fr = (chisq/float(nq-4))/(chisq0/float(nq-1))
          ftest = f_pdf(fr, nq-4, nq-1)
          print, 'Chisq=', chisq, '  chisq0=', chisq0,'  ndata=', nq
          print, '  F-test = ', ftest
          ploterr, f(q), p(q), e(q), psym=4
          oplot, f(q), yfit
          STOP
          IF ftest le 0.15 THEN BEGIN
            printf, outlun, 'Best fit =', parm
            printf, outlun, 'Errors =  ', sigma
            printf, outlun, 'Chisq=', chisq, '  chisq0=', chisq0,'  ndata=', nq
            printf, outlun, '  F-test = ', ftest
          ENDIF
        ENDFOR
      END ELSE BEGIN
        print, 'No significant peaks for this power spectrum.'
      END
      npowspec = npowspec +1
    END ELSE BEGIN
      print, errmsg
      no_more = 1
    END
    fxbclose, lun
  END UNTIL no_more
  print, 'Processed ', npowspec-1,' power spectra.'
  close, outlun
END
