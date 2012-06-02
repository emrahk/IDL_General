function detmass, det

mass=[944.9,959.0,959.6,958.0,965.8,965.1,960.4,939.9,956.2,956.3,956.0,$
      956.3,916.1,928.5,956.6,953.4,930.0,950.0,955.2]
  if det le 18 then return,mass(det)
  if det eq 19 then return,(mass(0)+mass(1))/2
  if det eq 20 then return,(mass(0)+mass(2))/2
  if det eq 21 then return,(mass(0)+mass(3))/2
  if det eq 22 then return,(mass(0)+mass(4))/2
  if det eq 23 then return,(mass(0)+mass(5))/2
  if det eq 24 then return,(mass(0)+mass(6))/2
  if det eq 25 then return,(mass(1)+mass(2))/2
  if det eq 26 then return,(mass(1)+mass(6))/2
  if det eq 27 then return,(mass(1)+mass(7))/2
  if det eq 28 then return,(mass(1)+mass(8))/2
  if det eq 29 then return,(mass(1)+mass(9))/2
  if det eq 30 then return,(mass(2)+mass(3))/2
  if det eq 31 then return,(mass(2)+mass(9))/2
  if det eq 32 then return,(mass(2)+mass(10))/2
  if det eq 33 then return,(mass(2)+mass(11))/2
  if det eq 34 then return,(mass(3)+mass(4))/2
  if det eq 35 then return,(mass(11)+mass(4))/2
  if det eq 36 then return,(mass(12)+mass(4))/2
  if det eq 37 then return,(mass(13)+mass(4))/2
  if det eq 38 then return,(mass(4)+mass(5))/2
  if det eq 39 then return,(mass(4)+mass(13))/2
  if det eq 40 then return,(mass(4)+mass(14))/2
  if det eq 41 then return,(mass(4)+mass(15))/2
  if det eq 42 then return,(mass(5)+mass(6))/2
  if det eq 43 then return,(mass(5)+mass(15))/2
  if det eq 44 then return,(mass(5)+mass(16))/2
  if det eq 45 then return,(mass(5)+mass(17))/2
  if det eq 46 then return,(mass(6)+mass(7))/2
  if det eq 47 then return,(mass(6)+mass(17))/2
  if det eq 48 then return,(mass(6)+mass(18))/2
  if det eq 49 then return,(mass(7)+mass(8))/2
  if det eq 50 then return,(mass(7)+mass(18))/2
  if det eq 51 then return,(mass(8)+mass(9))/2
  if det eq 52 then return,(mass(9)+mass(10))/2
  if det eq 53 then return,(mass(10)+mass(11))/2
  if det eq 54 then return,(mass(11)+mass(12))/2
  if det eq 55 then return,(mass(12)+mass(13))/2
  if det eq 56 then return,(mass(13)+mass(14))/2
  if det eq 57 then return,(mass(14)+mass(15))/2
  if det eq 58 then return,(mass(15)+mass(16))/2
  if det eq 59 then return,(mass(16)+mass(17))/2
  if det eq 60 then return,(mass(17)+mass(18))/2

end
