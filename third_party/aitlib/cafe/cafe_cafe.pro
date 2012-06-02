PRO  cafe_cafe, env,shorthelp=shorthelp
;+
; NAME:
;           cafe - introduction
;
; PURPOSE:
;           multi-purpose fit environment. 
;
; CATEGORY:
;           cafe 
;
; USE:
;          Call in IDL:
;          IDL> cafe [,"logfile"]
;          logfile - (optional) the file name of a log file to
;                    which all operations and results will be
;                    written into.
;          
;          This will start the cafe fit environment. To leave enter
;          "quit". 
;
; 
; DESCRIPTION:
;
; 
; CAFE is intended for the "every day fitting" for arbitrary data sets.
; Written in the interactive data language IDL (refer rsi corporation
; at www.rsinc.com) it could easily be adopted/expanded for personal
; purposes. Especially it is possible to define arbitrary models and
; to add specialized commands.
;
; The cafe environment supports:
;  - text/fits file data reading
;  - loading several data sets in distinct groups
;  - combining standard models in algebraic expressions
;  - defining separate models for each data group
;  - perform fit process for non-linear functions
;  - perform a joint fit with different models/data sets
;  - fix parameters
;  - ignore/allow data points for fitting
;  - plot result with several types of residuum
;  - simple batch processing
;  - sophisticated plotting with interface to all IDL plot commands.
;  - saving/printing results
;  - online help for all commands and subcommands
;
;  With some restrictions it is possible to perform multi dimensional
;  fits (by using models which project the x dimensions to a 1-d
;  output). For reading and plotting there are drivers
;  (dat2/data2/model2) to deal with 3-dim data. 
;
;  The cafe environment is not intended for automatic fit
;  processes. Due to the interactive approach the data
;  sets should be medium sized.
;
;  The CAFE environment does not reinvent the wheel (though it is a
;  intriguing challenge to do that - both the wheel and a fitting
;  program). The heart of the program - the fitting algorithm - is
;  implemented by Craig Marquardts mpfit library (refer
;  http://cow.physics.wisc.edu/~craigm/idl/idl.html). Also error
;  computations are taken from the astronomical library at the IAAT.
;
;  Therefore this environment acts rather as an user interface to
;  allow standard fitting processes. The syntax and appearance
;  resembles the one of the xspec spectral fit program to come faster
;  along with this program.
;
;  HELP:
;
;  Further information may be get with the online help function. Call
;    > help
;  to get a complete list of commands/topics.
;    > help, topic
;  returns closer information.
;
;
; DISCLAIMER:
;           This environment was built at the Institute for
;           Astronomy and Astrophysics Tuebingen (IAAT),
;           http://astro.uni-tuebingen.de).
;           Design, structure and basic commands are
;           created by Eckart Goehler, 2002.
;           
;           The software may be copied and distributed for free
;           following the terms of the free software foundation. 
;             
; 
;  
; HISTORY:
;           $Id: cafe_cafe.pro,v 1.8 2003/04/25 07:32:55 goehler Exp $
;-
;
; $Log: cafe_cafe.pro,v $
; Revision 1.8  2003/04/25 07:32:55  goehler
; updated documentation
;
; Revision 1.7  2003/03/17 14:11:26  goehler
; review/documentation updated.
;
; Revision 1.6  2003/02/13 14:52:43  goehler
; added remark about multi dimensional fit
;
; Revision 1.5  2002/09/10 13:24:31  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.4  2002/09/09 17:36:01  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;
;; this file is for documentation only - it contains no function or
;; procedure applicable for the cafe environment. 

    print, "cafe     - multi purpose fit environment"
    return
END 
