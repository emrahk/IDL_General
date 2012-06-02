pro int,value,int
;*****************************************************************
; Program gets the integration number for HEXTE widgets.
; Input variable:
;           value.................event value
; Output variable:
;             int.................integration number
;*****************************************************************
if(value eq '1 OF 1' or value eq 'SUM')then begin 
   int = 0
   value = 'UPDATE'
endif
if(value eq '1 OF 2')then begin 
   int = 1
   value = 'UPDATE'
endif
if(value eq '2 OF 2')then begin
   int = 2
   value = 'UPDATE'
endif
if(value eq '1 OF 4')then begin
   int = 1
   value = 'UPDATE'
endif
if(value eq '2 OF 4')then begin
   int = 2
   value = 'UPDATE'
endif
if(value eq '3 OF 4')then begin
   int = 3
   value = 'UPDATE'
endif
if(value eq '4 OF 4')then begin
   int = 4
   value = 'UPDATE'
endif
if(value eq '1 OF 8')then begin
   int = 1    
   value = 'UPDATE'
endif
if(value eq '2 OF 8')then begin
   int = 2
   value = 'UPDATE'
endif
if(value eq '3 OF 8')then begin
   int = 3
   value = 'UPDATE'
endif
if(value eq '4 OF 8')then begin
   int = 4
   value = 'UPDATE'
endif
if(value eq '5 OF 8')then begin
   int = 5
   value = 'UPDATE'
endif
if(value eq '6 OF 8')then begin
   int = 6
   value = 'UPDATE'
endif
if(value eq '7 OF 8')then begin
   int = 7
   value = 'UPDATE'
endif
if(value eq '8 OF 8')then begin
   int = 8
   value = 'UPDATE'
endif
if(value eq '1 OF 16')then begin
   int = 1
   value = 'UPDATE'
endif
if(value eq '2 OF 16')then begin
   int = 2
   value = 'UPDATE'
endif
if(value eq '3 OF 16')then begin
   int = 3
   value = 'UPDATE'
endif
if(value eq '4 OF 16')then begin
   int = 4
   value = 'UPDATE'
endif
if(value eq '5 OF 16')then begin
   int = 5
   value = 'UPDATE'
endif
if(value eq '6 OF 16')then begin
   int = 6
   value = 'UPDATE'
endif
if(value eq '7 OF 16')then begin
   int = 7
   value = 'UPDATE'
endif
if(value eq '8 OF 16')then begin
   int = 8
   value = 'UPDATE'
endif
if(value eq '9 OF 16')then begin
   int = 9
   value = 'UPDATE'
endif
if(value eq '10 OF 16')then begin
   int = 10
   value = 'UPDATE'
endif
if(value eq '11 OF 16')then begin
   int = 11
   value = 'UPDATE'
endif
if(value eq '12 OF 16')then begin
   int = 12
   value = 'UPDATE'
endif
if(value eq '13 OF 16')then begin
   int = 13
   value = 'UPDATE'
endif
if(value eq '14 OF 16')then begin
   int = 14
   value = 'UPDATE'
endif
if(value eq '15 OF 16')then begin
   int = 15
   value = 'UPDATE'
endif
if(value eq '16 OF 16')then begin
   int = 16
   value = 'UPDATE'
endif
;*********************************************************************
; Thats all ffolks
;*********************************************************************
return
end

