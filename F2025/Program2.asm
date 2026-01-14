; Programming Assignment 2
; Student Name: Matthias Christensen
; UT Eid: mc79777
; You are given an array of student records starting at location x3500.
; The array is terminated by a sentinel. Each student record in the array
; has two fields:
;      Score -  A value between 0 and 100
;      Address of Name  -  A value which is the address of a location in memory where
;                          this student's name is stored.
; The end of the array is indicated by the sentinel record whose Score is -1
; The array itself is unordered meaning that the student records dont follow
; any ordering by score or name.
; You are to perform two tasks:
; Task 1: Sort the array in decreasing order of Score. Highest score first.
; Task 2: You are given a name (string) at location x6100, You have to lookup this student 
;         in the Array (post Task1) and put the student's score at x60FF (i.e., in front of the name)
;         If the student is not in the list then a score of -1 must be written to x60FF
; Notes:
;       * If two students have the same score then keep their relative order as
;         in the original array.
;       * Names are case-sensitive.

.ORIG	x3000
    JSR Sort
    JSR Search
	TRAP	x25
; Bring addresses within reach
StudentAddr .FILL x3500
LookupAddr .FILL x6100

; Inputs: None
; Outputs: None
; Purpose: It sorts the array, putting students with highest score first.
Sort
    ST R0, SR0_Sort
    ST R1, SR1_Sort
    ST R2, SR2_Sort
    ST R3, SR3_Sort
    ST R4, SR4_Sort
    ST R5, SR5_Sort
    ST R7, SR7_Sort
    
    LD R0, StudentAddr ; Index
    OuterLoop
        LDR R3, R0, #0 ; Student[Index].score
        BRn Done
        AND R1, R1, #0
        ADD R1, R1, #-1 ; Max
        ADD R2, R0, #0 ; copy of starting address , i
        
        InnerLoop
            LDR R3, R2, #0 ; Student[i].score
            BRn Swap
            NOT R4, R3
            ADD R4, R4, #1
            ADD R4, R4, R1
            BRn MaxFound
            ADD R2, R2, #2 ; i += 2 , next student
            BR Innerloop
            
        Done
            LD R0, SR0_Sort
            LD R1, SR1_Sort
            LD R2, SR2_Sort
            LD R3, SR3_Sort
            LD R4, SR4_Sort
            LD R5, SR5_Sort
            LD R7, SR7_Sort
            JMP R7
            
        MaxFound
            ADD R5, R2, #0 ; stores the address of Max
            ADD R1, R3, #0 ; stores the Max
            ADD R2, R2, #2 ; i += 2 , next student
            BR Innerloop
            
        Swap
            LDR R2, R0, #0
            LDR R3, R5, #0
            STR R2, R5, #0
            STR R3, R0, #0
            LDR R2, R0, #1
            LDR R3, R5, #1
            STR R2, R5, #1
            STR R3, R0, #1
            ADD R0, R0, #2 ; Index += 2
            BR OuterLoop
    
    SR0_Sort .BLKW #1
    SR1_Sort .BLKW #1
    SR2_Sort .BLKW #1
    SR3_Sort .BLKW #1
    SR4_Sort .BLKW #1
    SR5_Sort .BLKW #1
    SR7_Sort .BLKW #1

; Inputs: None
; Outputs: None
; Purpose: If the student exists put their score in x60FF otherwise put -1 there
Search
    ST R0, SR0_Search
    ST R1, SR1_Search
    ST R2, SR2_Search
    ST R3, SR3_Search
    ST R4, SR4_Search
    ST R5, SR5_Search
    ST R6, SR6_Search
    ST R7, SR7_Search
    
    LD R0, LookupAddr
    LD R1, StudentAddr ; Index
    AND R2, R2, #0
    ADD R2, R2, #-1 ; result of search
    StudentLoop
        LDR R3, R1, #0 ; student score
        BRn Done1
        LDR R4, R1, #1 ; address of name
        StringLoop
            AND R7, R7, #0
            LDR R5, R4, #0 ; first char in name
            BRnp Skip
            ADD R7, R7, #1
            Skip
            LDR R6, R0, #0 ; first char in lookup
            BRnp Skip2
            ADD R7, R7, #-1
            BRz Match
            Skip2
            NOT R6, R6
            ADD R6, R6, #1
            ADD R6, R5, R6
            BRnp NoMatch
            ADD R4, R4, #1
            ADD R0, R0, #1
            BR StringLoop
            
    Match
        ADD R2, R2, #1
        ADD R2, R2, R3
        BR Done1

    NoMatch
        LD R0, LookupAddr
        ADD R1, R1, #2
        BR StudentLoop
    
    Done1
        LD R0, LookupAddr
        STR R2, R0, #-1
        LD R0, SR0_Search
        LD R1, SR1_Search
        LD R2, SR2_Search
        LD R3, SR3_Search
        LD R4, SR4_Search
        LD R5, SR5_Search
        LD R6, SR6_Search
        LD R7, SR7_Search
        JMP R7
    
    SR0_Search .BLKW #1
    SR1_Search .BLKW #1
    SR2_Search .BLKW #1
    SR3_Search .BLKW #1
    SR4_Search .BLKW #1
    SR5_Search .BLKW #1
    SR6_Search .BLKW #1
    SR7_Search .BLKW #1

.END

; Student records are at x3500
.ORIG	x3500
    .FILL   #55     ; student 0' score
    .FILL   x4700   ; student 0's nameAddr
    .FILL	#75     ; student 1' score
    .FILL   x4100   ; student 1's nameAdd
    .FILL   #65     ; student 2' score
    .FILL   x4200   ; student 2's nameAdd
	.FILL   #-1
.END

; Joe
	.ORIG	x4700
	.STRINGZ "Joe"
	.END
; Wow
	.ORIG	x4200
	.STRINGZ "Wonder Woman"
	.END
	
; Bat
	.ORIG	x4100
	.STRINGZ "Bat Man"
	.END

; Person to Lookup	
	.ORIG   x6100
;       The following lookup should give score of 55
	.STRINGZ  "Joe"
;       The following lookup should give score of 65
;	.STRINGZ  "Bat Man"
;       The following lookup should give score of -1 because Bat man is 
;           spelled with lowercase m; There is no student with that name 
;	.STRINGZ  "Bat man"
	.END
	
