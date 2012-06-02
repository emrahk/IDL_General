;+
; NAME:       syntax
; PURPOSE:    examples on syntax 
; CATEGORY:   CAFE
; ID:         $Id: cafe_tutorial_syntax.cmd,v 1.2 2003/05/02 08:49:36 goehler Exp $
;-
#; $Log: cafe_tutorial_syntax.cmd,v $
#; Revision 1.2  2003/05/02 08:49:36  goehler
#; fix: save with /clobber
#;
#; Revision 1.1  2003/02/19 07:31:45  goehler
#; intro in cafe syntax
#;
#;

; CAFE tries to use a common syntax for most commands. This syntax
; resembles the one to use for the IDL command line.
;
; This tutorial tries to give some reasonable examples how to use this
; syntax.
; 
; First we save the environment and import some data:
#; save current environment:
#save, "tutorial_state.sav",/clobber
#reset
#; create data to import:
#!x = indgen(100,/double)
#!y = 5.*exp(-((x-30)^2)/20.)+randomu(seed,n_elements(x),/normal)
import,(x),(y),1,gauss
#; interactive input variable:
#!input=""
#!read,input,prompt="continue?"
#

; First of all: commands are entered at the prompt and end with the
; command line end. The command parameters are separated with comma
; (","). This includes the separation from the first command. 
; 
; Example: 
show, data

#!read,input,prompt="continue?"

; Between the command ("show") and the parameter(s) must be a
; comma. On the other hand it is not necessary to quote strings. For
; example a title of the plot may be set immediately with:
setplot,title=This is a gaussian plot
#!read,input,prompt="continue?"

; And display:
plot

; Look at the result. 

#!read,input,prompt="continue?"

; In most cases this works. A string is something that doesn't start
; with a number or a "/" (the slash may be used for options which are
; not strings). In this cases we must quote explicitely:

; cafe> data,"/usr/home/me/test.dat"

#!read,input,prompt="continue?"

; On the otherhand sometimes the quoting is not desired. Then the
; parameter has to be given in brackets.
; This is important if you want to use some data created in the IDL
; background: 
!title="title="+"test"
#!read,input,prompt="continue?"
; We've created the variable "title" which now may be used:

#!read,input,prompt="continue?"
setplot,(title)

; update:
plot

; This also works.
; Remark: setplot internally uses the first parameter as a string and
; performs the splitting between "=" itself. Therefore we had to build
; an entire string.
;
; This construction also was used for the "import" command above to
; create data on the fly. 
#!read,input,prompt="continue?"

; As we also have seen it is possible to run IDL commands by
; prepending a "!":

!print,"Hallo World"
#!read,input,prompt="continue?"

; RANGES
;-------
; 
; Some commands use data ranges to select some of the data. There are
; different ways to select them: 
; 1.) The entire data set is refered with "*":
ignore, *

#!read,input,prompt="continue?"

; 2.) Specific datapoints can be accessed as a number:
notice,5

#!read,input,prompt="continue?"

; 3.) A range of datapoints may be selected with "num-num":
notice,20-30

#!read,input,prompt="continue?"

; 4.) If using floating point numbers the range applies to the
; dependend value (x):
notice,50.-55.

#!read,input,prompt="continue?"

; 5.) We can use a boolean expression for each datapoint. If this
; expression holds true it is within the range. Any IDL expression
; containing x, y or error are valid:
ignore, y LT 0.5 

#!read,input,prompt="continue?"

; 6.) If we want to apply a certain range more often it can be marked
;     as selected with either the "select" command or the "wplot"
;     tool. The selected range may then be applied with the expression
;     "selected": 
select, 10-80
notice,selected

#!read,input,prompt="continue?"

; CHAINING
;-------
;
; Some commands may be applied for several concatenated options. So
; for example the plot command may be applied to several different
; plot types. These items are concatenated with "+":

; First we set up a model:
model,const*gauss,/quiet
chpar,0,36
chpar,1,30
chpar,2,2.7

; Now we plot data, model and residuum:
#!read,input,prompt="continue?"
plot,data+model,res

; As we can see, data and model appear in the same window but with
; different colors. 

; A different example is the "wplot" command for which we can use
; several buttons, here moving left/right in a special manner:
; (you must press the exit button to continue)
wplot, seekleft+seekright

; Each concatenated item can be given specific options. These are
; given in brackets after the command. Here we disable the plot of
; error bars for the data (but not the residuum):

#!read,input,prompt="continue?"

plot, data[noerror]+model,res

; If a certain group should be used for a concatenated item it may be
; given after a colon:

#!read,input,prompt="continue?"

plot, data:0 + data[undef]:1, res

#!read,input,prompt="continue?"

; This also applies for the data command (which could not use chained
; files):

#!read,input,prompt="continue?"

#; where are the test data?
#!infile='"'+file_which('test.dat')+'[1,2]:1"'
#exec,("data,"+infile),/single

#!read,input,prompt="continue?"

; Now in group 1 new data are read in by using the columns 1 and 2 for
; x,y:
show, data
; 
;So far. 
#!read,input,prompt="continue?"

; FINISHED

#; restore environment:
#load, "tutorial_state.sav"
