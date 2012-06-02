pro rebin3sig,  spin, en, spout, err = err,  siglim = siglim


  if NOT keyword_set(err) then err = sqrt(float(spin))
  if NOT keyword_set(siglim) then siglim = 3.

  ;this version does not hadle errors other than Poisson for now.

  spout = [0.]
  en = [0.]

  k = 0L
  m = 0L
  nel = n_elements(spin)

while k lt nel do begin

  m = k
  totc = float(spin[m])
  tote = err[m]
  if totc le 0 then sig = 0. else sig = totc/tote

  while sig lt siglim do begin
      m = m+1L
      if m eq nel then sig = siglim else begin
         totc = totc+spin[m]
         tote = sqrt(totc)
         if totc le 0 then sig = 0. else sig = totc/tote
      endelse
    endwhile
  spout =  [spout, [totc/(m-k+1.), tote/(m-k+1.)]]
  en = [en, [k, m]]
  k = m+1
endwhile

spout = spout(1:n_elements(spout)-1L)
en = en(1:n_elements(en)-1L)

spout = reform(spout, 2, n_elements(spout)/2)
en = reform(en, 2, n_elements(en)/2)

end
