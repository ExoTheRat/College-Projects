; Programming Assignment 0
; Student Name: Matthias Christensen
; UT Eid: mc79777
; You are given three inputs A, B and C stored respectively at addresses, 
;    x30F0, x30F1 and x30F2. 
; Your job is to perform the following operations and store the results at address specified:
; X = A OR B               (store X at x30F4)
; Y = A XOR B              (store Y at x30F5)
; Z = NOT(A OR B OR C)     (store Z at x30F6)
; W = NOT(A) AND NOT(B) AND NOT(C) (store W at x30F7)
; Sum = A + B + C          (store Sum at x30F8)
; Diff= A - B - C          (store Diff at x30F9) 

	.ORIG	x3000
; Your code goes here
    LD R0, xEF ; R0 <-- A
    LD R1, xEF ; R1 <-- B
    LD R2, xEF ; R2 <-- C
    NOT R3, R0 ; R3 <-- A'
    NOT R4, R1 ; R4 <-- B'
    AND R5, R3, R4 ; R3 <-- A'B'
    NOT R5, R5 ; R3 <-- (A'B')' = A OR B = X
    ST R5, xEC ; x30F4 <-- X
    AND R5, R0, R4 ; R5 <-- AB'
    AND R6, R3, R1 ; R6 <-- A'B
    ADD R5, R5, R6 ; R5 <-- (AB') + (A'B) = A XOR B = Y , works because R5 and R6 will never both be 1
    ST R5, xE9 ; x30F5 <-- Y
    NOT R5, R2 ; R5 <-- C'
    AND R6, R3, R4 ; R6 <-- A'B'
    AND R6, R6, R5 ; R6 <-- A'B'C' = (A OR B OR C)' = Z = W
    ST R6, xE6 ; x30F6 <-- Z
    ST R6, xE6 ; x30F7 <-- W
    ADD R6, R0, R1 ; R6 <-- A + B
    ADD R6, R6, R2 ; R6 <-- A + B + C = Sum
    ST R6, xE4 ; x30F8 <-- Sum
    ADD R4, R4, #1 ; R4 <-- B'+ 1 = -B
    ADD R5, R5, #1 ; R5 <-- C' +1 = -C
    ADD R0, R0, R4 ; R0 <-- A - B
    ADD R0, R0, R5 ; R0 <-- A - B - C = Diff
    ST R0, xE0 ; x30F9 <-- Diff
    HALT
	.END

; Example test cases here
    .ORIG	x30F0
;    .FILL   x0001     ; A
;    .FILL   x0001     ; B
;    .FILL	 x0001     ; C
;    .FILL   x00AA     ; A
;    .FILL   x0055     ; B
;    .FILL	 x0022     ; C
    .FILL   x0ABC     ; A
    .FILL   xDEF0     ; B
    .FILL	x1234     ; C
    .FILL   x0000     ; Barrier
    .BLKW   #1        ; X
    .BLKW   #1        ; Y
    .BLKW   #1        ; Z
    .BLKW   #1        ; W
    .BLKW   #1        ; Sum
    .BLKW   #1        ; Diff
	.END
	
