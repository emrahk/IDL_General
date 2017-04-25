 pro test_goes, a

 a=ogoes()                            ;-- create a GOES lightcurve object (do this once only)

 a->read                              ;-- read GOES 10 3 sec data for current day [default]

 a->read,'1-jun-02','3-jun-02'        ;-- read 3 sec data for specified
                                      ;       date range

 a->read,'10-jun-02'                  ;-- read 3 sec data for specified
                                      ;       date (+ 24 hours)

 a->read,'1-jun-02','3-jun-02',/one   ;-- read 1 min data;

 a->read,'1-jun-02','3-jun-02',/three ;-- read 3 sec data

 a->read,/goes9                       ;-- read GOES 9



 a->plot                             ;-- plot last read lightcurve

 a->plotman                          ;-- use plotman to plot last read lightcurve in an
                                         ;   interactive plot interface
 a->plotman,'1-jun-02','3-jun-02'    ;-- use plotman to plot a new time

 a->help



 data=a->getdata()                            ;-- extract low and high energy channels

 help,data
;    FLOAT     = Array[25382, 2]

 low=a->getdata(/low)                         ;-- extract low channel only

 high=a->getdata(/high)                       ;-- extract high channel only

 times = a->get(/times)                       ;-- extract time array and UTBASE
 utbase = a->get(/utbase)

 utplot,times,high,utbase                      ;-- plot high channel data

 deri=deriv(times,high)                        ;-- take time derivative of high energy
                                               ;       channel (for Neupert Effect lovers)





 a->set,btimes=['1-Jun-2002 07:53:39.000', '1-Jun-2002 08:34:36.000']
 a->set, /bsub


a->set, bsub=0                             ; don't subtract background
a->select_background                       ; use graphical interface for selecting background



 temp = a->getdata(/temperature)
 emis = a->getdata(/emission)
 a->set,abund='Coronal'                    ; choose spectral model
                                               ; choices are 'Coronal', 'Photospheric', 'Meyer'





 a->plot, /temp                            ;-- (or could use plotman)

 a->plotman, /emis                         ;-- (or could use plot)




 a->savefile, filename='goes.sav'          ;-- If you don't specify a filename, a dialog box
                                               ;   will pop up to let you navigate to a file.



 restore, 'goes.sav'                       ;-- Restore saved data

 prstr, readme                             ;-- Print the readme variable to see a summary
                                               ;   of the saved variables




data = a->getdata(tstart='1-Jun-2002 00:00', tend='3-Jun-2002 00:00', /struct)

a -> plot,/temp, markbad=0, /sdac, /clean

a->set, btimes= [['1-Jun-2002 07:53:39.000', '1-Jun-2002 08:34:36.000'], $
                ['2-Jun-2002 14:01:00.000', '2-Jun-2002 15:10:00.000']]

a->plotman, /emis, /bsub

a->plotman, /emis, bsub=0

end