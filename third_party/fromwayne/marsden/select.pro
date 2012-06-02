pro select,disp,det,num_dets,int,rates,lvtme,a_lvtme,num_chns,num_spec,$
           rt,ltime,trt,opt
;***********************************************************************
; Program does the user choices
; Input variables are:
;	disp...............1 idf(0) or accum(1) display option
;        det...............detector choice
;   num_dets...............number of detectors
;        int...............integration #
;      rates...............array of rates
;      lvtme...............livetime array/ single IDF
;    a_lvtme...............   "       "  / accumulated IDFS
;   num_chns...............number of detector channels
;   num_spec...............number of spectra (integrations)/IDF
;        opt...............erientation/data option
;        sig...............sigma for netoff/channel
; Output varables are:
;         rt...............rates to plot
;      ltime...............livetime string
;      trate...............total count rate in a detector + error
; DISCLAIMER: This program is really ugly - I'm sorry. It's a 
;             masterpice of programming redundancy. It's a masterpiece
;             of programming redundancy.
; First do common block:
;***************************************************************************
common netoff,sig
;***************************************************************************
; First do single detector, single idf:
;***************************************************************************
sz = size(rates)
if (sz(0) eq 3)then prs = 1 else prs = 0
a_lvtme_save = a_lvtme
if (prs)then a_lvtme = reform(temporary(a_lvtme(*,*,int-1)))
if (det gt 0 and det le num_dets)then begin
   if(disp eq 0)then begin
      if (num_spec gt 1)then rt = rates(det-1,int-1,*) $
      else rt = rates(det-1,0,*)
      if (opt gt 2)then begin
         if (int ge 1)then ltime = lvtme(opt-3,det-1,int-1) else $
                           ltime = lvtme(opt-3,det-1,*)
      endif else begin
         if (num_spec gt 1)then begin
            a = lvtme(0,det-1,int-1) ne 0.
            b = lvtme(1,det-1,int-1) ne 0.
            ab = [a,b]
            if (opt eq 1)then begin
               ltime = lvtme(2,det-1,int-1)
            endif else begin
               if (total(ab) ne 0.)then $
               ltime = total(lvtme(0:1,det-1,int-1))/total(ab)
            endelse
         endif else begin
            a = lvtme(0,det-1,*) ne 0.
            b = lvtme(1,det-1,*) ne 0.
            ab = [a,b]
            if (opt eq 1)then begin
               ltime = lvtme(2,det-1,*)
            endif else begin
               if (total(ab) ne 0.)then $
               ltime = total(lvtme(0:1,det-1,*))/float(total(ab))
            endelse
         endelse
      endelse
;*******************************************************************************
; Now single detector, accum idfs
;*******************************************************************************
   endif else begin  
      if (ks(prs) eq 0)then begin
         rt = rates(det-1,*) 
      endif else begin
         rt = reform(rates(det-1,int-1,*))
      endelse
      if (opt gt 2)then begin
         ltime = a_lvtme(opt-3,det-1)
      endif else begin
         a = a_lvtme(0,det-1) ne 0.
         b = a_lvtme(1,det-1) ne 0.
         ab = [a,b]
         if (opt eq 1)then begin
            ltime = a_lvtme(2,det-1) 
         endif else begin
            if (total(ab) ne 0.)then $ 
            ltime = total(a_lvtme(0:1,det-1))/float(total(ab)) $
            else ltime = 0.
         endelse
      endelse
   endelse
