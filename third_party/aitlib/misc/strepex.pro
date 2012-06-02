;+
; NAME:
;             strepex
;
;
;
; PURPOSE:
;             Performs replacements of parts in strings by using
;             regular expressions (REPlacement of regular
;             EXpressions). Subexpressions may be also  
;             inserted into the replacement string.
;
;
;
; CATEGORY:
;             String processing
;
;
;
; CALLING SEQUENCE:
;             newstring = strepex( string, expression, [replacement],
;                                 /fold_case, /all) 
;
;
;
; INPUTS:
;             string     -  the string which will be analyzed and whose
;                           parts will be replaced in return.
;
;             expression -  A regular expression as being used for the
;                           REGEX function. Subexpressions must be
;                           given in parentheses.
;
;             replacement - String to replace for matching regular
;                           expressions. If it contains "&n" it
;                           will be replaced with the n-th
;                           subexpression in expression above
;                           (starting from 0). "&" may be escaped with
;                           "\&", "\" with "\\".
;                           If not given replacement will be empty
;                           string (deletion of string).
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;              fold_case -  Use case-insensitive regular expression
;                           matching.
;                           
;              all      -   Replace all occurrences of expression in
;                           given string. Default is to replace only
;                           the first occurrence of expression.
;
;
; OUTPUTS:
;              Returns the input string with a replacement of all
;              occurrences of a matching expression by the replacement
;              (which in turn may contain replacements of
;              subexpressions).
;              If no subexpression was found the input string remains
;              unaltered. 
;
;
; OPTIONAL OUTPUTS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;            Do not use in time critical sections: This implementation
;            uses recursion and is not speed optimized (but is short
;            enough to fit on a single paper sheet). 
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;             s = "x5*y3+2"
;             s1 = strepex(s,"(x|y)([0-9])","&0(&1)",/all)
;             -> s1 contains "x(5)*y(3)+2"
;
;
;
; MODIFICATION HISTORY:
;            $Log: strepex.pro,v $
;            Revision 1.3  2003/04/09 13:03:37  goehler
;            updated documentation/fix of example bug
;
;            Revision 1.2  2002/09/10 07:01:51  goehler
;            typos/fixed aitlib html style
;
;            Revision 1.1  2002/09/04 14:59:26  goehler
;            string function to perform regular expression replacements.
;
;
;-

FUNCTION strepex, input_string, regexstr, replstr, fold_case=fold_case, all=all

    ;; Implementation:
    ;; 1.) Search index of regular expression with stregex
    ;; 2.) Extract subexpressions
    ;; 3.) Copy part before into destination string
    ;; 4.) Replace &n with subexpression in replacement string
    ;;     (recursively calling strepex)
    ;; 5.) Replace escaped characters in replacement string 
    ;;     (recursively calling strepex)
    ;; 6.) Copy replacement string to destination expression
    ;; 7.) If /all repeat with 1.) till end of string.


    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------

    
    ;; copy of input string which may be modified (to support multiple
    ;; expression look up)
    instr = input_string

    ;; string for result
    newstr=""

    ;; index where to start regex search:
    s_index=0


    ;; ------------------------------------------------------------
    ;; MAIN LOOP
    ;; ------------------------------------------------------------

    REPEAT BEGIN 


        ;; ------------------------------------------------------------
        ;; LOOK FOR SUBSTRING
        ;; ------------------------------------------------------------

        sub_index = stregex(instr,regexstr,fold_case=fold_case,length=regex_len,/subexpr)


        ;; sub exrpession found -> replace it:
        IF sub_index[0] NE -1 THEN BEGIN 


            ;; ------------------------------------------------------------
            ;; ADD PART *BEFORE* MATCHING STRING:
            ;; ------------------------------------------------------------

            newstr = newstr + strmid(instr,0,sub_index[0])


            ;; ------------------------------------------------------------
            ;; PERFORM REPLACEMENT-EXPANSION OF SUBEXPRESSIONS:
            ;; ------------------------------------------------------------

            ;; auxilliary replacement string which holds a copy being
            ;; replaced with substrings:
            aux_replstr = replstr

            ;; replace subgroups found for "&":
            FOR i =1, n_elements(sub_index)-1 DO BEGIN 

                ;; substring -> current string in parentheses:
                substr = strmid(instr,sub_index[i],regex_len[i])

                ;; replace (recursively) &i -> i-th substring,
                ;; starting from substring 0
                aux_replstr = strepex(aux_replstr,"&"+strtrim(string(i-1),2),substr,/all)

            ENDFOR 

            ;; unescape replacement string:
            aux_replstr = strepex(aux_replstr,"\\(.)","&0",/all)


            ;; ------------------------------------------------------------
            ;; ADD REPLACEMENT STRING
            ;; ------------------------------------------------------------

            newstr = newstr+aux_replstr

            ;; remove matched part from input
            instr = strmid(instr,sub_index[0]+regex_len[0])
        ENDIF 
        

        ;; ------------------------------------------------------------
        ;; FINISH IF NO REGEX FOUND OR NOT ALL TO MATCH
        ;; ------------------------------------------------------------

    ENDREP UNTIL (sub_index[0] EQ -1) OR (keyword_set(all) EQ 0)


    ;; ------------------------------------------------------------
    ;; ADD REMINDER OF INPUT STRING:
    ;; ------------------------------------------------------------    

    newstr = newstr+instr
    

    RETURN, newstr 
END
