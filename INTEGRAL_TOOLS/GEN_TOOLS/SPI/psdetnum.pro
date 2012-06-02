function psdetnum, det1, det2

  if det1 gt det2 then begin
    detx=det2
    det2=det1
    det1=detx
  endif

  if ((det1 eq 0) and (det2 eq 1)) then return,19
  if ((det1 eq 0) and (det2 eq 2)) then return,20
  if ((det1 eq 0) and (det2 eq 3)) then return,21
  if ((det1 eq 0) and (det2 eq 4)) then return,22
  if ((det1 eq 0) and (det2 eq 5)) then return,23
  if ((det1 eq 0) and (det2 eq 6)) then return,24 
  if ((det1 eq 1) and (det2 eq 2)) then return,25
  if ((det1 eq 1) and (det2 eq 6)) then return,26
  if ((det1 eq 1) and (det2 eq 7)) then return,27
  if ((det1 eq 1) and (det2 eq 8)) then return,28
  if ((det1 eq 1) and (det2 eq 9)) then return,29
  if ((det1 eq 2) and (det2 eq 3)) then return,30
  if ((det1 eq 2) and (det2 eq 9)) then return,31
  if ((det1 eq 2) and (det2 eq 10)) then return,32
  if ((det1 eq 2) and (det2 eq 11)) then return,33
  if ((det1 eq 3) and (det2 eq 4)) then return,34
  if ((det1 eq 3) and (det2 eq 11)) then return,35
  if ((det1 eq 3) and (det2 eq 12)) then return,36
  if ((det1 eq 3) and (det2 eq 13)) then return,37
  if ((det1 eq 4) and (det2 eq 5)) then return,38
  if ((det1 eq 4) and (det2 eq 13)) then return,39
  if ((det1 eq 4) and (det2 eq 14)) then return,40
  if ((det1 eq 4) and (det2 eq 15)) then return,41
  if ((det1 eq 5) and (det2 eq 6)) then return,42
  if ((det1 eq 5) and (det2 eq 15)) then return,43
  if ((det1 eq 5) and (det2 eq 16)) then return,44
  if ((det1 eq 5) and (det2 eq 17)) then return,45
  if ((det1 eq 6) and (det2 eq 7)) then return,46
  if ((det1 eq 6) and (det2 eq 17)) then return,47
  if ((det1 eq 6) and (det2 eq 18)) then return,48
  if ((det1 eq 7) and (det2 eq 8)) then return,49
  if ((det1 eq 7) and (det2 eq 18)) then return,50
  if ((det1 eq 8) and (det2 eq 9)) then return,51
  if ((det1 eq 9) and (det2 eq 10)) then return,52
  if ((det1 eq 10) and (det2 eq 11)) then return,53
  if ((det1 eq 11) and (det2 eq 12)) then return,54 
  if ((det1 eq 12) and (det2 eq 13)) then return,55
  if ((det1 eq 13) and (det2 eq 14)) then return,56
  if ((det1 eq 14) and (det2 eq 15)) then return,57
  if ((det1 eq 15) and (det2 eq 16)) then return,58
  if ((det1 eq 16) and (det2 eq 17)) then return,59
  if ((det1 eq 17) and (det2 eq 18)) then return,60

end
