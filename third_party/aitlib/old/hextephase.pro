;; 
;; hextephase : main routine 
;; calls the creator routine with the necessary parameters and
;; filenames for each phase. Finally it calls the shell-script which
;; does the extraction.
;; 
;; April 1997 Ingo Kreykenbohm, AIT
;;

PRO hextephase,period,steps,t0,hka,hkb

spawn,'ls FS50_???????-???????_src',files50
spawn,'ls FS56_???????-???????_src',files56
files50=strmid(files50,0,20)
files56=strmid(files56,0,20)
files=[files50,files56]

FOR i=0,steps-1 DO BEGIN
    offset=period/steps*i
    FOR j=0,n_elements(files)-1 DO BEGIN 
        old_data_name=files(j)
        new_data_name=old_data_name+'_hp'+strtrim(string(i),1)
        print,new_data_name
        make_hpdata,old_data_name+'_src',new_data_name+'_src',period,$
          steps,offset,time0=t0
        make_hpdata,old_data_name+'_bkg',new_data_name+'_bkg',period,$
          steps,offset,time0=t0
    ENDFOR 
ENDFOR 
com='/usr/local/xte/ait_bin/hex '+string(fix(steps))+' '+files50(0)+' '+files50(1)+' '$
 +files56(0)+' '+files56(1)+' '+hka(0)+' '+hka(1)+' '+hkb(0)+' '+hkb(1)
spawn,com

END 