endif
;***************************************************************************
; Now do sum detectors, single idf
;***************************************************************************
if (det eq num_dets + 1 and disp eq 0)then begin
   rt = fltarr(num_chns)
   if(num_spec gt 1)then begin
      if (opt gt 2)then begin
         on = 0
         on = reform(lvtme(opt-3,*,int-1) ne 0.,num_dets)
         r_ = reform(rates(*,int-1,*),num_dets,num_chns)
         t = replicate(1.,num_dets)
         if (total(on) ne 0.)then begin
            rt = t#r_
            ltime = total(lvtme(opt-3,*,int-1))/float(total(on))
         endif 
      endif else begin     
         on = intarr(3,num_dets)
         for i = 0,num_dets-1 do begin
          for j = 0,2 do begin
           on(j,i) = lvtme(j,i,int-1) ne 0.   
          endfor
         endfor
         td_on = float(total(on(2,*)))      
         td_off = float(total(on(0:1,*)))
         if (opt eq 1)then begin
            if (td_on ne 0.)then ltime = total(lvtme(2,*,int-1))/td_on
         endif else begin
            if (td_off ne 0.) then ltime = total(lvtme(0:1,*,int-1))/td_off
         endelse
         r = reform(rates(*,int-1,*),num_dets,num_chns)
         t = replicate(1.,num_dets)
         rt = t#r
      endelse       
   endif else begin
      if (opt gt 2)then begin
        on = 0 
        on = reform(lvtme(opt-3,*,0) ne 0.,num_dets)          
         r_ = reform(rates(*,*,*),num_dets,num_chns)
         t = replicate(1.,num_dets)
         if (total(on) ne 0.)then begin
            rt = t#r_
            ltime = total(lvtme(opt-3,*,*))/float(total(on))
         endif
      endif else begin
         on = intarr(3,num_dets)
         for i = 0,num_dets-1 do begin
          for j = 0,2 do begin
           on(j,i) = lvtme(j,i,0) ne 0.   
          endfor
         endfor
         td_on = float(total(on(2,*)))      
         td_off = float(total(on(0:1,*)))
         if (opt eq 1)then begin
            if (td_on ne 0.)then ltime = total(lvtme(2,*,0))/td_on
         endif else begin
            if (td_off ne 0.) then ltime = total(lvtme(0:1,*,0))/td_off
         endelse
         r = reform(rates(*,0,*),num_dets,num_chns)
         t = replicate(1.,num_dets)
         rt = t#r
      endelse                 
   endelse
endif
;***********************************************************************
; Do sum detectors, accumulated idfs
;***********************************************************************
if (det eq num_dets + 1 and disp eq 1)then begin
   rt = fltarr(num_chns)
   if(num_spec gt 1)then begin
      if (opt gt 2)then begin
         on = 0
         on = reform(a_lvtme(opt-3,*) ne 0.,num_dets)
         t = replicate(1.,num_dets)
         if (total(on) ne 0.)then begin
            if (ks(prs) eq 0)then rt = t#rates $
            else rt = t#reform(rates(*,int-1,*))
            ltime = total(a_lvtme(opt-3,*))/float(total(on))
         endif 
      endif else begin     
         on = intarr(3,num_dets)
         for i = 0,num_dets-1 do begin
          for j = 0,2 do begin
           on(j,i) = a_lvtme(j,i) ne 0.   
          endfor
         endfor
         td_on = float(total(on(2,*)))      
         td_off = float(total(on(0:1,*)))
         if (opt eq 1)then begin
            if (td_on ne 0.)then ltime = total(a_lvtme(2,*))/td_on
         endif else begin
            if (td_off ne 0.) then ltime = total(a_lvtme(0:1,*))/td_off
         endelse
         t = replicate(1.,num_dets)
         if (ks(prs) eq 0)then rt = t#rates $
         else rt = t#reform(rates(*,int-1,*))
      endelse       
   endif else begin
      if (opt gt 2)then begin
         on = 0
         on = reform(a_lvtme(opt-3,*) ne 0.,num_dets)          
         t = replicate(1.,num_dets)
         if (total(on) ne 0.)then begin
            if (ks(prs) eq 0)then rt = t#rates $
            else rt = t#reform(rates(*,int-1,*))
            ltime = total(a_lvtme(opt-3,*))/float(total(on))
         endif
      endif else begin
         on = intarr(3,num_dets)
         for i = 0,num_dets-1 do begin
          for j = 0,2 do begin
           on(j,i) = a_lvtme(j,i) ne 0.   
          endfor
         endfor
         td_on = float(total(on(2,*)))     
         td_off = float(total(on(0:1,*)))
         if (opt eq 1)then begin
            if (td_on ne 0.)then ltime = total(a_lvtme(2,*))/td_on
         endif else begin
            if (td_off ne 0.) then ltime = total(a_lvtme(0:1,*))/td_off
         endelse
         t = replicate(1.,num_dets)
         if (ks(prs) eq 0)then rt = t#rates $
         else rt = t#reform(rates(*,int-1,*))
      endelse                 
   endelse
