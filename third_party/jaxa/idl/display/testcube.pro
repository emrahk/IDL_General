function testcube, n, nx, ny, labels=labels, gif=gif, outfiles=outfiles
;+
;   Name: testcube
; 
;   Purpose: return test data cube (shifted dist) - optionally make gif files
;
;   Input (all optional):
;      n  - number of 'images'  - default=5         
;      nx - X size of 'images'  - default=256
;      ny - Y size of 'images'  - default=nx 
;
;   Keyword Parameters:
;      gif (input) - if set, write to sequence of GIF files in current directory
;      outfiles (output) - output file names (only if /gif set)
;      labels (output) - text array (strarr(n)) - image labels (strarr(n))
;
;   Calling Sequence:
;     cube=testcube( [n, nx, labels=labels] )
;
;   Calling Examples:
;      cube1 = testcube()           ; default = 256x256x5
;      cube2 = testcube(10,512)     ;           512x512x10
;
;   Usage Example (xstepper test)
;      IDL> cubex=testcube(10,512,labels=labels)      
;      IDL> xstepper,cubex,labels
;
;   History:
;      Circa  1-jan-1992 - S.L.Freeland - for 3D SW testing
;             5-mar-1997 - S.L.Freeland - added LABELS output & documentation
;                          add /GIF and OUTFILES (for WWW movie testing)
;             13-Aug-2003, William Thompson
;                       Use SSW_WRITE_GIF instead of WRITE_GIF
;-
if n_elements(n) eq 0 then n=5
if n_elements(nx) eq 0 then nx=256
if n_elements(ny) eq 0 then ny=nx
im0=congrid(bytscl(dist(nx)),nx,ny)
shifter=nx/n
ocube=bytarr(nx,ny,n)
for i=0,n-1 do ocube(0,0,i)=shift(im0,shifter*i,shifter*i)
imgn=string(lindgen(n),format='(i2.2)')
labels='Image #'+ imgn
outfiles='Testcube_'+imgn+'.gif'

if keyword_set(gif) then for i=0,n-1 do ssw_write_gif,outfiles(i),ocube(*,*,i)

return,ocube
end
