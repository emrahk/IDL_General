
pro fixup, b, freq, p, p_err

nb = n_elements(b)

for i = 0,nb-1 do begin
  oplot, [freq(b(i)),freq(b(i))],[1.e-10,p(b(i))+p_err(b(i))]
endfor

end
