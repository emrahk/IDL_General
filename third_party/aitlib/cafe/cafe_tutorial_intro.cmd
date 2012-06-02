;+
; NAME:       intro
; PURPOSE:    first steps in fitting with cafe
; CATEGORY:   CAFE
; ID:         $Id: cafe_tutorial_intro.cmd,v 1.3 2003/05/02 08:49:35 goehler Exp $
;-
#; $Log: cafe_tutorial_intro.cmd,v $
#; Revision 1.3  2003/05/02 08:49:35  goehler
#; fix: save with /clobber
#;
#; Revision 1.2  2003/02/19 07:29:47  goehler
#; standard header
#;
#; Revision 1.1  2003/02/18 16:48:47  goehler
#; added tutorial command. For this the tutorial should be given as a
#; script with interspearsed (IDL) commands. exec is now able to execute a single line
#; and to disable echo with the "#" prefix.
#;

; HELLO ! 
; 
; This introduction tries to show some of the main features of the
; cafe fit environment.
; We try to read in some data, fit a model to this data, plot the
; result and compute some errors. 
; 
; The process will suspend at certain points. Press <Enter> to
; proceed. There is (unfortunately) no way to quit this tour except
; CTRL-C.
;
; Commands are displayed after the prompt:
; cafe> foo
; Comments are given after ";".
;
; The current state of the environment is saved in the file
; "tutorial_state.sav" in the current directory and may be restored with
; cafe> restore,tutorial_state.sav
#!input=""
#!read,input,prompt="continue?"
#
#; save current environment:
#save, "tutorial_state.sav",/clobber
#reset


; First we read in some test data using the "data" command:
#!read,input,prompt="continue?"
#; where are the test data?
#!infile='"'+file_which('test.dat')+'"'
#exec,("data,"+infile),/single

; The data command displays that the data are stored in the first
; group (0) and that this is the first data set in this group
; (subgroup 0). Data in the same group should be of the same type for
; applying a common model when fitting.
; We also see the number of datapoints read in (1000).
#!read,input,prompt="continue?"

; Now we want to look at the data. The first approach is to create a
; list. This can be done with the "print" command. Because we don't
; want to flood the screen with 1000 datapoints we select the first 10
; using a range 0-10.
#!read,input,prompt="continue?"
print, 0-10

; Each row is a single datapoint which contains information about the
; independend (x) value, the dependend (y) value, the error (may be
; ommited) and the information whether the datapoint should be used
; for fitting/plotting (is defined). 
#!read,input,prompt="continue?"

; If we want to plot the data we have to apply the "plot" command:
#!read,input,prompt="continue?"
plot

; So we can see that the data describe two gaussian like lines plus
; some noise.
#!read,input,prompt="continue?"

; We now want to model these data applying a gaussian. Because the
; gauss obviously is not normalized we multiply it with a constant.
; The /quiet option postpones the interactive setting of the required
; parameters. 
#!read,input,prompt="continue?"
model,const*gauss,/quiet
#!read,input,prompt="continue?"

; Now immediately the necessary parameters are listed, first with
; their increasing numbers, then the model number, the parameter name
; (usually in the model:param format) and finally the parameter value,
; the (still not estimated) error, and an indication whether the
; parameter is fixed.
; Below are some informations about the statistics using this set of
; parameters.

; Because these parameter are quite bad adapted and we have a clue we
; set some of the parameters manually:
; First the scaling constant (parameter 0) should be set at unity.
#!read,input,prompt="continue?"
; This will be done with the change parameter "chpar" command:
chpar,0,1
#!read,input,prompt="continue?"
; We see the updated parameter set now with the scaling at 1. 

; Because the mean value should be something like 200 we also change
; it (otherwise the fit may fail using inadequate start values):
#!read,input,prompt="continue?"
chpar,1,200
#!read,input,prompt="continue?"

; Now we are ready for the first model fit, using the command
; "fit". Be prepared to see a lot of information about the fitting
; process.
#!read,input,prompt="continue?"
fit
#!read,input,prompt="continue?"

; According the status the fit succeeded but the statistics of the
; reduced Chi^2 looks bad. This is of course because only one line was
; fitted. 

; If we want to see the current result we may use the plot command
; with some additional options:
plot,data+model,res
#!read,input,prompt="continue?"

; This plot commands now uses the data to display in the upper window
; (this is the default) but also the model applied with best fit
; parameters. With the second option we can display the lower window
; with some additional information, here the residuum. 
#!read,input,prompt="continue?"

; To enrich the plot command with some features we can use the setplot
; command, e.g. to set the title. The window can be selected via a
; number (0 - upper). 
setplot,title=gauss, 0
#!read,input,prompt="continue?"

; and set plot title for residuum:
#!read,input,prompt="continue?"
setplot,title=Residuum, 1

#!read,input,prompt="continue?"
; To update the plot we have to reenter the plot command (the
; parameters remain according last entered):
plot
#!read,input,prompt="continue?"

; So we see that one gaussian feature is missing. This must be added
; to the model: 
model,const*gauss,/add,/quiet
#!read,input,prompt="continue?"

; And also the new parameters must be set properly at the scaling
; unity and the mean value at about 500:
chpar,3,1
#!read,input,prompt="continue?"
chpar,4,500
#!read,input,prompt="continue?"

; Now repeat the fitting:
#!read,input,prompt="continue?"
fit
#!read,input,prompt="continue?"

; Ok, the statistics of the reduced Chi^2 has improved. Checking the
; plot:
#!read,input,prompt="continue?"
plot
#!read,input,prompt="continue?"

; This also looks good. 

; The remaining task is determine the fit errors. The parameter show
; some error information which is taken from the hessian but is not
; always appropriate. We will determine it better (this may last a
; bit) by stepping for all parameters through the Chi^2 space with the
; "error" command:
#!read,input,prompt="continue?"
error

#!read,input,prompt="continue?"
; This looks ok. So we are finished with the first tour. 

#!read,input,prompt="continue?"
; Help may be get from other tutorials; for reference use the "help, topic"
; command with a certain command as a topic. Informational topcics are
; "cafe", "syntax" and for technical aspects "maintenance". 

; Enjoy!


#; restore environment:
#load, "tutorial_state.sav"

; To quit the CAFE environment, simply apply:
#!print,"quit"
quit

