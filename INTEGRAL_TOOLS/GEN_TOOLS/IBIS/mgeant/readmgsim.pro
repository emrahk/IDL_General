pro readmgsim,file=file,en1=en1,dete1=dete1,dete2=dete2,mult=mult,sct1=sct1,$
              sct2=sct2,delt=delt,dest=dest,ipart=ipart,pos=pos

;extension 1 variables
en1=loadcol(file,'PI',ext=1)  ; energy before sorted for SE, PE
dete1=loadcol(file,'DETE',ext=1) ; det. before sorted SE, PE
mult=loadcol(file,'MULT',ext=1) ; multiplicity
sct1=loadcol(file,'SCTIME',ext=1) ; sct in ext1
delt=loadcol(file,'DELT',ext=1) ; delta in ext1

;PSD extension (2) variables

sct2=loadcol(file,'SCTIME',ext=2) ; sct in ext1
dete2=loadcol(file,'DETE',ext=2) ; detector in ext2
dest=loadcol(file,'DESTEP',ext=2) ; energy loss, each int.
ipart=loadcol(file,'IPART',ext=2) ; to determine how many scatter in each det.
x=loadcol(file,'X',ext=2) ; X pos
y=loadcol(file,'Y',ext=2) ; X pos
z=loadcol(file,'Z',ext=2) ; X pos
pos=dblarr(n_elements(x),3)
pos(*,0)=x
pos(*,1)=y
pos(*,2)=z

end
