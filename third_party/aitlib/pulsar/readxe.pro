
filename = 'goodxe1_gx0'

; open the file
fxbopen, unit, filename, 1, header
        
; read the event time
fxbread, unit, time, 'Time'

; read in the event pulse height
fxbread, unit, event, 'Event'
energy = event(2,*)

hist = histogram(energy,min=0,max=255,binsize=1)
x = findgen(256)
plot, x, hist, psym = 10
