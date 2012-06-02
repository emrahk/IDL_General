;+
; NAME:       tie
; PURPOSE:    How to use different groups and tied parameters
; CATEGORY:   CAFE
; ID:         $Id: cafe_tutorial_tie.cmd,v 1.1 2003/05/02 08:50:11 goehler Exp $
;-
;$Log: cafe_tutorial_tie.cmd,v $
;Revision 1.1  2003/05/02 08:50:11  goehler
;tutorial for tied parameters
;

; This tutorial tries to describe how to exploit the use of data in several 
; groups with different models and different parameters which have nevertheless 
; something in common. 
;
; Assume that we performed an experiment measuring radioactive decay of a 
; substance with common half-life but different number of counts per second.
; Also the background is different. 
; We try to combine these experiments to increase the statistics. For this we load 
; the data into our fit environment, but into different groups.
#!input=""
#!read,input,prompt="continue?"


; Reading the first measurement:
#! infile1='"'+file_which('decay1.dat')+'"'
#exec,("data,"+infile1),/single

#!read,input,prompt="continue?"
; Display the data:
plot,data

; The model is clearly a decay plus some background offset:
#!read,input,prompt="continue?"
model, const*EXP(-x*const)+const,/quiet

; According the plot we expect an initial decay value (first parameter)
; of something like 110:
#!read,input,prompt="continue?"
chpar,0,110

; Now first try to fit:
#!read,input,prompt="continue?"
fit

; This is not very good. We try again and set the first and second
;  parameter:
#!read,input,prompt="continue?"
chpar,0,110

; The half-life is less than 1. Try 0.1:
#!read,input,prompt="continue?"
chpar,1,0.1

; The third is something about 10:
#!read,input,prompt="continue?"
chpar,2,10

; Repeat the fit:
#!read,input,prompt="continue?"
fit

; Thats better.

; We add the plot model+residuals:
#!read,input,prompt="continue?"
plot,data+model,res

; Using delta chi residuals which look probably nicer:
#!read,input,prompt="continue?"
plot,data+model,delchi
; Thats fine.

#!read,input,prompt="continue?"
; The next step is to apply the second measurement also:
; For this we change the default group at 1 and read in the data:
#!read,input,prompt="continue?"
chgrp,1

#!read,input,prompt="continue?"
#! infile2='"'+file_which('decay2.dat')+'"'
#exec,("data,"+infile2),/single

; Look at the data we have loaded:
#!read,input,prompt="continue?"
show,data

; Obviously we did not apply a model for group 1. This will be done now:
; The model is the same as in group 0:
#!read,input,prompt="continue?"
model,const*EXP(-x*const)+const,/quiet

; Plotting the data+model is still poor:
#!read,input,prompt="continue?"
plot

; According the experience with the first data we have to set the initial
; parameters properly:
#!read,input,prompt="continue?"
chpar,0,200

; The half-life is the same as in the other data set:
#!read,input,prompt="continue?"
chpar,1,0.009

; The background is something like 30:
#!read,input,prompt="continue?"
chpar,2,30

; Now we fit both the first and the second group:
#!read,input,prompt="continue?"
fit

; The plot is better:
#!read,input,prompt="continue?"
plot

; So we are done and have fit both data sets. 
; Only on thing is bothering: The half life is fitted different 
; (the parameter 1 in each group). 
; We like to keep them as the same. This can be done by a tie between the two
; groups. We make the parameter 1 in group 1 to be the same as in group 0:
#!read,input,prompt="continue?"
tie, 1:1,1:0

; The parameter 1 in group 1 is marked with a "P(1)". This means that
; The parameter is directly dependend from parameter number 1 of all parameters 
; (we count from 0). That is obviously parameter 1 from group 0. 

; If we repeat the fit we see that both half-lifes are the same:
#!read,input,prompt="continue?"
fit

; Thats fine. 
; For this parameter we try to estimate the error:
#!read,input,prompt="continue?"
error

; So the estimated error is about 10%. 
; As you can see the error of parameter 1 in group 1 is zero. That is simply because
; the error command does not try to estimate errors of tied parameters. 
; The tied parameter is indicated with a star ("*") and its error can be ignored. 

; If you want to plot both groups the plot types have to marked with group numbers. 
; This would look like:
#!read,input,prompt="continue?"
plot,data:0+data:1+model:0+model:1,delchi:0+delchi:1

#!read,input,prompt="continue?"
; To make a better picture it is recomended not to plot errors:
#!read,input,prompt="continue?"
setplot,noerror

; Thats it. 
#; restore environment:
#load, "tutorial_state.sav"
