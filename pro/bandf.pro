pro bandf, a, b, eo, en, S, op = op

if not keyword_set(op) then op = 0

lim=(a-b)*eo
en2=findgen(floor(lim))+1.
en1=max(en2)+findgen(1000)+1.

S1=((en1/100.)^a)*exp(-1.*(en1/eo))

S2=(((a-b)*eo/100.))^(a-b)*exp(b-a)*(en2/100.)^b

S=[S2,S1]
en=[en2,en1]

if op then oplot,en,S, line = 2 else plot,en,S,/ylog

end