endif
;**********************************************************************    
; Do show all detectors, 1 idf
;**********************************************************************
if (det eq num_dets + 2 and disp eq 0)then begin
   rt = fltarr(4,num_chns) & trate = fltarr(4)
   ltime = fltarr(4)
   if(num_spec gt 1)then begin
      rt(*,*) = rates(*,int-1,*)
      if (opt gt 2)then begin
         on = 0
         on = reform(lvtme(opt-3,*,int-1) ne 0.,num_dets)
         if (total(on) ne 0.)then begin
            ltime = total(lvtme(opt-3,*,int-1))/float(total(on))
         endif 
      endif else begin     
         on = intarr(3,num_dets)
         for i = 0,num_dets-1 do begin
          for j = 0,2 do begin
           on(j,i) = lvtme(j,i,int-1) ne 0.   
          endfor
         endfor
         td_on = float(total(on(2,*)))      
         td_off = float(total(on(0:1,*)))
         if (opt eq 1)then begin
            if (td_on ne 0.)then ltime = total(lvtme(2,*,int-1))/td_on
         endif else begin
            if (td_off ne 0.) then ltime = total(lvtme(0:1,*,int-1))/td_off
         endelse
      endelse
   endif else begin
      rt(*,*) = rates(*,0,*)
      if (opt gt 2)then begin
         on = 0
         on = reform(lvtme(opt-3,*,0) ne 0.,num_dets)          
         if (total(on) ne 0.)then begin
            ltime = total(lvtme(opt-3,*,*))/float(total(on))
         endif
      endif else begin
         on = intarr(3,num_dets)
         for i = 0,num_dets-1 do begin
          for j = 0,2 do begin
           on(j,i) = lvtme(j,i,0) ne 0.   
          endfor
         endfor
         td_on = float(total(on(2,*)))      
         td_off = float(total(on(0:1,*)))
         if (opt eq 1)then begin
            if (td_on ne 0.)then ltime = total(lvtme(2,*,0))/td_on
         endif else begin
            if (td_off ne 0.) then ltime = total(lvtme(0:1,*,0))/td_off
         endelse
      endelse
   endelse
   for i = 0,num_dets-1 do begin
    sz = size(ltime)
    if (sz(n_elements(sz)-1) ne 1)then begin
       if (ltime(i) ne 0.)then trate(i) = total(rt(i,*)*ltime(i))/ltime(i)
    endif else begin
       if (ltime(0) ne 0.)then trate(i) = total(rt(i,*)*ltime)/ltime
    endelse    
   endfor
