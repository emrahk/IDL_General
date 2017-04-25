pro ssw_limit_colors,rr,gg,bb, noload=noload, nbins=nbins, help=help, $
    lower=lower
;
;+
;   Name: ssw_limit_colors
;
;   Purpose: ct for 'green/yellow/red' limit visualizations (AP,KP, EGSE..)
;
;   Input Parameters:
;      rr,gg,bb - optional user ct r,g,b (256 elements each) 
;                 default starts with the RSI Table 13 (rainbow) for G/Y/R
;   
;   Output Paramters:
;      rr,gg,bb - optionally returned if /NOLOAD requested (may clobber)
;  
;   Keyword Paramters:
;      noload - if set, just return 
;      help - if set, display a color bar (ala linecolors.pro)
;
;   Side Effects:
;      if /NOLOAD not set, will clobber lowest 10 CT values
;
;
;-
ptemp=!d.name

g2r=['00FF00','55FF00','88FF00','CCFF00','FFFF00','FFDD00',$
     'FF8800','FF5500','FF3300','FF0000']

rr=intarr(10)
gg=intarr(10)
bb=intarr(10)

reads,[strmid(g2r,0,2),strmid(g2r,2,2),strmid(g2r,4,2)], $
            rr,gg,bb,format='(z2.2)' 

tvlct,r,g,b,/get
if not keyword_set(lower) then lower=1
r(lower)=rr
g(lower)=gg
b(lower)=bb
used=n_elements(rr) 

if not keyword_set(noload) then begin  
   tvlct,r,g,b
   if keyword_set(help) and $ 
      ( (!d.name eq 'X') or (!d.name eq 'WIN') ) then begin 
           bar=rebin(indgen(used)+lower,32*(used+lower),(used+lower)*4,/sample)
   wtemp=!d.window
   wdef,zz,/ur,image=bar
   tv,bar                                                   
   xyouts,indgen(used)*32+8, 32,strtrim(indgen(used)+lower,2),/device,size=1.5,charthick=2.
   if wtemp ne -1 then wset,wtemp

         
   endif
endif

return
end
    


