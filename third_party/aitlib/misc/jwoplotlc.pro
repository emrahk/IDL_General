PRO jwoplotlc,time,count,error,color=color,psym=psym,dt=twidth
   ;;
   ;; Overplot a lightcurve on a set plot
   ;;

   IF (n_elements(color) EQ 0) THEN color=!p.color
   IF (n_elements(psym) EQ 0) THEN psym=10

   ;; Determine breaks in light-curve, preventing roundoff
   ;; (at most two bins are allowed to be missed)
   dt = time(1)-time(0)
   break = where(abs(shift(time,-1)-time - dt)/dt GT 2.)

   IF (break(0) EQ -1) THEN break(0)=n_elements(time)-1
   IF (break(n_elements(break)-1) EQ n_elements(time)-1) THEN  $
   break=[0,break] ELSE break=[0,break,n_elements(time)-1]
   
   ;; plot the data for each time block
   FOR i=long(1),long(n_elements(break)-1) DO BEGIN
       oplot,time(break(i-1)+1:break(i)),count(break(i-1)+1:break(i)),$
         color=color,psym=psym
   ENDFOR

   ;; plot the errorbars
   IF (n_elements(error) NE 0) THEN BEGIN 
       clip=!p.clip
       ranges=convert_coord([clip(0),clip(2)],[clip(1),clip(3)], $
                            /device,/to_data)
       tmi=ranges(0,0)
       tma=ranges(0,1)
       pb = max(where(time LE tmi))
       IF (pb(0) EQ -1) THEN pb=0
       pe = min(where(time GE tma))
       IF (pe(0) EQ -1) THEN pe=n_elements(time)-1
       FOR i=long(pb),long(pe) DO BEGIN
           oplot,[time(i),time(i)],[count(i)-error(i),count(i)+error(i)], $
             color=color
       ENDFOR 
   END 
   
   ;; plot the time-ranges
   IF (n_elements(twidth) NE 0) THEN BEGIN 
       clip=!p.clip
       ranges=convert_coord([clip(0),clip(2)],[clip(1),clip(3)], $
                            /device,/to_data)
       tmi=ranges(0,0)
       tma=ranges(0,1)
       pb = max(where(time LE tmi))
       IF (pb(0) EQ -1) THEN pb=0
       pe = min(where(time GE tma))
       IF (pe(0) EQ -1) THEN pe=n_elements(time)-1
       FOR i=long(pb),long(pe) DO BEGIN
           oplot,[time(i)-twidth(i),time(i)+twidth(i)],[count(i),count(i)], $
             color=color
       ENDFOR 
   END 
END 