endif
;**********************************************************************
; Do show all detectors, accum idfs
;**********************************************************************
if (det eq num_dets + 2 and disp eq 1)then begin
   rt = fltarr(4,num_chns) & trate = fltarr(4)
   ltime = fltarr(4)
   if(num_spec gt 1)then begin
      if (ks(prs))then rt = reform(rates(*,int-1,*)) $
      else rt = rates
      if (opt gt 2)then begin
         on = 0
         on = reform(a_lvtme(opt-3,*) ne 0.,num_dets)
         if (total(on) ne 0.)then begin
            ltime = total(a_lvtme(opt-3,*))/float(total(on))
         endif 
      endif else begin     
         on = intarr(3,num_dets)
         for i = 0,num_dets-1 do begin
          for j = 0,2 do begin
           on(j,i) = a_lvtme(j,i) ne 0.   
          endfor
         endfor
         td_on = float(total(on(2,*)))      
         td_off = float(total(on(0:1,*)))
         if (opt eq 1)then begin
            if (td_on ne 0.)then ltime = total(a_lvtme(2,*))/td_on
         endif else begin
            if (td_off ne 0.) then ltime = total(a_lvtme(0:1,*))/td_off
         endelse
      endelse
   endif else begin
      if (ks(prs))then rt = reform(rates(*,int-1,*)) $
      else rt = rates
      if (opt gt 2)then begin
         on = 0
         on = reform(a_lvtme(opt-3,*) ne 0.,num_dets)          
         if (total(on) ne 0.)then begin
            ltime = total(a_lvtme(opt-3,*))/float(total(on))
         endif
      endif else begin
         on = intarr(3,num_dets)
         for i = 0,num_dets-1 do begin
          for j = 0,2 do begin
           on(j,i) = a_lvtme(j,i) ne 0.   
          endfor
         endfor
         td_on = float(total(on(2,*)))      
         td_off = float(total(on(0:1,*)))
         if (opt eq 1)then begin
            if (td_on ne 0.)then ltime = total(a_lvtme(2,*))/td_on
         endif else begin
            if (td_off ne 0.) then ltime = total(a_lvtme(0:1,*))/td_off
         endelse
      endelse
   endelse
   for i = 0,num_dets-1 do begin
    sz = size(ltime)
    if (sz(n_elements(sz)-1) ne 1)then begin
       if (ltime(i) ne 0.)then trate(i) = total(rt(i,*)*ltime(i))/ltime(i)
    endif else begin
       if (ltime(0) ne 0.)then trate(i) = total(rt(i,*)*ltime)/ltime
    endelse    
   endfor
endif
;**********************************************************************
; Single detector
;**********************************************************************
if (det lt num_dets+2)then begin
     sz = size(ltime) & num = sz(n_elements(sz)-1)
     if (num ne 1)then begin
        on = 0
        on = reform(ltime ne 0.,num)
        if (total(on) ne 0.)then $
        ltime = temporary(total(ltime))/total(on) else $
        ltime = 0.
     endif
     if (ltime(0) ne 0.)then trate = total(rt*ltime)/ltime 
endif
if (opt eq 2 and det lt num_dets + 2)then begin
;**********************************************************************
; Calculate sigma and display results for net off.
;**********************************************************************
   if (det lt num_dets + 1)then begin
      if (num_spec gt 1)then sg = sig(det-1,int-1,*) else $
      sg = sig(det-1,*)
   endif else begin
      if (num_spec gt 1)then sg = reform(sig(*,int-1,*)) else sg = sig
      sg = replicate(1.,4)#sig/4.
   endelse
   print_netoff,rt,sg
endif
;**********************************************************************
; Undefined cases
;**********************************************************************  
if (not(ks(trate)))then trate_ = [0.,0.]
if (not(ks(ltime)))then ltime = 0.
if (not(ks(rt)))then rt = 0.
;**********************************************************************
; Calculate total rate string
;**********************************************************************
ndx = n_elements(size(trate))
if (ndx eq 3)then begin
   if (ltime(0) ne 0.)then trate_ = [trate,sqrt(abs(trate)/ltime)] $
   else trate_ = [0.,0.]
endif else begin
   trate_ = fltarr(2,4)
   trate_(0,*) = trate
   if (ltime(0) ne 0.)then trate_(1,*) = sqrt(abs(trate(*))/ltime) $
   else trate_ (1,*) = 0.
endelse 
if (det eq num_dets+1)then trate_ = temporary(trate_)/float(num_dets)  
ltime = string(temporary(ltime)) & trt = string(trate_)
a_lvtme = a_lvtme_save
;**********************************************************************
; Thats all ffolks
;**********************************************************************
return
end
