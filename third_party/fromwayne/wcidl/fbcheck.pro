PRO fbcheck, ph, pca, hxta, hxtb, bkga, bkgb, norenorm=norenorm
   
   pmulti=!p.multi & !p.multi=[0,1,3]
  
   if (keyword_set(norenorm)) then begin 
      fasebin_flc,'pca_ikfasebin.pha',/plot,ph=ph,flc=pca,/noreno
      fasebin_flc,'hxta_ikfasebin.pha',/plot,flc=hxta,/noreno
      fasebin_flc,'hxtb_ikfasebin.pha',/plot,flc=hxtb,/noreno
   endif else begin
      fasebin_flc,'pca_ikfasebin.pha',/plot,ph=ph,flc=pca
      fasebin_flc,'hxta_ikfasebin.pha',/plot,flc=hxta
      fasebin_flc,'hxtb_ikfasebin.pha',/plot,flc=hxtb
   endelse

   !p.multi=pmulti
   
   return
end

