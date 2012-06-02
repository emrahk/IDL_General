PRO tcreversect,nr
      
   ;; reverse color table
   
   IF keyword_set(nr) THEN loadct,nr
   
   TVLCT, r_orig, g_orig, b_orig, /GET
   
   
   cbot=0
   ncolors=n_elements(r_orig)
   
   l = lindgen(ncolors) + cbot
   r_orig[cbot] = reverse(r_orig[l])
   g_orig[cbot] = reverse(g_orig[l])
   b_orig[cbot] = reverse(b_orig[l])
         
   TVLCT, r_orig, g_orig, b_orig
   
END
