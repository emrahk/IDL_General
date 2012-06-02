; example file to show that and how cafe works
; $Log: test.cmd,v $
; Revision 1.3  2003/03/03 11:18:34  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.2  2003/02/18 16:48:48  goehler
; added tutorial command. For this the tutorial should be given as a
; script with interspearsed (IDL) commands. exec is now able to execute a single line
; and to disable echo with the "#" prefix.
;
; Revision 1.1  2002/09/09 17:36:21  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;


; load test data into environment:
data, test.dat

; look at it:
plot



; this is obviously a data set containing two lines
; model one:
model,const*gauss,/quiet

; set start parameter:
; 1.) of scaling:
chpar,0,1

; 2.) of mean value:
chpar,1,200

; fit now!
fit

; set plot title for top panel:
setplot,title=gauss, 0

; set plot title for residuum:
setplot,title=Residuum, 1


; and show data, the applied model and the 
; residuum:
plot,data+model,res


; this is ok, one line is missing:
; we add it
model,const*gauss,/quiet,/add

; and set the start parameter as above:
chpar,3,1
chpar,4,500

; fit again
fit

; this looks better
plot

; now we compute the fit parameter errors:
;error

; thats it.
quit

; (this quit does nothing; it stops this script only)


