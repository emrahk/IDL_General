;
; make_hpdata : the raw data creation routine for hexte phaseresolved
; spectra. It is called from hextephase and creates the new
; files.


PRO make_hpdata,old_data_name,new_data_name,period,steps,offset,time0=time0


command='rm xxxtemp?.gti'
spawn,command
command='rm '+new_data_name
spawn,command
command='fextract "'+old_data_name+'[2]" '+'xxxtemp1.gti'
spawn,command
print,'Got internal GTI-file'
timestep = period/steps
tab=readfits(old_data_name,h,exten=2)
startt=tbget(h,tab,'Start')
stopt=tbget(h,tab,'Stop')

IF (n_elements(time0) EQ 0) THEN time0=startt(0)

anzahl = (stopt(n_elements(stopt)-1)-time0)/period
phasegti=dindgen(anzahl)*period+time0+offset
pstart=phasegti
pstop=phasegti+timestep

writegti,pstart,pstop,'xxxtemp2.gti'
print,'Wrote phase GTI-file'
command='mgtime "xxxtemp1.gti,xxxtemp2.gti" xxxtemp3.gti AND ' + $
'instarts="Start,START" instops="Stop,STOP"'
spawn,command
print,'Created merged GTI-file'
readgti,t1,t2,'xxxtemp3.gti'
count=-1
idx=where(t1 EQ t2)
FOR i=0,n_elements(t2)-1 DO BEGIN
    jdx=where(i EQ idx)
    IF jdx(0) EQ -1 THEN BEGIN
        count =count+1
        IF (count EQ 0) THEN gut=i ELSE gut=[gut,i]
    ENDIF 
ENDFOR 

nt1=t1(gut)
nt2=t2(gut)
tab=readfits(old_data_name,h,exten=2)
mjdrefi=1.
mjdreff=1.
timezero=1.
timeunit=1.
tstartc=1.
tstopc=1.
getpar,h,'MJDREFI',mjdrefi
getpar,h,'MJDREFF',mjdreff
getpar,h,'TIMEZERO',timezero
getpar,h,'TIMEUNIT',timeunit
getpar,h,'Tstart',tstartc
getpar,h,'Tstop',tstopc
writegti,nt1,nt2,'xxxtemp4.gti',mjdrefi,mjdreff,timezero,timeunit,tstartc,tstopc
print,'Removed wrong times from GTI-file'

command='fextract "'+old_data_name+'[1]" '+new_data_name
spawn,command
command='fappend xxxtemp4.gti '+new_data_name
spawn,command
command='rm xxxtemp?.gti'
spawn,command
command='fchecksum '+new_data_name+' update=yes'
spawn,command
print,'Created new data file and removed temporary files.'
END 

