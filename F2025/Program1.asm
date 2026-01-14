; Programming Project 1 starter file
; Student Name  : Matthias Christensen
; UTEid: mc79777
; Modify this code to satisfy the requirements of Program 1
; Compute N^M, where N and M are non-negative inputs to your program.
; The input numbers are given to you in memory locations x3500 (N) and x3501 (M) 
; The computed result has to be placed in x3502 (N2theM). 
; If the computation of the value of NM exceeds x7FFF then you put the 
; value -1 at x3502. Assume 0^0 = 0.
; Read the complete Project Description on the Google doc linked
.ORIG  x3000
    ; Instantiate variables and clear registers
    LD R7, IOAddr ; get the address for the collection of inputs/outputs
    AND R2, R2, #0 ; final result
    LDR R0, R7, #0 ; R0 <- N
    BRz Done ; 0^M = 0
    LDR R1, R7, #1 ; R1 <- M 
    ADD R2, R2, #1 ; M^0 = 1
    
Powers ; loop for the each power until M=0
    ADD R1, R1, #0
    BRz Done
    AND R3, R3, #0 ; temporary multiplication result
    ADD R4, R2, #0 ; multiplication loop counter (copy of R2)
    
Multiplication ; loop for repeated addition until counter is 0
    ADD R4, R4, #0
    BRz MultiplicationDone
    ADD R3, R3, R0
    BRn Overflow
    ADD R4, R4, #-1 ; decrement counter
    BR Multiplication ; return to see if there is more multiplication needed
    
Overflow ; if result becomes negative set it to -1 for overflow
    AND R2, R2, #0
    ADD R2, R2, #-1
    BR Done

MultiplicationDone ; check if there are more powers to go through
    ADD R2, R3, #0 ; set final result to temporary result
    ADD R1, R1, #-1 ; decrement power counter
    BR Powers ; check to see if there are more powers left

Done ; Store the final R2 value
    STR R2, R7, #2 ; N2theM <- R2
	HALT
.END

.ORIG x30F0
    IOAddr .FILL x3500
.END
    
;---- Data: Inputs and Output go here
.ORIG x3500
N    
    .FILL x0003
M    
    .FILL x0002
;N    .FILL x000A
;M    .FILL x000A
;N    .FILL x0002
;M    .FILL x000A
;N    .FILL x00B2
;M    .FILL x0002
;N    .FILL x7FFF
;M    .FILL x0001
N2theM  
    .BLKW #1
.END